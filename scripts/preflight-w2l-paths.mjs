import fs from "node:fs";
import path from "node:path";
import { createHash } from "node:crypto";

const winPath = path.win32;
const reviewedSourceHashes = {
  "scripts\\build.ts": "972fb13e91a860ef6d4fdb2c9e987d4f95c24ce90ddf980aeb3466804030460c",
  "scripts\\common.ts": "bdafd7bed1d6c45354004e8149375939b9ca3dde304afda2f7bf19f80a14c709",
};

function fail(message, code = "PREFLIGHT_ERROR") {
  const error = new Error(message);
  error.code = code;
  throw error;
}

function absoluteWindowsPath(value, name) {
  if (
    typeof value !== "string" ||
    !/^[a-zA-Z]:[\\/]/.test(value) ||
    value.slice(2).split(/[\\/]/).some((part) =>
      part === "." || part === ".." ||
      /[<>:"|?*\x00-\x1f]/.test(part) ||
      /[. ]$/.test(part) ||
      /^(?:con|prn|aux|nul|com[1-9]|lpt[1-9])(?:\.|$)/i.test(part)
    )
  ) {
    fail(`${name} must be a local drive-absolute path without dot segments or device names`);
  }
  return winPath.normalize(value);
}

function parseArguments(args) {
  const options = {};
  const valueOptions = new Set([
    "--project-root",
    "--assume-w2l-dir",
    "--assume-w2l-cwd",
  ]);
  for (let i = 0; i < args.length; i++) {
    const option = args[i];
    if (Object.hasOwn(options, option)) {
      fail(`Duplicate argument: ${option}`);
    }
    if (option === "--assume-w2l-dir-unset") {
      options[option] = true;
    } else if (valueOptions.has(option)) {
      const value = args[++i];
      if (value === undefined || value.startsWith("--")) {
        fail(`Missing value for ${option}`);
      }
      options[option] = absoluteWindowsPath(value, option);
    } else {
      fail(`Unknown argument: ${option}`);
    }
  }

  if (!options["--project-root"]) {
    fail("--project-root is required");
  }
  const hasDir = options["--assume-w2l-dir"] !== undefined;
  const hasUnset = options["--assume-w2l-dir-unset"] === true;
  const hasCwd = options["--assume-w2l-cwd"] !== undefined;
  if ((hasDir && (hasUnset || hasCwd)) || hasUnset !== hasCwd) {
    fail("Specify either --assume-w2l-dir, or both --assume-w2l-dir-unset and --assume-w2l-cwd");
  }
  return options;
}

function isWithinRoot(root, file) {
  const relative = winPath.relative(root, file);
  return relative === "" || (
    !winPath.isAbsolute(relative) &&
    relative !== ".." &&
    !relative.startsWith(`..${winPath.sep}`)
  );
}

function errorDetails(error) {
  return { code: error.code ?? "UNKNOWN", message: error.message };
}

function inspectPath(root, file, expectedType, inspectLinkTarget = true) {
  const result = {
    path: file,
    source: "filesystem (lstat, without following detected links)",
    evidence: "read-only check",
    checked: false,
    status: "not_checked",
    exists: null,
    isDirectory: null,
    isFile: null,
    isSymbolicLink: null,
    blockedPath: null,
    linkTarget: null,
    error: null,
  };
  if (!isWithinRoot(root, file)) {
    result.status = "outside_project";
    result.error = { code: "OUTSIDE_PROJECT", message: "Path was not inspected outside the project root" };
    return result;
  }

  const parsed = winPath.parse(file);
  const parts = file.slice(parsed.root.length).split(winPath.sep).filter(Boolean);
  let current = parsed.root;
  for (let i = -1; i < parts.length; i++) {
    if (i >= 0) current = winPath.join(current, parts[i]);
    const final = i === parts.length - 1;
    let stat;
    try {
      stat = fs.lstatSync(current);
    } catch (error) {
      result.blockedPath = current;
      result.error = errorDetails(error);
      if (error.code === "ENOENT") {
        result.status = final ? "not_found" : "ancestor_not_found";
        result.checked = true;
        result.exists = false;
        result.isSymbolicLink = false;
      } else if (error.code === "ENOTDIR") {
        result.status = "ancestor_not_directory";
      } else if (error.code === "EACCES" || error.code === "EPERM") {
        result.status = "permission_denied";
      } else {
        result.status = "read_error";
      }
      return result;
    }

    if (stat.isSymbolicLink()) {
      result.status = final ? "symbolic_link" : "ancestor_symbolic_link";
      result.blockedPath = current;
      result.checked = final;
      result.exists = final ? true : null;
      result.isSymbolicLink = final ? true : null;
      result.error = { code: "SYMBOLIC_LINK", message: "Symbolic links and junctions are rejected" };
      if (final && inspectLinkTarget) {
        result.linkTarget = inspectSymbolicLinkTarget(root, current, expectedType);
      }
      return result;
    }
    if (!final && !stat.isDirectory()) {
      result.status = "ancestor_not_directory";
      result.blockedPath = current;
      result.error = { code: "NOT_DIRECTORY", message: "An ancestor is not a directory" };
      return result;
    }
    if (final) {
      result.checked = true;
      result.exists = true;
      result.isDirectory = stat.isDirectory();
      result.isFile = stat.isFile();
      result.isSymbolicLink = false;
      const matches = expectedType === "directory" ? result.isDirectory : result.isFile;
      result.status = matches ? "ok" : `not_${expectedType}`;
      if (!matches) {
        result.error = { code: `NOT_${expectedType.toUpperCase()}`, message: `Path is not a ${expectedType}` };
      }
    }
  }
  return result;
}

function inspectSymbolicLinkTarget(root, link, expectedType) {
  try {
    const target = fs.readlinkSync(link);
    const resolved = winPath.resolve(winPath.dirname(link), target);
    if (!/^[a-zA-Z]:\\/.test(resolved) || !isWithinRoot(root, resolved)) {
      return { status: "outside_project_or_unsupported", exists: null, error: null };
    }
    const check = inspectPath(root, resolved, expectedType, false);
    return { status: check.status, exists: check.exists, error: check.error };
  } catch (error) {
    return { status: "read_error", exists: null, error: errorDetails(error) };
  }
}

function readCheckedFile(root, file, reader) {
  const check = inspectPath(root, file, "file");
  if (check.status !== "ok") {
    return { check, value: null, error: check.error, closeError: null };
  }
  let fd;
  let value = null;
  let error = null;
  let closeError = null;
  try {
    fd = fs.openSync(file, "r");
    if (!fs.fstatSync(fd).isFile()) {
      fail(`Opened path is not a regular file: ${file}`, "NOT_FILE");
    }
    value = reader(fd);
  } catch (caught) {
    error = errorDetails(caught);
  } finally {
    if (fd !== undefined) {
      try {
        fs.closeSync(fd);
      } catch (caught) {
        closeError = errorDetails(caught);
      }
    }
  }
  return { check, value, error, closeError };
}

function readProjectFile(root, file) {
  const result = readCheckedFile(root, file, (fd) => fs.readFileSync(fd));
  if (result.error || result.closeError) {
    fail(`Cannot safely read ${file}: ${JSON.stringify({ error: result.error, closeError: result.closeError })}`,
      (result.error ?? result.closeError).code);
  }
  return result.value;
}

function readJson(root, file) {
  const contents = readProjectFile(root, file).toString("utf8");
  try {
    return JSON.parse(contents);
  } catch (error) {
    fail(`Invalid JSON in ${file}: ${error.message}`, "INVALID_JSON");
  }
}

function verifyBuildSources(root) {
  const hashes = {};
  for (const [relative, expected] of Object.entries(reviewedSourceHashes)) {
    const file = winPath.join(root, relative);
    const actual = createHash("sha256").update(readProjectFile(root, file)).digest("hex");
    hashes[relative] = actual;
    if (actual !== expected) {
      fail(`Unrecognized build source ${file}; project paths cannot be confirmed`, "UNRECOGNIZED_BUILD_SOURCE");
    }
  }
  return hashes;
}

function inspectMarker(root, input, inputCheck) {
  const markerPath = winPath.join(input, ".w3x");
  const result = {
    path: markerPath,
    source: "filesystem; rule: check_lni_mark.lua bytes 9-12",
    evidence: "read-only check",
    checked: false,
    status: "not_checked",
    exists: null,
    valid: null,
    error: null,
  };
  if (inputCheck.status !== "ok") {
    return result;
  }

  const read = readCheckedFile(root, markerPath, (fd) => {
    const bytes = Buffer.alloc(12);
    let count = 0;
    while (count < bytes.length) {
      const read = fs.readSync(fd, bytes, count, bytes.length - count, count);
      if (read === 0) {
        break;
      }
      count += read;
    }
    return count >= 12 && bytes.subarray(8, 12).equals(Buffer.from([0x57, 0x32, 0x4c, 0x01]));
  });
  result.exists = read.check.exists;
  result.linkTarget = read.check.linkTarget;
  result.closeError = read.closeError;
  if (read.check.status !== "ok") {
    result.status = read.check.status;
    result.error = read.error;
  } else if (read.error || read.closeError) {
    result.exists = null;
    if (read.closeError) {
      result.status = "close_error";
    } else if (read.error.code === "ENOENT") {
      result.status = "not_found_or_changed";
    } else if (read.error.code === "ENOTDIR") {
      result.status = "ancestor_not_directory";
    } else if (read.error.code === "EACCES" || read.error.code === "EPERM") {
      result.status = "permission_denied";
    } else {
      result.status = "read_error";
    }
    result.error = read.error;
  } else {
    result.checked = true;
    result.valid = read.value;
    result.status = result.valid ? "ok" : "invalid_marker";
    if (!result.valid) result.error = { code: "INVALID_LNI_MARK", message: "Marker does not contain W2L 01 at bytes 9-12" };
  }
  return result;
}

function inspectPaths(root, input, output) {
  const inputDirectory = inspectPath(root, input, "directory");
  return {
    inputDirectory,
    marker: inspectMarker(root, input, inputDirectory),
    outputDirectory: inspectPath(root, winPath.dirname(output), "directory"),
    outputFile: inspectPath(root, output, "file"),
    outputWritable: null,
  };
}

function checksHaveIssues(checks) {
  return (
    checks.inputDirectory.status !== "ok" ||
    checks.marker.status !== "ok" ||
    checks.outputDirectory.status !== "ok" ||
    !["ok", "not_found"].includes(checks.outputFile.status)
  );
}

function main() {
  const options = parseArguments(process.argv.slice(2));
  if (process.platform !== "win32") {
    fail("This preflight requires Windows for filesystem checks");
  }

  const root = options["--project-root"];
  const packagePath = winPath.join(root, "package.json");
  const configPath = winPath.join(root, "config.json");
  const manifest = readJson(root, packagePath);
  const config = readJson(root, configPath);
  const build = manifest?.scripts?.build;
  const buildMap = manifest?.scripts?.["build:map"];

  if (
    typeof build !== "string" ||
    !/^\s*ts-node\s+--project\s+tsconfig\.node\.json\s+scripts[\\/]build\.ts\s*$/.test(build)
  ) {
    fail("Unsupported scripts.build; project paths cannot be inferred safely");
  }
  if (
    typeof buildMap !== "string" ||
    !/^\s*dev_lib[\\/]w3x2lni[\\/]w2l\.exe\s+obj\s+maps\s+dist[\\/]map\.w3x\s*$/.test(buildMap)
  ) {
    fail("Unsupported scripts.build:map; project paths cannot be inferred safely");
  }
  if (typeof config?.w2l?.path !== "string" || !/^dev_lib[\\/]w3x2lni$/.test(config.w2l.path)) {
    fail("Unrecognized config.json w2l.path; build paths cannot be confirmed");
  }
  const sourceHashes = verifyBuildSources(root);

  const expectedInput = winPath.join(root, "maps");
  const expectedOutput = winPath.join(root, "dist", "map.w3x");
  const expectedChecks = inspectPaths(root, expectedInput, expectedOutput);
  let candidate = null;
  let candidateChecks = null;
  if (options["--assume-w2l-dir"] || options["--assume-w2l-dir-unset"]) {
    const dir = options["--assume-w2l-dir"] ?? null;
    const cwd = options["--assume-w2l-cwd"] ?? null;
    const base = dir ?? winPath.dirname(cwd);
    const input = winPath.join(base, "maps");
    const output = winPath.join(base, "dist", "map.w3x");
    candidateChecks = inspectPaths(root, input, output);
    candidate = {
      source: "explicit assumption and w2l Lua path rules",
      evidence: "conditional inference, not runtime observation",
      assumption: { w2lDir: dir, w2lDirUnset: dir === null, w2lWorkingDirectory: cwd },
      base,
      input,
      output,
      checks: candidateChecks,
    };
  }

  const issues = checksHaveIssues(expectedChecks) || (candidateChecks !== null && checksHaveIssues(candidateChecks));
  return {
    status: issues ? "issues" : "ok",
    projectRoot: { value: root, source: "--project-root", evidence: "explicit user input" },
    preflightWorkingDirectory: {
      value: process.cwd(),
      source: "preflight process",
      evidence: "not the w2l working directory",
    },
    configuration: {
      source: { packageJson: packagePath, configJson: configPath },
      evidence: "read-only project files",
      build,
      buildMap,
      w2lPath: config.w2l.path,
      sourceHashes,
    },
    projectExpected: {
      source: "project root and recognized build scripts",
      evidence: "project expectation, not runtime observation",
      input: expectedInput,
      output: expectedOutput,
      checks: expectedChecks,
    },
    candidate,
    safety: {
      source: "preflight policy",
      evidence: "best effort; not an atomic security boundary",
      uncPaths: "rejected",
      outsideProjectChecks: "Candidate paths and link targets outside the project root are not checked",
      ancestorMetadataChecks: "lstat may inspect ancestor directory metadata from the drive root to the project path",
      symbolicLinks: "rejected when detected",
      limitations: [
        "Path components can change between lstat and open; this may allow access through a substituted link.",
        "Drive letters can refer to remote or otherwise redirected storage.",
      ],
    },
    runtimeObserved: {
      source: "not observed",
      evidence: "unverified",
      w2lDir: null,
      w2lWorkingDirectory: null,
      base: null,
      input: null,
      output: null,
    },
  };
}

try {
  const report = main();
  process.stdout.write(`${JSON.stringify(report, null, 2)}\n`);
  if (report.status !== "ok") {
    process.exitCode = 1;
  }
} catch (error) {
  process.stdout.write(`${JSON.stringify({
    status: "error",
    source: "preflight",
    evidence: "no runtime observation",
    error: { code: error.code ?? "PREFLIGHT_ERROR", message: error.message },
    runtimeObserved: { w2lDir: null, w2lWorkingDirectory: null, base: null, input: null, output: null },
  }, null, 2)}\n`);
  process.exitCode = 1;
}

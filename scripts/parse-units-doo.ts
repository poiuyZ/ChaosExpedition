import * as fs from "node:fs";
import * as path from "node:path";

const HEADER_SIZE = 16;
const UNIT_ID_OFFSET = 0;
const POSITION_OFFSET = 8;
const FACING_OFFSET = 20;
const INVENTORY_COUNT_OFFSET = 83;
const INVENTORY_ENTRIES_OFFSET = 87;
const FIXED_RECORD_SIZE = 111;
const UNKNOWN_TAIL_SIZE = 20;
const INVENTORY_ENTRY_SIZE = 8;
const ABILITY_ENTRY_SIZE = 12;

interface FourCC {
  value: string;
  rawHex: string;
}

interface UnknownBytes {
  relativeOffset: number;
  rawHex: string;
}

interface ParsedAbilityModification {
  abilityId: FourCC;
  unknownFields: [string, string];
}

interface ParsedUnit {
  index: number;
  unitId: FourCC;
  position: { x: number; y: number; z: number };
  facing: { value: number; unit: "unknown" };
  inventory: Array<{ slot: number; itemId: FourCC }>;
  abilityModifications: ParsedAbilityModification[];
  unknownFields: UnknownBytes[];
}

interface ParsedDoo {
  format: "W3do";
  version: 8;
  subVersion: 11;
  unitCount: number;
  units: ParsedUnit[];
}

function ensureRange(buffer: Buffer, offset: number, size: number, label: string): void {
  const end = offset + size;
  if (
    !Number.isSafeInteger(offset) ||
    !Number.isSafeInteger(size) ||
    offset < 0 ||
    size < 0 ||
    !Number.isSafeInteger(end) ||
    end > buffer.length
  ) {
    throw new Error(
      `${label} exceeds file bounds (offset=${offset}, size=${size}, fileSize=${buffer.length})`,
    );
  }
}

function readUInt32(buffer: Buffer, offset: number, label: string): number {
  ensureRange(buffer, offset, 4, label);
  return buffer.readUInt32LE(offset);
}

function readFloat32(buffer: Buffer, offset: number, label: string): number {
  ensureRange(buffer, offset, 4, label);
  const value = buffer.readFloatLE(offset);
  if (!Number.isFinite(value)) {
    throw new Error(`${label} is not a finite 32-bit float at offset ${offset}`);
  }
  return value;
}

function readFourCC(buffer: Buffer, offset: number, label: string): FourCC {
  ensureRange(buffer, offset, 4, label);
  return {
    value: buffer.toString("latin1", offset, offset + 4),
    rawHex: buffer.subarray(offset, offset + 4).toString("hex"),
  };
}

function readUnknownBytes(buffer: Buffer, offset: number, size: number, relativeOffset: number): UnknownBytes {
  ensureRange(buffer, offset, size, "Unknown unit data");
  return {
    relativeOffset,
    rawHex: buffer.subarray(offset, offset + size).toString("hex"),
  };
}

export function parseWar3mapUnitsDoo(buffer: Buffer): ParsedDoo {
  ensureRange(buffer, 0, HEADER_SIZE, "W3do header");
  if (!buffer.subarray(0, 4).equals(Buffer.from("W3do", "ascii"))) {
    throw new Error(`Invalid W3do magic: ${JSON.stringify(buffer.toString("latin1", 0, 4))}`);
  }

  const version = readUInt32(buffer, 4, "Version");
  const subVersion = readUInt32(buffer, 8, "SubVersion");
  if (version !== 8 || subVersion !== 11) {
    throw new Error(`Unsupported W3do version ${version} / SubVersion ${subVersion}; expected 8 / 11`);
  }

  const unitCount = readUInt32(buffer, 12, "UnitCount");
  if (unitCount > Math.floor((buffer.length - HEADER_SIZE) / FIXED_RECORD_SIZE)) {
    throw new Error(`UnitCount ${unitCount} cannot fit in the remaining file`);
  }

  const units: ParsedUnit[] = [];
  let offset = HEADER_SIZE;

  for (let index = 0; index < unitCount; index++) {
    const recordStart = offset;
    const remainingUnits = unitCount - index - 1;
    ensureRange(buffer, recordStart, INVENTORY_ENTRIES_OFFSET, `Unit ${index} fixed prefix`);

    const inventoryCount = readUInt32(
      buffer,
      recordStart + INVENTORY_COUNT_OFFSET,
      `Unit ${index} InventoryCount`,
    );
    const bytesBeforeInventory = recordStart + INVENTORY_ENTRIES_OFFSET;
    const requiredAfterInventory =
      4 + UNKNOWN_TAIL_SIZE + remainingUnits * FIXED_RECORD_SIZE;
    const availableForInventory = buffer.length - bytesBeforeInventory - requiredAfterInventory;
    const maxInventoryCount = Math.floor(availableForInventory / INVENTORY_ENTRY_SIZE);
    if (inventoryCount > maxInventoryCount) {
      throw new Error(
        `Unit ${index} InventoryCount ${inventoryCount} exceeds the available file data`,
      );
    }

    const inventory: ParsedUnit["inventory"] = [];
    for (let itemIndex = 0; itemIndex < inventoryCount; itemIndex++) {
      const itemOffset = bytesBeforeInventory + itemIndex * INVENTORY_ENTRY_SIZE;
      inventory.push({
        slot: readUInt32(buffer, itemOffset, `Unit ${index} inventory slot ${itemIndex}`),
        itemId: readFourCC(buffer, itemOffset + 4, `Unit ${index} inventory item ${itemIndex}`),
      });
    }

    const abilityCountOffset = bytesBeforeInventory + inventoryCount * INVENTORY_ENTRY_SIZE;
    const abilityCount = readUInt32(
      buffer,
      abilityCountOffset,
      `Unit ${index} AbilityCount`,
    );
    const firstAbilityOffset = abilityCountOffset + 4;
    const bytesBeforeAbilities = firstAbilityOffset + UNKNOWN_TAIL_SIZE;
    ensureRange(
      buffer,
      firstAbilityOffset,
      UNKNOWN_TAIL_SIZE + remainingUnits * FIXED_RECORD_SIZE,
      `Unit ${index} ability header and following records`,
    );
    const maxAbilityCount = Math.floor(
      (buffer.length - bytesBeforeAbilities - remainingUnits * FIXED_RECORD_SIZE) /
        ABILITY_ENTRY_SIZE,
    );
    if (abilityCount > maxAbilityCount) {
      throw new Error(
        `Unit ${index} AbilityCount ${abilityCount} exceeds the available file data`,
      );
    }

    const abilityModifications: ParsedAbilityModification[] = [];
    for (let abilityIndex = 0; abilityIndex < abilityCount; abilityIndex++) {
      const abilityOffset = firstAbilityOffset + abilityIndex * ABILITY_ENTRY_SIZE;
      abilityModifications.push({
        abilityId: readFourCC(buffer, abilityOffset, `Unit ${index} ability ${abilityIndex}`),
        unknownFields: [
          buffer.subarray(abilityOffset + 4, abilityOffset + 8).toString("hex"),
          buffer.subarray(abilityOffset + 8, abilityOffset + 12).toString("hex"),
        ],
      });
    }

    const tailOffset = firstAbilityOffset + abilityCount * ABILITY_ENTRY_SIZE;
    const unknownFields: UnknownBytes[] = [
      readUnknownBytes(buffer, recordStart + 4, 4, 4),
      readUnknownBytes(
        buffer,
        recordStart + 24,
        INVENTORY_COUNT_OFFSET - 24,
        24,
      ),
      readUnknownBytes(buffer, tailOffset, UNKNOWN_TAIL_SIZE, tailOffset - recordStart),
    ];

    units.push({
      index,
      unitId: readFourCC(buffer, recordStart + UNIT_ID_OFFSET, `Unit ${index} ID`),
      position: {
        x: readFloat32(buffer, recordStart + POSITION_OFFSET, `Unit ${index} X`),
        y: readFloat32(buffer, recordStart + POSITION_OFFSET + 4, `Unit ${index} Y`),
        z: readFloat32(buffer, recordStart + POSITION_OFFSET + 8, `Unit ${index} Z`),
      },
      facing: {
        value: readFloat32(buffer, recordStart + FACING_OFFSET, `Unit ${index} facing`),
        unit: "unknown",
      },
      inventory,
      abilityModifications,
      unknownFields,
    });

    offset = tailOffset + UNKNOWN_TAIL_SIZE;
  }

  if (offset !== buffer.length) {
    throw new Error(`Unexpected trailing data: parsed through offset ${offset}, file size is ${buffer.length}`);
  }

  return {
    format: "W3do",
    version: 8,
    subVersion: 11,
    unitCount,
    units,
  };
}

function printHelp(): void {
  console.log([
    "Parse a Warcraft III 1.27 W3do war3mapUnits.doo file as JSON.",
    "",
    "Usage:",
    "  yarn parse:units <path-to-war3mapUnits.doo>",
    "",
    "JSON is written to stdout; the input file is read-only.",
  ].join("\n"));
}

function main(): void {
  const args = process.argv.slice(2);
  if (args.length === 1 && (args[0] === "--help" || args[0] === "-h")) {
    printHelp();
    return;
  }
  if (args.length !== 1) {
    printHelp();
    process.exitCode = 1;
    return;
  }

  try {
    const inputPath = path.resolve(args[0]);
    const result = parseWar3mapUnitsDoo(fs.readFileSync(inputPath));
    process.stdout.write(`${JSON.stringify(result, null, 2)}\n`);
  } catch (error) {
    console.error(error instanceof Error ? error.message : error);
    process.exitCode = 1;
  }
}

if (require.main === module) {
  main();
}

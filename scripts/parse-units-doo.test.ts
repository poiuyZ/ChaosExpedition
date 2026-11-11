import { strict as assert } from "node:assert";
import { test } from "node:test";
import { parseWar3mapUnitsDoo } from "./parse-units-doo";

interface UnitFixture {
  unitId?: string;
  position?: [number, number, number];
  facing?: number;
  inventory?: Array<{ slot: number; itemId: string }>;
  abilities?: Array<{ abilityId: string; unknownFields: [number, number] }>;
}

function writeFourCC(buffer: Buffer, offset: number, value: string): void {
  buffer.write(value, offset, 4, "latin1");
}

function createUnit(fixture: UnitFixture = {}): Buffer {
  const inventory = fixture.inventory ?? [];
  const abilities = fixture.abilities ?? [];
  const buffer = Buffer.alloc(111 + inventory.length * 8 + abilities.length * 12);

  writeFourCC(buffer, 0, fixture.unitId ?? "hfoo");
  const position = fixture.position ?? [1, 2, 3];
  buffer.writeFloatLE(position[0], 8);
  buffer.writeFloatLE(position[1], 12);
  buffer.writeFloatLE(position[2], 16);
  buffer.writeFloatLE(fixture.facing ?? 0.5, 20);
  buffer.writeUInt32LE(inventory.length, 83);

  let offset = 87;
  for (const item of inventory) {
    buffer.writeUInt32LE(item.slot, offset);
    writeFourCC(buffer, offset + 4, item.itemId);
    offset += 8;
  }

  buffer.writeUInt32LE(abilities.length, offset);
  offset += 4;
  for (const ability of abilities) {
    writeFourCC(buffer, offset, ability.abilityId);
    buffer.writeUInt32LE(ability.unknownFields[0], offset + 4);
    buffer.writeUInt32LE(ability.unknownFields[1], offset + 8);
    offset += 12;
  }

  buffer.fill(0xa5, offset);
  return buffer;
}

function createFile(units: Buffer[]): Buffer {
  const header = Buffer.alloc(16);
  header.write("W3do", 0, 4, "ascii");
  header.writeUInt32LE(8, 4);
  header.writeUInt32LE(11, 8);
  header.writeUInt32LE(units.length, 12);
  return Buffer.concat([header, ...units]);
}

test("parses header, unit position, inventory, abilities, and unknown bytes", () => {
  const file = createFile([
    createUnit({
      unitId: "Hpal",
      position: [10.5, -20.25, 4],
      facing: 1.25,
      inventory: [{ slot: 2, itemId: "I001" }],
      abilities: [{ abilityId: "A000", unknownFields: [0x12345678, 0x90abcdef] }],
    }),
  ]);

  const parsed = parseWar3mapUnitsDoo(file);
  assert.equal(parsed.format, "W3do");
  assert.equal(parsed.version, 8);
  assert.equal(parsed.subVersion, 11);
  assert.equal(parsed.unitCount, 1);
  assert.deepEqual(parsed.units[0].unitId, { value: "Hpal", rawHex: "4870616c" });
  assert.deepEqual(parsed.units[0].position, { x: 10.5, y: -20.25, z: 4 });
  assert.deepEqual(parsed.units[0].facing, { value: 1.25, unit: "unknown" });
  assert.deepEqual(parsed.units[0].inventory, [
    { slot: 2, itemId: { value: "I001", rawHex: "49303031" } },
  ]);
  assert.deepEqual(parsed.units[0].abilityModifications, [
    {
      abilityId: { value: "A000", rawHex: "41303030" },
      unknownFields: ["78563412", "efcdab90"],
    },
  ]);
  assert.equal(parsed.units[0].unknownFields[2].rawHex, "a5".repeat(20));
});

test("rejects a truncated unit record", () => {
  assert.throws(
    () => parseWar3mapUnitsDoo(createFile([createUnit().subarray(0, 110)])),
    /cannot fit|exceeds file bounds/,
  );
});

test("rejects inventory and ability counts that exceed file bounds", () => {
  const invalidInventory = createUnit();
  invalidInventory.writeUInt32LE(1, 83);
  assert.throws(() => parseWar3mapUnitsDoo(createFile([invalidInventory])), /InventoryCount/);

  const invalidAbility = createUnit();
  invalidAbility.writeUInt32LE(1, 87);
  assert.throws(() => parseWar3mapUnitsDoo(createFile([invalidAbility])), /AbilityCount/);
});

test("rejects unsupported headers and trailing bytes", () => {
  const badVersion = createFile([createUnit()]);
  badVersion.writeUInt32LE(9, 4);
  assert.throws(() => parseWar3mapUnitsDoo(badVersion), /Unsupported W3do version/);

  assert.throws(
    () => parseWar3mapUnitsDoo(Buffer.concat([createFile([]), Buffer.from([0])])),
    /Unexpected trailing data/,
  );
});

test("rejects non-finite position values", () => {
  const unit = createUnit();
  unit.writeFloatLE(Number.NaN, 8);
  assert.throws(() => parseWar3mapUnitsDoo(createFile([unit])), /not a finite/);
});

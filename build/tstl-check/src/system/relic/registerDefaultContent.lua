local ____exports = {}
local ____burningBlood = require("src.system.relic.definitions.burningBlood")
local burningBloodDefinition = ____burningBlood.burningBloodDefinition
local ____warFang = require("src.system.relic.definitions.warFang")
local warFangDefinition = ____warFang.warFangDefinition
local ____ironPlate = require("src.system.relic.definitions.ironPlate")
local ironPlateDefinition = ____ironPlate.ironPlateDefinition
local ____arcaneGrimoireWater = require("src.system.relic.definitions.arcaneGrimoireWater")
local arcaneGrimoireDefinition = ____arcaneGrimoireWater.arcaneGrimoireDefinition
local ____RelicSystem = require("src.system.relic.RelicSystem")
local RelicSystem = ____RelicSystem.RelicSystem
--- 注册示例遗物与命名池 `common`（可在 main 中调用一次）
function ____exports.registerDefaultRelicsAndPools()
    local rs = RelicSystem:getInstance()
    rs:registerDefinitions({burningBloodDefinition, warFangDefinition, ironPlateDefinition, arcaneGrimoireDefinition})
    rs:registerPool("common", {{id = "burning_blood", weight = 1}, {id = "war_fang", weight = 1}, {id = "iron_plate", weight = 1}, {id = "arcane_grimoire_water", weight = 1}})
    rs:bindDeathCleanup()
end
return ____exports

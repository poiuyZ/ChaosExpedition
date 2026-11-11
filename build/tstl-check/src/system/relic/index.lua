local ____exports = {}
do
    local ____RelicRegistry = require("src.system.relic.RelicRegistry")
    ____exports.RelicRegistry = ____RelicRegistry.RelicRegistry
end
do
    local ____RelicPool = require("src.system.relic.RelicPool")
    ____exports.RelicPool = ____RelicPool.RelicPool
end
do
    local ____RelicSystem = require("src.system.relic.RelicSystem")
    ____exports.RelicSystem = ____RelicSystem.RelicSystem
    ____exports.RELIC_EVENT_ADDED = ____RelicSystem.RELIC_EVENT_ADDED
    ____exports.RELIC_EVENT_REMOVED = ____RelicSystem.RELIC_EVENT_REMOVED
    ____exports.RELIC_EVENT_INVENTORY_CHANGED = ____RelicSystem.RELIC_EVENT_INVENTORY_CHANGED
end
do
    local ____registerDefaultContent = require("src.system.relic.registerDefaultContent")
    ____exports.registerDefaultRelicsAndPools = ____registerDefaultContent.registerDefaultRelicsAndPools
end
do
    local ____burningBlood = require("src.system.relic.definitions.burningBlood")
    ____exports.burningBloodDefinition = ____burningBlood.burningBloodDefinition
    ____exports.BURNING_BLOOD_MAX_HP_BONUS = ____burningBlood.BURNING_BLOOD_MAX_HP_BONUS
end
do
    local ____warFang = require("src.system.relic.definitions.warFang")
    ____exports.warFangDefinition = ____warFang.warFangDefinition
    ____exports.WAR_FANG_ATTACK_BONUS = ____warFang.WAR_FANG_ATTACK_BONUS
end
do
    local ____ironPlate = require("src.system.relic.definitions.ironPlate")
    ____exports.ironPlateDefinition = ____ironPlate.ironPlateDefinition
    ____exports.IRON_PLATE_ARMOR_LEVELS = ____ironPlate.IRON_PLATE_ARMOR_LEVELS
end
do
    local ____arcaneGrimoireWater = require("src.system.relic.definitions.arcaneGrimoireWater")
    ____exports.arcaneGrimoireDefinition = ____arcaneGrimoireWater.arcaneGrimoireDefinition
end
return ____exports

local ____exports = {}
local ____helper = require("src.utils.helper")
local FourCC = ____helper.FourCC
--- 大法师：召唤水元素（与 UnitEventExample 中 AHwe 一致）
local AB_SUMMON_WATER_ELEMENTAL = FourCC("AHwe")
____exports.arcaneGrimoireDefinition = {
    id = "arcane_grimoire_water",
    name = "奥术魔典：涌流",
    description = "习得技能「召唤水元素」（与法师英雄水元素相同，需消耗魔法）。",
    icon = "ReplaceableTextures\\CommandButtons\\BTNSummonWaterElemental.blp",
    rarity = "rare",
    maxStacks = 1,
    onAcquire = function(self, actor)
        actor:addAbility(AB_SUMMON_WATER_ELEMENTAL)
    end,
    onRemove = function(self, actor, _stacks)
        actor:removeAbility(AB_SUMMON_WATER_ELEMENTAL)
    end
}
return ____exports

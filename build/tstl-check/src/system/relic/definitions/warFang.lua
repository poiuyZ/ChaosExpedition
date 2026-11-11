local ____exports = {}
local ____units = require("src.constants.game.units")
local UNIT_TYPE_HERO = ____units.UNIT_TYPE_HERO
local ____helper = require("src.utils.helper")
local FourCC = ____helper.FourCC
--- 物品类「攻击伤害加成」技能（默认数据一般为每级 +1 伤害，具体以物编为准）
local AB_ITEM_DAMAGE_BONUS = FourCC("AIat")
local function isHero(u)
    return IsUnitType(u, UNIT_TYPE_HERO)
end
local function addHeroStrength(u, delta)
    local current = GetHeroStr(u, false)
    SetHeroStr(u, current + delta, true)
end
local function removeHeroStrength(u, delta)
    local current = GetHeroStr(u, false)
    SetHeroStr(
        u,
        math.max(1, current - delta),
        true
    )
end
--- +攻击力遗物：对英雄使用 +5 力量（近战主属性英雄每点力量 +1 近战攻击）；非英雄则叠物品加攻技能
____exports.WAR_FANG_ATTACK_BONUS = 5
____exports.warFangDefinition = {
    id = "war_fang",
    name = "战鬼之牙",
    description = "永久增加 5 点力量（英雄）。近战英雄每点力量额外增加 1 点近战攻击力。",
    icon = "ReplaceableTextures\\CommandButtons\\BTNClawsOfAttack.blp",
    rarity = "rare",
    maxStacks = 1,
    onAcquire = function(self, actor)
        local u = actor.handle
        if isHero(u) then
            addHeroStrength(u, ____exports.WAR_FANG_ATTACK_BONUS)
            return
        end
        actor:addAbility(AB_ITEM_DAMAGE_BONUS)
        actor:setAbilityLevel(AB_ITEM_DAMAGE_BONUS, ____exports.WAR_FANG_ATTACK_BONUS)
    end,
    onRemove = function(self, actor, stacks)
        local u = actor.handle
        local n = ____exports.WAR_FANG_ATTACK_BONUS * stacks
        if isHero(u) then
            removeHeroStrength(u, n)
            return
        end
        actor:removeAbility(AB_ITEM_DAMAGE_BONUS)
    end
}
return ____exports

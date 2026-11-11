local ____exports = {}
local ____units = require("src.constants.game.units")
local UNIT_STATE_LIFE = ____units.UNIT_STATE_LIFE
local UNIT_STATE_MAX_LIFE = ____units.UNIT_STATE_MAX_LIFE
--- 燃烧之血：增加的最大生命（可改此常量调整数值）
____exports.BURNING_BLOOD_MAX_HP_BONUS = 100
local function addMaxLife(actor, delta)
    local u = actor.handle
    local max = GetUnitState(u, UNIT_STATE_MAX_LIFE)
    local life = GetUnitState(u, UNIT_STATE_LIFE)
    local newMax = max + delta
    SetUnitState(u, UNIT_STATE_MAX_LIFE, newMax)
    SetUnitState(u, UNIT_STATE_LIFE, life + delta)
end
local function removeMaxLife(actor, delta)
    local u = actor.handle
    local max = GetUnitState(u, UNIT_STATE_MAX_LIFE)
    local life = GetUnitState(u, UNIT_STATE_LIFE)
    local newMax = math.max(1, max - delta)
    SetUnitState(u, UNIT_STATE_MAX_LIFE, newMax)
    SetUnitState(
        u,
        UNIT_STATE_LIFE,
        math.min(life, newMax)
    )
end
____exports.burningBloodDefinition = {
    id = "burning_blood",
    name = "燃烧之血",
    description = "获得时增加 100 点生命上限，并回复等量生命。",
    icon = "ReplaceableTextures\\CommandButtons\\BTNHeartOfAszune.blp",
    rarity = "boss",
    maxStacks = 1,
    onAcquire = function(self, actor)
        addMaxLife(actor, ____exports.BURNING_BLOOD_MAX_HP_BONUS)
    end,
    onRemove = function(self, actor, stacks)
        removeMaxLife(actor, ____exports.BURNING_BLOOD_MAX_HP_BONUS * stacks)
    end
}
return ____exports

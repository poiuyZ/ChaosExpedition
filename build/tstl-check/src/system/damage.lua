local ____lualib = require("lualib_bundle")
local __TS__Class = ____lualib.__TS__Class
local __TS__New = ____lualib.__TS__New
local ____exports = {}
local _____2A = require("lua_modules.@eiriksgata.wc3ts.src.index")
local EVENT_UNIT_DAMAGED = _____2A.EVENT_UNIT_DAMAGED
local Group = _____2A.Group
local Rectangle = _____2A.Rectangle
local Region = _____2A.Region
local Timer = _____2A.Timer
local Trigger = _____2A.Trigger
local Unit = _____2A.Unit
local UNIT_TYPE_DEAD = _____2A.UNIT_TYPE_DEAD
local ____event = require("src.system.event.index")
local gameEvents = ____event.gameEvents
local UnitDamageEventData = ____event.UnitDamageEventData
local ____helper = require("src.utils.helper")
local FourCC = ____helper.FourCC
local ____actor = require("src.system.actor")
local Actor = ____actor.Actor
local ____EventBus = require("src.system.event.EventBus")
local eventBus = ____EventBus.eventBus
local LOCUST_ABILITY_ID = FourCC("Aloc")
local REBUILD_INTERVAL = 10 * 60
local REBUILD_EVENT_THRESHOLD = 30000
local function isLocust(u)
    return GetUnitAbilityLevel(u, LOCUST_ABILITY_ID) > 0
end
local function isAliveHandle(u)
    return not IsUnitType(
        u,
        UNIT_TYPE_DEAD()
    ) and GetWidgetLife(u) > 0.405
end
____exports.default = __TS__Class()
local DamageSystem = ____exports.default
DamageSystem.name = "DamageSystem"
function DamageSystem.prototype.____constructor(self)
end
function DamageSystem.getInstance(self)
    if not ____exports.default.instance then
        ____exports.default.instance = __TS__New(____exports.default)
    end
    return ____exports.default.instance
end
function DamageSystem.prototype.initialize(self)
    ____exports.default.unitGroup = ____exports.default.unitGroup or Group:create()
    ____exports.default:bindDamageTrigger()
    ____exports.default:bindEnterRegion()
    ____exports.default:enumExistingUnits()
    ____exports.default:bindRebuildTimer()
    ____exports.default:bindActorCreated()
    ____exports.default:bindUnitDeath()
end
function DamageSystem.bindDamageTrigger(self)
    ____exports.default.dmgTrigger = Trigger:create()
    ____exports.default.dmgTrigger:addAction(function()
        local damagedUnit = GetTriggerUnit()
        local damageSource = GetEventDamageSource()
        local rawDamage = GetEventDamage()
        local data = __TS__New(
            UnitDamageEventData,
            Actor:fromHandle(damagedUnit),
            GetUnitTypeId(damagedUnit),
            GetOwningPlayer(damagedUnit),
            Actor:fromHandle(damageSource),
            rawDamage
        )
        gameEvents:emit("game:Actor:damaged", data)
    end)
end
function DamageSystem.bindEnterRegion(self)
    if ____exports.default.enterTrigger ~= nil then
        return
    end
    ____exports.default.enterTrigger = Trigger:create()
    local region = Region:create()
    local worldBounds = Rectangle:getWorldBounds()
    region:addRect(worldBounds)
    ____exports.default.worldRegion = region
    ____exports.default.enterTrigger:registerEnterRegion(
        region,
        function()
            local u = GetEnteringUnit()
            if u == nil then
                return false
            end
            ____exports.default:tryRegisterHandle(u)
            return false
        end
    )
end
function DamageSystem.enumExistingUnits(self)
    local temp = Group:create()
    temp:enumUnitsInRange(
        0,
        0,
        10000,
        function()
            local u = GetFilterUnit()
            if u == nil then
                return false
            end
            ____exports.default:tryRegisterHandle(u)
            return false
        end
    )
    temp:destroy()
end
function DamageSystem.bindRebuildTimer(self)
    if ____exports.default.rebuildTimer ~= nil then
        return
    end
    ____exports.default.rebuildTimer = Timer:create()
    ____exports.default.rebuildTimer:start(
        REBUILD_INTERVAL,
        true,
        function()
            if ____exports.default.triggerEventCount > REBUILD_EVENT_THRESHOLD then
                ____exports.default:getInstance():releaseUnitEvent()
            end
        end
    )
end
function DamageSystem.bindActorCreated(self)
    if ____exports.default.createdBound then
        return
    end
    ____exports.default.createdBound = true
    eventBus:on(
        "game:Actor:created",
        function(____bindingPattern0)
            local actor
            actor = ____bindingPattern0.actor
            if actor.handle == nil then
                return
            end
            ____exports.default:tryRegisterHandle(actor.handle)
        end
    )
end
function DamageSystem.bindUnitDeath(self)
    if ____exports.default.deathBound then
        return
    end
    ____exports.default.deathBound = true
    gameEvents:onUnitDeath(function(data)
        local unit = data.Actor
        if unit == nil then
            return
        end
        if ____exports.default.unitGroup ~= nil then
            ____exports.default.unitGroup:removeUnit(unit)
        end
    end)
end
function DamageSystem.tryRegisterHandle(self, u)
    if u == nil or not isAliveHandle(u) or isLocust(u) then
        return false
    end
    local wrapped = Unit:fromHandle(u)
    if wrapped == nil then
        return false
    end
    if not ____exports.default.unitGroup or not ____exports.default.dmgTrigger then
        return false
    end
    if ____exports.default.unitGroup:hasUnit(wrapped) then
        return false
    end
    ____exports.default.dmgTrigger:registerUnitEvent(
        wrapped,
        EVENT_UNIT_DAMAGED()
    )
    ____exports.default.unitGroup:addUnit(wrapped)
    local ____exports_default_0, ____triggerEventCount_1 = ____exports.default, "triggerEventCount"
    ____exports_default_0[____triggerEventCount_1] = ____exports_default_0[____triggerEventCount_1] + 1
    return true
end
function DamageSystem.prototype.releaseUnitEvent(self)
    ____exports.default.dmgTrigger:destroy()
    ____exports.default:bindDamageTrigger()
    ____exports.default.triggerEventCount = 0
    local stillAlive = {}
    local ____self_2 = ____exports.default.unitGroup
    ____self_2["for"](
        ____self_2,
        function()
            local u = Unit:fromHandle(GetEnumUnit())
            if u == nil or u.handle == nil then
                return
            end
            if isAliveHandle(u.handle) then
                stillAlive[#stillAlive + 1] = u
            end
        end
    )
    ____exports.default.unitGroup:clear()
    for ____, u in ipairs(stillAlive) do
        ____exports.default.dmgTrigger:registerUnitEvent(
            u,
            EVENT_UNIT_DAMAGED()
        )
        ____exports.default.unitGroup:addUnit(u)
        local ____exports_default_3, ____triggerEventCount_4 = ____exports.default, "triggerEventCount"
        ____exports_default_3[____triggerEventCount_4] = ____exports_default_3[____triggerEventCount_4] + 1
    end
end
DamageSystem.triggerEventCount = 0
DamageSystem.createdBound = false
DamageSystem.deathBound = false
return ____exports

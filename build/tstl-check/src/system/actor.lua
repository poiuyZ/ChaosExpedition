local ____lualib = require("lualib_bundle")
local __TS__Class = ____lualib.__TS__Class
local __TS__ClassExtends = ____lualib.__TS__ClassExtends
local __TS__ObjectAssign = ____lualib.__TS__ObjectAssign
local __TS__Delete = ____lualib.__TS__Delete
local __TS__SetDescriptor = ____lualib.__TS__SetDescriptor
local __TS__New = ____lualib.__TS__New
local ____exports = {}
local _____2A = require("lua_modules.@eiriksgata.wc3ts.src.index")
local Unit = _____2A.Unit
local UNIT_TYPE_DEAD = _____2A.UNIT_TYPE_DEAD
local ____UnitBlood = require("src.system.ui.component.UnitBlood")
local UnitBlood = ____UnitBlood.UnitBlood
local ____BuffManager = require("src.system.buff.BuffManager")
local BuffManager = ____BuffManager.BuffManager
local ____types = require("src.system.buff.types")
local BUFF_DURATION_PERMANENT = ____types.BUFF_DURATION_PERMANENT
local ____EventBus = require("src.system.event.EventBus")
local eventBus = ____EventBus.eventBus
____exports.Actor = __TS__Class()
local Actor = ____exports.Actor
Actor.name = "Actor"
__TS__ClassExtends(Actor, Unit)
function Actor.prototype.____constructor(self, owner, unitId, x, y, face)
    Unit.prototype.____constructor(
        self,
        owner,
        unitId,
        x,
        y,
        face
    )
    self._hpBarUIHeight = 100
    self._size = 1
    self._buffManager = nil
    self.label = ""
    self.bloodBarUI = nil
    ____exports.Actor.allActors[self.id] = self
end
function Actor.ensureActorFields(self, obj)
    local f = obj
    if f._hpBarUIHeight == nil then
        f._hpBarUIHeight = 100
    end
    if f._size == nil then
        f._size = 1
    end
    if f._buffManager == nil then
        f._buffManager = nil
    end
    if f.label == nil then
        f.label = ""
    end
    if f.bloodBarUI == nil then
        f.bloodBarUI = nil
    end
end
function Actor.ensureActorPrototype(self, obj)
    setmetatable(obj, ____exports.Actor.prototype)
end
function Actor.isHandleAlive(self, handle)
    return not IsUnitType(
        handle,
        UNIT_TYPE_DEAD()
    ) and GetWidgetLife(handle) > 0.405
end
function Actor.create(self, owner, unitId, x, y, facing)
    if facing == nil then
        facing = 0
    end
    if not owner then
        return nil
    end
    local handle = CreateUnit(
        owner.handle,
        unitId,
        x,
        y,
        facing
    )
    if not handle then
        return nil
    end
    local actor = ____exports.Actor:getObject(handle)
    if not actor then
        return nil
    end
    ____exports.Actor:ensureActorPrototype(actor)
    ____exports.Actor:ensureActorFields(actor)
    __TS__ObjectAssign(actor, {handle = handle})
    ____exports.Actor.allActors[actor.id] = actor
    eventBus:emit("game:Actor:created", {actor = actor})
    return actor
end
function Actor.fromUnit(self, unit)
    if not unit then
        return nil
    end
    local existing = ____exports.Actor.allActors[unit.id]
    if existing ~= nil then
        return existing
    end
    return ____exports.Actor:fromHandle(unit.handle)
end
function Actor.fromHandle(self, handle)
    if not handle then
        return nil
    end
    local hid = GetHandleId(handle)
    local existing = ____exports.Actor.allActors[hid]
    if existing ~= nil then
        return existing
    end
    local actor = ____exports.Actor:getObject(handle)
    if not actor then
        return nil
    end
    ____exports.Actor:ensureActorPrototype(actor)
    ____exports.Actor:ensureActorFields(actor)
    __TS__ObjectAssign(actor, {handle = handle})
    ____exports.Actor.allActors[actor.id] = actor
    if ____exports.Actor:isHandleAlive(handle) then
        eventBus:emit("game:Actor:created", {actor = actor})
    end
    return actor
end
function Actor.getById(self, unitId)
    return ____exports.Actor.allActors[unitId]
end
function Actor.prototype.detach(self)
    if self._buffManager ~= nil then
        self._buffManager:clearAll()
        self._buffManager = nil
    end
    UnitBlood:remove(self)
    self.bloodBarUI = nil
    __TS__Delete(____exports.Actor.allActors, self.id)
end
function Actor.prototype.destroy(self)
    self:detach()
    Unit.prototype.destroy(self)
end
function Actor.prototype.hasBuffManager(self)
    return self._buffManager ~= nil
end
function Actor.prototype.hasShield(self)
    return self.buffManager:getTotalShieldCurrent() > 0
end
function Actor.prototype.addShield(self, delta, duration, displayKey)
    if duration == nil then
        duration = BUFF_DURATION_PERMANENT
    end
    if delta > 0 then
        self.buffManager:addShieldBuff(delta, duration, displayKey)
    elseif delta < 0 then
        self.buffManager:reduceShield(-delta)
    end
end
function Actor.prototype.setLabel(self, value)
    self.label = value
    if self.bloodBarUI then
        self.bloodBarUI.nameFrame:setText(value)
    end
end
function Actor.prototype.getLabel(self)
    return self.label
end
function Actor.prototype.createBloodBar(self)
    self.bloodBarUI = UnitBlood:create(self)
end
Actor.allActors = {}
__TS__SetDescriptor(
    Actor.prototype,
    "hpBarUIHeight",
    {
        get = function(self)
            return self._hpBarUIHeight
        end,
        set = function(self, value)
            self._hpBarUIHeight = value
        end
    },
    true
)
__TS__SetDescriptor(
    Actor.prototype,
    "size",
    {
        get = function(self)
            return self._size
        end,
        set = function(self, value)
            self._size = value
        end
    },
    true
)
__TS__SetDescriptor(
    Actor.prototype,
    "buffManager",
    {get = function(self)
        if self._buffManager == nil then
            self._buffManager = __TS__New(BuffManager, self)
        end
        return self._buffManager
    end},
    true
)
__TS__SetDescriptor(
    Actor.prototype,
    "shield",
    {get = function(self)
        return self.buffManager:getTotalShieldCurrent()
    end},
    true
)
__TS__SetDescriptor(
    Actor.prototype,
    "maxShield",
    {get = function(self)
        return self.buffManager:getTotalShieldMax()
    end},
    true
)
__TS__SetDescriptor(
    Actor.prototype,
    "shieldPercent",
    {get = function(self)
        local max = self.buffManager:getTotalShieldMax()
        if max <= 0 then
            return 0
        end
        return self.buffManager:getTotalShieldCurrent() / max
    end},
    true
)
return ____exports

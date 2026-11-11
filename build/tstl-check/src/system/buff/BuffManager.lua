local ____lualib = require("lualib_bundle")
local __TS__Class = ____lualib.__TS__Class
local __TS__ArrayIndexOf = ____lualib.__TS__ArrayIndexOf
local __TS__ArraySplice = ____lualib.__TS__ArraySplice
local __TS__ArrayFind = ____lualib.__TS__ArrayFind
local __TS__ArraySlice = ____lualib.__TS__ArraySlice
local __TS__ArrayFilter = ____lualib.__TS__ArrayFilter
local __TS__InstanceOf = ____lualib.__TS__InstanceOf
local __TS__ArrayReduce = ____lualib.__TS__ArrayReduce
local __TS__New = ____lualib.__TS__New
local ____exports = {}
local ____EventBus = require("src.system.event.EventBus")
local eventBus = ____EventBus.eventBus
local ____types = require("src.system.buff.types")
local BUFF_EVENT_BUFFS_CHANGED = ____types.BUFF_EVENT_BUFFS_CHANGED
local ____ShieldBuff = require("src.system.buff.ShieldBuff")
local ShieldBuff = ____ShieldBuff.ShieldBuff
local ____types = require("src.system.buff.types")
local BUFF_DURATION_PERMANENT = ____types.BUFF_DURATION_PERMANENT
____exports.BuffManager = __TS__Class()
local BuffManager = ____exports.BuffManager
BuffManager.name = "BuffManager"
function BuffManager.prototype.____constructor(self, owner)
    self.buffs = {}
    self.owner = owner
end
function BuffManager.prototype.emitChanged(self)
    eventBus:emit(BUFF_EVENT_BUFFS_CHANGED, {actor = self.owner})
end
function BuffManager.prototype.getOwner(self)
    return self.owner
end
function BuffManager.prototype.addBuff(self, buff)
    buff.holderId = self.owner.id
    local ____self_buffs_0 = self.buffs
    ____self_buffs_0[#____self_buffs_0 + 1] = buff
    buff:onApply()
    self:emitChanged()
end
function BuffManager.prototype.removeBuff(self, buff)
    local idx = __TS__ArrayIndexOf(self.buffs, buff)
    if idx < 0 then
        return false
    end
    __TS__ArraySplice(self.buffs, idx, 1)
    buff:onRemove()
    self:emitChanged()
    return true
end
function BuffManager.prototype.removeBuffById(self, id)
    local b = __TS__ArrayFind(
        self.buffs,
        function(____, x) return x.id == id end
    )
    local ____b_1
    if b then
        ____b_1 = self:removeBuff(b)
    else
        ____b_1 = false
    end
    return ____b_1
end
function BuffManager.prototype.getBuffs(self)
    return __TS__ArraySlice(self.buffs)
end
function BuffManager.prototype.getBuffsByType(self, typeId)
    return __TS__ArrayFilter(
        self.buffs,
        function(____, b) return b.typeId == typeId end
    )
end
function BuffManager.prototype.clearAll(self)
    if #self.buffs == 0 then
        return
    end
    local copy = self.buffs
    self.buffs = {}
    do
        local i = #copy - 1
        while i >= 0 do
            copy[i + 1]:onRemove()
            i = i - 1
        end
    end
    self:emitChanged()
end
function BuffManager.prototype.getShieldBuffs(self)
    return __TS__ArrayFilter(
        self.buffs,
        function(____, b) return __TS__InstanceOf(b, ShieldBuff) end
    )
end
function BuffManager.prototype.tick(self, delta)
    do
        local i = #self.buffs - 1
        while i >= 0 do
            local buff = self.buffs[i + 1]
            buff:tick(delta)
            if buff:isExpired() then
                __TS__ArraySplice(self.buffs, i, 1)
                buff:onRemove()
                self:emitChanged()
            end
            i = i - 1
        end
    end
    do
        local i = #self.buffs - 1
        while i >= 0 do
            local b = self.buffs[i + 1]
            if __TS__InstanceOf(b, ShieldBuff) and b:isDepleted() then
                __TS__ArraySplice(self.buffs, i, 1)
                b:onRemove()
                self:emitChanged()
            end
            i = i - 1
        end
    end
end
function BuffManager.prototype.getTotalShieldCurrent(self)
    return __TS__ArrayReduce(
        self:getShieldBuffs(),
        function(____, sum, b) return sum + b.current end,
        0
    )
end
function BuffManager.prototype.getTotalShieldMax(self)
    return __TS__ArrayReduce(
        self:getShieldBuffs(),
        function(____, sum, b) return sum + b.max end,
        0
    )
end
function BuffManager.prototype.addShieldBuff(self, amount, duration, displayKey)
    if duration == nil then
        duration = BUFF_DURATION_PERMANENT
    end
    local buff = __TS__New(ShieldBuff, amount, duration, displayKey)
    self:addBuff(buff)
    return buff
end
function BuffManager.prototype.applyShieldDamage(self, damage)
    local remaining = damage
    local changed = false
    local shields = self:getShieldBuffs()
    for ____, sh in ipairs(shields) do
        if remaining <= 0 then
            break
        end
        local absorb = sh:absorbDamage(remaining)
        remaining = remaining - absorb
        if absorb > 0 then
            changed = true
        end
        if sh:isDepleted() then
            local idx = __TS__ArrayIndexOf(self.buffs, sh)
            if idx >= 0 then
                __TS__ArraySplice(self.buffs, idx, 1)
                sh:onRemove()
            end
        end
    end
    if changed then
        self:emitChanged()
    end
    return remaining
end
function BuffManager.prototype.reduceShield(self, amount)
    self:applyShieldDamage(amount)
end
return ____exports

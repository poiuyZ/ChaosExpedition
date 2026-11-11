local ____lualib = require("lualib_bundle")
local __TS__Class = ____lualib.__TS__Class
local __TS__ClassExtends = ____lualib.__TS__ClassExtends
local ____exports = {}
local ____Buff = require("src.system.buff.Buff")
local Buff = ____Buff.Buff
local ____types = require("src.system.buff.types")
local BuffTypeId = ____types.BuffTypeId
local BUFF_DURATION_PERMANENT = ____types.BUFF_DURATION_PERMANENT
____exports.ShieldBuff = __TS__Class()
local ShieldBuff = ____exports.ShieldBuff
ShieldBuff.name = "ShieldBuff"
__TS__ClassExtends(ShieldBuff, Buff)
function ShieldBuff.prototype.____constructor(self, amount, duration, displayKey)
    if duration == nil then
        duration = BUFF_DURATION_PERMANENT
    end
    Buff.prototype.____constructor(self, duration, 1)
    self.typeId = BuffTypeId.SHIELD
    self.current = amount
    self.max = amount
    self.displayKey = displayKey
end
function ShieldBuff.prototype.absorbDamage(self, damage)
    local absorb = math.min(self.current, damage)
    self.current = math.max(0, self.current - absorb)
    return absorb
end
function ShieldBuff.prototype.isDepleted(self)
    return self.current <= 0
end
return ____exports

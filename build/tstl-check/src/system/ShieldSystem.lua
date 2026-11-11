local ____lualib = require("lualib_bundle")
local __TS__Class = ____lualib.__TS__Class
local __TS__New = ____lualib.__TS__New
local ____exports = {}
local ____event = require("src.system.event.index")
local gameEvents = ____event.gameEvents
--- 高优先级，确保先于飘字等逻辑修改伤害值
local SHIELD_PRIORITY = 10
____exports.default = __TS__Class()
local ShieldSystem = ____exports.default
ShieldSystem.name = "ShieldSystem"
function ShieldSystem.prototype.____constructor(self)
end
function ShieldSystem.getInstance(self)
    if not ____exports.default.instance then
        ____exports.default.instance = __TS__New(____exports.default)
    end
    return ____exports.default.instance
end
function ShieldSystem.prototype.init(self)
    gameEvents:onUnitDamaged(
        function(data) return self:onUnitDamaged(data) end,
        {priority = SHIELD_PRIORITY}
    )
end
function ShieldSystem.prototype.onUnitDamaged(self, data)
    local target = data.Actor
    if not target or not target:hasShield() or data.damage <= 0 then
        return
    end
    local remaining = target.buffManager:applyShieldDamage(data.damage)
    data:setEventDamage(remaining)
end
return ____exports

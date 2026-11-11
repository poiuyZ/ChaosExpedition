local ____lualib = require("lualib_bundle")
local __TS__Class = ____lualib.__TS__Class
local ____exports = {}
local ____types = require("src.system.buff.types")
local BUFF_DURATION_PERMANENT = ____types.BUFF_DURATION_PERMANENT
local nextBuffId = 1
____exports.Buff = __TS__Class()
local Buff = ____exports.Buff
Buff.name = "Buff"
function Buff.prototype.____constructor(self, duration, polarity)
    if duration == nil then
        duration = BUFF_DURATION_PERMANENT
    end
    if polarity == nil then
        polarity = 1
    end
    self.holderId = 0
    self.elapsed = 0
    self.sourceId = 0
    local ____nextBuffId_0 = nextBuffId
    nextBuffId = ____nextBuffId_0 + 1
    self.id = ____nextBuffId_0
    self.duration = duration
    self.polarity = polarity
end
function Buff.prototype.isExpired(self)
    if self.duration < 0 then
        return false
    end
    return self.elapsed >= self.duration
end
function Buff.prototype.tick(self, delta)
    if self.duration < 0 then
        return
    end
    self.elapsed = self.elapsed + delta
end
function Buff.prototype.onApply(self)
end
function Buff.prototype.onRemove(self)
end
return ____exports

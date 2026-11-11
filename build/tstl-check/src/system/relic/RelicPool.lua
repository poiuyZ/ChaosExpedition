local ____lualib = require("lualib_bundle")
local __TS__Class = ____lualib.__TS__Class
local __TS__ArrayFilter = ____lualib.__TS__ArrayFilter
local ____exports = {}
--- 权重随机遗物池（单次 draw 返回一个 id）
____exports.RelicPool = __TS__Class()
local RelicPool = ____exports.RelicPool
RelicPool.name = "RelicPool"
function RelicPool.prototype.____constructor(self, entries)
    self.entries = __TS__ArrayFilter(
        entries,
        function(____, e) return e.weight > 0 end
    )
end
function RelicPool.prototype.setEntries(self, entries)
    self.entries = __TS__ArrayFilter(
        entries,
        function(____, e) return e.weight > 0 end
    )
end
function RelicPool.prototype.draw(self)
    if #self.entries == 0 then
        return nil
    end
    local total = 0
    for ____, e in ipairs(self.entries) do
        total = total + e.weight
    end
    if total <= 0 then
        return nil
    end
    local r = GetRandomReal(0, total)
    for ____, e in ipairs(self.entries) do
        r = r - e.weight
        if r <= 0 then
            return e.id
        end
    end
    return self.entries[#self.entries].id
end
return ____exports

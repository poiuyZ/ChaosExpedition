local ____lualib = require("lualib_bundle")
local __TS__Class = ____lualib.__TS__Class
local Map = ____lualib.Map
local __TS__New = ____lualib.__TS__New
local ____exports = {}
local ____logger = require("src.utils.logger")
local createLogger = ____logger.createLogger
local log = createLogger("RelicRegistry")
--- 遗物 id → 定义（启动时注册）
____exports.RelicRegistry = __TS__Class()
local RelicRegistry = ____exports.RelicRegistry
RelicRegistry.name = "RelicRegistry"
function RelicRegistry.prototype.____constructor(self)
    self.map = __TS__New(Map)
end
function RelicRegistry.prototype.register(self, def)
    if self.map:has(def.id) then
        log:warn("overwrite relic definition: " .. def.id)
    end
    self.map:set(def.id, def)
end
function RelicRegistry.prototype.registerAll(self, defs)
    for ____, d in ipairs(defs) do
        self:register(d)
    end
end
function RelicRegistry.prototype.get(self, id)
    return self.map:get(id)
end
function RelicRegistry.prototype.has(self, id)
    return self.map:has(id)
end
return ____exports

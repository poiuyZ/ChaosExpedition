local ____lualib = require("lualib_bundle")
local WeakMap = ____lualib.WeakMap
local __TS__New = ____lualib.__TS__New
local Map = ____lualib.Map
local __TS__Class = ____lualib.__TS__Class
local __TS__SetDescriptor = ____lualib.__TS__SetDescriptor
local ____exports = {}
local objectMap = __TS__New(WeakMap)
local numberMap = __TS__New(Map)
____exports.Handle = __TS__Class()
local Handle = ____exports.Handle
Handle.name = "Handle"
function Handle.prototype.____constructor(self, handle)
    self.handle = handle == nil and ____exports.Handle.initHandle or handle
    ____exports.Handle:store(self.handle, self)
end
function Handle.initFromHandle(self)
    return ____exports.Handle.initHandle ~= nil
end
function Handle.store(self, rawHandle, obj)
    if type(rawHandle) == "number" then
        numberMap:set(rawHandle, obj)
    else
        objectMap:set(rawHandle, obj)
    end
end
function Handle.release(self, rawHandle)
    if type(rawHandle) == "number" then
        numberMap:delete(rawHandle)
    else
        objectMap:delete(rawHandle)
    end
end
function Handle.prototype.uncache(self)
    ____exports.Handle:release(self.handle)
end
function Handle.getObject(self, rawHandle)
    local ____temp_0
    if type(rawHandle) == "number" then
        ____temp_0 = numberMap:get(rawHandle)
    else
        ____temp_0 = objectMap:get(rawHandle)
    end
    local obj = ____temp_0
    if obj ~= nil then
        return obj
    end
    ____exports.Handle.initHandle = rawHandle
    local newObj = __TS__New(self)
    ____exports.Handle.initHandle = nil
    return newObj
end
__TS__SetDescriptor(
    Handle.prototype,
    "id",
    {get = function(self)
        local raw = self.handle
        if type(raw) == "number" then
            return raw
        end
        return GetHandleId(raw)
    end},
    true
)
return ____exports

local ____lualib = require("lualib_bundle")
local __TS__Class = ____lualib.__TS__Class
local __TS__ClassExtends = ____lualib.__TS__ClassExtends
local Error = ____lualib.Error
local RangeError = ____lualib.RangeError
local ReferenceError = ____lualib.ReferenceError
local SyntaxError = ____lualib.SyntaxError
local TypeError = ____lualib.TypeError
local URIError = ____lualib.URIError
local __TS__ObjectAssign = ____lualib.__TS__ObjectAssign
local __TS__SetDescriptor = ____lualib.__TS__SetDescriptor
local ____exports = {}
local ____handle = require("lua_modules.@eiriksgata.wc3ts.src.handles.handle")
local Handle = ____handle.Handle
local ____effect = require("lua_modules.@eiriksgata.wc3ts.src.handles.effect")
local Effect = ____effect.Effect
____exports.EffectGroup = __TS__Class()
local EffectGroup = ____exports.EffectGroup
EffectGroup.name = "EffectGroup"
__TS__ClassExtends(EffectGroup, Handle)
function EffectGroup.prototype.____constructor(self)
    if Handle:initFromHandle() then
        Handle.prototype.____constructor(self)
        return
    end
    local handle = DzEffectGroupCreate()
    if handle == nil then
        Error(nil, "w3ts failed to create dzeffectgroup handle.")
    end
    Handle.prototype.____constructor(self, handle)
end
function EffectGroup.create(self)
    local handle = DzEffectGroupCreate()
    if handle ~= nil then
        local obj = self:getObject(handle)
        local values = {}
        values.handle = handle
        return __TS__ObjectAssign(obj, values)
    end
    return nil
end
function EffectGroup.createEnumRange(self, x, y, range)
    local group = self:create()
    if group == nil then
        return nil
    end
    group:enumRange(
        x,
        y,
        range,
        false,
        false
    )
    return group
end
function EffectGroup.createEnumRect(self, whichRect)
    local group = self:create()
    if group == nil then
        return nil
    end
    group:enumRect(whichRect, false, false)
    return group
end
function EffectGroup.prototype.at(self, index)
    return Effect:fromHandle(DzEffectGroupAt(self.handle, index))
end
function EffectGroup.prototype.clear(self)
    return DzEffectGroupClear(self.handle)
end
function EffectGroup.prototype.add(self, whichEffect, allowDuplicate)
    if allowDuplicate == nil then
        allowDuplicate = false
    end
    return DzEffectGroupAdd(self.handle, whichEffect.handle, allowDuplicate)
end
function EffectGroup.prototype.remove(self, whichEffect, firstOnly)
    if firstOnly == nil then
        firstOnly = true
    end
    return DzEffectGroupRemove(self.handle, whichEffect.handle, firstOnly)
end
function EffectGroup.prototype.contains(self, whichEffect)
    return DzEffectGroupContains(self.handle, whichEffect.handle)
end
function EffectGroup.prototype.enumRange(self, x, y, range, clear, allowDuplicate)
    if clear == nil then
        clear = false
    end
    if allowDuplicate == nil then
        allowDuplicate = false
    end
    return DzEffectGroupEnumRange(
        self.handle,
        x,
        y,
        range,
        clear,
        allowDuplicate
    )
end
function EffectGroup.prototype.enumRect(self, whichRect, clear, allowDuplicate)
    if clear == nil then
        clear = false
    end
    if allowDuplicate == nil then
        allowDuplicate = false
    end
    return DzEffectGroupEnumRect(self.handle, whichRect.handle, clear, allowDuplicate)
end
function EffectGroup.prototype.destroy(self)
    return DzEffectGroupDestroy(self.handle)
end
EffectGroup.prototype["for"] = function(self, callback)
    return DzForEffectGroup(self.handle, callback)
end
function EffectGroup.prototype.getEffects(self)
    local effects = {}
    local n = self.size
    do
        local i = 1
        while i <= n do
            local e = self:at(i)
            if e ~= nil then
                effects[#effects + 1] = e
            end
            i = i + 1
        end
    end
    return effects
end
function EffectGroup.fromHandle(self, handle)
    local ____temp_0
    if handle ~= nil then
        ____temp_0 = self:getObject(handle)
    else
        ____temp_0 = nil
    end
    return ____temp_0
end
function EffectGroup.fromHandleId(self, handleId)
    return self:fromHandle(DzHandle2EffectGroup(handleId))
end
function EffectGroup.getEnumEffect(self)
    return Effect:fromHandle(DzGetEnumEffect())
end
__TS__SetDescriptor(
    EffectGroup.prototype,
    "size",
    {get = function(self)
        return DzEffectGroupGetSize(self.handle)
    end},
    true
)
return ____exports

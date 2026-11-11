local ____lualib = require("lualib_bundle")
local __TS__Class = ____lualib.__TS__Class
local __TS__ClassExtends = ____lualib.__TS__ClassExtends
local __TS__New = ____lualib.__TS__New
local __TS__ObjectAssign = ____lualib.__TS__ObjectAssign
local __TS__Delete = ____lualib.__TS__Delete
local __TS__SetDescriptor = ____lualib.__TS__SetDescriptor
local ____exports = {}
local _____2A = require("lua_modules.@eiriksgata.wc3ts.src.index")
local Effect = _____2A.Effect
--- Effect 的增强封装：
-- - 链式设置坐标/旋转/缩放
-- - 提供 fromHandle/createAttachment 的“类型升级”
-- - 维护一个轻量的实例注册表，便于调试与集中销毁
____exports.EffectEx = __TS__Class()
local EffectEx = ____exports.EffectEx
EffectEx.name = "EffectEx"
__TS__ClassExtends(EffectEx, Effect)
function EffectEx.prototype.____constructor(self, modelName, a, b)
    self._destroyed = false
    if type(a) == "number" and type(b) == "number" then
        Effect.prototype.____constructor(self, modelName, a, b)
    else
        Effect.prototype.____constructor(self, modelName, a, b)
    end
    ____exports.EffectEx:remember(self)
end
function EffectEx.ensureFields(self, obj)
    local f = obj
    if f._destroyed == nil then
        f._destroyed = false
    end
end
function EffectEx.remember(self, obj)
    ____exports.EffectEx:ensureFields(obj)
    ____exports.EffectEx.allEffects[obj.id] = obj
    return obj
end
function EffectEx.create(self, modelName, x, y, z)
    local obj = __TS__New(____exports.EffectEx, modelName, x, y)
    if z ~= nil then
        obj:setZ(z)
    end
    return obj
end
function EffectEx.createAttachment(self, modelName, targetWidget, attachPointName)
    return __TS__New(____exports.EffectEx, modelName, targetWidget, attachPointName)
end
function EffectEx.fromHandle(self, handle, z)
    if not handle then
        return nil
    end
    local id = GetHandleId(handle)
    local existing = ____exports.EffectEx.allEffects[id]
    if existing ~= nil then
        return existing
    end
    local obj = ____exports.EffectEx:getObject(handle)
    if not obj then
        return nil
    end
    ____exports.EffectEx:ensureFields(obj)
    __TS__ObjectAssign(obj, {handle = handle})
    ____exports.EffectEx.allEffects[id] = obj
    if z ~= nil then
        obj:setZ(z)
    end
    return obj
end
function EffectEx.destroyAll(self)
    for id in pairs(____exports.EffectEx.allEffects) do
        local fx = ____exports.EffectEx.allEffects[id]
        if fx ~= nil then
            fx:destroy()
        end
    end
end
function EffectEx.prototype.setXY(self, x, y)
    EXSetEffectXY(self.handle, x, y)
    return self
end
function EffectEx.prototype.setZ(self, z)
    EXSetEffectZ(self.handle, z)
    return self
end
function EffectEx.prototype.setXYZ(self, x, y, z)
    EXSetEffectXY(self.handle, x, y)
    EXSetEffectZ(self.handle, z)
    return self
end
function EffectEx.prototype.moveBy(self, dx, dy, dz)
    if dz == nil then
        dz = 0
    end
    EXSetEffectXY(self.handle, self.x + dx, self.y + dy)
    if dz ~= 0 then
        EXSetEffectZ(self.handle, self.z + dz)
    end
    return self
end
function EffectEx.prototype.setUniformScale(self, scale)
    EXSetEffectSize(self.handle, scale)
    return self
end
function EffectEx.prototype.setSpeed(self, speed)
    EXSetEffectSpeed(self.handle, speed)
    return self
end
function EffectEx.prototype.rotateX(self, angleDeg)
    EXEffectMatRotateX(self.handle, angleDeg)
    return self
end
function EffectEx.prototype.rotateY(self, angleDeg)
    EXEffectMatRotateY(self.handle, angleDeg)
    return self
end
function EffectEx.prototype.rotateZ(self, angleDeg)
    EXEffectMatRotateZ(self.handle, angleDeg)
    return self
end
function EffectEx.prototype.faceByRadians(self, yawRad)
    EXEffectMatReset(self.handle)
    EXEffectMatRotateZ(self.handle, yawRad * 180 / math.pi)
    return self
end
function EffectEx.prototype.scaleXYZ(self, x, y, z)
    EXEffectMatScale(self.handle, x, y, z)
    return self
end
function EffectEx.prototype.resetMatrix(self)
    EXEffectMatReset(self.handle)
    return self
end
function EffectEx.prototype.destroy(self)
    if self._destroyed then
        return
    end
    self._destroyed = true
    __TS__Delete(____exports.EffectEx.allEffects, self.id)
    Effect.prototype.destroy(self)
end
EffectEx.allEffects = {}
__TS__SetDescriptor(
    EffectEx.prototype,
    "isDestroyed",
    {get = function(self)
        return self._destroyed
    end},
    true
)
return ____exports

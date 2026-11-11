local ____exports = {}
function ____exports.c2i(char)
    return (string.unpack(">I4", char))
end
function ____exports.i2c(id)
    return string.pack(">I4", id)
end
function ____exports.FourCC(id)
    return ____exports.c2i(id)
end
--- 世界坐标转屏幕坐标（基于 Antares 的 FastWorld2ScreenTransform，支持任意宽高比）
-- 
-- 在 worldToScreen 的基础上添加宽高比校正，确保在不同屏幕比例下都能正确工作
-- 
-- @param x 世界坐标 X
-- @param y 世界坐标 Y
-- @param z 世界坐标 Z（垂直高度）
-- @param options 可选的偏移配置
-- @returns 屏幕坐标 { screenX, screenY, onScreen }
function ____exports.worldToScreen(x, y, z, options)
    if z == nil then
        z = 0
    end
    if options == nil then
        options = {}
    end
    local eyeX = GetCameraEyePositionX()
    local eyeY = GetCameraEyePositionY()
    local eyeZ = GetCameraEyePositionZ()
    local angleOfAttack = GetCameraField(ConvertCameraField(2))
    local rotation = GetCameraField(ConvertCameraField(5))
    local fieldOfView = GetCameraField(ConvertCameraField(3))
    local cosAttack = math.cos(angleOfAttack)
    local sinAttack = math.sin(angleOfAttack)
    local cosRot = math.cos(rotation)
    local sinRot = math.sin(rotation)
    local yCenterScreenShift = 0.1284 * cosAttack
    local scaleFactor = 0.0524 * fieldOfView * fieldOfView * fieldOfView - 0.0283 * fieldOfView * fieldOfView + 1.061 * fieldOfView
    local cosAttackCosRot = cosAttack * cosRot
    local cosAttackSinRot = cosAttack * sinRot
    local sinAttackCosRot = sinAttack * cosRot
    local sinAttackSinRot = sinAttack * sinRot
    local dx = x - eyeX
    local dy = y - eyeY
    local dz = z - eyeZ
    local xPrime = scaleFactor * (-cosAttackCosRot * dx - cosAttackSinRot * dy - sinAttack * dz)
    local clientWidth = DzGetWindowWidth()
    local clientHeight = DzGetWindowHeight()
    local aspectRatio = 4 / 3
    if clientHeight > 0 then
        aspectRatio = clientWidth / clientHeight
    end
    local baseAspectRatio = 4 / 3
    local aspectRatioCorrection = baseAspectRatio / aspectRatio
    local screenX = 0.4 + (cosRot * dy - sinRot * dx) / xPrime * aspectRatioCorrection
    local screenY = 0.42625 - yCenterScreenShift + (sinAttackCosRot * dx + sinAttackSinRot * dy - cosAttack * dz) / xPrime
    local onScreen = xPrime < 0 and screenX > -0.1333 and screenX < 0.9333 and screenY > 0 and screenY < 0.6
    local finalScreenX = screenX + (options.offsetScreenX or 0)
    local finalScreenY = screenY + (options.offsetScreenY or 0)
    return {screenX = finalScreenX, screenY = finalScreenY, onScreen = onScreen}
end
return ____exports

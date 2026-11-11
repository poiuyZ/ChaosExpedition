local ____lualib = require("lualib_bundle")
local __TS__Class = ____lualib.__TS__Class
local ____exports = {}
local ____logger = require("src.utils.logger")
local createLogger = ____logger.createLogger
local log = createLogger("CameraControl")
--- 镜头控制工具类
-- 提供鼠标滚轮控制镜头距离和宽屏设置功能
____exports.CameraControl = __TS__Class()
local CameraControl = ____exports.CameraControl
CameraControl.name = "CameraControl"
function CameraControl.prototype.____constructor(self)
end
function CameraControl.initMouseControl(self)
    SetCameraField(
        ConvertCameraField(1),
        9999999,
        0
    )
    local mouseTrigger = CreateTrigger()
    DzTriggerRegisterMouseWheelEventByCode(
        mouseTrigger,
        false,
        function()
            ____exports.CameraControl:onWheel()
        end
    )
    log:info("鼠标控制已初始化")
end
function CameraControl.onWheel(self)
    local delta = DzGetWheelDelta()
    if not DzIsMouseOverUI() then
        return
    end
    self.resetCam = true
    log:info("视角角度: " .. tostring(GetCameraField(ConvertCameraField(2))))
    if delta < 0 then
        if self.viewLevel < self.viewLevelMax then
            self.viewLevel = self.viewLevel + 1
        end
    else
        if self.viewLevel > self.viewLevelMin then
            self.viewLevel = self.viewLevel - 1
        end
    end
end
function CameraControl.update(self)
    if self.resetCam then
        SetCameraField(
            ConvertCameraField(1),
            9999999,
            0
        )
        SetCameraField(
            ConvertCameraField(2),
            305,
            0
        )
        SetCameraField(
            ConvertCameraField(0),
            self.viewLevel * 200,
            self.wheelSpeed
        )
        self.resetCam = false
    end
end
function CameraControl.setWideScreen(self)
    self.wideScr = not self.wideScr
    DzEnableWideScreen(self.wideScr)
    log:info("宽屏模式" .. (self.wideScr and "开启" or "关闭"))
    return self.wideScr
end
function CameraControl.rad2Deg(self, rad)
    return rad * 180 / math.pi
end
function CameraControl.degToRad(self, deg)
    return deg * math.pi / 180
end
function CameraControl.getViewLevel(self)
    return self.viewLevel
end
function CameraControl.setViewLevel(self, level)
    if level >= self.viewLevelMin and level <= self.viewLevelMax then
        self.viewLevel = level
        self.resetCam = true
        log:info("视野等级设置为 " .. tostring(level))
    else
        log:warn(((("视野等级必须在 " .. tostring(self.viewLevelMin)) .. "-") .. tostring(self.viewLevelMax)) .. " 之间")
    end
end
function CameraControl.isWideScreen(self)
    return self.wideScr
end
function CameraControl.resetCamera(self)
    self.viewLevel = 8
    self.xAngle = 306
    self.resetCam = true
    log:info("镜头已重置到默认设置")
end
function CameraControl.setWheelSpeed(self, speed)
    if speed >= 0 and speed <= 1 then
        self.wheelSpeed = speed
        log:info("镜头平滑度设置为 " .. tostring(speed))
    else
        log:warn("镜头平滑度必须在 0-1 之间")
    end
end
function CameraControl.getCameraHeight(self)
    return GetCameraEyePositionZ()
end
function CameraControl.getCameraPosition(self)
    return {
        x = GetCameraEyePositionX(),
        y = GetCameraEyePositionY(),
        z = GetCameraEyePositionZ()
    }
end
function CameraControl.getCameraTargetPosition(self)
    return {
        x = GetCameraTargetPositionX(),
        y = GetCameraTargetPositionY(),
        z = GetCameraTargetPositionZ()
    }
end
CameraControl.viewLevel = 8
CameraControl.resetCam = false
CameraControl.wheelSpeed = 0.1
CameraControl.wideScr = false
CameraControl.xAngle = 306
CameraControl.viewLevelMax = 30
CameraControl.viewLevelMin = 4
CameraControl.gameStartXAngle = GetCameraField(ConvertCameraField(2))
CameraControl.unitBloodScale = 1
return ____exports

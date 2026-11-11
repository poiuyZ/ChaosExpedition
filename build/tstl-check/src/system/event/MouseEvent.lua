local ____lualib = require("lualib_bundle")
local __TS__Class = ____lualib.__TS__Class
local __TS__ClassExtends = ____lualib.__TS__ClassExtends
local __TS__New = ____lualib.__TS__New
local ____exports = {}
local ____EventEmitter = require("src.system.event.EventEmitter")
local EventEmitter = ____EventEmitter.EventEmitter
local ____logger = require("src.utils.logger")
local createLogger = ____logger.createLogger
local log = createLogger("MouseEventManager")
--- 鼠标事件管理器
-- 负责管理所有鼠标相关事件的订阅和分发
____exports.MouseEventManager = __TS__Class()
local MouseEventManager = ____exports.MouseEventManager
MouseEventManager.name = "MouseEventManager"
__TS__ClassExtends(MouseEventManager, EventEmitter)
function MouseEventManager.prototype.____constructor(self)
    EventEmitter.prototype.____constructor(self, "MouseEventManager")
    self.initialized = false
    self.nativeTriggers = {}
end
function MouseEventManager.getInstance(self)
    if not ____exports.MouseEventManager.instance then
        ____exports.MouseEventManager.instance = __TS__New(____exports.MouseEventManager)
    end
    return ____exports.MouseEventManager.instance
end
function MouseEventManager.prototype.initialize(self)
    if self.initialized then
        return
    end
    self:registerMouseButtonEvent(1, true)
    self:registerMouseButtonEvent(1, false)
    self:registerMouseButtonEvent(2, true)
    self:registerMouseButtonEvent(2, false)
    self:registerMouseMoveEvent()
    self:registerMouseWheelEvent()
    self.initialized = true
    log:info("初始化完成")
end
function MouseEventManager.prototype.registerMouseButtonEvent(self, button, isDown)
    local trig = CreateTrigger()
    local ____self_nativeTriggers_0 = self.nativeTriggers
    ____self_nativeTriggers_0[#____self_nativeTriggers_0 + 1] = trig
    local eventType = isDown and "mouse:down" or "mouse:up"
    DzTriggerRegisterMouseEventByCode(
        trig,
        button,
        isDown and 1 or 0,
        false,
        function()
            local data = self:createMouseEventData(button, eventType)
            self:emit(eventType, data)
            self:emit(
                (eventType .. ":") .. tostring(button),
                data
            )
        end
    )
end
function MouseEventManager.prototype.registerMouseMoveEvent(self)
    local trig = CreateTrigger()
    local ____self_nativeTriggers_1 = self.nativeTriggers
    ____self_nativeTriggers_1[#____self_nativeTriggers_1 + 1] = trig
    DzTriggerRegisterMouseMoveEventByCode(
        trig,
        false,
        function()
            local data = self:createMouseEventData(0, "mouse:move")
            self:emit("mouse:move", data)
        end
    )
end
function MouseEventManager.prototype.registerMouseWheelEvent(self)
    local trig = CreateTrigger()
    local ____self_nativeTriggers_2 = self.nativeTriggers
    ____self_nativeTriggers_2[#____self_nativeTriggers_2 + 1] = trig
    DzTriggerRegisterMouseWheelEventByCode(
        trig,
        false,
        function()
            local data = self:createMouseEventData(0, "mouse:wheel")
            data.wheelDelta = DzGetWheelDelta()
            self:emit("mouse:wheel", data)
        end
    )
end
function MouseEventManager.prototype.createMouseEventData(self, button, ____type)
    return {
        button = button,
        screenX = DzGetMouseX(),
        screenY = DzGetMouseY(),
        terrainX = DzGetMouseTerrainX(),
        terrainY = DzGetMouseTerrainY(),
        isOverUI = DzIsMouseOverUI(),
        type = ____type
    }
end
function MouseEventManager.prototype.onMouseDown(self, handler, button, options)
    local eventName = button and ("mouse:down" .. ":") .. tostring(button) or "mouse:down"
    return self:on(eventName, handler, options)
end
function MouseEventManager.prototype.onMouseUp(self, handler, button, options)
    local eventName = button and ("mouse:up" .. ":") .. tostring(button) or "mouse:up"
    return self:on(eventName, handler, options)
end
function MouseEventManager.prototype.onMouseMove(self, handler, options)
    return self:on("mouse:move", handler, options)
end
function MouseEventManager.prototype.onMouseWheel(self, handler, options)
    return self:on("mouse:wheel", handler, options)
end
function MouseEventManager.prototype.getMousePosition(self)
    return {
        screenX = DzGetMouseX(),
        screenY = DzGetMouseY(),
        terrainX = DzGetMouseTerrainX(),
        terrainY = DzGetMouseTerrainY()
    }
end
function MouseEventManager.prototype.isMouseOverUI(self)
    return DzIsMouseOverUI()
end
function MouseEventManager.prototype.destroy(self)
    EventEmitter.prototype.destroy(self)
    for ____, trig in ipairs(self.nativeTriggers) do
        DestroyTrigger(trig)
    end
    self.nativeTriggers = {}
    self.initialized = false
end
--- 快捷访问鼠标事件管理器
____exports.mouseEvents = ____exports.MouseEventManager:getInstance()
return ____exports

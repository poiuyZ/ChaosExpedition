local ____lualib = require("lualib_bundle")
local __TS__Class = ____lualib.__TS__Class
local __TS__ArrayForEach = ____lualib.__TS__ArrayForEach
local ____exports = {}
local ____events = require("src.constants.frame.events")
local FRAMEEVENT_CONTROL_CLICK = ____events.FRAMEEVENT_CONTROL_CLICK
local FRAMEEVENT_MOUSE_ENTER = ____events.FRAMEEVENT_MOUSE_ENTER
local FRAMEEVENT_MOUSE_LEAVE = ____events.FRAMEEVENT_MOUSE_LEAVE
local FRAMEEVENT_MOUSE_UP = ____events.FRAMEEVENT_MOUSE_UP
local FRAMEEVENT_MOUSE_WHEEL = ____events.FRAMEEVENT_MOUSE_WHEEL
local FRAMEEVENT_CHECKBOX_CHECKED = ____events.FRAMEEVENT_CHECKBOX_CHECKED
local FRAMEEVENT_EDITBOX_TEXT_CHANGED = ____events.FRAMEEVENT_EDITBOX_TEXT_CHANGED
--- Frame事件工具类
-- 提供便捷的事件绑定方法
____exports.FrameEventUtils = __TS__Class()
local FrameEventUtils = ____exports.FrameEventUtils
FrameEventUtils.name = "FrameEventUtils"
function FrameEventUtils.prototype.____constructor(self)
end
function FrameEventUtils.bindClickEvent(self, frame, handler)
    DzFrameSetScriptByCode(frame.handle, FRAMEEVENT_CONTROL_CLICK, handler, true)
end
function FrameEventUtils.bindMouseEnterEvent(self, frame, handler)
    DzFrameSetScriptByCode(frame.handle, FRAMEEVENT_MOUSE_ENTER, handler, true)
end
function FrameEventUtils.bindMouseLeaveEvent(self, frame, handler)
    DzFrameSetScriptByCode(frame.handle, FRAMEEVENT_MOUSE_LEAVE, handler, true)
end
function FrameEventUtils.bindMouseUpEvent(self, frame, handler)
    DzFrameSetScriptByCode(frame.handle, FRAMEEVENT_MOUSE_UP, handler, true)
end
function FrameEventUtils.bindMouseWheelEvent(self, frame, handler)
    DzFrameSetScriptByCode(frame.handle, FRAMEEVENT_MOUSE_WHEEL, handler, true)
end
function FrameEventUtils.bindCheckboxCheckedEvent(self, frame, handler)
    DzFrameSetScriptByCode(frame.handle, FRAMEEVENT_CHECKBOX_CHECKED, handler, true)
end
function FrameEventUtils.bindTextChangedEvent(self, frame, handler)
    DzFrameSetScriptByCode(frame.handle, FRAMEEVENT_EDITBOX_TEXT_CHANGED, handler, true)
end
function FrameEventUtils.bindEvents(self, frame, events)
    if events.onClick then
        self:bindClickEvent(frame, events.onClick)
    end
    if events.onMouseEnter then
        self:bindMouseEnterEvent(frame, events.onMouseEnter)
    end
    if events.onMouseLeave then
        self:bindMouseLeaveEvent(frame, events.onMouseLeave)
    end
    if events.onMouseUp then
        self:bindMouseUpEvent(frame, events.onMouseUp)
    end
    if events.onMouseWheel then
        self:bindMouseWheelEvent(frame, events.onMouseWheel)
    end
    if events.onCheckboxChecked then
        self:bindCheckboxCheckedEvent(frame, events.onCheckboxChecked)
    end
    if events.onTextChanged then
        self:bindTextChangedEvent(frame, events.onTextChanged)
    end
end
function FrameEventUtils.unbindAllEvents(self, frame)
    local events = {
        FRAMEEVENT_CONTROL_CLICK,
        FRAMEEVENT_MOUSE_ENTER,
        FRAMEEVENT_MOUSE_LEAVE,
        FRAMEEVENT_MOUSE_UP,
        FRAMEEVENT_MOUSE_WHEEL,
        FRAMEEVENT_CHECKBOX_CHECKED,
        FRAMEEVENT_EDITBOX_TEXT_CHANGED
    }
    local function emptyHandler()
    end
    __TS__ArrayForEach(
        events,
        function(____, eventType)
            DzFrameSetScriptByCode(frame.handle, eventType, emptyHandler, true)
        end
    )
end
return ____exports

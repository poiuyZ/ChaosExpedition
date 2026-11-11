local ____lualib = require("lualib_bundle")
local __TS__Class = ____lualib.__TS__Class
local __TS__New = ____lualib.__TS__New
local Map = ____lualib.Map
local ____exports = {}
local _____2A = require("lua_modules.@eiriksgata.wc3ts.src.index")
local Frame = _____2A.Frame
local FRAME_ALIGN_CENTER = _____2A.FRAME_ALIGN_CENTER
local ____frame = require("src.constants.frame.index")
local FrameEventUtils = ____frame.FrameEventUtils
local ____logger = require("src.utils.logger")
local createLogger = ____logger.createLogger
local log = createLogger("FDFButtonBuilder")
--- 按钮模板类型枚举
____exports.ButtonTemplateType = ____exports.ButtonTemplateType or ({})
____exports.ButtonTemplateType.STANDARD = "StandardButtonTemplate"
____exports.ButtonTemplateType.ICON = "IconButtonTemplate"
____exports.ButtonTemplateType.LARGE = "LargeButtonTemplate"
____exports.ButtonTemplateType.SMALL = "SmallButtonTemplate"
____exports.ButtonTemplateType.SCRIPT = "ScriptButtonTemplate"
--- FDF按钮创建工具类
-- 用于创建和管理基于FDF模板的按钮
____exports.FDFButtonBuilder = __TS__Class()
local FDFButtonBuilder = ____exports.FDFButtonBuilder
FDFButtonBuilder.name = "FDFButtonBuilder"
function FDFButtonBuilder.prototype.____constructor(self)
    self.buttonFrame = nil
    self.textFrame = nil
    self.iconFrame = nil
    self.hotkeyFrame = nil
end
function FDFButtonBuilder.createButton(self, name, config, events)
    return __TS__New(____exports.FDFButtonBuilder):build(name, ____exports.ButtonTemplateType.STANDARD, config, events)
end
function FDFButtonBuilder.createIconButton(self, name, config, events)
    return __TS__New(____exports.FDFButtonBuilder):build(name, ____exports.ButtonTemplateType.ICON, config, events)
end
function FDFButtonBuilder.createLargeButton(self, name, config, events)
    return __TS__New(____exports.FDFButtonBuilder):build(name, ____exports.ButtonTemplateType.LARGE, config, events)
end
function FDFButtonBuilder.createSmallButton(self, name, config, events)
    return __TS__New(____exports.FDFButtonBuilder):build(name, ____exports.ButtonTemplateType.SMALL, config, events)
end
function FDFButtonBuilder.prototype.build(self, name, template, config, events)
    local parent = config.parent or Frame:fromHandle(DzGetGameUI())
    local buttonFrame
    if template == ____exports.ButtonTemplateType.SCRIPT then
        buttonFrame = Frame:createType(
            name,
            parent,
            0,
            "BACKDROP",
            template
        )
    elseif template == ____exports.ButtonTemplateType.ICON then
        buttonFrame = Frame:createType(
            name,
            parent,
            0,
            "BUTTON",
            template
        )
    else
        buttonFrame = Frame:createType(
            name,
            parent,
            0,
            "GLUETEXTBUTTON",
            template
        )
    end
    self.buttonFrame = buttonFrame or nil
    if not self.buttonFrame then
        log:error("Failed to create button: " .. name)
        return self
    end
    if config.x ~= nil and config.y ~= nil then
        local anchor = config.anchor or FRAME_ALIGN_CENTER
        self.buttonFrame:setAbsPoint(anchor, config.x, config.y)
    end
    if config.width ~= nil and config.height ~= nil then
        self.buttonFrame:setSize(config.width, config.height)
    end
    if config.text then
        self:setText(config.text)
    end
    if config.icon and template == ____exports.ButtonTemplateType.ICON then
        self:setIcon(config.icon)
    end
    if config.hotkey then
        self:setHotkey(config.hotkey)
    end
    if config.tooltip then
        self:setTooltip(config.tooltip)
    end
    if config.visible ~= nil then
        self:setVisible(config.visible)
    end
    if config.enabled ~= nil then
        self:setEnabled(config.enabled)
    end
    if events then
        self:bindEvents(events)
    end
    return self
end
function FDFButtonBuilder.prototype.setText(self, text)
    if not self.buttonFrame then
        return self
    end
    self.buttonFrame:setText(text)
    return self
end
function FDFButtonBuilder.prototype.setIcon(self, iconPath)
    if self.buttonFrame == nil then
        return self
    end
    local iconHandle = DzFrameFindByName("IconButtonIcon", 0)
    if iconHandle ~= nil and iconHandle ~= nil then
        DzFrameSetTexture(iconHandle, iconPath, 0)
    end
    return self
end
function FDFButtonBuilder.prototype.setHotkey(self, hotkey)
    if self.buttonFrame == nil then
        return self
    end
    local hotkeyHandle = DzFrameFindByName("ButtonHotkey", 0)
    if hotkeyHandle ~= nil and hotkeyHandle ~= nil then
        DzFrameSetText(hotkeyHandle, hotkey)
    end
    return self
end
function FDFButtonBuilder.prototype.setTooltip(self, tooltip)
    if not self.buttonFrame then
        return self
    end
    DzFrameSetTooltip(
        self.buttonFrame.handle,
        DzCreateFrameByTagName(
            "TEXT",
            "",
            self.buttonFrame.handle,
            "",
            0
        )
    )
    return self
end
function FDFButtonBuilder.prototype.setVisible(self, visible)
    if not self.buttonFrame then
        return self
    end
    self.buttonFrame:setVisible(visible)
    return self
end
function FDFButtonBuilder.prototype.setEnabled(self, enabled)
    if not self.buttonFrame then
        return self
    end
    self.buttonFrame:setEnabled(enabled)
    return self
end
function FDFButtonBuilder.prototype.setPosition(self, x, y, anchor)
    if not self.buttonFrame then
        return self
    end
    local alignType = anchor or FRAME_ALIGN_CENTER
    self.buttonFrame:setAbsPoint(alignType, x, y)
    return self
end
function FDFButtonBuilder.prototype.setSize(self, width, height)
    if not self.buttonFrame then
        return self
    end
    self.buttonFrame:setSize(width, height)
    return self
end
function FDFButtonBuilder.prototype.bindEvents(self, events)
    if not self.buttonFrame then
        return self
    end
    FrameEventUtils:bindEvents(self.buttonFrame, {onClick = events.onClick, onMouseEnter = events.onMouseEnter, onMouseLeave = events.onMouseLeave})
    return self
end
function FDFButtonBuilder.prototype.getFrame(self)
    return self.buttonFrame
end
function FDFButtonBuilder.prototype.destroy(self)
    if self.buttonFrame then
        self.buttonFrame:destroy()
        self.buttonFrame = nil
    end
    self.textFrame = nil
    self.iconFrame = nil
    self.hotkeyFrame = nil
end
--- 按钮组管理器
-- 用于批量管理多个按钮
____exports.ButtonGroup = __TS__Class()
local ButtonGroup = ____exports.ButtonGroup
ButtonGroup.name = "ButtonGroup"
function ButtonGroup.prototype.____constructor(self)
    self.buttons = __TS__New(Map)
end
function ButtonGroup.prototype.addButton(self, id, button)
    self.buttons:set(id, button)
    return self
end
function ButtonGroup.prototype.getButton(self, id)
    return self.buttons:get(id)
end
function ButtonGroup.prototype.removeButton(self, id)
    local button = self.buttons:get(id)
    if button then
        button:destroy()
        self.buttons:delete(id)
        return true
    end
    return false
end
function ButtonGroup.prototype.showAll(self)
    self.buttons:forEach(function(____, button) return button:setVisible(true) end)
    return self
end
function ButtonGroup.prototype.hideAll(self)
    self.buttons:forEach(function(____, button) return button:setVisible(false) end)
    return self
end
function ButtonGroup.prototype.enableAll(self)
    self.buttons:forEach(function(____, button) return button:setEnabled(true) end)
    return self
end
function ButtonGroup.prototype.disableAll(self)
    self.buttons:forEach(function(____, button) return button:setEnabled(false) end)
    return self
end
function ButtonGroup.prototype.destroyAll(self)
    self.buttons:forEach(function(____, button) return button:destroy() end)
    self.buttons:clear()
end
function ButtonGroup.prototype.size(self)
    return self.buttons.size
end
return ____exports

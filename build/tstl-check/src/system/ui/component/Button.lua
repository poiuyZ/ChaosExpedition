local ____lualib = require("lualib_bundle")
local __TS__Class = ____lualib.__TS__Class
local __TS__New = ____lualib.__TS__New
local ____exports = {}
local _____2A = require("lua_modules.@eiriksgata.wc3ts.src.index")
local Frame = _____2A.Frame
local FRAME_ALIGN_LEFT_TOP = _____2A.FRAME_ALIGN_LEFT_TOP
local FRAME_ALIGN_RIGHT_BOTTOM = _____2A.FRAME_ALIGN_RIGHT_BOTTOM
local ____ScreenCoordinates = require("src.system.ui.ScreenCoordinates")
local ScreenCoordinates = ____ScreenCoordinates.ScreenCoordinates
local ____UILayout = require("src.system.ui.UILayout")
local UILayout = ____UILayout.UILayout
local ____utils = require("src.constants.frame.utils")
local FrameEventUtils = ____utils.FrameEventUtils
local ____MouseEvent = require("src.system.event.MouseEvent")
local MouseEventManager = ____MouseEvent.MouseEventManager
local ____Text = require("src.system.ui.component.Text")
local Text = ____Text.Text
local TextAlign = ____Text.TextAlign
local VerticalAlign = ____Text.VerticalAlign
local ____preset = require("src.constants.ui.preset")
local UIBackgrounds = ____preset.UIBackgrounds
local ____logger = require("src.utils.logger")
local createLogger = ____logger.createLogger
local log = createLogger("Button")
--- FDF 模板预设
____exports.ButtonTemplates = {
    NORMAL_UP = "normal_button_up",
    NORMAL_DOWN = "normal_button_down",
    NORMAL_DIALOG = "normal_dialog",
    TOOLTIP = "tooltips",
    TOOLTIP2 = "tooltips2",
    BUTTON1 = "button1"
}
--- Button类 - 使用 Text 组件的按钮
-- 包含: 背景框架(Backdrop) + Text组件 + 按钮框架(Button)
____exports.Button = __TS__Class()
local Button = ____exports.Button
Button.name = "Button"
function Button.prototype.____constructor(self, label, x, y, width, height, origin)
    if width == nil then
        width = 120
    end
    if height == nil then
        height = 40
    end
    if origin == nil then
        origin = ScreenCoordinates.ORIGIN_TOP_LEFT
    end
    self.backdropFrame = nil
    self.textComponent = nil
    self.buttonFrame = nil
    self.onClick = nil
    self.onHover = nil
    self.onLeave = nil
    self.isEnabled = true
    self.isVisible = true
    self.texture = UIBackgrounds.BLACK_TRANSPARENT
    self.textAlignment = TextAlign.CENTER
    self.verticalAlignment = VerticalAlign.MIDDLE
    self.textColor = "FFFFFF"
    self.tooltip = ""
    self.origin = ScreenCoordinates.ORIGIN_TOP_LEFT
    self.useTemplate = false
    self.templateName = ""
    self.isDraggable = false
    self.isDragging = false
    self.dragTimer = nil
    self.dragOffsetX = 0
    self.dragOffsetY = 0
    self.dragMouseDownId = -1
    self.dragMouseUpId = -1
    self.isMouseOver = false
    self.onDragStart = nil
    self.onDragEnd = nil
    self.onDragging = nil
    self.label = label
    self.pixelX = x
    self.pixelY = y
    self.pixelWidth = width
    self.pixelHeight = height
    self.origin = origin
end
function Button.createWithPreset(self, label, x, y, sizePreset, origin, parent)
    if sizePreset == nil then
        sizePreset = "MEDIUM"
    end
    if origin == nil then
        origin = ScreenCoordinates.ORIGIN_TOP_LEFT
    end
    local size = UILayout.BUTTON_SIZES[sizePreset]
    local button = __TS__New(
        ____exports.Button,
        label,
        x,
        y,
        size.width,
        size.height,
        origin
    )
    button:create(parent)
    return button
end
function Button.createAtPresetPosition(self, label, positionPreset, sizePreset, centered, parent)
    if sizePreset == nil then
        sizePreset = "MEDIUM"
    end
    if centered == nil then
        centered = true
    end
    local position = ScreenCoordinates:getPresetPosition(positionPreset)
    local size = UILayout.BUTTON_SIZES[sizePreset]
    local x = position.x
    local y = position.y
    if centered then
        x = position.x - size.width / 2
        y = position.y - size.height / 2
    end
    local button = __TS__New(
        ____exports.Button,
        label,
        x,
        y,
        size.width,
        size.height
    )
    button:create(parent)
    return button
end
function Button.createCentered(self, label, sizePreset, parent)
    if sizePreset == nil then
        sizePreset = "MEDIUM"
    end
    return ____exports.Button:createAtPresetPosition(
        label,
        "CENTER",
        sizePreset,
        true,
        parent
    )
end
function Button.createWithTemplate(self, label, x, y, width, height, template, origin, parent)
    if origin == nil then
        origin = ScreenCoordinates.ORIGIN_TOP_LEFT
    end
    local button = __TS__New(
        ____exports.Button,
        label,
        x,
        y,
        width,
        height,
        origin
    )
    button.useTemplate = true
    button.templateName = template
    button:create(parent)
    return button
end
function Button.createWithTemplatePreset(self, label, x, y, width, height, templatePreset, origin, parent)
    if width == nil then
        width = 120
    end
    if height == nil then
        height = 40
    end
    if templatePreset == nil then
        templatePreset = "NORMAL_UP"
    end
    if origin == nil then
        origin = ScreenCoordinates.ORIGIN_TOP_LEFT
    end
    return ____exports.Button:createWithTemplate(
        label,
        x,
        y,
        width,
        height,
        ____exports.ButtonTemplates[templatePreset],
        origin,
        parent
    )
end
function Button.createCenteredWithTemplate(self, label, templatePreset, sizePreset, parent)
    if templatePreset == nil then
        templatePreset = "NORMAL_UP"
    end
    if sizePreset == nil then
        sizePreset = "MEDIUM"
    end
    local size = UILayout.BUTTON_SIZES[sizePreset]
    local centerX = (ScreenCoordinates.STANDARD_WIDTH - size.width) / 2
    local centerY = (ScreenCoordinates.STANDARD_HEIGHT - size.height) / 2
    return ____exports.Button:createWithTemplate(
        label,
        centerX,
        centerY,
        size.width,
        size.height,
        ____exports.ButtonTemplates[templatePreset],
        ScreenCoordinates.ORIGIN_TOP_LEFT,
        parent
    )
end
function Button.prototype.create(self, parent)
    if self.backdropFrame then
        log:info("already created")
        return
    end
    local parentFrame = parent or Frame:fromHandle(DzGetGameUI())
    local wc3Pos = ScreenCoordinates:pixelToWC3(self.pixelX, self.pixelY, self.origin)
    local wc3Width = self.pixelWidth / ScreenCoordinates.STANDARD_WIDTH * ScreenCoordinates.WC3_SCREEN_WIDTH
    local wc3Height = self.pixelHeight / ScreenCoordinates.STANDARD_HEIGHT * ScreenCoordinates.WC3_SCREEN_HEIGHT
    if self.useTemplate and self.templateName then
        self.backdropFrame = Frame:createType(
            "ButtonBackdrop_" .. tostring(os.time()),
            parentFrame,
            0,
            "BACKDROP",
            self.templateName
        ) or nil
        log:info("Creating button with FDF template: " .. self.templateName)
    else
        self.backdropFrame = Frame:createType(
            "ButtonBackdrop_" .. tostring(os.time()),
            parentFrame,
            0,
            "BACKDROP",
            ""
        ) or nil
    end
    if not self.backdropFrame then
        log:error("Failed to create backdrop frame")
        return
    end
    local rightX = wc3Pos.x + wc3Width
    local bottomY = wc3Pos.y - wc3Height
    self.backdropFrame:setAbsPoint(FRAME_ALIGN_LEFT_TOP, wc3Pos.x, wc3Pos.y):setAbsPoint(FRAME_ALIGN_RIGHT_BOTTOM, rightX, bottomY)
    if not self.useTemplate then
        self.backdropFrame:setTexture(self.texture, 0, true)
    end
    self.textComponent = __TS__New(
        Text,
        self.label,
        self.pixelX,
        self.pixelY,
        self.pixelWidth,
        self.pixelHeight,
        self.origin
    )
    self.textComponent:setColor(self.textColor):setAlignment(self.textAlignment, self.verticalAlignment)
    self.textComponent:create(self.backdropFrame)
    self.buttonFrame = Frame:createType(
        "ButtonFrame_" .. tostring(os.time()),
        self.backdropFrame,
        0,
        "BUTTON",
        ""
    ) or nil
    if not self.buttonFrame then
        log:error("Failed to create button frame")
        return
    end
    self.buttonFrame:setAllPoints(self.backdropFrame)
    self:setVisible(self.isVisible)
    self:setEnabled(self.isEnabled)
    self:setupEventListeners()
    if self.useTemplate and self.backdropFrame then
        self.backdropFrame:setVisible(true)
        self.backdropFrame:setAlpha(255)
    end
    log:info(("\"" .. self.label) .. "\" created successfully with Text component")
end
function Button.prototype.setOnClick(self, callback)
    self.onClick = callback
    if self.buttonFrame then
        self:setupEventListeners()
    end
    return self
end
function Button.prototype.setOnHover(self, callback)
    self.onHover = callback
    if self.buttonFrame then
        self:setupEventListeners()
    end
    return self
end
function Button.prototype.setOnLeave(self, callback)
    self.onLeave = callback
    if self.buttonFrame then
        self:setupEventListeners()
    end
    return self
end
function Button.prototype.setText(self, text)
    self.label = text
    if self.textComponent then
        self.textComponent:setText(text)
    end
    return self
end
function Button.prototype.getText(self)
    return self.label
end
function Button.prototype.setTextColor(self, hexColor)
    self.textColor = hexColor
    if self.textComponent then
        self.textComponent:setColor(hexColor)
    end
    return self
end
function Button.prototype.setTextAlignment(self, alignment, verticalAlign)
    self.textAlignment = alignment
    if verticalAlign ~= nil then
        self.verticalAlignment = verticalAlign
    end
    if self.textComponent then
        self.textComponent:setAlignment(self.textAlignment, self.verticalAlignment)
    end
    return self
end
function Button.prototype.setPosition(self, x, y)
    self.pixelX = x
    self.pixelY = y
    if self.backdropFrame then
        local wc3Pos = ScreenCoordinates:pixelToWC3(self.pixelX, self.pixelY, self.origin)
        local wc3Width = self.pixelWidth / ScreenCoordinates.STANDARD_WIDTH * ScreenCoordinates.WC3_SCREEN_WIDTH
        local wc3Height = self.pixelHeight / ScreenCoordinates.STANDARD_HEIGHT * ScreenCoordinates.WC3_SCREEN_HEIGHT
        local rightX = wc3Pos.x + wc3Width
        local bottomY = wc3Pos.y - wc3Height
        self.backdropFrame:setAbsPoint(FRAME_ALIGN_LEFT_TOP, wc3Pos.x, wc3Pos.y):setAbsPoint(FRAME_ALIGN_RIGHT_BOTTOM, rightX, bottomY)
    end
    if self.textComponent then
        self.textComponent:setPosition(x, y)
    end
    return self
end
function Button.prototype.setSize(self, width, height)
    self.pixelWidth = width
    self.pixelHeight = height
    if self.backdropFrame then
        local wc3Pos = ScreenCoordinates:pixelToWC3(self.pixelX, self.pixelY, self.origin)
        local wc3Width = self.pixelWidth / ScreenCoordinates.STANDARD_WIDTH * ScreenCoordinates.WC3_SCREEN_WIDTH
        local wc3Height = self.pixelHeight / ScreenCoordinates.STANDARD_HEIGHT * ScreenCoordinates.WC3_SCREEN_HEIGHT
        local rightX = wc3Pos.x + wc3Width
        local bottomY = wc3Pos.y - wc3Height
        self.backdropFrame:setAbsPoint(FRAME_ALIGN_LEFT_TOP, wc3Pos.x, wc3Pos.y):setAbsPoint(FRAME_ALIGN_RIGHT_BOTTOM, rightX, bottomY)
    end
    if self.textComponent then
        self.textComponent:setSize(width, height)
    end
    return self
end
function Button.prototype.setTexture(self, texturePath)
    self.texture = texturePath
    if self.backdropFrame then
        if self.useTemplate then
            log:warn("Setting texture on a template-based button may override template styles")
        end
        self.backdropFrame:setTexture(texturePath, 0, true)
    end
    return self
end
function Button.prototype.setTexturePreset(self, preset)
    return self:setTexture(UIBackgrounds[preset])
end
function Button.prototype.setBackdropAlpha(self, alpha)
    if self.backdropFrame then
        self.backdropFrame:setAlpha(alpha)
    end
    return self
end
function Button.prototype.hideBackdrop(self)
    return self:setTexture("")
end
function Button.prototype.setBackground(self, path)
    return self:setTexture(path)
end
function Button.prototype.setTooltip(self, tooltip)
    self.tooltip = tooltip
    return self
end
function Button.prototype.setEnabled(self, enabled)
    self.isEnabled = enabled
    if self.buttonFrame then
        if enabled then
            local ____opt_0 = self.backdropFrame
            if ____opt_0 ~= nil then
                ____opt_0:setAlpha(255)
            end
            local ____opt_2 = self.textComponent
            if ____opt_2 ~= nil then
                ____opt_2:setAlpha(255)
            end
        else
            local ____opt_4 = self.backdropFrame
            if ____opt_4 ~= nil then
                ____opt_4:setAlpha(128)
            end
            local ____opt_6 = self.textComponent
            if ____opt_6 ~= nil then
                ____opt_6:setAlpha(128)
            end
        end
    end
    return self
end
function Button.prototype.setVisible(self, visible)
    self.isVisible = visible
    if self.backdropFrame then
        self.backdropFrame:setVisible(visible)
    end
    if self.textComponent then
        self.textComponent:setVisible(visible)
    end
    if self.buttonFrame then
        self.buttonFrame:setVisible(visible)
    end
    return self
end
function Button.prototype.getEnabled(self)
    return self.isEnabled
end
function Button.prototype.getVisible(self)
    return self.isVisible
end
function Button.prototype.getBackdropFrame(self)
    return self.backdropFrame
end
function Button.prototype.getTextComponent(self)
    return self.textComponent
end
function Button.prototype.getTextFrame(self)
    local ____opt_8 = self.textComponent
    return ____opt_8 and ____opt_8:getTextFrame() or nil
end
function Button.prototype.getButtonFrame(self)
    return self.buttonFrame
end
function Button.prototype.getPosition(self)
    return {x = self.pixelX, y = self.pixelY}
end
function Button.prototype.getSize(self)
    return {width = self.pixelWidth, height = self.pixelHeight}
end
function Button.prototype.getMainFrame(self)
    return self.backdropFrame or self.buttonFrame
end
function Button.prototype.getComponentInfo(self)
    return {
        frame = self:getMainFrame(),
        x = self.pixelX,
        y = self.pixelY,
        width = self.pixelWidth,
        height = self.pixelHeight
    }
end
function Button.prototype.isUsingTemplate(self)
    return self.useTemplate
end
function Button.prototype.getTemplateName(self)
    return self.templateName
end
function Button.prototype.destroy(self)
    if self.isDragging then
        self:endDrag()
    end
    if self.buttonFrame then
        self.buttonFrame:destroy()
        self.buttonFrame = nil
    end
    if self.textComponent then
        self.textComponent:destroy()
        self.textComponent = nil
    end
    if self.backdropFrame then
        self.backdropFrame:destroy()
        self.backdropFrame = nil
    end
    self.onClick = nil
    self.onHover = nil
    self.onLeave = nil
    self.onDragStart = nil
    self.onDragEnd = nil
    self.onDragging = nil
end
function Button.prototype.setupEventListeners(self)
    if not self.buttonFrame then
        return
    end
    FrameEventUtils:bindEvents(
        self.buttonFrame,
        {
            onClick = function()
                if not self.isDragging and not self.isDraggable and self.isEnabled and self.onClick then
                    self.onClick()
                end
            end,
            onMouseEnter = function()
                self.isMouseOver = true
                if self.isEnabled and self.onHover then
                    self.onHover()
                end
            end,
            onMouseLeave = function()
                self.isMouseOver = false
                if self.isEnabled and self.onLeave and not self.isDragging then
                    self.onLeave()
                end
            end
        }
    )
end
function Button.prototype.click(self)
    if self.isEnabled and self.onClick then
        self.onClick()
        log:info(("\"" .. self.label) .. "\" clicked")
    end
end
function Button.prototype.addHoverEffect(self, hoverAlpha, normalAlpha)
    if hoverAlpha == nil then
        hoverAlpha = 200
    end
    if normalAlpha == nil then
        normalAlpha = 255
    end
    self:setOnHover(function()
        if self.backdropFrame and self.isEnabled then
            self.backdropFrame:setAlpha(hoverAlpha)
        end
    end)
    self:setOnLeave(function()
        if self.backdropFrame and self.isEnabled then
            self.backdropFrame:setAlpha(normalAlpha)
        end
    end)
    return self
end
function Button.prototype.configure(self, config)
    if config.text ~= nil then
        self:setText(config.text)
    end
    if config.textColor ~= nil then
        self:setTextColor(config.textColor)
    end
    if config.texture ~= nil then
        self:setTexture(config.texture)
    end
    if config.onClick ~= nil then
        self:setOnClick(config.onClick)
    end
    if config.onHover ~= nil then
        self:setOnHover(config.onHover)
    end
    if config.onLeave ~= nil then
        self:setOnLeave(config.onLeave)
    end
    if config.enabled ~= nil then
        self:setEnabled(config.enabled)
    end
    if config.visible ~= nil then
        self:setVisible(config.visible)
    end
    if config.fontSize ~= nil then
        self:setFontSize(config.fontSize)
    end
    if config.fontPath ~= nil and self.textComponent then
        self.textComponent:setFont(config.fontPath)
    end
    if config.padding ~= nil and self.textComponent then
        self.textComponent:setPadding(config.padding)
    end
    return self
end
function Button.prototype.setFontSize(self, size)
    if self.textComponent then
        self.textComponent:setFontSize(size)
    end
    return self
end
function Button.prototype.setFontSizePixels(self, pixelSize)
    if self.textComponent then
        self.textComponent:setFontSizePixels(pixelSize)
    end
    return self
end
function Button.prototype.setFont(self, fontPath)
    if self.textComponent then
        self.textComponent:setFont(fontPath)
    end
    return self
end
function Button.prototype.setTextPadding(self, padding)
    if self.textComponent then
        self.textComponent:setPadding(padding)
    end
    return self
end
function Button.prototype.setTextPaddingTRBL(self, top, right, bottom, left)
    if self.textComponent then
        self.textComponent:setPaddingTRBL(top, right, bottom, left)
    end
    return self
end
function Button.prototype.centerText(self)
    self.textAlignment = TextAlign.CENTER
    self.verticalAlignment = VerticalAlign.MIDDLE
    if self.textComponent then
        self.textComponent:center()
    end
    return self
end
function Button.prototype.alignTextLeft(self)
    self.textAlignment = TextAlign.LEFT
    if self.textComponent then
        self.textComponent:alignLeft()
    end
    return self
end
function Button.prototype.alignTextRight(self)
    self.textAlignment = TextAlign.RIGHT
    if self.textComponent then
        self.textComponent:alignRight()
    end
    return self
end
function Button.prototype.setDraggable(self, draggable)
    if self.isDraggable == draggable then
        return self
    end
    self.isDraggable = draggable
    if draggable then
        self:setupDragEventListeners()
    else
        self:cleanupDragEventListeners()
    end
    return self
end
function Button.prototype.getDraggable(self)
    return self.isDraggable
end
function Button.prototype.getIsDragging(self)
    return self.isDragging
end
function Button.prototype.setOnDragStart(self, callback)
    self.onDragStart = callback
    return self
end
function Button.prototype.setOnDragEnd(self, callback)
    self.onDragEnd = callback
    return self
end
function Button.prototype.setOnDragging(self, callback)
    self.onDragging = callback
    return self
end
function Button.prototype.getMousePixelX(self)
    local windowWidth = DzGetWindowWidth()
    local mouseRelativeX = DzGetMouseXRelative()
    return mouseRelativeX / windowWidth * ScreenCoordinates.STANDARD_WIDTH
end
function Button.prototype.getMousePixelY(self)
    local windowHeight = DzGetWindowHeight()
    local mouseRelativeY = DzGetMouseYRelative()
    return mouseRelativeY / windowHeight * ScreenCoordinates.STANDARD_HEIGHT
end
function Button.prototype.startDrag(self)
    if not self.isDraggable or self.isDragging then
        return
    end
    self.isDragging = true
    local currentMouseX = self:getMousePixelX()
    local currentMouseY = self:getMousePixelY()
    self.dragOffsetX = currentMouseX - self.pixelX
    self.dragOffsetY = currentMouseY - self.pixelY
    log:info(((((((("Drag started at mouse(" .. tostring(currentMouseX)) .. ", ") .. tostring(currentMouseY)) .. "), offset(") .. tostring(self.dragOffsetX)) .. ", ") .. tostring(self.dragOffsetY)) .. ")")
    if self.onDragStart then
        self.onDragStart()
    end
    self.dragTimer = CreateTimer()
    TimerStart(
        self.dragTimer,
        0.01,
        true,
        function()
            self:updateDragPosition()
        end
    )
    local mouseEvents = MouseEventManager:getInstance()
    self.dragMouseUpId = mouseEvents:onMouseUp(
        function()
            self:endDrag()
        end,
        1,
        {once = true}
    )
end
function Button.prototype.updateDragPosition(self)
    if not self.isDragging then
        return
    end
    local currentMouseX = self:getMousePixelX()
    local currentMouseY = self:getMousePixelY()
    local newX = currentMouseX - self.dragOffsetX
    local newY = currentMouseY - self.dragOffsetY
    self:setPosition(newX, newY)
    if self.onDragging then
        self.onDragging(newX, newY)
    end
end
function Button.prototype.endDrag(self)
    if not self.isDragging then
        return
    end
    self.isDragging = false
    if self.dragTimer then
        PauseTimer(self.dragTimer)
        DestroyTimer(self.dragTimer)
        self.dragTimer = nil
    end
    if self.dragMouseUpId >= 0 then
        local mouseEvents = MouseEventManager:getInstance()
        mouseEvents:off(self.dragMouseUpId)
        self.dragMouseUpId = -1
    end
    log:info(((("Drag ended at position(" .. tostring(self.pixelX)) .. ", ") .. tostring(self.pixelY)) .. ")")
    if self.onDragEnd then
        self.onDragEnd(self.pixelX, self.pixelY)
    end
end
function Button.prototype.setupDragEventListeners(self)
    if self.dragMouseDownId >= 0 then
        return
    end
    local mouseEvents = MouseEventManager:getInstance()
    self.dragMouseDownId = mouseEvents:onMouseDown(
        function()
            if self.isMouseOver and self.isDraggable and not self.isDragging and self.isEnabled then
                self:startDrag()
            end
        end,
        1
    )
end
function Button.prototype.cleanupDragEventListeners(self)
    local mouseEvents = MouseEventManager:getInstance()
    if self.dragMouseDownId >= 0 then
        mouseEvents:off(self.dragMouseDownId)
        self.dragMouseDownId = -1
    end
    if self.dragMouseUpId >= 0 then
        mouseEvents:off(self.dragMouseUpId)
        self.dragMouseUpId = -1
    end
    if self.isDragging then
        self:endDrag()
    end
end
function Button.prototype.enableDrag(self, config)
    self:setDraggable(true)
    if config then
        if config.onDragStart then
            self:setOnDragStart(config.onDragStart)
        end
        if config.onDragEnd then
            self:setOnDragEnd(config.onDragEnd)
        end
        if config.onDragging then
            self:setOnDragging(config.onDragging)
        end
    end
    return self
end
function Button.prototype.disableDrag(self)
    self:setDraggable(false)
    if self.isDragging then
        self:endDrag()
    end
    return self
end
return ____exports

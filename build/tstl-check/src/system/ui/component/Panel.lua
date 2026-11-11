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
local ____MouseEvent = require("src.system.event.MouseEvent")
local MouseEventManager = ____MouseEvent.MouseEventManager
local ____preset = require("src.constants.ui.preset")
local UIBackgrounds = ____preset.UIBackgrounds
local ____logger = require("src.utils.logger")
local createLogger = ____logger.createLogger
local log = createLogger("Panel")
--- 面板尺寸预设
____exports.PanelSizes = {
    SMALL = {width = 200, height = 150},
    MEDIUM = {width = 400, height = 300},
    LARGE = {width = 600, height = 450},
    WIDE = {width = 800, height = 200},
    TALL = {width = 300, height = 500},
    FULLSCREEN = {width = 1920, height = 1080}
}
--- Panel类 - 面板容器组件
-- 可作为其他UI组件的父容器，支持拖拽、缩放、标题栏等功能
____exports.Panel = __TS__Class()
local Panel = ____exports.Panel
Panel.name = "Panel"
function Panel.prototype.____constructor(self, x, y, width, height, origin)
    if width == nil then
        width = 400
    end
    if height == nil then
        height = 300
    end
    if origin == nil then
        origin = ScreenCoordinates.ORIGIN_TOP_LEFT
    end
    self.backdropFrame = nil
    self.titleBarFrame = nil
    self.titleTextFrame = nil
    self.contentFrame = nil
    self.closeButtonFrame = nil
    self.closeBackdropFrame = nil
    self.titleBarHitFrame = nil
    self.isVisible = true
    self.isEnabled = true
    self.background = UIBackgrounds.BLACK_TRANSPARENT
    self.titleBarHeight = 30
    self.closeButtonSize = 26
    self.showTitleBar = false
    self.title = ""
    self.titleColor = "FFFFFF"
    self.showCloseButton = false
    self.origin = ScreenCoordinates.ORIGIN_TOP_LEFT
    self.alpha = 255
    self.isDraggable = false
    self.isDragging = false
    self.dragTimer = nil
    self.dragOffsetX = 0
    self.dragOffsetY = 0
    self.dragMouseDownId = -1
    self.dragMouseUpId = -1
    self.isMouseOverTitleBar = false
    self.onClose = nil
    self.onDragStart = nil
    self.onDragEnd = nil
    self.onDragging = nil
    self.pixelX = x
    self.pixelY = y
    self.pixelWidth = width
    self.pixelHeight = height
    self.origin = origin
end
function Panel.createWithPreset(self, x, y, sizePreset, origin, parent)
    if sizePreset == nil then
        sizePreset = "MEDIUM"
    end
    if origin == nil then
        origin = ScreenCoordinates.ORIGIN_TOP_LEFT
    end
    local size = ____exports.PanelSizes[sizePreset]
    local panel = __TS__New(
        ____exports.Panel,
        x,
        y,
        size.width,
        size.height,
        origin
    )
    panel:create(parent)
    return panel
end
function Panel.createCentered(self, sizePreset, parent)
    if sizePreset == nil then
        sizePreset = "MEDIUM"
    end
    local size = ____exports.PanelSizes[sizePreset]
    local centerX = (ScreenCoordinates.STANDARD_WIDTH - size.width) / 2
    local centerY = (ScreenCoordinates.STANDARD_HEIGHT - size.height) / 2
    local panel = __TS__New(
        ____exports.Panel,
        centerX,
        centerY,
        size.width,
        size.height
    )
    panel:create(parent)
    return panel
end
function Panel.createWithTitle(self, title, x, y, width, height, parent)
    if width == nil then
        width = 400
    end
    if height == nil then
        height = 300
    end
    local panel = __TS__New(
        ____exports.Panel,
        x,
        y,
        width,
        height
    )
    panel:setTitle(title)
    panel:setShowTitleBar(true)
    panel:create(parent)
    return panel
end
function Panel.createDraggable(self, title, x, y, width, height, parent)
    if width == nil then
        width = 400
    end
    if height == nil then
        height = 300
    end
    local panel = __TS__New(
        ____exports.Panel,
        x,
        y,
        width,
        height
    )
    panel:setTitle(title)
    panel:setShowTitleBar(true)
    panel:setDraggable(true)
    panel:setShowCloseButton(true)
    panel:create(parent)
    return panel
end
function Panel.prototype.create(self, parent)
    if self.backdropFrame then
        log:info("already created")
        return
    end
    local parentFrame = parent or Frame:fromHandle(DzGetGameUI())
    local wc3Pos = ScreenCoordinates:pixelToWC3(self.pixelX, self.pixelY, self.origin)
    local wc3Width = self.pixelWidth / ScreenCoordinates.STANDARD_WIDTH * ScreenCoordinates.WC3_SCREEN_WIDTH
    local wc3Height = self.pixelHeight / ScreenCoordinates.STANDARD_HEIGHT * ScreenCoordinates.WC3_SCREEN_HEIGHT
    local rightX = wc3Pos.x + wc3Width
    local bottomY = wc3Pos.y - wc3Height
    self.backdropFrame = Frame:createType(
        "PanelBackdrop",
        parentFrame,
        0,
        "BACKDROP",
        ""
    )
    if not self.backdropFrame then
        log:error("Failed to create panel backdrop frame")
        return
    end
    self.backdropFrame:setAbsPoint(FRAME_ALIGN_LEFT_TOP, wc3Pos.x, wc3Pos.y):setAbsPoint(FRAME_ALIGN_RIGHT_BOTTOM, rightX, bottomY):setTexture(self.background, 0, true):setAlpha(self.alpha)
    if self.showTitleBar then
        self:createTitleBar(wc3Pos.x, wc3Pos.y, wc3Width)
    end
    self:createContentArea(wc3Pos.x, wc3Pos.y, wc3Width, wc3Height)
    self:setVisible(self.isVisible)
    log:info((((((("created at (" .. tostring(self.pixelX)) .. ", ") .. tostring(self.pixelY)) .. ") with size ") .. tostring(self.pixelWidth)) .. "x") .. tostring(self.pixelHeight))
end
function Panel.prototype.createTitleBar(self, wc3X, wc3Y, wc3Width)
    local titleBarWC3Height = self.titleBarHeight / ScreenCoordinates.STANDARD_HEIGHT * ScreenCoordinates.WC3_SCREEN_HEIGHT
    local closeButtonWC3Size = self.closeButtonSize / ScreenCoordinates.STANDARD_WIDTH * ScreenCoordinates.WC3_SCREEN_WIDTH
    self.titleBarFrame = Frame:createType(
        "PanelTitleBar",
        self.backdropFrame,
        0,
        "BACKDROP",
        ""
    )
    if self.titleBarFrame ~= nil then
        self.titleBarFrame:setAbsPoint(FRAME_ALIGN_LEFT_TOP, wc3X, wc3Y):setAbsPoint(FRAME_ALIGN_RIGHT_BOTTOM, wc3X + wc3Width, wc3Y - titleBarWC3Height):setTexture(UIBackgrounds.BLACK_TRANSPARENT, 0, true):setAlpha(200)
        self:setupTitleBarEvents()
    end
    self.titleTextFrame = Frame:createType(
        "PanelTitleText",
        self.titleBarFrame,
        0,
        "TEXT",
        ""
    )
    if self.titleTextFrame ~= nil then
        local textRightX = self.showCloseButton and wc3X + wc3Width - closeButtonWC3Size - 0.005 or wc3X + wc3Width
        self.titleTextFrame:setAbsPoint(FRAME_ALIGN_LEFT_TOP, wc3X + 0.005, wc3Y - 0.002):setAbsPoint(FRAME_ALIGN_RIGHT_BOTTOM, textRightX, wc3Y - titleBarWC3Height + 0.002):setText((("|cff" .. self.titleColor) .. self.title) .. "|r"):setTextAlignment(0, 50)
    end
    if self.showCloseButton then
        self:createCloseButton(wc3X + wc3Width - closeButtonWC3Size - 0.002, wc3Y - 0.002, closeButtonWC3Size)
    end
end
function Panel.prototype.createCloseButton(self, wc3X, wc3Y, wc3Size)
    self.closeBackdropFrame = Frame:createType(
        "PanelCloseBackdrop",
        self.titleBarFrame,
        0,
        "BACKDROP",
        ""
    )
    if self.closeBackdropFrame ~= nil then
        self.closeBackdropFrame:setAbsPoint(FRAME_ALIGN_LEFT_TOP, wc3X, wc3Y):setAbsPoint(FRAME_ALIGN_RIGHT_BOTTOM, wc3X + wc3Size, wc3Y - wc3Size):setTexture(UIBackgrounds.SHUIMO_STYLE_CLOSE_BUTTON_BACKGROUND, 0, true)
    end
    self.closeButtonFrame = Frame:createType(
        "PanelCloseButton",
        self.closeBackdropFrame,
        0,
        "BUTTON",
        ""
    )
    if self.closeButtonFrame ~= nil then
        self.closeButtonFrame:setAllPoints(self.closeBackdropFrame)
        DzFrameSetScriptByCode(
            self.closeButtonFrame.handle,
            1,
            function()
                self:close()
            end,
            false
        )
    end
end
function Panel.prototype.createContentArea(self, wc3X, wc3Y, wc3Width, wc3Height)
    local titleBarWC3Height = self.showTitleBar and self.titleBarHeight / ScreenCoordinates.STANDARD_HEIGHT * ScreenCoordinates.WC3_SCREEN_HEIGHT or 0
    self.contentFrame = Frame:createType(
        "PanelContent",
        self.backdropFrame,
        0,
        "FRAME",
        ""
    )
    if self.contentFrame ~= nil then
        self.contentFrame:setAbsPoint(FRAME_ALIGN_LEFT_TOP, wc3X, wc3Y - titleBarWC3Height):setAbsPoint(FRAME_ALIGN_RIGHT_BOTTOM, wc3X + wc3Width, wc3Y - wc3Height)
    end
end
function Panel.prototype.setupTitleBarEvents(self)
    if not self.titleBarFrame then
        return
    end
    self.titleBarHitFrame = Frame:createType(
        "PanelTitleBarHit",
        self.titleBarFrame,
        0,
        "BUTTON",
        ""
    )
    if self.titleBarHitFrame ~= nil then
        self.titleBarHitFrame:setAllPoints(self.titleBarFrame)
        DzFrameSetScriptByCode(
            self.titleBarHitFrame.handle,
            3,
            function()
                self.isMouseOverTitleBar = true
            end,
            false
        )
        DzFrameSetScriptByCode(
            self.titleBarHitFrame.handle,
            4,
            function()
                self.isMouseOverTitleBar = false
            end,
            false
        )
    end
end
function Panel.prototype.setTitle(self, title)
    self.title = title
    if self.titleTextFrame then
        self.titleTextFrame:setText((("|cff" .. self.titleColor) .. title) .. "|r")
    end
    return self
end
function Panel.prototype.getTitle(self)
    return self.title
end
function Panel.prototype.setTitleColor(self, hexColor)
    self.titleColor = hexColor
    if self.titleTextFrame then
        self.titleTextFrame:setText((("|cff" .. self.titleColor) .. self.title) .. "|r")
    end
    return self
end
function Panel.prototype.setShowTitleBar(self, show)
    self.showTitleBar = show
    return self
end
function Panel.prototype.setTitleBarHeight(self, height)
    self.titleBarHeight = height
    return self
end
function Panel.prototype.setShowCloseButton(self, show)
    self.showCloseButton = show
    return self
end
function Panel.prototype.setCloseButtonSize(self, size)
    self.closeButtonSize = size
    if self.titleBarFrame and self.showTitleBar then
        log:info(("更新关闭按钮大小为 " .. tostring(size)) .. "px，需要重新创建标题栏")
    end
    return self
end
function Panel.prototype.setOnClose(self, callback)
    self.onClose = callback
    return self
end
function Panel.prototype.close(self)
    if self.onClose then
        self.onClose()
    end
    self:setVisible(false)
end
function Panel.prototype.setBackground(self, texturePath)
    self.background = texturePath
    if self.backdropFrame then
        self.backdropFrame:setTexture(texturePath, 0, true)
    end
    return self
end
function Panel.prototype.setBackgroundPreset(self, preset)
    return self:setBackground(UIBackgrounds[preset])
end
function Panel.prototype.setAlpha(self, alpha)
    self.alpha = alpha
    if self.backdropFrame then
        self.backdropFrame:setAlpha(alpha)
    end
    return self
end
function Panel.prototype.setPosition(self, x, y)
    self.pixelX = x
    self.pixelY = y
    self:updateFramePositions()
    return self
end
function Panel.prototype.setSize(self, width, height)
    self.pixelWidth = width
    self.pixelHeight = height
    self:updateFramePositions()
    return self
end
function Panel.prototype.getPosition(self)
    return {x = self.pixelX, y = self.pixelY}
end
function Panel.prototype.getSize(self)
    return {width = self.pixelWidth, height = self.pixelHeight}
end
function Panel.prototype.updateFramePositions(self)
    if not self.backdropFrame then
        return
    end
    local wc3Pos = ScreenCoordinates:pixelToWC3(self.pixelX, self.pixelY, self.origin)
    local wc3Width = self.pixelWidth / ScreenCoordinates.STANDARD_WIDTH * ScreenCoordinates.WC3_SCREEN_WIDTH
    local wc3Height = self.pixelHeight / ScreenCoordinates.STANDARD_HEIGHT * ScreenCoordinates.WC3_SCREEN_HEIGHT
    local rightX = wc3Pos.x + wc3Width
    local bottomY = wc3Pos.y - wc3Height
    self.backdropFrame:setAbsPoint(FRAME_ALIGN_LEFT_TOP, wc3Pos.x, wc3Pos.y):setAbsPoint(FRAME_ALIGN_RIGHT_BOTTOM, rightX, bottomY)
    if self.titleBarFrame then
        local titleBarWC3Height = self.titleBarHeight / ScreenCoordinates.STANDARD_HEIGHT * ScreenCoordinates.WC3_SCREEN_HEIGHT
        self.titleBarFrame:setAbsPoint(FRAME_ALIGN_LEFT_TOP, wc3Pos.x, wc3Pos.y):setAbsPoint(FRAME_ALIGN_RIGHT_BOTTOM, wc3Pos.x + wc3Width, wc3Pos.y - titleBarWC3Height)
    end
    if self.titleTextFrame then
        local titleBarWC3Height = self.titleBarHeight / ScreenCoordinates.STANDARD_HEIGHT * ScreenCoordinates.WC3_SCREEN_HEIGHT
        local closeButtonSize = self.titleBarHeight - 4
        local closeButtonWC3Size = closeButtonSize / ScreenCoordinates.STANDARD_WIDTH * ScreenCoordinates.WC3_SCREEN_WIDTH
        local textRightX = self.showCloseButton and wc3Pos.x + wc3Width - closeButtonWC3Size - 0.005 or wc3Pos.x + wc3Width
        self.titleTextFrame:setAbsPoint(FRAME_ALIGN_LEFT_TOP, wc3Pos.x + 0.005, wc3Pos.y - 0.002):setAbsPoint(FRAME_ALIGN_RIGHT_BOTTOM, textRightX, wc3Pos.y - titleBarWC3Height + 0.002)
    end
    if self.contentFrame then
        local titleBarWC3Height = self.showTitleBar and self.titleBarHeight / ScreenCoordinates.STANDARD_HEIGHT * ScreenCoordinates.WC3_SCREEN_HEIGHT or 0
        self.contentFrame:setAbsPoint(FRAME_ALIGN_LEFT_TOP, wc3Pos.x, wc3Pos.y - titleBarWC3Height):setAbsPoint(FRAME_ALIGN_RIGHT_BOTTOM, wc3Pos.x + wc3Width, wc3Pos.y - wc3Height)
    end
    if self.closeBackdropFrame then
        local closeButtonSize = self.titleBarHeight - 4
        local closeButtonWC3Size = closeButtonSize / ScreenCoordinates.STANDARD_WIDTH * ScreenCoordinates.WC3_SCREEN_WIDTH
        local closeButtonX = wc3Pos.x + wc3Width - closeButtonWC3Size - 0.002
        local closeButtonY = wc3Pos.y - 0.002
        self.closeBackdropFrame:setAbsPoint(FRAME_ALIGN_LEFT_TOP, closeButtonX, closeButtonY):setAbsPoint(FRAME_ALIGN_RIGHT_BOTTOM, closeButtonX + closeButtonWC3Size, closeButtonY - closeButtonWC3Size)
    end
end
function Panel.prototype.setVisible(self, visible)
    self.isVisible = visible
    if self.backdropFrame then
        self.backdropFrame:setVisible(visible)
    end
    return self
end
function Panel.prototype.getVisible(self)
    return self.isVisible
end
function Panel.prototype.show(self)
    return self:setVisible(true)
end
function Panel.prototype.hide(self)
    return self:setVisible(false)
end
function Panel.prototype.toggle(self)
    return self:setVisible(not self.isVisible)
end
function Panel.prototype.setEnabled(self, enabled)
    self.isEnabled = enabled
    if self.backdropFrame then
        self.backdropFrame:setAlpha(enabled and self.alpha or math.floor(self.alpha * 0.5))
    end
    return self
end
function Panel.prototype.getEnabled(self)
    return self.isEnabled
end
function Panel.prototype.setDraggable(self, draggable)
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
function Panel.prototype.getDraggable(self)
    return self.isDraggable
end
function Panel.prototype.getIsDragging(self)
    return self.isDragging
end
function Panel.prototype.setOnDragStart(self, callback)
    self.onDragStart = callback
    return self
end
function Panel.prototype.setOnDragEnd(self, callback)
    self.onDragEnd = callback
    return self
end
function Panel.prototype.setOnDragging(self, callback)
    self.onDragging = callback
    return self
end
function Panel.prototype.getMousePixelX(self)
    local windowWidth = DzGetWindowWidth()
    local mouseRelativeX = DzGetMouseXRelative()
    return mouseRelativeX / windowWidth * ScreenCoordinates.STANDARD_WIDTH
end
function Panel.prototype.getMousePixelY(self)
    local windowHeight = DzGetWindowHeight()
    local mouseRelativeY = DzGetMouseYRelative()
    return mouseRelativeY / windowHeight * ScreenCoordinates.STANDARD_HEIGHT
end
function Panel.prototype.startDrag(self)
    if not self.isDraggable or self.isDragging then
        return
    end
    self.isDragging = true
    local currentMouseX = self:getMousePixelX()
    local currentMouseY = self:getMousePixelY()
    self.dragOffsetX = currentMouseX - self.pixelX
    self.dragOffsetY = currentMouseY - self.pixelY
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
function Panel.prototype.updateDragPosition(self)
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
function Panel.prototype.endDrag(self)
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
    if self.onDragEnd then
        self.onDragEnd(self.pixelX, self.pixelY)
    end
end
function Panel.prototype.setupDragEventListeners(self)
    if self.dragMouseDownId >= 0 then
        return
    end
    local mouseEvents = MouseEventManager:getInstance()
    self.dragMouseDownId = mouseEvents:onMouseDown(
        function()
            if self.isMouseOverTitleBar and self.isDraggable and not self.isDragging and self.isEnabled then
                self:startDrag()
            end
        end,
        1
    )
end
function Panel.prototype.cleanupDragEventListeners(self)
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
function Panel.prototype.getBackdropFrame(self)
    return self.backdropFrame
end
function Panel.prototype.getContentFrame(self)
    return self.contentFrame
end
function Panel.prototype.getTitleBarFrame(self)
    return self.titleBarFrame
end
function Panel.prototype.getContentPosition(self)
    local offsetY = self.showTitleBar and self.titleBarHeight or 0
    return {x = self.pixelX, y = self.pixelY + offsetY}
end
function Panel.prototype.getContentSize(self)
    local heightOffset = self.showTitleBar and self.titleBarHeight or 0
    return {width = self.pixelWidth, height = self.pixelHeight - heightOffset}
end
function Panel.prototype.configure(self, config)
    if config.title ~= nil then
        self:setTitle(config.title)
    end
    if config.titleColor ~= nil then
        self:setTitleColor(config.titleColor)
    end
    if config.showTitleBar ~= nil then
        self:setShowTitleBar(config.showTitleBar)
    end
    if config.showCloseButton ~= nil then
        self:setShowCloseButton(config.showCloseButton)
    end
    if config.closeButtonSize ~= nil then
        self:setCloseButtonSize(config.closeButtonSize)
    end
    if config.background ~= nil then
        self:setBackground(config.background)
    end
    if config.alpha ~= nil then
        self:setAlpha(config.alpha)
    end
    if config.draggable ~= nil then
        self:setDraggable(config.draggable)
    end
    if config.visible ~= nil then
        self:setVisible(config.visible)
    end
    if config.enabled ~= nil then
        self:setEnabled(config.enabled)
    end
    if config.onClose ~= nil then
        self:setOnClose(config.onClose)
    end
    return self
end
function Panel.prototype.destroy(self)
    if self.isDragging then
        self:endDrag()
    end
    self:cleanupDragEventListeners()
    if self.closeButtonFrame then
        self.closeButtonFrame:destroy()
        self.closeButtonFrame = nil
    end
    if self.closeBackdropFrame then
        self.closeBackdropFrame:destroy()
        self.closeBackdropFrame = nil
    end
    if self.titleTextFrame then
        self.titleTextFrame:destroy()
        self.titleTextFrame = nil
    end
    if self.titleBarHitFrame then
        self.titleBarHitFrame:destroy()
        self.titleBarHitFrame = nil
    end
    if self.titleBarFrame then
        self.titleBarFrame:destroy()
        self.titleBarFrame = nil
    end
    if self.contentFrame then
        self.contentFrame:destroy()
        self.contentFrame = nil
    end
    if self.backdropFrame then
        self.backdropFrame:destroy()
        self.backdropFrame = nil
    end
    self.onClose = nil
    self.onDragStart = nil
    self.onDragEnd = nil
    self.onDragging = nil
end
return ____exports

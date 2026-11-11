local ____lualib = require("lualib_bundle")
local __TS__Class = ____lualib.__TS__Class
local __TS__New = ____lualib.__TS__New
local __TS__NumberToString = ____lualib.__TS__NumberToString
local __TS__StringPadStart = ____lualib.__TS__StringPadStart
local __TS__StringSplit = ____lualib.__TS__StringSplit
local __TS__StringAccess = ____lualib.__TS__StringAccess
local ____exports = {}
local _____2A = require("lua_modules.@eiriksgata.wc3ts.src.index")
local Frame = _____2A.Frame
local FRAME_ALIGN_LEFT_TOP = _____2A.FRAME_ALIGN_LEFT_TOP
local FRAME_ALIGN_RIGHT_BOTTOM = _____2A.FRAME_ALIGN_RIGHT_BOTTOM
local ____ScreenCoordinates = require("src.system.ui.ScreenCoordinates")
local ScreenCoordinates = ____ScreenCoordinates.ScreenCoordinates
local ____UIComponentBase = require("src.system.ui.component.UIComponentBase")
local DraggableMixin = ____UIComponentBase.DraggableMixin
local ____utils = require("src.constants.frame.utils")
local FrameEventUtils = ____utils.FrameEventUtils
--- 文本对齐方式
____exports.TextAlign = {LEFT = 0, CENTER = 50, RIGHT = 100}
--- 垂直对齐方式
____exports.VerticalAlign = {TOP = 0, MIDDLE = 50, BOTTOM = 100}
--- 常用背景纹理预设
____exports.TextBackgrounds = {
    NONE = "",
    BLACK_TRANSPARENT = "UI\\Widgets\\EscMenu\\Human\\editbox-background.blp",
    TOOLTIP = "UI\\Widgets\\ToolTips\\Human\\human-tooltip-background.blp",
    DIALOG = "UI\\Widgets\\Glues\\GlueScreen-DialogBackground.blp",
    HUMAN_BORDER = "UI\\Widgets\\print\\Human\\CommandButton\\human-multipleselection-border.blp",
    QUEST = "UI\\Widgets\\Quests\\QuestMainBackdrop.blp"
}
--- 预设颜色
____exports.TextColors = {
    WHITE = "FFFFFF",
    BLACK = "000000",
    RED = "FF0000",
    GREEN = "00FF00",
    BLUE = "0000FF",
    YELLOW = "FFFF00",
    ORANGE = "FFA500",
    PURPLE = "800080",
    CYAN = "00FFFF",
    PINK = "FFC0CB",
    GOLD = "FFD700",
    SILVER = "C0C0C0",
    GRAY = "808080"
}
--- 尺寸预设
____exports.TextSizes = {
    SMALL = {width = 100, height = 20},
    MEDIUM = {width = 200, height = 30},
    LARGE = {width = 300, height = 40},
    TITLE = {width = 400, height = 50},
    AUTO = {width = 0, height = 0}
}
--- 字体预设
____exports.TextFonts = {DEFAULT = "", CUSTOM = "UI\\hpbar\\ZiTi.ttf", MASTER = "Fonts\\FZXH1JW.TTF"}
--- 字体大小预设（WC3坐标系）
____exports.FontSizes = {
    TINY = 0.008,
    SMALL = 0.01,
    MEDIUM = 0.012,
    LARGE = 0.014,
    XLARGE = 0.016,
    TITLE = 0.02,
    HUGE = 0.024
}
--- Text类 - 文本显示组件
-- 包含: 背景框架(Backdrop，可选) + 文本框架(Text)
-- 支持拖拽功能
____exports.Text = __TS__Class()
local Text = ____exports.Text
Text.name = "Text"
function Text.prototype.____constructor(self, content, x, y, width, height, origin)
    if width == nil then
        width = 200
    end
    if height == nil then
        height = 30
    end
    if origin == nil then
        origin = ScreenCoordinates.ORIGIN_TOP_LEFT
    end
    self.backdropFrame = nil
    self.textFrame = nil
    self.buttonFrame = nil
    self.isVisible = true
    self.isEnabled = true
    self.background = ____exports.TextBackgrounds.NONE
    self.showBackground = false
    self.textColor = ____exports.TextColors.WHITE
    self.horizontalAlign = ____exports.TextAlign.LEFT
    self.verticalAlign = ____exports.VerticalAlign.TOP
    self.fontPath = ""
    self.fontSize = ____exports.FontSizes.MEDIUM
    self.fontFlags = 0
    self.origin = ScreenCoordinates.ORIGIN_TOP_LEFT
    self.paddingTop = 0
    self.paddingRight = 0
    self.paddingBottom = 0
    self.paddingLeft = 0
    self.autoWidth = false
    self.autoHeight = false
    self.minWidth = 50
    self.minHeight = 20
    self.maxWidth = 800
    self.maxHeight = 600
    self.content = content
    self.pixelX = x
    self.pixelY = y
    self.pixelWidth = width
    self.pixelHeight = height
    self.origin = origin
    self.draggable = __TS__New(DraggableMixin, self)
end
function Text.createWithPreset(self, content, x, y, sizePreset, origin, parent)
    if sizePreset == nil then
        sizePreset = "MEDIUM"
    end
    if origin == nil then
        origin = ScreenCoordinates.ORIGIN_TOP_LEFT
    end
    local size = ____exports.TextSizes[sizePreset]
    local text = __TS__New(
        ____exports.Text,
        content,
        x,
        y,
        size.width,
        size.height,
        origin
    )
    if sizePreset == "AUTO" then
        text:setAutoSize(true, true)
    end
    text:create(parent)
    return text
end
function Text.createAtPresetPosition(self, content, positionPreset, sizePreset, centered, parent)
    if sizePreset == nil then
        sizePreset = "MEDIUM"
    end
    if centered == nil then
        centered = true
    end
    local position = ScreenCoordinates:getPresetPosition(positionPreset)
    local size = ____exports.TextSizes[sizePreset]
    local x = position.x
    local y = position.y
    if centered and sizePreset ~= "AUTO" then
        x = position.x - size.width / 2
        y = position.y - size.height / 2
    end
    local text = __TS__New(
        ____exports.Text,
        content,
        x,
        y,
        size.width,
        size.height
    )
    if sizePreset == "AUTO" then
        text:setAutoSize(true, true)
    end
    text:create(parent)
    return text
end
function Text.createCentered(self, content, sizePreset, parent)
    if sizePreset == nil then
        sizePreset = "MEDIUM"
    end
    return ____exports.Text:createAtPresetPosition(
        content,
        "CENTER",
        sizePreset,
        true,
        parent
    )
end
function Text.createWithBackground(self, content, x, y, width, height, background, parent)
    if width == nil then
        width = 200
    end
    if height == nil then
        height = 30
    end
    if background == nil then
        background = ____exports.TextBackgrounds.BLACK_TRANSPARENT
    end
    local text = __TS__New(
        ____exports.Text,
        content,
        x,
        y,
        width,
        height
    )
    text:setBackground(background)
    text:create(parent)
    return text
end
function Text.prototype.create(self, parent)
    if self.textFrame then
        return
    end
    local parentFrame = parent or Frame:fromHandle(DzGetGameUI())
    local isGameUI = not parent or parent.handle == DzGetGameUI()
    if self.autoWidth or self.autoHeight then
        self:calculateAutoSize()
    end
    local wc3Pos = ScreenCoordinates:pixelToWC3(self.pixelX, self.pixelY, self.origin)
    local wc3Width = self.pixelWidth / ScreenCoordinates.STANDARD_WIDTH * ScreenCoordinates.WC3_SCREEN_WIDTH
    local wc3Height = self.pixelHeight / ScreenCoordinates.STANDARD_HEIGHT * ScreenCoordinates.WC3_SCREEN_HEIGHT
    local rightX = wc3Pos.x + wc3Width
    local bottomY = wc3Pos.y - wc3Height
    local paddingTopWC3 = self.paddingTop / ScreenCoordinates.STANDARD_HEIGHT * ScreenCoordinates.WC3_SCREEN_HEIGHT
    local paddingRightWC3 = self.paddingRight / ScreenCoordinates.STANDARD_WIDTH * ScreenCoordinates.WC3_SCREEN_WIDTH
    local paddingBottomWC3 = self.paddingBottom / ScreenCoordinates.STANDARD_HEIGHT * ScreenCoordinates.WC3_SCREEN_HEIGHT
    local paddingLeftWC3 = self.paddingLeft / ScreenCoordinates.STANDARD_WIDTH * ScreenCoordinates.WC3_SCREEN_WIDTH
    if self.showBackground and self.background ~= "" then
        self.backdropFrame = Frame:createType(
            "BACKDROP",
            parentFrame,
            0,
            "BACKDROP",
            ""
        )
        if self.backdropFrame ~= nil then
            self.backdropFrame:setAbsPoint(FRAME_ALIGN_LEFT_TOP, wc3Pos.x, wc3Pos.y):setAbsPoint(FRAME_ALIGN_RIGHT_BOTTOM, rightX, bottomY):setTexture(self.background, 0, true)
        end
    end
    local textParent = self.backdropFrame or parentFrame
    self.textFrame = Frame:createType(
        "TEXT",
        textParent,
        0,
        "TEXT",
        ""
    )
    if not self.textFrame then
        return
    end
    self.textFrame:setAbsPoint(FRAME_ALIGN_LEFT_TOP, wc3Pos.x + paddingLeftWC3, wc3Pos.y - paddingTopWC3):setAbsPoint(FRAME_ALIGN_RIGHT_BOTTOM, rightX - paddingRightWC3, bottomY + paddingBottomWC3):setText(self:getFormattedText()):setTextAlignment(self.horizontalAlign, self.verticalAlign)
    if self.fontPath ~= "" then
        self.textFrame:setFont(self.fontPath, self.fontSize, self.fontFlags)
    end
    self.buttonFrame = Frame:createType(
        "BUTTON",
        textParent,
        0,
        "BUTTON",
        ""
    )
    if self.buttonFrame ~= nil then
        self.buttonFrame:setAbsPoint(FRAME_ALIGN_LEFT_TOP, wc3Pos.x, wc3Pos.y):setAbsPoint(FRAME_ALIGN_RIGHT_BOTTOM, rightX, bottomY)
        self:setupMouseEvents()
    end
    self:setVisible(self.isVisible)
end
function Text.prototype.setupMouseEvents(self)
    if not self.buttonFrame then
        return
    end
    FrameEventUtils:bindEvents(
        self.buttonFrame,
        {
            onMouseEnter = function()
                self.draggable:setMouseOver(true)
            end,
            onMouseLeave = function()
                self.draggable:setMouseOver(false)
            end
        }
    )
end
function Text.prototype.setText(self, content)
    self.content = content
    if self.textFrame then
        if self.autoWidth or self.autoHeight then
            self:calculateAutoSize()
            self:updateFramePositions()
        end
        self.textFrame:setText(self:getFormattedText())
    end
    return self
end
function Text.prototype.getText(self)
    return self.content
end
function Text.prototype.appendText(self, text)
    return self:setText(self.content .. text)
end
function Text.prototype.clearText(self)
    return self:setText("")
end
function Text.prototype.setColor(self, hexColor)
    self.textColor = hexColor
    if self.textFrame then
        self.textFrame:setText(self:getFormattedText())
    end
    return self
end
function Text.prototype.setColorPreset(self, preset)
    return self:setColor(____exports.TextColors[preset])
end
function Text.prototype.setColorRGB(self, r, g, b)
    local function toHex(n)
        return __TS__StringPadStart(
            __TS__NumberToString(
                math.max(
                    0,
                    math.min(255, n)
                ),
                16
            ),
            2,
            "0"
        )
    end
    return self:setColor((toHex(r) .. toHex(g)) .. toHex(b))
end
function Text.prototype.getColor(self)
    return self.textColor
end
function Text.prototype.setFont(self, fontPath, fontSize, flags)
    self.fontPath = fontPath
    if fontSize ~= nil then
        self.fontSize = fontSize
    end
    if flags ~= nil then
        self.fontFlags = flags
    end
    if self.textFrame and fontPath ~= "" then
        self.textFrame:setFont(self.fontPath, self.fontSize, self.fontFlags)
    end
    return self
end
function Text.prototype.setFontPreset(self, preset, size)
    self.fontPath = ____exports.TextFonts[preset]
    if size ~= nil then
        self.fontSize = ____exports.FontSizes[size]
    end
    if self.textFrame and self.fontPath ~= "" then
        self.textFrame:setFont(self.fontPath, self.fontSize, self.fontFlags)
    end
    return self
end
function Text.prototype.setFontSize(self, size)
    self.fontSize = size
    if self.textFrame and self.fontPath ~= "" then
        self.textFrame:setFont(self.fontPath, self.fontSize, self.fontFlags)
    end
    return self
end
function Text.prototype.setFontSizePreset(self, preset)
    return self:setFontSize(____exports.FontSizes[preset])
end
function Text.prototype.setFontSizePixels(self, pixelSize)
    local wc3Size = pixelSize / ScreenCoordinates.STANDARD_HEIGHT * ScreenCoordinates.WC3_SCREEN_HEIGHT
    return self:setFontSize(wc3Size)
end
function Text.prototype.getFontPath(self)
    return self.fontPath
end
function Text.prototype.getFontSize(self)
    return self.fontSize
end
function Text.prototype.setHorizontalAlign(self, align)
    self.horizontalAlign = align
    if self.textFrame then
        self.textFrame:setTextAlignment(self.horizontalAlign, self.verticalAlign)
    end
    return self
end
function Text.prototype.setVerticalAlign(self, align)
    self.verticalAlign = align
    if self.textFrame then
        self.textFrame:setTextAlignment(self.horizontalAlign, self.verticalAlign)
    end
    return self
end
function Text.prototype.setAlignment(self, horizontal, vertical)
    self.horizontalAlign = horizontal
    self.verticalAlign = vertical
    if self.textFrame then
        self.textFrame:setTextAlignment(self.horizontalAlign, self.verticalAlign)
    end
    return self
end
function Text.prototype.setAlignPreset(self, horizontal, vertical)
    if vertical == nil then
        vertical = "TOP"
    end
    return self:setAlignment(____exports.TextAlign[horizontal], ____exports.VerticalAlign[vertical])
end
function Text.prototype.center(self)
    return self:setAlignment(____exports.TextAlign.CENTER, ____exports.VerticalAlign.MIDDLE)
end
function Text.prototype.alignLeft(self)
    return self:setHorizontalAlign(____exports.TextAlign.LEFT)
end
function Text.prototype.alignRight(self)
    return self:setHorizontalAlign(____exports.TextAlign.RIGHT)
end
function Text.prototype.setBackground(self, texturePath)
    self.background = texturePath
    self.showBackground = texturePath ~= ""
    if self.textFrame and self.showBackground and not self.backdropFrame then
        self:recreate()
    elseif self.backdropFrame then
        if texturePath == "" then
            self.backdropFrame:setVisible(false)
        else
            self.backdropFrame:setTexture(texturePath, 0, true)
            self.backdropFrame:setVisible(true)
        end
    end
    return self
end
function Text.prototype.setBackgroundPreset(self, preset)
    return self:setBackground(____exports.TextBackgrounds[preset])
end
function Text.prototype.setShowBackground(self, show)
    self.showBackground = show
    if self.backdropFrame then
        self.backdropFrame:setVisible(show)
    end
    return self
end
function Text.prototype.setBackdropAlpha(self, alpha)
    if self.backdropFrame then
        self.backdropFrame:setAlpha(alpha)
    end
    return self
end
function Text.prototype.setPadding(self, padding)
    self.paddingTop = padding
    self.paddingRight = padding
    self.paddingBottom = padding
    self.paddingLeft = padding
    self:updateFramePositions()
    return self
end
function Text.prototype.setPaddingVH(self, vertical, horizontal)
    self.paddingTop = vertical
    self.paddingBottom = vertical
    self.paddingLeft = horizontal
    self.paddingRight = horizontal
    self:updateFramePositions()
    return self
end
function Text.prototype.setPaddingTRBL(self, top, right, bottom, left)
    self.paddingTop = top
    self.paddingRight = right
    self.paddingBottom = bottom
    self.paddingLeft = left
    self:updateFramePositions()
    return self
end
function Text.prototype.setPaddingTop(self, padding)
    self.paddingTop = padding
    self:updateFramePositions()
    return self
end
function Text.prototype.setPaddingRight(self, padding)
    self.paddingRight = padding
    self:updateFramePositions()
    return self
end
function Text.prototype.setPaddingBottom(self, padding)
    self.paddingBottom = padding
    self:updateFramePositions()
    return self
end
function Text.prototype.setPaddingLeft(self, padding)
    self.paddingLeft = padding
    self:updateFramePositions()
    return self
end
function Text.prototype.getPadding(self)
    return {top = self.paddingTop, right = self.paddingRight, bottom = self.paddingBottom, left = self.paddingLeft}
end
function Text.prototype.setAutoSize(self, autoWidth, autoHeight)
    if autoHeight == nil then
        autoHeight = false
    end
    self.autoWidth = autoWidth
    self.autoHeight = autoHeight
    if (autoWidth or autoHeight) and self.textFrame then
        self:calculateAutoSize()
        self:updateFramePositions()
    end
    return self
end
function Text.prototype.setAutoSizeLimits(self, minWidth, maxWidth, minHeight, maxHeight)
    self.minWidth = minWidth
    self.maxWidth = maxWidth
    self.minHeight = minHeight
    self.maxHeight = maxHeight
    return self
end
function Text.prototype.calculateAutoSize(self)
    local plainText = self:removeColorCodes(self.content)
    local lines = __TS__StringSplit(plainText, "\n")
    if self.autoWidth then
        local maxLineLength = 0
        for ____, line in ipairs(lines) do
            if #line > maxLineLength then
                maxLineLength = #line
            end
        end
        local calculatedWidth = maxLineLength * ____exports.Text.CHAR_WIDTH + self.paddingLeft + self.paddingRight
        self.pixelWidth = math.max(
            self.minWidth,
            math.min(self.maxWidth, calculatedWidth)
        )
    end
    if self.autoHeight then
        local calculatedHeight = #lines * ____exports.Text.LINE_HEIGHT + self.paddingTop + self.paddingBottom
        self.pixelHeight = math.max(
            self.minHeight,
            math.min(self.maxHeight, calculatedHeight)
        )
    end
end
function Text.prototype.setPosition(self, x, y)
    self.pixelX = x
    self.pixelY = y
    self:updateFramePositions()
    return self
end
function Text.prototype.getPixelX(self)
    return self.pixelX
end
function Text.prototype.getPixelY(self)
    return self.pixelY
end
function Text.prototype.getEnabled(self)
    return self.isEnabled
end
function Text.prototype.setEnabled(self, enabled)
    self.isEnabled = enabled
    return self
end
function Text.prototype.setSize(self, width, height)
    self.pixelWidth = width
    self.pixelHeight = height
    self.autoWidth = false
    self.autoHeight = false
    self:updateFramePositions()
    return self
end
function Text.prototype.getPosition(self)
    return {x = self.pixelX, y = self.pixelY}
end
function Text.prototype.getSize(self)
    return {width = self.pixelWidth, height = self.pixelHeight}
end
function Text.prototype.updateFramePositions(self)
    if not self.textFrame then
        return
    end
    local wc3Pos = ScreenCoordinates:pixelToWC3(self.pixelX, self.pixelY, self.origin)
    local wc3Width = self.pixelWidth / ScreenCoordinates.STANDARD_WIDTH * ScreenCoordinates.WC3_SCREEN_WIDTH
    local wc3Height = self.pixelHeight / ScreenCoordinates.STANDARD_HEIGHT * ScreenCoordinates.WC3_SCREEN_HEIGHT
    local rightX = wc3Pos.x + wc3Width
    local bottomY = wc3Pos.y - wc3Height
    local paddingTopWC3 = self.paddingTop / ScreenCoordinates.STANDARD_HEIGHT * ScreenCoordinates.WC3_SCREEN_HEIGHT
    local paddingRightWC3 = self.paddingRight / ScreenCoordinates.STANDARD_WIDTH * ScreenCoordinates.WC3_SCREEN_WIDTH
    local paddingBottomWC3 = self.paddingBottom / ScreenCoordinates.STANDARD_HEIGHT * ScreenCoordinates.WC3_SCREEN_HEIGHT
    local paddingLeftWC3 = self.paddingLeft / ScreenCoordinates.STANDARD_WIDTH * ScreenCoordinates.WC3_SCREEN_WIDTH
    if self.backdropFrame then
        self.backdropFrame:setAbsPoint(FRAME_ALIGN_LEFT_TOP, wc3Pos.x, wc3Pos.y):setAbsPoint(FRAME_ALIGN_RIGHT_BOTTOM, rightX, bottomY)
    end
    if self.buttonFrame then
        self.buttonFrame:setAbsPoint(FRAME_ALIGN_LEFT_TOP, wc3Pos.x, wc3Pos.y):setAbsPoint(FRAME_ALIGN_RIGHT_BOTTOM, rightX, bottomY)
    end
    self.textFrame:setAbsPoint(FRAME_ALIGN_LEFT_TOP, wc3Pos.x + paddingLeftWC3, wc3Pos.y - paddingTopWC3):setAbsPoint(FRAME_ALIGN_RIGHT_BOTTOM, rightX - paddingRightWC3, bottomY + paddingBottomWC3)
end
function Text.prototype.setVisible(self, visible)
    self.isVisible = visible
    if self.textFrame then
        self.textFrame:setVisible(visible)
    end
    if self.backdropFrame then
        self.backdropFrame:setVisible(visible and self.showBackground)
    end
    if self.buttonFrame then
        self.buttonFrame:setVisible(visible)
    end
    return self
end
function Text.prototype.getVisible(self)
    return self.isVisible
end
function Text.prototype.show(self)
    return self:setVisible(true)
end
function Text.prototype.hide(self)
    return self:setVisible(false)
end
function Text.prototype.toggle(self)
    return self:setVisible(not self.isVisible)
end
function Text.prototype.setAlpha(self, alpha)
    if self.textFrame then
        self.textFrame:setAlpha(alpha)
    end
    return self
end
function Text.prototype.getTextFrame(self)
    return self.textFrame
end
function Text.prototype.getBackdropFrame(self)
    return self.backdropFrame
end
function Text.prototype.getFormattedText(self)
    return (("|cff" .. self.textColor) .. self.content) .. "|r"
end
function Text.prototype.removeColorCodes(self, text)
    local result = ""
    local i = 0
    while i < #text do
        if i + 1 < #text and __TS__StringAccess(text, i) == "|" and __TS__StringAccess(text, i + 1) == "c" then
            i = i + 10
        elseif i + 1 < #text and __TS__StringAccess(text, i) == "|" and __TS__StringAccess(text, i + 1) == "r" then
            i = i + 2
        else
            result = result .. __TS__StringAccess(text, i)
            i = i + 1
        end
    end
    return result
end
function Text.prototype.recreate(self)
    local ____table_textFrame_0
    if self.textFrame then
        ____table_textFrame_0 = nil
    else
        ____table_textFrame_0 = nil
    end
    local parent = ____table_textFrame_0
    self:destroy()
    self:create(parent)
end
function Text.prototype.configure(self, config)
    if config.text ~= nil then
        self:setText(config.text)
    end
    if config.color ~= nil then
        self:setColor(config.color)
    end
    if config.horizontalAlign ~= nil then
        self:setHorizontalAlign(config.horizontalAlign)
    end
    if config.verticalAlign ~= nil then
        self:setVerticalAlign(config.verticalAlign)
    end
    if config.background ~= nil then
        self:setBackground(config.background)
    end
    if config.visible ~= nil then
        self:setVisible(config.visible)
    end
    if config.alpha ~= nil then
        self:setAlpha(config.alpha)
    end
    if config.fontPath ~= nil then
        self:setFont(config.fontPath, config.fontSize)
    elseif config.fontSize ~= nil then
        self:setFontSize(config.fontSize)
    end
    if config.draggable ~= nil then
        self:setDraggable(config.draggable)
    end
    return self
end
function Text.prototype.setDraggable(self, draggable)
    self.draggable:setEnabled(draggable)
    return self
end
function Text.prototype.getDraggable(self)
    return self.draggable:getEnabled()
end
function Text.prototype.getIsDragging(self)
    return self.draggable:getIsDragging()
end
function Text.prototype.setOnDragStart(self, callback)
    self.draggable:setOnDragStart(callback)
    return self
end
function Text.prototype.setOnDragEnd(self, callback)
    self.draggable:setOnDragEnd(callback)
    return self
end
function Text.prototype.setOnDragging(self, callback)
    self.draggable:setOnDragging(callback)
    return self
end
function Text.prototype.enableDrag(self, config)
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
function Text.prototype.disableDrag(self)
    self:setDraggable(false)
    return self
end
function Text.prototype.destroy(self)
    self.draggable:cleanup()
    if self.buttonFrame then
        self.buttonFrame:destroy()
        self.buttonFrame = nil
    end
    if self.textFrame then
        self.textFrame:destroy()
        self.textFrame = nil
    end
    if self.backdropFrame then
        self.backdropFrame:destroy()
        self.backdropFrame = nil
    end
end
Text.CHAR_WIDTH = 10
Text.LINE_HEIGHT = 18
return ____exports

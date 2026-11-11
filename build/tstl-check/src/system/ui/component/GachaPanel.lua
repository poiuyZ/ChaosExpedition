local ____lualib = require("lualib_bundle")
local __TS__Class = ____lualib.__TS__Class
local __TS__New = ____lualib.__TS__New
local Error = ____lualib.Error
local RangeError = ____lualib.RangeError
local ReferenceError = ____lualib.ReferenceError
local SyntaxError = ____lualib.SyntaxError
local TypeError = ____lualib.TypeError
local URIError = ____lualib.URIError
local __TS__ArrayForEach = ____lualib.__TS__ArrayForEach
local __TS__ArrayMap = ____lualib.__TS__ArrayMap
local ____exports = {}
local _____2A = require("lua_modules.@eiriksgata.wc3ts.src.index")
local Frame = _____2A.Frame
local FRAME_ALIGN_LEFT_TOP = _____2A.FRAME_ALIGN_LEFT_TOP
local FRAME_ALIGN_RIGHT_BOTTOM = _____2A.FRAME_ALIGN_RIGHT_BOTTOM
local ____Panel = require("src.system.ui.component.Panel")
local Panel = ____Panel.Panel
local ____Button = require("src.system.ui.component.Button")
local Button = ____Button.Button
local ButtonTemplates = ____Button.ButtonTemplates
local ____Text = require("src.system.ui.component.Text")
local Text = ____Text.Text
local TextColors = ____Text.TextColors
local ____preset = require("src.constants.ui.preset")
local UIBackgrounds = ____preset.UIBackgrounds
local ____ScreenCoordinates = require("src.system.ui.ScreenCoordinates")
local ScreenCoordinates = ____ScreenCoordinates.ScreenCoordinates
local ____utils = require("src.constants.frame.utils")
local FrameEventUtils = ____utils.FrameEventUtils
local ____logger = require("src.utils.logger")
local createLogger = ____logger.createLogger
local log = createLogger("GachaPanel")
--- 抽卡 UI 面板
-- - 居中显示在屏幕中间
-- - 支持动态添加多张“卡片”
-- - 卡片为一排横向排列，整体始终居中
-- - 鼠标移入卡片时边框高亮（通过背景 Alpha 提升实现）
____exports.GachaPanel = __TS__Class()
local GachaPanel = ____exports.GachaPanel
GachaPanel.name = "GachaPanel"
function GachaPanel.prototype.____constructor(self, title, width, height)
    if title == nil then
        title = "抽卡"
    end
    if width == nil then
        width = 900
    end
    if height == nil then
        height = 380
    end
    self.cards = {}
    self.cardWidth = 260
    self.cardHeight = 280
    self.cardSpacing = 24
    self.contentPaddingTop = 40
    self.contentPaddingBottom = 40
    self.cardPaddingX = 24
    self.cardPaddingTop = 20
    self.cardPaddingBottom = 20
    self.isCreated = false
    self.panelWidth = width
    self.panelHeight = height
    local centerX = (1920 - width) / 2
    local centerY = (1080 - height) / 2
    self.panel = __TS__New(
        Panel,
        centerX,
        centerY,
        width,
        height
    )
    self.panel:setTitle(title)
end
function GachaPanel.createCentered(self, title, width, height, parent)
    if title == nil then
        title = "抽卡"
    end
    if width == nil then
        width = 900
    end
    if height == nil then
        height = 380
    end
    local gacha = __TS__New(____exports.GachaPanel, title, width, height)
    gacha:create(parent)
    return gacha
end
function GachaPanel.prototype.create(self, parent)
    if self.isCreated then
        return
    end
    self.panel:setShowTitleBar(true):setShowCloseButton(true):setBackground(UIBackgrounds.SHUIMO_STYLE_PANEL_BACKGROUND):setAlpha(230):setOnClose(function()
        self:hide()
    end)
    self.panel:create(parent)
    self.isCreated = true
end
function GachaPanel.prototype.addCard(self, config)
    if not self.isCreated then
        log:error("GachaPanel not created yet. Call create() first.")
        error(
            __TS__New(Error, "GachaPanel not created"),
            0
        )
    end
    local button = Button:createWithTemplate(
        "",
        0,
        0,
        self.cardWidth,
        self.cardHeight,
        ButtonTemplates.NORMAL_DIALOG,
        nil,
        nil
    )
    local backdrop = button:getBackdropFrame()
    local titleText = __TS__New(
        Text,
        config.title,
        0,
        0,
        self.cardWidth - self.cardPaddingX * 2,
        26
    )
    titleText:create(backdrop or nil)
    titleText:setColor(TextColors.GOLD):setAlignPreset("CENTER", "MIDDLE"):setFontSizePixels(18)
    local descText = __TS__New(
        Text,
        config.description,
        0,
        0,
        self.cardWidth - self.cardPaddingX * 2,
        self.cardHeight - (self.cardPaddingTop + self.cardPaddingBottom + 80)
    )
    descText:create(backdrop or nil)
    descText:setColor(TextColors.WHITE):setAlignPreset("LEFT", "TOP"):setFontSizePixels(12):setPaddingTRBL(4, 4, 4, 4)
    local iconFrame = nil
    if backdrop then
        iconFrame = Frame:createType(
            "GachaCardIcon",
            backdrop,
            0,
            "BACKDROP",
            ""
        ) or nil
        if iconFrame then
            iconFrame:setTexture(config.icon, 0, true)
        end
    end
    local normalAlpha = 200
    local hoverAlpha = 255
    button:setBackdropAlpha(normalAlpha)
    local hoverFrame = nil
    if backdrop then
        hoverFrame = Frame:createType(
            "GachaCardHover",
            backdrop,
            0,
            "BUTTON",
            ""
        ) or nil
        if hoverFrame then
            hoverFrame:setAllPoints(backdrop)
            FrameEventUtils:bindEvents(
                hoverFrame,
                {
                    onMouseEnter = function()
                        button:setBackdropAlpha(hoverAlpha)
                    end,
                    onMouseLeave = function()
                        button:setBackdropAlpha(normalAlpha)
                    end,
                    onClick = function()
                        if config.onClick then
                            config:onClick()
                        end
                    end
                }
            )
        end
    end
    local visible = self:getVisible()
    button:setVisible(visible)
    titleText:setVisible(visible)
    descText:setVisible(visible)
    if iconFrame then
        iconFrame:setVisible(visible)
    end
    if hoverFrame then
        hoverFrame:setVisible(visible)
    end
    local ____self_cards_0 = self.cards
    ____self_cards_0[#____self_cards_0 + 1] = {
        button = button,
        iconFrame = iconFrame,
        titleText = titleText,
        descText = descText,
        hoverFrame = hoverFrame
    }
    self:repositionCards()
    return button
end
function GachaPanel.prototype.clearCards(self)
    __TS__ArrayForEach(
        self.cards,
        function(____, card)
            card.button:destroy()
            card.titleText:destroy()
            card.descText:destroy()
            if card.iconFrame then
                card.iconFrame:destroy()
            end
            if card.hoverFrame then
                card.hoverFrame:destroy()
            end
        end
    )
    self.cards = {}
end
function GachaPanel.prototype.getCards(self)
    return __TS__ArrayMap(
        self.cards,
        function(____, c) return c.button end
    )
end
function GachaPanel.prototype.repositionCards(self)
    if not self.isCreated or #self.cards == 0 then
        return
    end
    local contentPos = self.panel:getContentPosition()
    local contentSize = self.panel:getContentSize()
    local totalWidth = #self.cards * self.cardWidth + (#self.cards - 1) * self.cardSpacing
    local startX = contentPos.x + (contentSize.width - totalWidth) / 2
    local y = contentPos.y + self.contentPaddingTop
    __TS__ArrayForEach(
        self.cards,
        function(____, cardView, index)
            local x = startX + index * (self.cardWidth + self.cardSpacing)
            cardView.button:setPosition(x, y)
            local innerWidth = self.cardWidth - self.cardPaddingX * 2
            local iconSize = math.min(innerWidth, 64)
            local iconX = x + (self.cardWidth - iconSize) / 2
            local iconY = y + self.cardPaddingTop
            if cardView.iconFrame then
                local wc3Pos = ScreenCoordinates:pixelToWC3(iconX, iconY, ScreenCoordinates.ORIGIN_TOP_LEFT)
                local wc3Size = ScreenCoordinates:pixelSizeToWC3(iconSize, iconSize)
                local rightX = wc3Pos.x + wc3Size.width
                local bottomY = wc3Pos.y - wc3Size.height
                cardView.iconFrame:setAbsPoint(FRAME_ALIGN_LEFT_TOP, wc3Pos.x, wc3Pos.y):setAbsPoint(FRAME_ALIGN_RIGHT_BOTTOM, rightX, bottomY)
            end
            local titleX = x + self.cardPaddingX
            local titleY = iconY + iconSize + 8
            local titleWidth = innerWidth
            local titleHeight = 26
            cardView.titleText:setPosition(titleX, titleY):setSize(titleWidth, titleHeight)
            local descX = x + self.cardPaddingX
            local descY = titleY + titleHeight + 4
            local descWidth = innerWidth
            local descHeight = self.cardHeight - (descY - y) - self.cardPaddingBottom
            cardView.descText:setPosition(descX, descY):setSize(descWidth, descHeight)
        end
    )
end
function GachaPanel.prototype.setCardSize(self, width, height)
    self.cardWidth = width
    self.cardHeight = height
    self:repositionCards()
    return self
end
function GachaPanel.prototype.setCardSpacing(self, spacing)
    self.cardSpacing = spacing
    self:repositionCards()
    return self
end
function GachaPanel.prototype.setContentPadding(self, top, bottom)
    self.contentPaddingTop = top
    self.contentPaddingBottom = bottom
    self:repositionCards()
    return self
end
function GachaPanel.prototype.setCardInnerPadding(self, horizontal, top, bottom)
    self.cardPaddingX = horizontal
    self.cardPaddingTop = top
    self.cardPaddingBottom = bottom
    self:repositionCards()
    return self
end
function GachaPanel.prototype.setPosition(self, x, y)
    self.panel:setPosition(x, y)
    self:repositionCards()
    return self
end
function GachaPanel.prototype.getPosition(self)
    return self.panel:getPosition()
end
function GachaPanel.prototype.setSize(self, width, height)
    self.panelWidth = width
    self.panelHeight = height
    self.panel:setSize(width, height)
    self:repositionCards()
    return self
end
function GachaPanel.prototype.getSize(self)
    return self.panel:getSize()
end
function GachaPanel.prototype.setDraggable(self, draggable)
    if draggable then
        self.panel:setOnDragging(function(_x, _y)
            self:repositionCards()
        end):setOnDragEnd(function(_x, _y)
            self:repositionCards()
        end)
    end
    self.panel:setDraggable(draggable)
    return self
end
function GachaPanel.prototype.getDraggable(self)
    return self.panel:getDraggable()
end
function GachaPanel.prototype.setVisible(self, visible)
    self.panel:setVisible(visible)
    __TS__ArrayForEach(
        self.cards,
        function(____, card)
            card.button:setVisible(visible)
            card.titleText:setVisible(visible)
            card.descText:setVisible(visible)
            if card.iconFrame then
                card.iconFrame:setVisible(visible)
            end
            if card.hoverFrame then
                card.hoverFrame:setVisible(visible)
            end
        end
    )
    return self
end
function GachaPanel.prototype.getVisible(self)
    return self.panel:getVisible()
end
function GachaPanel.prototype.show(self)
    return self:setVisible(true)
end
function GachaPanel.prototype.hide(self)
    return self:setVisible(false)
end
function GachaPanel.prototype.toggle(self)
    local visible = self:getVisible()
    return self:setVisible(not visible)
end
function GachaPanel.prototype.setTitle(self, title)
    self.panel:setTitle(title)
    return self
end
function GachaPanel.prototype.getTitle(self)
    return self.panel:getTitle()
end
function GachaPanel.prototype.setBackground(self, texturePath)
    self.panel:setBackground(texturePath)
    return self
end
function GachaPanel.prototype.setBackgroundPreset(self, preset)
    self.panel:setBackgroundPreset(preset)
    return self
end
function GachaPanel.prototype.setAlpha(self, alpha)
    self.panel:setAlpha(alpha)
    return self
end
function GachaPanel.prototype.setTitleColor(self, hexColor)
    self.panel:setTitleColor(hexColor)
    return self
end
function GachaPanel.prototype.getPanel(self)
    return self.panel
end
function GachaPanel.prototype.destroy(self)
    self:clearCards()
    self.panel:destroy()
    self.isCreated = false
end
return ____exports

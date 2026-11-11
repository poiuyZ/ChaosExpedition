local ____lualib = require("lualib_bundle")
local __TS__Class = ____lualib.__TS__Class
local __TS__StringCharAt = ____lualib.__TS__StringCharAt
local __TS__StringSubstring = ____lualib.__TS__StringSubstring
local __TS__StringSplit = ____lualib.__TS__StringSplit
local __TS__New = ____lualib.__TS__New
local ____exports = {}
local _____2A = require("lua_modules.@eiriksgata.wc3ts.src.index")
local Frame = _____2A.Frame
local FRAMEPOINT_TOPLEFT = _____2A.FRAMEPOINT_TOPLEFT
local FRAMEPOINT_BOTTOMRIGHT = _____2A.FRAMEPOINT_BOTTOMRIGHT
local ____ScreenCoordinates = require("src.system.ui.ScreenCoordinates")
local ScreenCoordinates = ____ScreenCoordinates.ScreenCoordinates
local ____logger = require("src.utils.logger")
local createLogger = ____logger.createLogger
local log = createLogger("Tips")
--- Tips 动画类型
____exports.TipsAnimation = ____exports.TipsAnimation or ({})
____exports.TipsAnimation.NONE = "none"
____exports.TipsAnimation.FADE = "fade"
____exports.TipsAnimation.SLIDE_RIGHT = "slideRight"
____exports.TipsAnimation.SLIDE_LEFT = "slideLeft"
____exports.TipsAnimation.SLIDE_TOP = "slideTop"
____exports.TipsAnimation.SLIDE_BOTTOM = "slideBottom"
--- Tips 显示位置
____exports.TipsPosition = ____exports.TipsPosition or ({})
____exports.TipsPosition.AUTO = "auto"
____exports.TipsPosition.RIGHT = "right"
____exports.TipsPosition.LEFT = "left"
____exports.TipsPosition.TOP = "top"
____exports.TipsPosition.BOTTOM = "bottom"
--- Tips 组件 - 单例模式
-- 用于显示鼠标悬停提示、技能说明、物品介绍等
-- 
-- @example ```typescript
-- const tips = Tips.getInstance();
-- const info = button.getComponentInfo();
-- tips.showFromComponentInfo({
--   text: "技能说明…",
--   textColor: "FFD700",
--   icon: "ReplaceableTextures\\CommandButtons\\BTNFireBolt.blp",
--   position: TipsPosition.AUTO,
--   animation: TipsAnimation.NONE,
--   delayShow: 0,
-- }, info);
-- tips.hide();
-- ```
____exports.Tips = __TS__Class()
local Tips = ____exports.Tips
Tips.name = "Tips"
function Tips.prototype.____constructor(self)
    self.backdropFrame = nil
    self.iconFrame = nil
    self.textFrame = nil
    self.isVisible = false
    self.isCreated = false
    self.currentConfig = nil
    self.componentWidth = 100
    self.componentHeight = 40
    self.lastTipsWidthPx = 300
    self.lastTipsHeightPx = 400
    self.showTimer = nil
    self.hideTimer = nil
    self.animationTimer = nil
    self.currentAlpha = 0
    self.targetAlpha = 255
    self.animationProgress = 0
    self.finalPositionX = 0
    self.finalPositionY = 0
end
function Tips.formatDisplayText(self, raw, hexColor)
    if raw == nil or raw == nil then
        return ""
    end
    local hex = hexColor and #hexColor >= 6 and hexColor or ____exports.Tips.DEFAULT_TEXT_COLOR
    if (string.find(raw, "|", nil, true) or 0) - 1 >= 0 then
        return raw
    end
    return (("|cff" .. hex) .. raw) .. "|r"
end
function Tips.isHexDigit(self, ch)
    local c = string.sub(ch, 1, 1)
    return c >= "0" and c <= "9" or c >= "a" and c <= "f" or c >= "A" and c <= "F"
end
function Tips.stripWarcraftColorCodes(self, s)
    if not s then
        return ""
    end
    local r = ""
    local i = 0
    while i < #s do
        do
            if __TS__StringCharAt(s, i) == "|" and i + 3 < #s and __TS__StringSubstring(s, i, i + 4) == "|cff" then
                local j = i + 4
                local hexDigits = 0
                while j < #s and hexDigits < 8 and ____exports.Tips:isHexDigit(__TS__StringCharAt(s, j)) do
                    hexDigits = hexDigits + 1
                    j = j + 1
                end
                if hexDigits == 6 or hexDigits == 8 then
                    i = j
                    goto __continue9
                end
            end
            if __TS__StringCharAt(s, i) == "|" and i + 1 < #s and __TS__StringSubstring(s, i, i + 2) == "|r" then
                i = i + 2
                goto __continue9
            end
            if __TS__StringCharAt(s, i) == "|" and i + 1 < #s and __TS__StringSubstring(s, i, i + 2) == "|n" then
                r = r .. "\n"
                i = i + 2
                goto __continue9
            end
            r = r .. __TS__StringCharAt(s, i)
            i = i + 1
        end
        ::__continue9::
    end
    return r
end
function Tips.estimateTextHeightPx(self, displayText, textWidthPx, lineHeightPx, charWidthPx)
    if textWidthPx <= 0 then
        return ____exports.Tips.MIN_TIPS_HEIGHT_PX
    end
    local plain = ____exports.Tips:stripWarcraftColorCodes(displayText)
    local charsPerLine = math.max(
        1,
        math.floor(textWidthPx / charWidthPx)
    )
    local parts = __TS__StringSplit(plain, "\n")
    local lineCount = 0
    for ____, part in ipairs(parts) do
        local len = #part
        if len == 0 then
            lineCount = lineCount + 1
        else
            lineCount = lineCount + math.max(
                1,
                math.ceil(len / charsPerLine)
            )
        end
    end
    local h = lineCount * lineHeightPx
    return math.max(____exports.Tips.MIN_TIPS_HEIGHT_PX, h)
end
function Tips.getInstance(self)
    if not ____exports.Tips.instance then
        ____exports.Tips.instance = __TS__New(____exports.Tips)
    end
    if not ____exports.Tips.instance.isCreated then
        ____exports.Tips.instance:create()
    end
    return ____exports.Tips.instance
end
function Tips.prototype.create(self)
    if self.isCreated then
        return
    end
    local gameUI = Frame:fromHandle(DzGetGameUI())
    if not gameUI then
        log:error("Cannot get game UI frame")
        return
    end
    local timestamp = math.floor(os.clock() * 1000)
    self.backdropFrame = Frame:createType(
        "TipsBackdrop_" .. tostring(timestamp),
        gameUI,
        0,
        "BACKDROP",
        ""
    ) or nil
    if not self.backdropFrame then
        log:error("Failed to create backdrop frame")
        return
    end
    self.backdropFrame:setSize(0.2, 0.15):setAbsPoint(FRAMEPOINT_TOPLEFT, 0.4, 0.5):setTexture(____exports.Tips.DEFAULT_BACKGROUND, 0, true):setAlpha(0)
    DzFrameSetPriority(self.backdropFrame.handle, 1000)
    self.backdropFrame:setIgnoreTrackEvents(true)
    self.iconFrame = Frame:createType(
        "TipsIcon_" .. tostring(timestamp),
        self.backdropFrame,
        0,
        "BACKDROP",
        ""
    ) or nil
    if self.iconFrame then
        self.iconFrame:setSize(0.03, 0.03):setPoint(
            FRAMEPOINT_TOPLEFT,
            self.backdropFrame,
            FRAMEPOINT_TOPLEFT,
            0.005,
            -0.005
        ):setAlpha(0)
        self.iconFrame:setIgnoreTrackEvents(true)
    end
    self.textFrame = Frame:createType(
        "TipsText_" .. tostring(timestamp),
        self.backdropFrame,
        0,
        "TEXT",
        ""
    ) or nil
    if not self.textFrame then
        log:error("Failed to create text frame")
        return
    end
    self.textFrame:setPoint(
        FRAMEPOINT_TOPLEFT,
        self.backdropFrame,
        FRAMEPOINT_TOPLEFT,
        0.005,
        -0.005
    ):setPoint(
        FRAMEPOINT_BOTTOMRIGHT,
        self.backdropFrame,
        FRAMEPOINT_BOTTOMRIGHT,
        -0.005,
        0.005
    ):setText(""):setTextAlignment(0, 50):setAlpha(0)
    self.textFrame:setIgnoreTrackEvents(true)
    self.isCreated = true
    self.isVisible = false
end
function Tips.prototype.showFromComponentInfo(self, config, componentInfo)
    self:show(
        config,
        componentInfo.x,
        componentInfo.y,
        componentInfo.width,
        componentInfo.height
    )
end
function Tips.prototype.show(self, config, targetPixelX, targetPixelY, componentWidth, componentHeight)
    if componentWidth == nil then
        componentWidth = 100
    end
    if componentHeight == nil then
        componentHeight = 40
    end
    if not self.isCreated then
        self:create()
        if not self.isCreated then
            return
        end
    end
    self:cancelTimers()
    self.currentConfig = config
    self.componentWidth = componentWidth
    self.componentHeight = componentHeight
    if self.isVisible then
        self:doShow(config, targetPixelX, targetPixelY)
        return
    end
    local delayShow = config.delayShow or ____exports.Tips.DEFAULT_DELAY_SHOW
    if delayShow > 0 then
        local timer = CreateTimer()
        self.showTimer = timer
        TimerStart(
            timer,
            delayShow,
            false,
            function()
                self:doShow(config, targetPixelX, targetPixelY)
            end
        )
    else
        self:doShow(config, targetPixelX, targetPixelY)
    end
end
function Tips.prototype.doShow(self, config, targetPixelX, targetPixelY)
    if not self.backdropFrame or not self.textFrame then
        return
    end
    self:updateContent(config)
    local position = self:calculatePosition(config, targetPixelX, targetPixelY)
    self.backdropFrame:setAbsPoint(FRAMEPOINT_TOPLEFT, position.x, position.y)
    if self.isVisible and self.currentAlpha >= 200 then
        self:setAlpha(255)
        return
    end
    self:setVisible(true)
    local animation = config.animation or ____exports.TipsAnimation.FADE
    self:playAnimation(animation, true)
    self.isVisible = true
end
function Tips.prototype.hide(self)
    if not self.isCreated then
        return
    end
    self:cancelTimers()
    if not self.isVisible then
        return
    end
    local ____opt_0 = self.currentConfig
    local delayHide = ____opt_0 and ____opt_0.delayHide or ____exports.Tips.DEFAULT_DELAY_HIDE
    if delayHide > 0 then
        local timer = CreateTimer()
        self.hideTimer = timer
        TimerStart(
            timer,
            delayHide,
            false,
            function()
                self:doHide()
            end
        )
    else
        self:doHide()
    end
end
function Tips.prototype.doHide(self)
    if not self.isVisible then
        return
    end
    local ____opt_2 = self.currentConfig
    local animation = ____opt_2 and ____opt_2.animation or ____exports.TipsAnimation.FADE
    self:playAnimation(animation, false)
    self.isVisible = false
    self.currentConfig = nil
    self:setVisible(false)
end
function Tips.prototype.updateContent(self, config)
    if not self.backdropFrame or not self.textFrame then
        return
    end
    local widthPx = config.width or ____exports.Tips.DEFAULT_WIDTH
    local maxHeightPx = config.maxHeight or ____exports.Tips.DEFAULT_MAX_HEIGHT
    local autoHeight = config.autoHeight ~= false
    local lineHeightPx = config.lineHeightPx or ____exports.Tips.DEFAULT_LINE_HEIGHT_PX
    local charWidthPx = config.charWidthPx or ____exports.Tips.DEFAULT_CHAR_WIDTH_PX
    local wc3Width = widthPx / ScreenCoordinates.STANDARD_WIDTH * ScreenCoordinates.WC3_SCREEN_WIDTH
    local textColor = config.textColor or ____exports.Tips.DEFAULT_TEXT_COLOR
    local displayText = ____exports.Tips:formatDisplayText(config.text, textColor)
    local iconSizePx = 32
    local iconPaddingPx = 8
    local leftPaddingPx = 8
    local topPaddingPx = 8
    local rightPaddingPx = 8
    local bottomPaddingPx = 8
    local wc3IconSize = iconSizePx / ScreenCoordinates.STANDARD_WIDTH * ScreenCoordinates.WC3_SCREEN_WIDTH
    local wc3IconPadding = iconPaddingPx / ScreenCoordinates.STANDARD_WIDTH * ScreenCoordinates.WC3_SCREEN_WIDTH
    local wc3LeftPadding = leftPaddingPx / ScreenCoordinates.STANDARD_WIDTH * ScreenCoordinates.WC3_SCREEN_WIDTH
    local wc3TopPadding = topPaddingPx / ScreenCoordinates.STANDARD_HEIGHT * ScreenCoordinates.WC3_SCREEN_HEIGHT
    local wc3RightPadding = rightPaddingPx / ScreenCoordinates.STANDARD_WIDTH * ScreenCoordinates.WC3_SCREEN_WIDTH
    local wc3BottomPadding = bottomPaddingPx / ScreenCoordinates.STANDARD_HEIGHT * ScreenCoordinates.WC3_SCREEN_HEIGHT
    local textWidthPx
    local backdropHeightPx
    if config.icon then
        textWidthPx = widthPx - leftPaddingPx - iconSizePx - iconPaddingPx - rightPaddingPx
        if autoHeight then
            local textBlockH = ____exports.Tips:estimateTextHeightPx(displayText, textWidthPx, lineHeightPx, charWidthPx)
            local innerH = math.max(iconSizePx, textBlockH)
            backdropHeightPx = topPaddingPx + innerH + bottomPaddingPx
            backdropHeightPx = math.min(backdropHeightPx, maxHeightPx)
            backdropHeightPx = math.max(backdropHeightPx, ____exports.Tips.MIN_TIPS_HEIGHT_PX)
        else
            backdropHeightPx = maxHeightPx
        end
        if self.iconFrame then
            self.iconFrame:setVisible(true)
            self.iconFrame:setSize(wc3IconSize, wc3IconSize):setTexture(config.icon, 0, true):clearPoints():setPoint(
                FRAMEPOINT_TOPLEFT,
                self.backdropFrame,
                FRAMEPOINT_TOPLEFT,
                wc3LeftPadding,
                -wc3TopPadding
            ):setAlpha(0)
        end
        local textLeftOffset = wc3LeftPadding + wc3IconSize + wc3IconPadding
        local textHeightPx = math.max(1, backdropHeightPx - topPaddingPx - bottomPaddingPx)
        local wc3TextHeight = textHeightPx / ScreenCoordinates.STANDARD_HEIGHT * ScreenCoordinates.WC3_SCREEN_HEIGHT
        local textWidthWc3 = textWidthPx / ScreenCoordinates.STANDARD_WIDTH * ScreenCoordinates.WC3_SCREEN_WIDTH
        self.textFrame:clearPoints()
        self.textFrame:setPoint(
            FRAMEPOINT_TOPLEFT,
            self.backdropFrame,
            FRAMEPOINT_TOPLEFT,
            textLeftOffset,
            -wc3TopPadding
        )
        self.textFrame:setSize(textWidthWc3, wc3TextHeight)
    else
        textWidthPx = widthPx - leftPaddingPx - rightPaddingPx
        if autoHeight then
            local textBlockH = ____exports.Tips:estimateTextHeightPx(displayText, textWidthPx, lineHeightPx, charWidthPx)
            backdropHeightPx = topPaddingPx + textBlockH + bottomPaddingPx
            backdropHeightPx = math.min(backdropHeightPx, maxHeightPx)
            backdropHeightPx = math.max(backdropHeightPx, ____exports.Tips.MIN_TIPS_HEIGHT_PX)
        else
            backdropHeightPx = maxHeightPx
        end
        if self.iconFrame then
            self.iconFrame:setVisible(false)
        end
        local textHeightPx = math.max(1, backdropHeightPx - topPaddingPx - bottomPaddingPx)
        local wc3TextHeight = textHeightPx / ScreenCoordinates.STANDARD_HEIGHT * ScreenCoordinates.WC3_SCREEN_HEIGHT
        local textWidthWc3 = textWidthPx / ScreenCoordinates.STANDARD_WIDTH * ScreenCoordinates.WC3_SCREEN_WIDTH
        self.textFrame:clearPoints()
        self.textFrame:setPoint(
            FRAMEPOINT_TOPLEFT,
            self.backdropFrame,
            FRAMEPOINT_TOPLEFT,
            wc3LeftPadding,
            -wc3TopPadding
        )
        self.textFrame:setSize(textWidthWc3, wc3TextHeight)
    end
    local wc3BackdropHeight = backdropHeightPx / ScreenCoordinates.STANDARD_HEIGHT * ScreenCoordinates.WC3_SCREEN_HEIGHT
    self.backdropFrame:setSize(wc3Width, wc3BackdropHeight):setTexture(config.background or ____exports.Tips.DEFAULT_BACKGROUND, 0, true)
    self.textFrame:setText(displayText):setTextAlignment(0, 0)
    self.lastTipsWidthPx = widthPx
    self.lastTipsHeightPx = backdropHeightPx
end
function Tips.prototype.calculatePosition(self, config, targetPixelX, targetPixelY)
    local pixelX
    local pixelY
    if targetPixelX ~= nil and targetPixelY ~= nil then
        pixelX = targetPixelX
        pixelY = targetPixelY
    else
        pixelX = ScreenCoordinates.STANDARD_WIDTH / 2
        pixelY = ScreenCoordinates.STANDARD_HEIGHT / 2
    end
    local tipsWidth = self.lastTipsWidthPx
    local tipsHeight = self.lastTipsHeightPx
    local offset = config.offset or ____exports.Tips.DEFAULT_OFFSET
    local position = config.position or ____exports.TipsPosition.AUTO
    if position == ____exports.TipsPosition.AUTO then
        position = self:detectBestPosition(
            pixelX,
            pixelY,
            tipsWidth,
            tipsHeight,
            offset
        )
    end
    local finalPixelX
    local finalPixelY
    repeat
        local ____switch63 = position
        local ____cond63 = ____switch63 == ____exports.TipsPosition.RIGHT
        if ____cond63 then
            finalPixelX = pixelX + self.componentWidth + offset
            finalPixelY = pixelY
            break
        end
        ____cond63 = ____cond63 or ____switch63 == ____exports.TipsPosition.LEFT
        if ____cond63 then
            finalPixelX = pixelX - tipsWidth - offset
            finalPixelY = pixelY
            break
        end
        ____cond63 = ____cond63 or ____switch63 == ____exports.TipsPosition.TOP
        if ____cond63 then
            finalPixelX = pixelX
            finalPixelY = pixelY - tipsHeight - offset
            break
        end
        ____cond63 = ____cond63 or ____switch63 == ____exports.TipsPosition.BOTTOM
        if ____cond63 then
            finalPixelX = pixelX
            finalPixelY = pixelY + self.componentHeight + offset
            break
        end
        do
            finalPixelX = pixelX + self.componentWidth + offset
            finalPixelY = pixelY
        end
    until true
    finalPixelX = math.max(
        10,
        math.min(finalPixelX, ScreenCoordinates.STANDARD_WIDTH - tipsWidth - 10)
    )
    finalPixelY = math.max(
        10,
        math.min(finalPixelY, ScreenCoordinates.STANDARD_HEIGHT - tipsHeight - 10)
    )
    local wc3X = finalPixelX / ScreenCoordinates.STANDARD_WIDTH * ScreenCoordinates.WC3_SCREEN_WIDTH
    local wc3Y = ScreenCoordinates.WC3_SCREEN_HEIGHT - finalPixelY / ScreenCoordinates.STANDARD_HEIGHT * ScreenCoordinates.WC3_SCREEN_HEIGHT
    self.finalPositionX = wc3X
    self.finalPositionY = wc3Y
    return {x = wc3X, y = wc3Y}
end
function Tips.prototype.detectBestPosition(self, pixelX, pixelY, tipsWidth, tipsHeight, offset)
    local screenWidth = ScreenCoordinates.STANDARD_WIDTH
    local screenHeight = ScreenCoordinates.STANDARD_HEIGHT
    local componentCenterX = pixelX + self.componentWidth / 2
    local componentCenterY = pixelY + self.componentHeight / 2
    local spaceRight = screenWidth - (pixelX + self.componentWidth) - offset
    local spaceLeft = pixelX - offset
    local spaceTop = pixelY - offset
    local spaceBottom = screenHeight - (pixelY + self.componentHeight) - offset
    local isLeft = componentCenterX < screenWidth / 3
    local isRight = componentCenterX > screenWidth * 2 / 3
    local isTop = componentCenterY < screenHeight / 3
    local isBottom = componentCenterY > screenHeight * 2 / 3
    if isRight and isTop then
        if spaceLeft >= tipsWidth then
            return ____exports.TipsPosition.LEFT
        elseif spaceBottom >= tipsHeight then
            return ____exports.TipsPosition.BOTTOM
        end
    end
    if isRight and isBottom then
        if spaceLeft >= tipsWidth then
            return ____exports.TipsPosition.LEFT
        elseif spaceTop >= tipsHeight then
            return ____exports.TipsPosition.TOP
        end
    end
    if isLeft and isTop then
        if spaceRight >= tipsWidth then
            return ____exports.TipsPosition.RIGHT
        elseif spaceBottom >= tipsHeight then
            return ____exports.TipsPosition.BOTTOM
        end
    end
    if isLeft and isBottom then
        if spaceRight >= tipsWidth then
            return ____exports.TipsPosition.RIGHT
        elseif spaceTop >= tipsHeight then
            return ____exports.TipsPosition.TOP
        end
    end
    if isRight and spaceLeft >= tipsWidth then
        return ____exports.TipsPosition.LEFT
    end
    if isLeft and spaceRight >= tipsWidth then
        return ____exports.TipsPosition.RIGHT
    end
    if isTop and spaceBottom >= tipsHeight then
        return ____exports.TipsPosition.BOTTOM
    end
    if isBottom and spaceTop >= tipsHeight then
        return ____exports.TipsPosition.TOP
    end
    if spaceRight >= tipsWidth then
        return ____exports.TipsPosition.RIGHT
    elseif spaceLeft >= tipsWidth then
        return ____exports.TipsPosition.LEFT
    elseif spaceBottom >= tipsHeight then
        return ____exports.TipsPosition.BOTTOM
    elseif spaceTop >= tipsHeight then
        return ____exports.TipsPosition.TOP
    end
    local maxSpace = math.max(spaceRight, spaceLeft, spaceTop, spaceBottom)
    if maxSpace == spaceRight then
        return ____exports.TipsPosition.RIGHT
    end
    if maxSpace == spaceLeft then
        return ____exports.TipsPosition.LEFT
    end
    if maxSpace == spaceBottom then
        return ____exports.TipsPosition.BOTTOM
    end
    return ____exports.TipsPosition.TOP
end
function Tips.prototype.playAnimation(self, animation, isShowing)
    if self.animationTimer then
        DestroyTimer(self.animationTimer)
        self.animationTimer = nil
    end
    self.animationProgress = 0
    self.currentAlpha = isShowing and 0 or 255
    self.targetAlpha = isShowing and 255 or 0
    if animation == ____exports.TipsAnimation.NONE then
        self:setAlpha(self.targetAlpha)
        if not isShowing then
            self:setVisible(false)
        end
        return
    end
    local slideDistance = 20
    local slideOffsetWC3 = ScreenCoordinates:pixelToWC3(slideDistance, 0).x
    local startOffsetX = 0
    local startOffsetY = 0
    if isShowing then
        repeat
            local ____switch93 = animation
            local ____cond93 = ____switch93 == ____exports.TipsAnimation.SLIDE_RIGHT
            if ____cond93 then
                startOffsetX = -slideOffsetWC3
                break
            end
            ____cond93 = ____cond93 or ____switch93 == ____exports.TipsAnimation.SLIDE_LEFT
            if ____cond93 then
                startOffsetX = slideOffsetWC3
                break
            end
            ____cond93 = ____cond93 or ____switch93 == ____exports.TipsAnimation.SLIDE_TOP
            if ____cond93 then
                startOffsetY = -slideOffsetWC3
                break
            end
            ____cond93 = ____cond93 or ____switch93 == ____exports.TipsAnimation.SLIDE_BOTTOM
            if ____cond93 then
                startOffsetY = slideOffsetWC3
                break
            end
        until true
    end
    local targetX = self.finalPositionX
    local targetY = self.finalPositionY
    local interval = 1 / ____exports.Tips.ANIMATION_FPS
    local totalSteps = ____exports.Tips.ANIMATION_DURATION * ____exports.Tips.ANIMATION_FPS
    local timer = CreateTimer()
    self.animationTimer = timer
    TimerStart(
        timer,
        interval,
        true,
        function()
            self.animationProgress = self.animationProgress + 1 / totalSteps
            if self.animationProgress >= 1 then
                self.animationProgress = 1
                self:setAlpha(self.targetAlpha)
                if self.backdropFrame and animation ~= ____exports.TipsAnimation.FADE then
                    self.backdropFrame:clearPoints()
                    self.backdropFrame:setAbsPoint(FRAMEPOINT_TOPLEFT, targetX, targetY)
                end
                if not isShowing then
                    self:setVisible(false)
                end
                if self.animationTimer then
                    DestroyTimer(self.animationTimer)
                    self.animationTimer = nil
                end
                return
            end
            local eased = 1 - (1 - self.animationProgress) ^ 3
            local alpha = self.currentAlpha + (self.targetAlpha - self.currentAlpha) * eased
            self:setAlpha(math.floor(alpha))
            if animation ~= ____exports.TipsAnimation.FADE and self.backdropFrame then
                local currentOffsetX = startOffsetX * (1 - eased)
                local currentOffsetY = startOffsetY * (1 - eased)
                self.backdropFrame:clearPoints()
                self.backdropFrame:setAbsPoint(FRAMEPOINT_TOPLEFT, targetX + currentOffsetX, targetY + currentOffsetY)
            end
        end
    )
end
function Tips.prototype.setAlpha(self, alpha)
    if self.backdropFrame then
        self.backdropFrame:setAlpha(alpha)
    end
    if self.textFrame then
        self.textFrame:setAlpha(alpha)
    end
    local ____self_iconFrame_6 = self.iconFrame
    if ____self_iconFrame_6 then
        local ____opt_4 = self.currentConfig
        ____self_iconFrame_6 = ____opt_4 and ____opt_4.icon
    end
    if ____self_iconFrame_6 then
        self.iconFrame:setAlpha(alpha)
    end
end
function Tips.prototype.setVisible(self, visible)
    if self.backdropFrame then
        self.backdropFrame:setVisible(visible)
    end
    if self.textFrame then
        self.textFrame:setVisible(visible)
    end
    if not visible and self.iconFrame then
        self.iconFrame:setVisible(false)
    end
end
function Tips.prototype.cancelTimers(self)
    if self.showTimer then
        DestroyTimer(self.showTimer)
        self.showTimer = nil
    end
    if self.hideTimer then
        DestroyTimer(self.hideTimer)
        self.hideTimer = nil
    end
    if self.animationTimer then
        DestroyTimer(self.animationTimer)
        self.animationTimer = nil
    end
end
function Tips.prototype.destroy(self)
    self:cancelTimers()
    if self.backdropFrame then
        self.backdropFrame:destroy()
        self.backdropFrame = nil
    end
    if self.iconFrame then
        self.iconFrame:destroy()
        self.iconFrame = nil
    end
    if self.textFrame then
        self.textFrame:destroy()
        self.textFrame = nil
    end
    self.isCreated = false
    self.isVisible = false
    ____exports.Tips.instance = nil
end
function Tips.prototype.getIsVisible(self)
    return self.isVisible
end
Tips.instance = nil
Tips.DEFAULT_WIDTH = 300
Tips.DEFAULT_MAX_HEIGHT = 400
Tips.DEFAULT_BACKGROUND = "UI\\Widgets\\EscMenu\\Human\\editbox-background.blp"
Tips.DEFAULT_TEXT_COLOR = "FFFFFF"
Tips.DEFAULT_DELAY_SHOW = 0.3
Tips.DEFAULT_DELAY_HIDE = 0.1
Tips.DEFAULT_OFFSET = 10
Tips.DEFAULT_LINE_HEIGHT_PX = 18
Tips.DEFAULT_CHAR_WIDTH_PX = 9
Tips.MIN_TIPS_HEIGHT_PX = 32
Tips.ANIMATION_DURATION = 0.15
Tips.ANIMATION_FPS = 30
return ____exports

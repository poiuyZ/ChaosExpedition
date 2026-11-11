local ____lualib = require("lualib_bundle")
local __TS__Class = ____lualib.__TS__Class
local ____exports = {}
local ____ScreenCoordinates = require("src.system.ui.ScreenCoordinates")
local ScreenCoordinates = ____ScreenCoordinates.ScreenCoordinates
____exports.UILayout = __TS__Class()
local UILayout = ____exports.UILayout
UILayout.name = "UILayout"
function UILayout.prototype.____constructor(self)
end
function UILayout.setFramePosition(self, frame, preset, anchorPoint)
    local pixelPos = ScreenCoordinates:getPresetPosition(preset)
    local wc3Pos = ScreenCoordinates:pixelToWC3(pixelPos.x, pixelPos.y, ScreenCoordinates.ORIGIN_TOP_LEFT)
    local resolvedAnchor = ____exports.UILayout:resolveAnchor(preset, anchorPoint)
    frame:setAbsPoint(resolvedAnchor, wc3Pos.x, wc3Pos.y)
end
function UILayout.setFrame(self, frame, preset, pixelWidth, pixelHeight, anchorPoint)
    self:setFramePosition(frame, preset, anchorPoint)
    if pixelWidth ~= nil and pixelHeight ~= nil then
        self:setFrameSize(frame, pixelWidth, pixelHeight)
    end
end
function UILayout.setFrameWithinScreen(self, frame, preset, pixelWidth, pixelHeight, anchorPoint)
    local pixelPos = ScreenCoordinates:getPresetPosition(preset)
    local wc3Pos = ScreenCoordinates:pixelToWC3(pixelPos.x, pixelPos.y, ScreenCoordinates.ORIGIN_TOP_LEFT)
    local resolvedAnchor = ____exports.UILayout:resolveAnchor(preset, anchorPoint)
    local anchorFactors = ____exports.UILayout:resolveAnchorFactors(resolvedAnchor)
    local size = ScreenCoordinates:pixelSizeToWC3(pixelWidth, pixelHeight)
    local clampedX = math.min(
        math.max(wc3Pos.x, anchorFactors.x * size.width),
        ScreenCoordinates.WC3_SCREEN_WIDTH - (1 - anchorFactors.x) * size.width
    )
    local clampedY = math.min(
        math.max(wc3Pos.y, anchorFactors.y * size.height),
        ScreenCoordinates.WC3_SCREEN_HEIGHT - (1 - anchorFactors.y) * size.height
    )
    frame:setAbsPoint(resolvedAnchor, clampedX, clampedY)
    frame:setSize(size.width, size.height)
end
function UILayout.centerFrame(self, frame, pixelWidth, pixelHeight)
    self:setFrame(
        frame,
        "CENTER",
        pixelWidth,
        pixelHeight,
        4
    )
end
function UILayout.setFrameSize(self, frame, pixelWidth, pixelHeight)
    local size = ScreenCoordinates:pixelSizeToWC3(pixelWidth, pixelHeight)
    frame:setSize(size.width, size.height)
end
function UILayout.setFrameRect(self, frame, pixelRect, anchorPoint)
    if anchorPoint == nil then
        anchorPoint = 0
    end
    local wc3Pos = ScreenCoordinates:pixelToWC3(pixelRect.x, pixelRect.y, ScreenCoordinates.ORIGIN_TOP_LEFT)
    frame:setAbsPoint(anchorPoint, wc3Pos.x, wc3Pos.y)
    self:setFrameSize(frame, pixelRect.width, pixelRect.height)
end
function UILayout.resolveAnchor(self, preset, anchorPoint)
    if anchorPoint ~= nil then
        return anchorPoint
    end
    repeat
        local ____switch12 = preset
        local ____cond12 = ____switch12 == "TOP_LEFT" or ____switch12 == "UI_TOP_LEFT"
        if ____cond12 then
            return 0
        end
        ____cond12 = ____cond12 or ____switch12 == "TOP_CENTER"
        if ____cond12 then
            return 1
        end
        ____cond12 = ____cond12 or (____switch12 == "TOP_RIGHT" or ____switch12 == "UI_TOP_RIGHT")
        if ____cond12 then
            return 2
        end
        ____cond12 = ____cond12 or ____switch12 == "LEFT_CENTER"
        if ____cond12 then
            return 3
        end
        ____cond12 = ____cond12 or ____switch12 == "CENTER"
        if ____cond12 then
            return 4
        end
        ____cond12 = ____cond12 or ____switch12 == "RIGHT_CENTER"
        if ____cond12 then
            return 5
        end
        ____cond12 = ____cond12 or (____switch12 == "BOTTOM_LEFT" or ____switch12 == "UI_BOTTOM_LEFT")
        if ____cond12 then
            return 6
        end
        ____cond12 = ____cond12 or ____switch12 == "BOTTOM_CENTER"
        if ____cond12 then
            return 7
        end
        ____cond12 = ____cond12 or (____switch12 == "BOTTOM_RIGHT" or ____switch12 == "UI_BOTTOM_RIGHT")
        if ____cond12 then
            return 8
        end
        do
            return 4
        end
    until true
end
function UILayout.resolveAnchorFactors(self, anchorPoint)
    repeat
        local ____switch14 = anchorPoint
        local ____cond14 = ____switch14 == 0
        if ____cond14 then
            return {x = 0, y = 1}
        end
        ____cond14 = ____cond14 or ____switch14 == 1
        if ____cond14 then
            return {x = 0.5, y = 1}
        end
        ____cond14 = ____cond14 or ____switch14 == 2
        if ____cond14 then
            return {x = 1, y = 1}
        end
        ____cond14 = ____cond14 or ____switch14 == 3
        if ____cond14 then
            return {x = 0, y = 0.5}
        end
        ____cond14 = ____cond14 or ____switch14 == 4
        if ____cond14 then
            return {x = 0.5, y = 0.5}
        end
        ____cond14 = ____cond14 or ____switch14 == 5
        if ____cond14 then
            return {x = 1, y = 0.5}
        end
        ____cond14 = ____cond14 or ____switch14 == 6
        if ____cond14 then
            return {x = 0, y = 0}
        end
        ____cond14 = ____cond14 or ____switch14 == 7
        if ____cond14 then
            return {x = 0.5, y = 0}
        end
        ____cond14 = ____cond14 or ____switch14 == 8
        if ____cond14 then
            return {x = 1, y = 0}
        end
        do
            return {x = 0.5, y = 0.5}
        end
    until true
end
UILayout.BUTTON_SIZES = {SMALL = {width = 80, height = 32}, MEDIUM = {width = 120, height = 40}, LARGE = {width = 160, height = 48}, EXTRA_LARGE = {width = 200, height = 56}}
UILayout.PANEL_SIZES = {SMALL = {width = 300, height = 200}, MEDIUM = {width = 500, height = 350}, LARGE = {width = 700, height = 500}, FULLSCREEN = {width = 1820, height = 980}}
UILayout.SPACING = {
    TINY = 4,
    SMALL = 8,
    MEDIUM = 16,
    LARGE = 24,
    EXTRA_LARGE = 32
}
return ____exports

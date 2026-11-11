local ____lualib = require("lualib_bundle")
local __TS__Class = ____lualib.__TS__Class
local Error = ____lualib.Error
local RangeError = ____lualib.RangeError
local ReferenceError = ____lualib.ReferenceError
local SyntaxError = ____lualib.SyntaxError
local TypeError = ____lualib.TypeError
local URIError = ____lualib.URIError
local __TS__New = ____lualib.__TS__New
local ____exports = {}
--- 屏幕坐标系统转换工具
-- 将常规的像素坐标转换为魔兽争霸3的相对坐标
____exports.ScreenCoordinates = __TS__Class()
local ScreenCoordinates = ____exports.ScreenCoordinates
ScreenCoordinates.name = "ScreenCoordinates"
function ScreenCoordinates.prototype.____constructor(self)
end
function ScreenCoordinates.pixelToWC3(self, pixelX, pixelY, origin)
    if origin == nil then
        origin = ____exports.ScreenCoordinates.ORIGIN_TOP_LEFT
    end
    local wc3X
    local wc3Y
    repeat
        local ____switch4 = origin
        local centerX, centerY
        local ____cond4 = ____switch4 == ____exports.ScreenCoordinates.ORIGIN_TOP_LEFT
        if ____cond4 then
            wc3X = pixelX / ____exports.ScreenCoordinates.STANDARD_WIDTH * ____exports.ScreenCoordinates.WC3_SCREEN_WIDTH
            wc3Y = ____exports.ScreenCoordinates.WC3_SCREEN_HEIGHT - pixelY / ____exports.ScreenCoordinates.STANDARD_HEIGHT * ____exports.ScreenCoordinates.WC3_SCREEN_HEIGHT
            break
        end
        ____cond4 = ____cond4 or ____switch4 == ____exports.ScreenCoordinates.ORIGIN_BOTTOM_LEFT
        if ____cond4 then
            wc3X = pixelX / ____exports.ScreenCoordinates.STANDARD_WIDTH * ____exports.ScreenCoordinates.WC3_SCREEN_WIDTH
            wc3Y = pixelY / ____exports.ScreenCoordinates.STANDARD_HEIGHT * ____exports.ScreenCoordinates.WC3_SCREEN_HEIGHT
            break
        end
        ____cond4 = ____cond4 or ____switch4 == ____exports.ScreenCoordinates.ORIGIN_CENTER
        if ____cond4 then
            centerX = ____exports.ScreenCoordinates.STANDARD_WIDTH / 2
            centerY = ____exports.ScreenCoordinates.STANDARD_HEIGHT / 2
            wc3X = (pixelX + centerX) / ____exports.ScreenCoordinates.STANDARD_WIDTH * ____exports.ScreenCoordinates.WC3_SCREEN_WIDTH
            wc3Y = ____exports.ScreenCoordinates.WC3_SCREEN_HEIGHT - (pixelY + centerY) / ____exports.ScreenCoordinates.STANDARD_HEIGHT * ____exports.ScreenCoordinates.WC3_SCREEN_HEIGHT
            break
        end
        do
            error(
                __TS__New(Error, "Unsupported origin type: " .. origin),
                0
            )
        end
    until true
    return {
        x = math.max(
            0,
            math.min(____exports.ScreenCoordinates.WC3_SCREEN_WIDTH, wc3X)
        ),
        y = math.max(
            0,
            math.min(____exports.ScreenCoordinates.WC3_SCREEN_HEIGHT, wc3Y)
        )
    }
end
function ScreenCoordinates.wc3ToPixel(self, wc3X, wc3Y, origin)
    if origin == nil then
        origin = ____exports.ScreenCoordinates.ORIGIN_TOP_LEFT
    end
    local pixelX
    local pixelY
    repeat
        local ____switch6 = origin
        local centerX, centerY
        local ____cond6 = ____switch6 == ____exports.ScreenCoordinates.ORIGIN_TOP_LEFT
        if ____cond6 then
            pixelX = wc3X / ____exports.ScreenCoordinates.WC3_SCREEN_WIDTH * ____exports.ScreenCoordinates.STANDARD_WIDTH
            pixelY = (1 - wc3Y / ____exports.ScreenCoordinates.WC3_SCREEN_HEIGHT) * ____exports.ScreenCoordinates.STANDARD_HEIGHT
            break
        end
        ____cond6 = ____cond6 or ____switch6 == ____exports.ScreenCoordinates.ORIGIN_BOTTOM_LEFT
        if ____cond6 then
            pixelX = wc3X / ____exports.ScreenCoordinates.WC3_SCREEN_WIDTH * ____exports.ScreenCoordinates.STANDARD_WIDTH
            pixelY = wc3Y / ____exports.ScreenCoordinates.WC3_SCREEN_HEIGHT * ____exports.ScreenCoordinates.STANDARD_HEIGHT
            break
        end
        ____cond6 = ____cond6 or ____switch6 == ____exports.ScreenCoordinates.ORIGIN_CENTER
        if ____cond6 then
            centerX = ____exports.ScreenCoordinates.STANDARD_WIDTH / 2
            centerY = ____exports.ScreenCoordinates.STANDARD_HEIGHT / 2
            pixelX = wc3X / ____exports.ScreenCoordinates.WC3_SCREEN_WIDTH * ____exports.ScreenCoordinates.STANDARD_WIDTH - centerX
            pixelY = (1 - wc3Y / ____exports.ScreenCoordinates.WC3_SCREEN_HEIGHT) * ____exports.ScreenCoordinates.STANDARD_HEIGHT - centerY
            break
        end
        do
            error(
                __TS__New(Error, "Unsupported origin type: " .. origin),
                0
            )
        end
    until true
    return {
        x = math.floor(pixelX + 0.5),
        y = math.floor(pixelY + 0.5)
    }
end
function ScreenCoordinates.getPresetPosition(self, preset)
    local positions = {
        TOP_LEFT = {x = 0, y = 0},
        TOP_RIGHT = {x = 1820, y = 0},
        BOTTOM_LEFT = {x = 0, y = 1080},
        BOTTOM_RIGHT = {x = 1820, y = 1080},
        TOP_CENTER = {x = 960, y = 0},
        BOTTOM_CENTER = {x = 960, y = 1080},
        LEFT_CENTER = {x = 0, y = 540},
        RIGHT_CENTER = {x = 1820, y = 540},
        CENTER = {x = 960, y = 540},
        UI_TOP_LEFT = {x = 50, y = 50},
        UI_TOP_RIGHT = {x = 1770, y = 50},
        UI_BOTTOM_LEFT = {x = 50, y = 950},
        UI_BOTTOM_RIGHT = {x = 1770, y = 950}
    }
    if not (positions[preset] ~= nil) then
        error(
            __TS__New(Error, "Unknown preset position: " .. preset),
            0
        )
    end
    return positions[preset]
end
function ScreenCoordinates.distance(self, x1, y1, x2, y2)
    return math.sqrt((x2 - x1) ^ 2 + (y2 - y1) ^ 2)
end
function ScreenCoordinates.isInRect(self, pointX, pointY, rectX, rectY, rectWidth, rectHeight)
    return pointX >= rectX and pointX <= rectX + rectWidth and pointY >= rectY and pointY <= rectY + rectHeight
end
function ScreenCoordinates.pixelSizeToWC3(self, pixelWidth, pixelHeight)
    return {width = pixelWidth / ____exports.ScreenCoordinates.STANDARD_WIDTH * ____exports.ScreenCoordinates.WC3_SCREEN_WIDTH, height = pixelHeight / ____exports.ScreenCoordinates.STANDARD_HEIGHT * ____exports.ScreenCoordinates.WC3_SCREEN_HEIGHT}
end
function ScreenCoordinates.wc3SizeToPixel(self, wc3Width, wc3Height)
    return {
        width = math.floor(wc3Width / ____exports.ScreenCoordinates.WC3_SCREEN_WIDTH * ____exports.ScreenCoordinates.STANDARD_WIDTH + 0.5),
        height = math.floor(wc3Height / ____exports.ScreenCoordinates.WC3_SCREEN_HEIGHT * ____exports.ScreenCoordinates.STANDARD_HEIGHT + 0.5)
    }
end
ScreenCoordinates.WC3_SCREEN_WIDTH = 0.8
ScreenCoordinates.WC3_SCREEN_HEIGHT = 0.6
ScreenCoordinates.STANDARD_WIDTH = 1920
ScreenCoordinates.STANDARD_HEIGHT = 1080
ScreenCoordinates.ORIGIN_TOP_LEFT = "TOP_LEFT"
ScreenCoordinates.ORIGIN_BOTTOM_LEFT = "BOTTOM_LEFT"
ScreenCoordinates.ORIGIN_CENTER = "CENTER"
return ____exports

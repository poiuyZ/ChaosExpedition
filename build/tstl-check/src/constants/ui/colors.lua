local ____lualib = require("lualib_bundle")
local __TS__Class = ____lualib.__TS__Class
local __TS__NumberToString = ____lualib.__TS__NumberToString
local __TS__StringReplace = ____lualib.__TS__StringReplace
local __TS__StringSubstring = ____lualib.__TS__StringSubstring
local __TS__ParseInt = ____lualib.__TS__ParseInt
local ____exports = {}
--- UI颜色常量定义
____exports.COLOR_WHITE = "#FFFFFF"
____exports.COLOR_BLACK = "#000000"
____exports.COLOR_RED = "#FF0000"
____exports.COLOR_GREEN = "#00FF00"
____exports.COLOR_BLUE = "#0000FF"
____exports.COLOR_YELLOW = "#FFFF00"
____exports.COLOR_CYAN = "#00FFFF"
____exports.COLOR_MAGENTA = "#FF00FF"
____exports.PLAYER_COLOR_RED = "#FF0303"
____exports.PLAYER_COLOR_BLUE = "#0042FF"
____exports.PLAYER_COLOR_TEAL = "#1CE6B9"
____exports.PLAYER_COLOR_PURPLE = "#540081"
____exports.PLAYER_COLOR_YELLOW = "#FFFC01"
____exports.PLAYER_COLOR_ORANGE = "#FEBA0E"
____exports.PLAYER_COLOR_GREEN = "#20C000"
____exports.PLAYER_COLOR_PINK = "#E55BB0"
____exports.PLAYER_COLOR_GRAY = "#959697"
____exports.PLAYER_COLOR_LIGHT_BLUE = "#7EBFF1"
____exports.PLAYER_COLOR_DARK_GREEN = "#106246"
____exports.PLAYER_COLOR_BROWN = "#4E2A04"
____exports.UI_COLOR_PRIMARY = "#1890FF"
____exports.UI_COLOR_SUCCESS = "#52C41A"
____exports.UI_COLOR_WARNING = "#FAAD14"
____exports.UI_COLOR_ERROR = "#FF4D4F"
____exports.UI_COLOR_INFO = "#1890FF"
____exports.ALPHA_TRANSPARENT = 0
____exports.ALPHA_QUARTER = 64
____exports.ALPHA_HALF = 128
____exports.ALPHA_THREE_QUARTERS = 192
____exports.ALPHA_OPAQUE = 255
____exports.ColorUtils = __TS__Class()
local ColorUtils = ____exports.ColorUtils
ColorUtils.name = "ColorUtils"
function ColorUtils.prototype.____constructor(self)
end
function ColorUtils.rgbToHex(self, r, g, b)
    return "#" .. string.sub(
        __TS__NumberToString((1 << 24) + (r << 16) + (g << 8) + b, 16),
        2
    )
end
function ColorUtils.hexToRgba(self, hex, alpha)
    if alpha == nil then
        alpha = 255
    end
    local cleanHex = __TS__StringReplace(hex, "#", "")
    if #cleanHex ~= 6 then
        return {r = 0, g = 0, b = 0, a = alpha}
    end
    local r = __TS__ParseInt(
        __TS__StringSubstring(cleanHex, 0, 2),
        16
    )
    local g = __TS__ParseInt(
        __TS__StringSubstring(cleanHex, 2, 4),
        16
    )
    local b = __TS__ParseInt(
        __TS__StringSubstring(cleanHex, 4, 6),
        16
    )
    return {r = r, g = g, b = b, a = alpha}
end
function ColorUtils.getPlayerColorCode(self, playerIndex)
    local colors = {
        "|cFFFF0303",
        "|cFF0042FF",
        "|cFF1CE6B9",
        "|cFF540081",
        "|cFFFFFC01",
        "|cFFFEBA0E",
        "|cFF20C000",
        "|cFFE55BB0",
        "|cFF959697",
        "|cFF7EBFF1",
        "|cFF106246",
        "|cFF4E2A04"
    }
    return colors[playerIndex + 1] or "|cFFFFFFFF"
end
return ____exports

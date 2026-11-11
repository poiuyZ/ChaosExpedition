local ____lualib = require("lualib_bundle")
local __TS__New = ____lualib.__TS__New
local __TS__NumberToFixed = ____lualib.__TS__NumberToFixed
local __TS__ObjectEntries = ____lualib.__TS__ObjectEntries
local __TS__ArrayForEach = ____lualib.__TS__ArrayForEach
local ____exports = {}
local ____Button = require("src.system.ui.component.Button")
local Button = ____Button.Button
local ____ScreenCoordinates = require("src.system.ui.ScreenCoordinates")
local ScreenCoordinates = ____ScreenCoordinates.ScreenCoordinates
local ____UILayout = require("src.system.ui.UILayout")
local UILayout = ____UILayout.UILayout
function ____exports.testButton()
    print("=== Button Component Test ===")
    local basicButton = __TS__New(
        Button,
        "Basic Button",
        100,
        100,
        120,
        40,
        ScreenCoordinates.ORIGIN_TOP_LEFT
    )
    print(((((((("Basic Button: Position(" .. tostring(basicButton:getPosition().x)) .. ", ") .. tostring(basicButton:getPosition().y)) .. "), Size(") .. tostring(basicButton:getSize().width)) .. ", ") .. tostring(basicButton:getSize().height)) .. ")")
    local simpleButton = __TS__New(Button, "Simple Button", 200, 200)
    print(((("Simple Button: Position(" .. tostring(simpleButton:getPosition().x)) .. ", ") .. tostring(simpleButton:getPosition().y)) .. ")")
    local customButton = __TS__New(
        Button,
        "Custom Button",
        200,
        250,
        150,
        50
    )
    print(((("Custom Button: Position(" .. tostring(customButton:getPosition().x)) .. ", ") .. tostring(customButton:getPosition().y)) .. ")")
    local centerButton = __TS__New(
        Button,
        "Center Button",
        960,
        540,
        160,
        50,
        ScreenCoordinates.ORIGIN_CENTER
    )
    local centerPos = centerButton:getPosition()
    local wc3Pos = ScreenCoordinates:pixelToWC3(centerPos.x, centerPos.y, ScreenCoordinates.ORIGIN_CENTER)
    print(((((((("Center Button: Pixel(" .. tostring(centerPos.x)) .. ", ") .. tostring(centerPos.y)) .. ") -> WC3(") .. __TS__NumberToFixed(wc3Pos.x, 3)) .. ", ") .. __TS__NumberToFixed(wc3Pos.y, 3)) .. ")")
    local dynamicButton = __TS__New(Button, "Dynamic Button", 400, 100)
    dynamicButton:setPosition(500, 200)
    dynamicButton:setSize(180, 60)
    local newPos = dynamicButton:getPosition()
    local newSize = dynamicButton:getSize()
    print(((((((("Dynamic Button after changes: Position(" .. tostring(newPos.x)) .. ", ") .. tostring(newPos.y)) .. "), Size(") .. tostring(newSize.width)) .. ", ") .. tostring(newSize.height)) .. ")")
    local presetButtons = {}
    local offsetY = 300
    __TS__ArrayForEach(
        __TS__ObjectEntries(UILayout.BUTTON_SIZES),
        function(____, ____bindingPattern0)
            local size
            local sizeName
            sizeName = ____bindingPattern0[1]
            size = ____bindingPattern0[2]
            local button = __TS__New(
                Button,
                sizeName .. " Button",
                50,
                offsetY,
                size.width,
                size.height,
                ScreenCoordinates.ORIGIN_TOP_LEFT
            )
            presetButtons[#presetButtons + 1] = button
            print(((((sizeName .. " Button: Size(") .. tostring(size.width)) .. "x") .. tostring(size.height)) .. ")")
            offsetY = offsetY + (size.height + 10)
        end
    )
    local gridButtons = {}
    local startX = 50
    local startY = 350
    local buttonWidth = 100
    local buttonHeight = 35
    local spacing = 20
    do
        local row = 0
        while row < 2 do
            do
                local col = 0
                while col < 3 do
                    local x = startX + col * (buttonWidth + spacing)
                    local y = startY + row * (buttonHeight + spacing)
                    local button = __TS__New(
                        Button,
                        "Grid " .. tostring(row * 3 + col + 1),
                        x,
                        y,
                        buttonWidth,
                        buttonHeight,
                        ScreenCoordinates.ORIGIN_TOP_LEFT
                    )
                    gridButtons[#gridButtons + 1] = button
                    print(((((("Grid Button " .. tostring(row * 3 + col + 1)) .. ": Position(") .. tostring(x)) .. ", ") .. tostring(y)) .. ")")
                    col = col + 1
                end
            end
            row = row + 1
        end
    end
    print("=== Button Test Complete ===")
end
return ____exports

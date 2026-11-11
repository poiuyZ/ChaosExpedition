local ____lualib = require("lualib_bundle")
local __TS__Class = ____lualib.__TS__Class
local __TS__New = ____lualib.__TS__New
local __TS__ArrayForEach = ____lualib.__TS__ArrayForEach
local ____exports = {}
local _____2A = require("lua_modules.@eiriksgata.wc3ts.src.index")
local FRAME_ALIGN_CENTER = _____2A.FRAME_ALIGN_CENTER
local ____FDFButton = require("src.system.ui.fdf.FDFButton")
local FDFButtonBuilder = ____FDFButton.FDFButtonBuilder
local ButtonGroup = ____FDFButton.ButtonGroup
--- FDF按钮使用示例
____exports.FDFButtonExample = __TS__Class()
local FDFButtonExample = ____exports.FDFButtonExample
FDFButtonExample.name = "FDFButtonExample"
function FDFButtonExample.prototype.____constructor(self)
    self.buttonGroup = __TS__New(ButtonGroup)
end
function FDFButtonExample.prototype.createExampleButtons(self)
    print("Creating FDF button examples...")
    self:createStandardButton()
    self:createLargeButton()
    self:createSmallButton()
    self:createIconButton()
    self:createButtonArray()
    print("FDF button examples created!")
end
function FDFButtonExample.prototype.createStandardButton(self)
    local button = FDFButtonBuilder:createButton(
        "StandardButtonExample",
        {
            text = "标准按钮",
            x = 0.4,
            y = 0.5,
            anchor = FRAME_ALIGN_CENTER,
            tooltip = "这是一个标准按钮",
            visible = true,
            enabled = true
        },
        {
            onClick = function()
                print("标准按钮被点击了!")
                DisplayTimedTextToPlayer(
                    GetLocalPlayer(),
                    0,
                    0,
                    5,
                    "标准按钮被点击!"
                )
            end,
            onMouseEnter = function()
                print("鼠标进入标准按钮")
            end,
            onMouseLeave = function()
                print("鼠标离开标准按钮")
            end
        }
    )
    self.buttonGroup:addButton("standard", button)
end
function FDFButtonExample.prototype.createLargeButton(self)
    local button = FDFButtonBuilder:createLargeButton(
        "LargeButtonExample",
        {
            text = "大型按钮",
            x = 0.4,
            y = 0.4,
            anchor = FRAME_ALIGN_CENTER,
            tooltip = "这是一个大型按钮",
            hotkey = "Q",
            visible = true,
            enabled = true
        },
        {onClick = function()
            print("大型按钮被点击了!")
            DisplayTimedTextToPlayer(
                GetLocalPlayer(),
                0,
                0,
                5,
                "大型按钮被点击!"
            )
        end}
    )
    self.buttonGroup:addButton("large", button)
end
function FDFButtonExample.prototype.createSmallButton(self)
    local button = FDFButtonBuilder:createSmallButton(
        "SmallButtonExample",
        {
            text = "小型按钮",
            x = 0.4,
            y = 0.3,
            anchor = FRAME_ALIGN_CENTER,
            tooltip = "这是一个小型按钮"
        },
        {onClick = function()
            print("小型按钮被点击了!")
            DisplayTimedTextToPlayer(
                GetLocalPlayer(),
                0,
                0,
                5,
                "小型按钮被点击!"
            )
        end}
    )
    self.buttonGroup:addButton("small", button)
end
function FDFButtonExample.prototype.createIconButton(self)
    local button = FDFButtonBuilder:createIconButton(
        "IconButtonExample",
        {
            x = 0.5,
            y = 0.5,
            anchor = FRAME_ALIGN_CENTER,
            icon = "ReplaceableTextures\\CommandButtons\\BTNHeroArchMage.blp",
            tooltip = "这是一个图标按钮"
        },
        {onClick = function()
            print("图标按钮被点击了!")
            DisplayTimedTextToPlayer(
                GetLocalPlayer(),
                0,
                0,
                5,
                "图标按钮被点击!"
            )
        end}
    )
    self.buttonGroup:addButton("icon", button)
end
function FDFButtonExample.prototype.createButtonArray(self)
    local startX = 0.3
    local startY = 0.2
    local spacing = 0.04
    do
        local i = 0
        while i < 6 do
            local button = FDFButtonBuilder:createIconButton(
                "SkillButton" .. tostring(i),
                {
                    x = startX + i * spacing,
                    y = startY,
                    icon = self:getSkillIcon(i),
                    tooltip = "技能 " .. tostring(i + 1),
                    hotkey = self:getSkillHotkey(i)
                },
                {onClick = function()
                    print(("技能按钮 " .. tostring(i + 1)) .. " 被点击!")
                    DisplayTimedTextToPlayer(
                        GetLocalPlayer(),
                        0,
                        0,
                        3,
                        "使用技能 " .. tostring(i + 1)
                    )
                end}
            )
            self.buttonGroup:addButton(
                "skill" .. tostring(i),
                button
            )
            i = i + 1
        end
    end
end
function FDFButtonExample.prototype.getSkillIcon(self, index)
    local icons = {
        "ReplaceableTextures\\CommandButtons\\BTNHeroArchMage.blp",
        "ReplaceableTextures\\CommandButtons\\BTNHeroPaladin.blp",
        "ReplaceableTextures\\CommandButtons\\BTNHeroMountainKing.blp",
        "ReplaceableTextures\\CommandButtons\\BTNHeroBloodElfPrince.blp",
        "ReplaceableTextures\\CommandButtons\\BTNPeasant.blp",
        "ReplaceableTextures\\CommandButtons\\BTNFootman.blp"
    }
    return icons[index + 1] or icons[1]
end
function FDFButtonExample.prototype.getSkillHotkey(self, index)
    local hotkeys = {
        "Q",
        "W",
        "E",
        "R",
        "D",
        "F"
    }
    return hotkeys[index + 1] or ""
end
function FDFButtonExample.prototype.showAllButtons(self)
    self.buttonGroup:showAll()
    print("All buttons shown")
end
function FDFButtonExample.prototype.hideAllButtons(self)
    self.buttonGroup:hideAll()
    print("All buttons hidden")
end
function FDFButtonExample.prototype.enableAllButtons(self)
    self.buttonGroup:enableAll()
    print("All buttons enabled")
end
function FDFButtonExample.prototype.disableAllButtons(self)
    self.buttonGroup:disableAll()
    print("All buttons disabled")
end
function FDFButtonExample.prototype.cleanup(self)
    self.buttonGroup:destroyAll()
    print("All buttons destroyed")
end
--- 高级示例：动态菜单系统
____exports.DynamicMenuExample = __TS__Class()
local DynamicMenuExample = ____exports.DynamicMenuExample
DynamicMenuExample.name = "DynamicMenuExample"
function DynamicMenuExample.prototype.____constructor(self)
    self.menuButtons = __TS__New(ButtonGroup)
    self.currentMenu = "main"
end
function DynamicMenuExample.prototype.createMainMenu(self)
    self:clearMenu()
    local menuItems = {
        {
            text = "开始游戏",
            action = function() return self:startGame() end
        },
        {
            text = "选项设置",
            action = function() return self:showOptions() end
        },
        {
            text = "关于",
            action = function() return self:showAbout() end
        },
        {
            text = "退出",
            action = function() return self:exitGame() end
        }
    }
    local startY = 0.45
    local spacing = 0.05
    __TS__ArrayForEach(
        menuItems,
        function(____, item, index)
            local button = FDFButtonBuilder:createLargeButton(
                "MainMenu" .. tostring(index),
                {text = item.text, x = 0.4, y = startY - index * spacing, anchor = FRAME_ALIGN_CENTER},
                {onClick = item.action}
            )
            self.menuButtons:addButton(
                "menu" .. tostring(index),
                button
            )
        end
    )
    self.currentMenu = "main"
end
function DynamicMenuExample.prototype.clearMenu(self)
    self.menuButtons:destroyAll()
end
function DynamicMenuExample.prototype.startGame(self)
    print("Starting game...")
    DisplayTimedTextToPlayer(
        GetLocalPlayer(),
        0,
        0,
        3,
        "游戏开始!"
    )
    self:clearMenu()
end
function DynamicMenuExample.prototype.showOptions(self)
    print("Showing options...")
    DisplayTimedTextToPlayer(
        GetLocalPlayer(),
        0,
        0,
        3,
        "打开选项菜单"
    )
end
function DynamicMenuExample.prototype.showAbout(self)
    print("Showing about...")
    DisplayTimedTextToPlayer(
        GetLocalPlayer(),
        0,
        0,
        3,
        "关于本游戏"
    )
end
function DynamicMenuExample.prototype.exitGame(self)
    print("Exiting game...")
    DisplayTimedTextToPlayer(
        GetLocalPlayer(),
        0,
        0,
        3,
        "退出游戏"
    )
end
function ____exports.createFDFButtonExamples()
    local example = __TS__New(____exports.FDFButtonExample)
    example:createExampleButtons()
    return example
end
function ____exports.createDynamicMenu()
    local menu = __TS__New(____exports.DynamicMenuExample)
    menu:createMainMenu()
    return menu
end
return ____exports

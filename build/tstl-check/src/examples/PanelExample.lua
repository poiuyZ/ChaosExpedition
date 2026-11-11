local ____lualib = require("lualib_bundle")
local __TS__Class = ____lualib.__TS__Class
local __TS__New = ____lualib.__TS__New
local ____exports = {}
local ____Panel = require("src.system.ui.component.Panel")
local Panel = ____Panel.Panel
local ____Button = require("src.system.ui.component.Button")
local Button = ____Button.Button
local ____Text = require("src.system.ui.component.Text")
local Text = ____Text.Text
local TextColors = ____Text.TextColors
local ____ModuleManager = require("src.system.ModuleManager")
local ModuleManager = ____ModuleManager.ModuleManager
local ____UIComponent = require("src.system.ui.UIComponent")
local HotReloadHelper = ____UIComponent.HotReloadHelper
local ____preset = require("src.constants.ui.preset")
local UIBackgrounds = ____preset.UIBackgrounds
--- Panel 组件使用示例（支持热重载）
-- 展示如何创建和使用面板容器
-- 
-- 热重载设计要点：
-- 1. 使用 HotReloadHelper 自动管理UI组件
-- 2. 在 cleanup() 中调用 helper.cleanup() 即可销毁所有组件
-- 3. 使用 helper.register() 注册组件，无需手动管理数组
local PanelExample = __TS__Class()
PanelExample.name = "PanelExample"
function PanelExample.prototype.____constructor(self)
    self.ui = __TS__New(HotReloadHelper, "PanelExample")
end
function PanelExample.prototype.createExamples(self)
    print("=== Panel Component Examples ===")
    self:example1_BasicPanel()
    self:example2_PanelWithTitle()
    self:example3_DraggablePanel()
    self:example4_PanelWithChildren()
    self:example5_PanelPresets()
    self:example6_FullyConfiguredPanel()
    print("=== Panel Examples Complete ===")
    print(("✓ Registered " .. tostring(self.ui:getComponentCount())) .. " components for hot reload")
end
function PanelExample.prototype.example1_BasicPanel(self)
    print("\n--- Example 1: Basic Panel ---")
    local panel = __TS__New(
        Panel,
        100,
        100,
        300,
        200
    )
    panel:create()
    panel:setBackground(UIBackgrounds.DIALOG):setAlpha(200)
    self.ui:register(panel)
    print("✓ 创建了基本面板")
end
function PanelExample.prototype.example2_PanelWithTitle(self)
    print("\n--- Example 2: Panel with Title ---")
    local panel = Panel:createWithTitle(
        "信息面板",
        500,
        100,
        350,
        250
    )
    panel:setTitleColor(TextColors.GOLD):setShowCloseButton(true):setCloseButtonSize(32):setOnClose(function()
        print("面板被关闭")
        panel:hide()
    end)
    self.ui:register(panel)
    print("✓ 创建了带标题栏的面板（关闭按钮: 32px）")
end
function PanelExample.prototype.example3_DraggablePanel(self)
    print("\n--- Example 3: Draggable Panel ---")
    local panel = Panel:createDraggable(
        "可拖拽面板",
        100,
        400,
        400,
        300
    )
    panel:setOnDragStart(function()
        print("开始拖拽面板")
        panel:setAlpha(180)
    end):setOnDragEnd(function(x, y)
        print(((("面板拖拽到: (" .. tostring(x)) .. ", ") .. tostring(y)) .. ")")
        panel:setAlpha(255)
    end):setOnDragging(function(_x, _y)
    end)
    self.ui:register(panel)
    print("✓ 创建了可拖拽面板")
    print("  提示: 拖动标题栏可以移动面板")
end
function PanelExample.prototype.example4_PanelWithChildren(self)
    print("\n--- Example 4: Panel with Children ---")
    local panel = Panel:createWithTitle(
        "控制面板",
        600,
        400,
        400,
        350
    )
    panel:setShowCloseButton(true):setBackground(UIBackgrounds.QUEST):setAlpha(220)
    local contentPos = panel:getContentPosition()
    local contentSize = panel:getContentSize()
    print((((((("内容区域: (" .. tostring(contentPos.x)) .. ", ") .. tostring(contentPos.y)) .. "), ") .. tostring(contentSize.width)) .. "x") .. tostring(contentSize.height))
    local title = __TS__New(
        Text,
        "欢迎使用控制面板",
        contentPos.x + 20,
        contentPos.y + 20,
        contentSize.width - 40,
        30
    )
    title:create(panel:getContentFrame())
    title:setColor(TextColors.GOLD):center():setFontSizePixels(16)
    local description = __TS__New(
        Text,
        "这是一个包含多个子组件的面板示例",
        contentPos.x + 20,
        contentPos.y + 60,
        contentSize.width - 40,
        20
    )
    description:create(panel:getContentFrame())
    description:setColor(TextColors.WHITE):setFontSizePixels(12)
    local button1 = __TS__New(
        Button,
        "选项 1",
        contentPos.x + 50,
        contentPos.y + 100,
        150,
        40
    )
    button1:create(panel:getContentFrame())
    button1:setOnClick(function()
        print("点击了选项 1")
        description:setText("你选择了选项 1")
    end)
    local button2 = __TS__New(
        Button,
        "选项 2",
        contentPos.x + 50,
        contentPos.y + 160,
        150,
        40
    )
    button2:create(panel:getContentFrame())
    button2:setOnClick(function()
        print("点击了选项 2")
        description:setText("你选择了选项 2")
    end)
    local button3 = __TS__New(
        Button,
        "关闭面板",
        contentPos.x + 50,
        contentPos.y + 220,
        150,
        40
    )
    button3:create(panel:getContentFrame())
    button3:setTextColor(TextColors.RED):setOnClick(function()
        panel:hide()
        print("面板已隐藏")
    end)
    self.ui:register(panel)
    print("✓ 创建了包含子组件的面板")
end
function PanelExample.prototype.example5_PanelPresets(self)
    print("\n--- Example 5: Panel Presets ---")
    local smallPanel = Panel:createWithPreset(1100, 100, "SMALL")
    smallPanel:setBackground(UIBackgrounds.BLACK_TRANSPARENT):setAlpha(200)
    local centerPanel = Panel:createCentered("LARGE")
    centerPanel:setBackground(UIBackgrounds.ESC_MENU):setAlpha(230):hide()
    local showButton = __TS__New(
        Button,
        "显示大面板",
        1100,
        250,
        150,
        40
    )
    showButton:create()
    showButton:setOnClick(function()
        centerPanel:toggle()
        print(centerPanel:getVisible() and "显示大面板" or "隐藏大面板")
    end)
    self.ui:register(smallPanel)
    self.ui:register(centerPanel)
    self.ui:register(showButton)
    print("✓ 创建了预设尺寸的面板")
    print("  SMALL: 200x150")
    print("  MEDIUM: 400x300")
    print("  LARGE: 600x450")
    print("  WIDE: 800x200")
    print("  TALL: 300x500")
end
function PanelExample.prototype.example6_FullyConfiguredPanel(self)
    print("\n--- Example 6: Fully Configured Panel ---")
    local panel = __TS__New(
        Panel,
        1200,
        400,
        450,
        400
    )
    panel:create()
    panel:configure({
        title = "游戏设置",
        titleColor = TextColors.CYAN,
        showTitleBar = true,
        showCloseButton = true,
        closeButtonSize = 28,
        background = UIBackgrounds.DIALOG,
        alpha = 240,
        draggable = true,
        visible = true,
        enabled = true,
        onClose = function()
            print("设置面板已关闭")
            panel:hide()
        end
    })
    local contentPos = panel:getContentPosition()
    local contentSize = panel:getContentSize()
    local volumeLabel = __TS__New(
        Text,
        "音量: 100%",
        contentPos.x + 30,
        contentPos.y + 30,
        contentSize.width - 60,
        25
    )
    volumeLabel:create(panel:getContentFrame())
    volumeLabel:setColor(TextColors.WHITE):setFontSizePixels(14)
    local resolutionLabel = __TS__New(
        Text,
        "分辨率: 1920x1080",
        contentPos.x + 30,
        contentPos.y + 80,
        contentSize.width - 60,
        25
    )
    resolutionLabel:create(panel:getContentFrame())
    resolutionLabel:setColor(TextColors.WHITE):setFontSizePixels(14)
    local saveButton = __TS__New(
        Button,
        "保存设置",
        contentPos.x + 100,
        contentPos.y + contentSize.height - 60,
        120,
        40
    )
    saveButton:create(panel:getContentFrame())
    saveButton:setTextColor(TextColors.GREEN):centerText():setOnClick(function()
        print("设置已保存")
    end)
    local resetButton = __TS__New(
        Button,
        "重置",
        contentPos.x + 240,
        contentPos.y + contentSize.height - 60,
        120,
        40
    )
    resetButton:create(panel:getContentFrame())
    resetButton:setTextColor(TextColors.ORANGE):centerText():setOnClick(function()
        volumeLabel:setText("音量: 100%")
        resolutionLabel:setText("分辨率: 1920x1080")
        print("设置已重置")
    end)
    self.ui:register(panel)
    print("✓ 创建了完整配置的面板")
end
function PanelExample.prototype.cleanup(self)
    print("PanelExample: Cleanup called...")
    self.ui:cleanup()
    print("PanelExample: All resources cleaned up")
end
function PanelExample.prototype.initialize(self)
    print("PanelExample: Initializing...")
    self:createExamples()
    print("PanelExample initialized")
end
function PanelExample.onHotReload(self)
    print("PanelExample hot reloaded!")
end
local panelInstance = nil
print(">>> PanelExample: Module file loaded, about to register...")
local manager = ModuleManager:getInstance()
print(">>> PanelExample: Got ModuleManager instance")
manager:registerModule(
    PanelExample,
    {
        initialize = function()
            print(">>> PanelExample: Initialize callback called")
            if not panelInstance then
                panelInstance = __TS__New(PanelExample)
            end
            panelInstance:initialize()
        end,
        cleanup = function()
            print(">>> PanelExample: Cleanup callback called")
            if panelInstance then
                panelInstance:cleanup()
            end
        end,
        onHotReload = function()
            print(">>> PanelExample: onHotReload callback called")
            PanelExample:onHotReload()
        end
    }
)
print(">>> PanelExample: Module registration completed")
____exports.PanelExample = PanelExample
--- 快速开始示例 - 最简单的用法（独立导出函数）
function ____exports.quickStartPanel()
    print("\n=== Quick Start: Simple Panel ===")
    local simplePanel = __TS__New(
        Panel,
        100,
        100,
        300,
        200
    )
    simplePanel:create()
    local _titlePanel = Panel:createWithTitle(
        "我的面板",
        500,
        100,
        300,
        200
    )
    local _dragPanel = Panel:createDraggable(
        "可拖拽",
        100,
        400,
        300,
        200
    )
    local _centerPanel = Panel:createCentered("MEDIUM")
    print("✓ 快速开始示例完成")
end
return ____exports

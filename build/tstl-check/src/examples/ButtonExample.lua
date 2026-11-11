local ____lualib = require("lualib_bundle")
local __TS__Class = ____lualib.__TS__Class
local __TS__New = ____lualib.__TS__New
local ____exports = {}
local ____Button = require("src.system.ui.component.Button")
local Button = ____Button.Button
local ____preset = require("src.constants.ui.preset")
local UIBackgrounds = ____preset.UIBackgrounds
local ____logger = require("src.utils.logger")
local createLogger = ____logger.createLogger
local log = createLogger("ButtonExample")
--- Button使用示例
-- 演示三层结构按钮的创建和使用
____exports.ButtonExample = __TS__Class()
local ButtonExample = ____exports.ButtonExample
ButtonExample.name = "ButtonExample"
function ButtonExample.prototype.____constructor(self)
    self.testButton = nil
    self.centerButton = nil
end
function ButtonExample.prototype.initialize(self)
    log:info("初始化按钮示例")
    self.testButton = __TS__New(
        Button,
        "测试按钮",
        400,
        300,
        100,
        36
    )
    self.testButton:setTextColor("FFCC00"):setTexturePreset("BLACK_TRANSPARENT"):setOnClick(function()
        log:info("测试按钮被点击了!")
    end):setOnHover(function()
        log:info("鼠标进入测试按钮")
    end):setOnLeave(function()
        log:info("鼠标离开测试按钮")
    end):addHoverEffect()
    self.testButton:create()
    self.centerButton = Button:createCentered("屏幕中心按钮", "LARGE")
    self.centerButton:setTextColor("00FF00"):setBackground(UIBackgrounds.DIALOG):setOnClick(function()
        log:info("中心按钮被点击!")
    end)
    self.centerButton:create()
    log:info("按钮已创建")
end
function ButtonExample.prototype.cleanup(self)
    if self.testButton then
        self.testButton:destroy()
        self.testButton = nil
    end
    if self.centerButton then
        self.centerButton:destroy()
        self.centerButton = nil
    end
    log:info("清理完成")
end
return ____exports

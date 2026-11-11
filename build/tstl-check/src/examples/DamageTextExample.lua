local ____lualib = require("lualib_bundle")
local __TS__Class = ____lualib.__TS__Class
local __TS__New = ____lualib.__TS__New
local ____exports = {}
local ____DamageTexttag = require("src.system.ui.DamageTexttag")
local DamageTextManager = ____DamageTexttag.DamageTextManager
local FloatDirection = ____DamageTexttag.FloatDirection
local ____Button = require("src.system.ui.component.Button")
local Button = ____Button.Button
local _____2A = require("lua_modules.@eiriksgata.wc3ts.src.index")
local Timer = _____2A.Timer
local ____ModuleManager = require("src.system.ModuleManager")
local ModuleManager = ____ModuleManager.ModuleManager
local ____UIComponent = require("src.system.ui.UIComponent")
local HotReloadHelper = ____UIComponent.HotReloadHelper
--- 伤害文字使用示例（支持热重载）
local DamageTextExample = __TS__Class()
DamageTextExample.name = "DamageTextExample"
function DamageTextExample.prototype.____constructor(self)
    self.ui = __TS__New(HotReloadHelper, "DamageTextExample")
    self.testTimer = nil
end
function DamageTextExample.prototype.createExamples(self)
    print("=== Damage Text Examples ===")
    DamageTextManager:getInstance(50)
    local button1 = __TS__New(
        Button,
        "快速伤害",
        100,
        100,
        120,
        40
    )
    button1:create()
    button1:setText("显示伤害")
    button1:setOnClick(function()
        local centerX = 0
        local centerY = 0
        DamageTextManager:showDamage(1234, centerX, centerY, 100)
        print("显示快速伤害: 1234")
    end)
    self.ui:register(button1)
    local button2 = __TS__New(
        Button,
        "向上漂浮",
        100,
        160,
        120,
        40
    )
    button2:create()
    button2:setText("向上")
    button2:setOnClick(function()
        local centerX = GetRandomReal(-500, 500)
        local centerY = GetRandomReal(-500, 500)
        DamageTextManager:show({
            damage = 999,
            worldX = centerX,
            worldY = centerY,
            height = 100,
            direction = FloatDirection.UP,
            speed = 100,
            duration = 2,
            scale = 1,
            fadeOut = true
        })
        print("向上漂浮: 999")
    end)
    self.ui:register(button2)
    local button3 = __TS__New(
        Button,
        "向右漂浮",
        100,
        220,
        120,
        40
    )
    button3:create()
    button3:setText("向右")
    button3:setOnClick(function()
        local centerX = GetRandomReal(-500, 500)
        local centerY = GetRandomReal(-500, 500)
        DamageTextManager:show({
            damage = 777,
            worldX = centerX,
            worldY = centerY,
            height = 100,
            direction = FloatDirection.RIGHT,
            speed = 120,
            duration = 1.5,
            scale = 0.9,
            fadeOut = true
        })
        print("向右漂浮: 777")
    end)
    self.ui:register(button3)
    local button4 = __TS__New(
        Button,
        "向左漂浮",
        100,
        280,
        120,
        40
    )
    button4:create()
    button4:setText("向左")
    button4:setOnClick(function()
        local centerX = GetRandomReal(-500, 500)
        local centerY = GetRandomReal(-500, 500)
        DamageTextManager:show({
            damage = 555,
            worldX = centerX,
            worldY = centerY,
            height = 100,
            direction = FloatDirection.LEFT,
            speed = 120,
            duration = 1.5,
            scale = 0.9,
            fadeOut = true
        })
        print("向左漂浮: 555")
    end)
    self.ui:register(button4)
    local button5 = __TS__New(
        Button,
        "大数字",
        100,
        340,
        120,
        40
    )
    button5:create()
    button5:setText("暴击")
    button5:setOnClick(function()
        local centerX = GetRandomReal(-500, 500)
        local centerY = GetRandomReal(-500, 500)
        DamageTextManager:show({
            damage = 99999,
            worldX = centerX,
            worldY = centerY,
            height = 120,
            direction = FloatDirection.UP,
            speed = 60,
            duration = 2,
            scale = 1.2,
            fadeOut = true
        })
        print("暴击伤害: 99999")
    end)
    self.ui:register(button5)
    local button6 = __TS__New(
        Button,
        "静态显示",
        100,
        400,
        120,
        40
    )
    button6:create()
    button6:setText("静态")
    button6:setOnClick(function()
        local centerX = GetRandomReal(-500, 500)
        local centerY = GetRandomReal(-500, 500)
        DamageTextManager:show({
            damage = 333,
            worldX = centerX,
            worldY = centerY,
            height = 100,
            direction = FloatDirection.NONE,
            speed = 0,
            duration = 2,
            scale = 0.8,
            fadeOut = true
        })
        print("静态显示: 333")
    end)
    self.ui:register(button6)
    local button7 = __TS__New(
        Button,
        "连续伤害",
        100,
        460,
        120,
        40
    )
    button7:create()
    button7:setText("压力测试")
    button7:setOnClick(function()
        print("开始连续伤害测试...")
        local centerX = 0
        local centerY = 0
        local count = 0
        self.testTimer = Timer:create()
        self.testTimer:start(
            0.1,
            true,
            function()
                if count >= 30 then
                    if self.testTimer then
                        self.testTimer:destroy()
                        self.testTimer = nil
                    end
                    print("连续伤害测试完成")
                    return
                end
                local damage = GetRandomInt(100, 999)
                local offsetX = GetRandomReal(-300, 300)
                local offsetY = GetRandomReal(-300, 300)
                DamageTextManager:show({
                    damage = damage,
                    worldX = centerX + offsetX,
                    worldY = centerY + offsetY,
                    height = 100,
                    direction = FloatDirection.UP,
                    speed = 80,
                    duration = 1.5,
                    scale = 0.7,
                    fadeOut = true
                })
                count = count + 1
            end
        )
    end)
    self.ui:register(button7)
    local button8 = __TS__New(
        Button,
        "清理全部",
        100,
        520,
        120,
        40
    )
    button8:create()
    button8:setText("清理")
    button8:setOnClick(function()
        DamageTextManager:getInstance():clear()
        print("已清理所有伤害文字")
    end)
    self.ui:register(button8)
    print("=== Damage Text Examples Created ===")
    print(("✓ Registered " .. tostring(self.ui:getComponentCount())) .. " components")
end
function DamageTextExample.prototype.cleanup(self)
    print("DamageTextExample: Cleanup...")
    if self.testTimer then
        self.testTimer:destroy()
        self.testTimer = nil
    end
    self.ui:cleanup()
    print("DamageTextExample: Cleanup complete")
end
function DamageTextExample.prototype.initialize(self)
    print("DamageTextExample: Initializing...")
    self:createExamples()
    print("DamageTextExample initialized")
end
function DamageTextExample.onHotReload(self)
    print("DamageTextExample hot reloaded!")
end
local exampleInstance = nil
print(">>> DamageTextExample: Module file loaded, registering...")
local manager = ModuleManager:getInstance()
manager:registerModule(
    DamageTextExample,
    {
        initialize = function()
            print(">>> DamageTextExample: Initialize callback called")
            if not exampleInstance then
                exampleInstance = __TS__New(DamageTextExample)
            end
            exampleInstance:initialize()
        end,
        cleanup = function()
            print(">>> DamageTextExample: Cleanup callback called")
            if exampleInstance then
                exampleInstance:cleanup()
            end
        end,
        onHotReload = function()
            print(">>> DamageTextExample: onHotReload callback called")
            DamageTextExample:onHotReload()
        end
    }
)
print(">>> DamageTextExample: Module registration completed")
____exports.DamageTextExample = DamageTextExample
return ____exports

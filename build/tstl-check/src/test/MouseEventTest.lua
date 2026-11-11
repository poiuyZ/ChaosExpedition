local ____lualib = require("lualib_bundle")
local __TS__Class = ____lualib.__TS__Class
local __TS__New = ____lualib.__TS__New
local ____exports = {}
local ____ModuleManager = require("src.system.ModuleManager")
local ModuleManager = ____ModuleManager.ModuleManager
local ____event = require("src.system.event.index")
local mouseEvents = ____event.mouseEvents
--- 鼠标事件测试模块
-- 
-- 热重载设计要点：
-- 1. 需要在热重载时销毁的资源（如UI组件）应保存为类的成员变量
-- 2. 在 cleanup() 中销毁所有需要清理的资源
-- 3. 在 initialize() 中重新创建资源
local MouseEventTest = __TS__Class()
MouseEventTest.name = "MouseEventTest"
function MouseEventTest.prototype.____constructor(self)
    self.subscriptionIds = {}
end
function MouseEventTest.prototype.run(self)
    local leftDownId = mouseEvents:onMouseDown(
        function(data)
            print(((("[鼠标左键按下] 屏幕: (" .. tostring(data.screenX)) .. ", ") .. tostring(data.screenY)) .. ")")
            print(((("  地形坐标: (" .. tostring(math.floor(data.terrainX))) .. ", ") .. tostring(math.floor(data.terrainY))) .. ")")
            print("  是否在UI上: " .. tostring(data.isOverUI))
        end,
        1
    )
    local ____self_subscriptionIds_0 = self.subscriptionIds
    ____self_subscriptionIds_0[#____self_subscriptionIds_0 + 1] = leftDownId
    local rightDownId = mouseEvents:onMouseDown(
        function(data)
            print(((("[鼠标右键按下] 屏幕: (" .. tostring(data.screenX)) .. ", ") .. tostring(data.screenY)) .. ")")
        end,
        2
    )
    local ____self_subscriptionIds_1 = self.subscriptionIds
    ____self_subscriptionIds_1[#____self_subscriptionIds_1 + 1] = rightDownId
    local rightUpId = mouseEvents:onMouseUp(
        function(data)
            print(((("[鼠标右键松开] 屏幕: (" .. tostring(data.screenX)) .. ", ") .. tostring(data.screenY)) .. ")")
        end,
        2
    )
    local ____self_subscriptionIds_2 = self.subscriptionIds
    ____self_subscriptionIds_2[#____self_subscriptionIds_2 + 1] = rightUpId
    local leftUpId = mouseEvents:onMouseUp(
        function(data)
            print(((("[鼠标左键松开] 屏幕: (" .. tostring(data.screenX)) .. ", ") .. tostring(data.screenY)) .. ")")
        end,
        1
    )
    local ____self_subscriptionIds_3 = self.subscriptionIds
    ____self_subscriptionIds_3[#____self_subscriptionIds_3 + 1] = leftUpId
    local wheelId = mouseEvents:onMouseWheel(function(data)
        local direction = data.wheelDelta and data.wheelDelta > 0 and "向上" or "向下"
        print((("[鼠标滚轮] " .. direction) .. "滚动, delta: ") .. tostring(data.wheelDelta))
    end)
    local ____self_subscriptionIds_4 = self.subscriptionIds
    ____self_subscriptionIds_4[#____self_subscriptionIds_4 + 1] = wheelId
    print("=== 鼠标事件测试已启动 ===")
    print("- 左键按下/松开: 显示坐标信息")
    print("- 右键按下: 显示屏幕坐标")
    print("- 鼠标移动: 每0.5秒显示一次")
    print("- 滚轮: 显示滚动方向")
end
function MouseEventTest.prototype.cleanup(self)
    print("MouseEventTest: Cleanup called, destroying resources...")
    for ____, id in ipairs(self.subscriptionIds) do
        mouseEvents:off(id)
    end
    self.subscriptionIds = {}
    print("MouseEventTest: All subscriptions cleaned up")
end
function MouseEventTest.prototype.initialize(self)
    print("MouseEventTest: Initializing...")
    self:run()
    print("MouseEventTest initialized")
end
function MouseEventTest.onHotReload(self)
    print("MouseEventTest hot reloaded!")
end
local mouseTestInstance = nil
print(">>> MouseEventTest: Module file loaded, about to register...")
local manager = ModuleManager:getInstance()
print(">>> MouseEventTest: Got ModuleManager instance")
manager:registerModule(
    MouseEventTest,
    {
        initialize = function()
            print(">>> MouseEventTest: Initialize callback called")
            if not mouseTestInstance then
                mouseTestInstance = __TS__New(MouseEventTest)
            end
            mouseTestInstance:initialize()
        end,
        cleanup = function()
            print(">>> MouseEventTest: Cleanup callback called")
            if mouseTestInstance then
                mouseTestInstance:cleanup()
            end
        end,
        onHotReload = function()
            print(">>> MouseEventTest: onHotReload callback called")
            MouseEventTest:onHotReload()
        end
    }
)
print(">>> MouseEventTest: Module registration completed")
____exports.MouseEventTest = MouseEventTest
return ____exports

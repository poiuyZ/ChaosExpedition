local ____lualib = require("lualib_bundle")
local __TS__Class = ____lualib.__TS__Class
local __TS__New = ____lualib.__TS__New
local ____exports = {}
local ____ModuleManager = require("src.system.ModuleManager")
local ModuleManager = ____ModuleManager.ModuleManager
local ____UIComponent = require("src.system.ui.UIComponent")
local HotReloadHelper = ____UIComponent.HotReloadHelper
--- 热更新模板
-- 
-- 热重载设计要点：
-- 1. 使用 HotReloadHelper 自动管理UI组件
-- 2. 在 cleanup() 中调用 helper.cleanup() 即可销毁所有组件
-- 3. 使用 helper.register() 注册组件，无需手动管理数组
local ReloadTemplateExample = __TS__Class()
ReloadTemplateExample.name = "ReloadTemplateExample"
function ReloadTemplateExample.prototype.____constructor(self)
    self.ui = __TS__New(HotReloadHelper, "ReloadTemplate")
end
function ReloadTemplateExample.prototype.TestButton(self)
end
function ReloadTemplateExample.prototype.cleanup(self)
    print("ReloadTemplate: Cleanup called...")
    self.ui:cleanup()
    print("ReloadTemplate: All resources cleaned up")
end
function ReloadTemplateExample.prototype.initialize(self)
    print("ReloadTemplate: Initializing...")
    self:TestButton()
    print("ReloadTemplate initialized")
end
function ReloadTemplateExample.onHotReload(self)
    print("ReloadTemplate hot reloaded!")
end
local reloadInstance = nil
print(">>> ReloadTemplate: Module file loaded, about to register...")
local manager = ModuleManager:getInstance()
print(">>> ReloadTemplate: Got ModuleManager instance")
manager:registerModule(
    ReloadTemplateExample,
    {
        initialize = function()
            print(">>> ReloadTemplate: Initialize callback called")
            if not reloadInstance then
                reloadInstance = __TS__New(ReloadTemplateExample)
            end
            reloadInstance:initialize()
        end,
        cleanup = function()
            print(">>> ReloadTemplate: Cleanup callback called")
            if reloadInstance then
                reloadInstance:cleanup()
            end
        end,
        onHotReload = function()
            print(">>> ReloadTemplate: onHotReload callback called")
            ReloadTemplateExample:onHotReload()
        end
    }
)
print(">>> ReloadTemplate: Module registration completed")
____exports.ReloadTemplateExample = ReloadTemplateExample
return ____exports

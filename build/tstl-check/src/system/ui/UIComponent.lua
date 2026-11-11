local ____lualib = require("lualib_bundle")
local __TS__Class = ____lualib.__TS__Class
local Set = ____lualib.Set
local __TS__New = ____lualib.__TS__New
local Map = ____lualib.Map
local __TS__Iterator = ____lualib.__TS__Iterator
local __TS__ArrayFrom = ____lualib.__TS__ArrayFrom
local ____exports = {}
local ____logger = require("src.utils.logger")
local createLogger = ____logger.createLogger
local log = createLogger("UIComponentManager")
--- UI组件管理器
-- 单例模式，管理所有需要热重载时清理的UI组件
____exports.UIComponentManager = __TS__Class()
local UIComponentManager = ____exports.UIComponentManager
UIComponentManager.name = "UIComponentManager"
function UIComponentManager.prototype.____constructor(self)
    self.components = __TS__New(Set)
    self.taggedComponents = __TS__New(Map)
end
function UIComponentManager.getInstance(self)
    if not ____exports.UIComponentManager.instance then
        ____exports.UIComponentManager.instance = __TS__New(____exports.UIComponentManager)
    end
    return ____exports.UIComponentManager.instance
end
function UIComponentManager.prototype.register(self, component, tag)
    self.components:add(component)
    if tag then
        if not self.taggedComponents:has(tag) then
            self.taggedComponents:set(
                tag,
                __TS__New(Set)
            )
        end
        self.taggedComponents:get(tag):add(component)
    end
end
function UIComponentManager.prototype.unregister(self, component)
    self.components:delete(component)
    for ____, tagSet in __TS__Iterator(self.taggedComponents:values()) do
        tagSet:delete(component)
    end
end
function UIComponentManager.prototype.destroyAll(self)
    local count = self.components.size
    for ____, component in __TS__Iterator(self.components) do
        do
            local function ____catch(e)
                log:error("Error destroying component: " .. tostring(e))
            end
            local ____try, ____hasReturned = pcall(function()
                component:destroy()
            end)
            if not ____try then
                ____catch(____hasReturned)
            end
        end
    end
    self.components:clear()
    self.taggedComponents:clear()
    log:info(("Destroyed " .. tostring(count)) .. " components")
end
function UIComponentManager.prototype.destroyByTag(self, tag)
    local tagSet = self.taggedComponents:get(tag)
    if not tagSet then
        return
    end
    local count = tagSet.size
    for ____, component in __TS__Iterator(tagSet) do
        do
            local function ____catch(e)
                log:error("Error destroying component: " .. tostring(e))
            end
            local ____try, ____hasReturned = pcall(function()
                component:destroy()
                self.components:delete(component)
            end)
            if not ____try then
                ____catch(____hasReturned)
            end
        end
    end
    self.taggedComponents:delete(tag)
    log:info(((("Destroyed " .. tostring(count)) .. " components with tag \"") .. tag) .. "\"")
end
function UIComponentManager.prototype.getComponentCount(self)
    return self.components.size
end
function UIComponentManager.prototype.getComponentCountByTag(self, tag)
    local ____opt_0 = self.taggedComponents:get(tag)
    return ____opt_0 and ____opt_0.size or 0
end
function UIComponentManager.prototype.getAllComponents(self)
    return __TS__ArrayFrom(self.components)
end
function UIComponentManager.prototype.getComponentsByTag(self, tag)
    return __TS__ArrayFrom(self.taggedComponents:get(tag) or ({}))
end
UIComponentManager.instance = nil
--- 创建一个可以自动注册到热重载管理的组件包装器
-- 
-- @example ```typescript
-- // 创建按钮并自动注册
-- const button = UIComponents.create(() => {
--   const btn = Button.createCentered("Test");
--   btn.setOnClick(() => print("clicked"));
--   return btn;
-- }, "myModule");
-- 
-- // 热重载时自动销毁所有 "myModule" 标签的组件
-- UIComponents.destroyByTag("myModule");
-- ```
____exports.UIComponents = {
    create = function(self, factory, tag)
        local component = factory()
        ____exports.UIComponentManager:getInstance():register(component, tag)
        return component
    end,
    register = function(self, component, tag)
        ____exports.UIComponentManager:getInstance():register(component, tag)
        return component
    end,
    unregister = function(self, component)
        ____exports.UIComponentManager:getInstance():unregister(component)
    end,
    destroyAll = function(self)
        ____exports.UIComponentManager:getInstance():destroyAll()
    end,
    destroyByTag = function(self, tag)
        ____exports.UIComponentManager:getInstance():destroyByTag(tag)
    end,
    getManager = function(self)
        return ____exports.UIComponentManager:getInstance()
    end
}
--- 热重载辅助类
-- 简化模块的热重载管理
____exports.HotReloadHelper = __TS__Class()
local HotReloadHelper = ____exports.HotReloadHelper
HotReloadHelper.name = "HotReloadHelper"
function HotReloadHelper.prototype.____constructor(self, tag)
    self.tag = tag
end
function HotReloadHelper.prototype.create(self, factory)
    return ____exports.UIComponents:create(factory, self.tag)
end
function HotReloadHelper.prototype.register(self, component)
    return ____exports.UIComponents:register(component, self.tag)
end
function HotReloadHelper.prototype.cleanup(self)
    ____exports.UIComponents:destroyByTag(self.tag)
end
function HotReloadHelper.prototype.getComponentCount(self)
    return ____exports.UIComponentManager:getInstance():getComponentCountByTag(self.tag)
end
return ____exports

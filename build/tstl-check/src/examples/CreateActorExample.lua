local ____lualib = require("lualib_bundle")
local __TS__Class = ____lualib.__TS__Class
local __TS__New = ____lualib.__TS__New
local ____exports = {}
local _____2A = require("lua_modules.@eiriksgata.wc3ts.src.index")
local Players = _____2A.Players
local Unit = _____2A.Unit
local ____ModuleManager = require("src.system.ModuleManager")
local ModuleManager = ____ModuleManager.ModuleManager
local ____helper = require("src.utils.helper")
local FourCC = ____helper.FourCC
--- 热更新模板
-- 
-- 热重载设计要点：
-- 1. 需要在热重载时销毁的资源（如UI组件）应保存为类的成员变量
-- 2. 在 cleanup() 中销毁所有需要清理的资源
-- 3. 在 initialize() 中重新创建资源
local CreateActorExample = __TS__Class()
CreateActorExample.name = "CreateActorExample"
function CreateActorExample.prototype.____constructor(self)
    self.actorList = {}
end
function CreateActorExample.prototype.TestButton(self)
    do
        local i = 0
        while i < 10 do
            local x = -2000 + i * 200
            local y = 0
            local paladin = Unit:create(
                Players[1],
                FourCC("Hpal"),
                x,
                y,
                270
            )
            if paladin then
                local ____self_actorList_0 = self.actorList
                ____self_actorList_0[#____self_actorList_0 + 1] = paladin
                print(((((("Created Paladin " .. tostring(i + 1)) .. " at (") .. tostring(x)) .. ", ") .. tostring(y)) .. ")")
            end
            i = i + 1
        end
    end
end
function CreateActorExample.prototype.cleanup(self)
    for ____, actor in ipairs(self.actorList) do
        actor:destroy()
    end
    self.actorList = {}
end
function CreateActorExample.prototype.initialize(self)
    self:TestButton()
end
function CreateActorExample.onHotReload(self)
    print("CreateActorExample hot reloaded!")
end
local reloadInstance = nil
print(">>> CreateActorExample: Module file loaded, about to register...")
local manager = ModuleManager:getInstance()
print(">>> CreateActorExample: Got ModuleManager instance")
manager:registerModule(
    CreateActorExample,
    {
        initialize = function()
            print(">>> CreateActorExample: Initialize callback called")
            if not reloadInstance then
                reloadInstance = __TS__New(CreateActorExample)
            end
            reloadInstance:initialize()
        end,
        cleanup = function()
            print(">>> CreateActorExample: Cleanup callback called")
            if reloadInstance then
                reloadInstance:cleanup()
            end
        end,
        onHotReload = function()
            print(">>> CreateActorExample: onHotReload callback called")
            CreateActorExample:onHotReload()
        end
    }
)
print(">>> CreateActorExample: Module registration completed")
____exports.CreateActorExample = CreateActorExample
return ____exports

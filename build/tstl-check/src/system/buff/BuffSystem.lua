local ____lualib = require("lualib_bundle")
local __TS__Class = ____lualib.__TS__Class
local __TS__New = ____lualib.__TS__New
local ____exports = {}
local _____2A = require("lua_modules.@eiriksgata.wc3ts.src.index")
local Timer = _____2A.Timer
local ____actor = require("src.system.actor")
local Actor = ____actor.Actor
local TICK_INTERVAL = 0.1
____exports.BuffSystem = __TS__Class()
local BuffSystem = ____exports.BuffSystem
BuffSystem.name = "BuffSystem"
function BuffSystem.prototype.____constructor(self)
    self.timer = nil
end
function BuffSystem.getInstance(self)
    if not ____exports.BuffSystem.instance then
        ____exports.BuffSystem.instance = __TS__New(____exports.BuffSystem)
    end
    return ____exports.BuffSystem.instance
end
function BuffSystem.prototype.init(self)
    if self.timer ~= nil then
        return
    end
    self.timer = Timer:create()
    self.timer:start(
        TICK_INTERVAL,
        true,
        function()
            local delta = TICK_INTERVAL
            for id in pairs(Actor.allActors) do
                local actor = Actor.allActors[id]
                if actor ~= nil and actor:hasBuffManager() then
                    actor.buffManager:tick(delta)
                end
            end
        end
    )
end
return ____exports

local ____exports = {}
local ____define = require("lua_modules.@eiriksgata.wc3ts.src.globals.define")
local bj_MAX_PLAYER_SLOTS = ____define.bj_MAX_PLAYER_SLOTS
local ____player = require("lua_modules.@eiriksgata.wc3ts.src.handles.player")
local MapPlayer = ____player.MapPlayer
do
    local ____export = require("lua_modules.@eiriksgata.wc3ts.src.handles.index")
    for ____exportKey, ____exportValue in pairs(____export) do
        if ____exportKey ~= "default" then
            ____exports[____exportKey] = ____exportValue
        end
    end
end
do
    local ____export = require("lua_modules.@eiriksgata.wc3ts.src.system.index")
    for ____exportKey, ____exportValue in pairs(____export) do
        if ____exportKey ~= "default" then
            ____exports[____exportKey] = ____exportValue
        end
    end
end
do
    local ____export = require("lua_modules.@eiriksgata.wc3ts.src.utils.index")
    for ____exportKey, ____exportValue in pairs(____export) do
        if ____exportKey ~= "default" then
            ____exports[____exportKey] = ____exportValue
        end
    end
end
do
    local ____export = require("lua_modules.@eiriksgata.wc3ts.src.globals.index")
    for ____exportKey, ____exportValue in pairs(____export) do
        if ____exportKey ~= "default" then
            ____exports[____exportKey] = ____exportValue
        end
    end
end
____exports.Players = {}
do
    local i = 0
    while i < bj_MAX_PLAYER_SLOTS do
        local pl = MapPlayer:fromHandle(Player(i))
        if pl then
            ____exports.Players[i + 1] = pl
        end
        i = i + 1
    end
end
return ____exports

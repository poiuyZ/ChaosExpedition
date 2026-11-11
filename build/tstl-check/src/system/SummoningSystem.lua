local ____lualib = require("lualib_bundle")
local __TS__Class = ____lualib.__TS__Class
local __TS__New = ____lualib.__TS__New
local ____exports = {}
local _____2A = require("lua_modules.@eiriksgata.wc3ts.src.index")
local UNIT_STATE_ATTACK_WHITE = _____2A.UNIT_STATE_ATTACK_WHITE
local ____event = require("src.system.event.index")
local gameEvents = ____event.gameEvents
____exports.default = __TS__Class()
local SummoningSystem = ____exports.default
SummoningSystem.name = "SummoningSystem"
function SummoningSystem.prototype.____constructor(self)
end
function SummoningSystem.getInstance(self)
    if not ____exports.default.instance then
        ____exports.default.instance = __TS__New(____exports.default)
    end
    return ____exports.default.instance
end
function SummoningSystem.prototype.init(self)
    gameEvents:onUnitSummoned(function(data)
        local summoningUnit = data.SummoningUnit
        local summonedUnit = data.SummonedUnit
        if summoningUnit == nil or summonedUnit == nil then
            return
        end
        if summoningUnit:isHero() then
            summonedUnit.maxLife = summonedUnit.maxLife + summoningUnit.maxLife
            summonedUnit.life = summonedUnit.maxLife
            summonedUnit:setBaseDamageJAPI(summonedUnit:getState(UNIT_STATE_ATTACK_WHITE()) + summoningUnit:getState(UNIT_STATE_ATTACK_WHITE()))
        end
    end)
end
return ____exports

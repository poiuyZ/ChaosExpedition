local ____exports = {}
local _____2A = require("lua_modules.@eiriksgata.wc3ts.src.index")
local Timer = _____2A.Timer
local Players = _____2A.Players
local ____actor = require("src.system.actor")
local Actor = ____actor.Actor
local ____event = require("src.system.event.index")
local gameEvents = ____event.gameEvents
local ____helper = require("src.utils.helper")
local FourCC = ____helper.FourCC
local ____logger = require("src.utils.logger")
local createLogger = ____logger.createLogger
local log = createLogger("UnitEventExample")
function ____exports.rgeisterUnitSpellEffectEvent()
    gameEvents:onSpellEffect(function(data)
        log:info("单位释放了技能: " .. tostring(data.abilityId))
    end)
    gameEvents:onUnitDeath(function(data)
        local time
        time = Timer:create():start(
            1,
            false,
            function()
                local ____opt_0 = data.Actor
                if ____opt_0 ~= nil then
                    ____opt_0:revive(0, 0, true)
                end
                data.Actor.mana = 3000
                time:destroy()
            end
        )
    end)
    do
        local j = 0
        while j < 5 do
            do
                local i = 0
                while i < 10 do
                    do
                        local unit = Actor:create(
                            Players[j + 1],
                            FourCC("Hpal"),
                            0,
                            0
                        )
                        if unit == nil then
                            goto __continue9
                        end
                        log:info("创建单位: " .. tostring(unit.id))
                        unit:setPreselectUIVisible(false)
                        unit:createBloodBar()
                        unit:setLabel("测试单位")
                        unit:addAbility(FourCC("AUfn"))
                        unit:addAbility(FourCC("AHwe"))
                        unit.maxMana = 3000
                        unit.mana = 3000
                        unit:addShield(1000)
                    end
                    ::__continue9::
                    i = i + 1
                end
            end
            j = j + 1
        end
    end
end
return ____exports

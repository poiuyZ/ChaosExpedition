local ____exports = {}
local _____2A = require("lua_modules.@eiriksgata.wc3ts.src.index")
local Players = _____2A.Players
local Timer = _____2A.Timer
local ____actor = require("src.system.actor")
local Actor = ____actor.Actor
local ____bullethell = require("src.system.bullethell.index")
local SpellCardBulletSystem = ____bullethell.SpellCardBulletSystem
local SpellCardId = ____bullethell.SpellCardId
local ____helper = require("src.utils.helper")
local FourCC = ____helper.FourCC
local ____logger = require("src.utils.logger")
local createLogger = ____logger.createLogger
local log = createLogger("BulletHellTest")
local function getDefaultSpellCardOptions(cardId)
    if cardId == SpellCardId.DUAL_SPIRAL then
        return {
            duration = 7,
            emissionInterval = 0.05,
            baseSpeed = 640,
            bulletLife = 3.5,
            bulletRadius = 85,
            bulletDamage = 10
        }
    end
    if cardId == SpellCardId.FAN_PULSE then
        return {
            duration = 7,
            emissionInterval = 0.09,
            baseSpeed = 700,
            bulletLife = 2.8,
            bulletRadius = 95,
            bulletDamage = 14
        }
    end
    if cardId == SpellCardId.ROSE_BLOOM then
        return {
            duration = 7,
            emissionInterval = 0.09,
            baseSpeed = 610,
            bulletLife = 3.4,
            bulletRadius = 88,
            bulletDamage = 11
        }
    end
    if cardId == SpellCardId.ECHO_FAN then
        return {
            duration = 7,
            emissionInterval = 0.08,
            baseSpeed = 680,
            bulletLife = 3,
            bulletRadius = 92,
            bulletDamage = 13
        }
    end
    if cardId == SpellCardId.LATTICE_SPIN then
        return {
            duration = 7,
            emissionInterval = 0.06,
            baseSpeed = 650,
            bulletLife = 3.1,
            bulletRadius = 82,
            bulletDamage = 12
        }
    end
    return {
        duration = 7,
        emissionInterval = 0.08,
        baseSpeed = 600,
        bulletLife = 3.3,
        bulletRadius = 90,
        bulletDamage = 12
    }
end
--- 弹幕压测入口：
-- 1. 创建巫妖单位
-- 2. 依次释放 6 张符卡（每张 7 秒）
-- 3. 每 2 秒打印一次统计，便于观察 200~300 并发下的稳定性
function ____exports.runSpellCardBulletHellTest()
    local caster = Actor:create(
        Players[1],
        FourCC("Ulic"),
        0,
        0,
        0
    )
    Actor:create(
        Players[2],
        FourCC("Ulic"),
        700,
        0,
        270
    )
    Actor:create(
        Players[2],
        FourCC("Ulic"),
        -700,
        700,
        90
    )
    if not caster then
        log:error("创建巫妖失败")
        return
    end
    local system = SpellCardBulletSystem:getInstance()
    system:initialize({maxBullets = 320, collisionChecksPerTick = 84, collisionTickStride = 2})
    local cards = {
        SpellCardId.RING_BURST,
        SpellCardId.DUAL_SPIRAL,
        SpellCardId.FAN_PULSE,
        SpellCardId.ROSE_BLOOM,
        SpellCardId.ECHO_FAN,
        SpellCardId.LATTICE_SPIN
    }
    local startDelay = 7.2
    do
        local i = 0
        while i < #cards do
            do
                local cardId = cards[i + 1]
                local options = getDefaultSpellCardOptions(cardId)
                if i == 0 then
                    system:startCardFromCaster(caster.handle, cardId, options)
                    goto __continue11
                end
                Timer:create():start(
                    startDelay * i,
                    false,
                    function()
                        system:startCardFromCaster(caster.handle, cardId, options)
                    end
                )
            end
            ::__continue11::
            i = i + 1
        end
    end
    local statTimer = Timer:create()
    statTimer:start(
        2,
        true,
        function()
            local s = system:getStats()
            log:info((((((((((("active=" .. tostring(s.activeBullets)) .. ", emitters=") .. tostring(s.activeEmitters)) .. ", spawned=") .. tostring(s.totalSpawned)) .. ", dropped=") .. tostring(s.totalDropped)) .. ", recycled=") .. tostring(s.totalRecycled)) .. ", hit=") .. tostring(s.totalHit))
            if s.activeEmitters <= 0 and s.activeBullets <= 0 then
                statTimer:destroy()
                log:info("全部符卡结束")
            end
        end
    )
end
--- 直接对任意单位释放符卡（你需求里的主入口）。
function ____exports.castSpellCardFromUnit(caster, cardId)
    local system = SpellCardBulletSystem:getInstance()
    system:initialize()
    return system:startCardFromCaster(
        caster,
        cardId,
        getDefaultSpellCardOptions(cardId)
    )
end
return ____exports

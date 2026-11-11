local ____exports = {}
local _____2A = require("lua_modules.@eiriksgata.wc3ts.src.index")
local Unit = _____2A.Unit
local Players = _____2A.Players
local Timer = _____2A.Timer
local ____helper = require("src.utils.helper")
local FourCC = ____helper.FourCC
local ____HeroUnitSkill = require("src.examples.HeroUnitSkill")
local castBlizzardSkill = ____HeroUnitSkill.castBlizzardSkill
local castRushBarrageSkill = ____HeroUnitSkill.castRushBarrageSkill
local ____actor = require("src.system.actor")
local Actor = ____actor.Actor
local ____logger = require("src.utils.logger")
local createLogger = ____logger.createLogger
local log = createLogger("HeroUnitSkillTest")
function ____exports.castBlizzardSkillTest()
    local caster = Unit:create(
        Players[1],
        FourCC("Hpal"),
        0,
        0
    )
    local target = Unit:create(
        Players[2],
        FourCC("Hpal"),
        400,
        0
    )
    if not caster or not target then
        return
    end
    Timer:create():start(
        1,
        false,
        function()
            castBlizzardSkill(caster.handle, target.x, target.y, {
                damage = 120,
                radius = 400,
                duration = 3,
                interval = 0.3,
                stormCount = 8
            })
        end
    )
end
function ____exports.castRushBarrageSkillTest()
    local caster = Unit:create(
        Players[1],
        FourCC("Hpal"),
        0,
        0
    )
    local target = Unit:create(
        Players[2],
        FourCC("Hpal"),
        400,
        0
    )
    if not caster or not target then
        return
    end
    Timer:create():start(
        1,
        false,
        function()
            castRushBarrageSkill(caster.handle, target.handle, {
                hitCount = 10,
                hitInterval = 0.14,
                damagePerHit = 45,
                knockbackDist = 40,
                selfLungeDist = 26,
                standDist = 88
            })
        end
    )
end
function ____exports.testAddShield()
    local caster = Actor:create(
        Players[1],
        FourCC("Hpal"),
        0,
        0
    )
    local target = Actor:create(
        Players[2],
        FourCC("Hpal"),
        400,
        0
    )
    if not caster or not target then
        return
    end
    caster:addShield(3000)
    target:addShield(300)
    log:info((("casterShield=" .. tostring(caster.shield)) .. ", targetShield=") .. tostring(target.shield))
end
return ____exports

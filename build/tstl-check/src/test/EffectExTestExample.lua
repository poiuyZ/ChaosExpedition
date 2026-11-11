local ____exports = {}
local _____2A = require("lua_modules.@eiriksgata.wc3ts.src.index")
local Players = _____2A.Players
local Timer = _____2A.Timer
local ____actor = require("src.system.actor")
local Actor = ____actor.Actor
local ____EffectEx = require("src.system.EffectEx")
local EffectEx = ____EffectEx.EffectEx
local ____helper = require("src.utils.helper")
local FourCC = ____helper.FourCC
local ____logger = require("src.utils.logger")
local createLogger = ____logger.createLogger
local log = createLogger("EffectExTest")
--- EffectEx 测试：
-- 1) 创建牛头酋长（Otch）
-- 2) 创建冲击波（Shockwave）特效
-- 3) 让特效沿圆轨迹移动，并实时改变面向（切线方向）
function ____exports.shockwaveEffectCircleTest()
    local owner = Players[1]
    local hero = Actor:create(
        owner,
        FourCC("Otch"),
        0,
        0
    )
    if not hero then
        log:error("创建牛头酋长失败")
        return
    end
    local model = "Abilities\\Spells\\Orc\\Shockwave\\ShockwaveMissile.mdl"
    local centerX = hero.x
    local centerY = hero.y
    local radius = 420
    local z = 90
    local duration = 12
    local interval = 0.03
    local angularSpeed = 1.6
    local theta = 0
    local elapsed = 0
    local startX = centerX + radius
    local startY = centerY
    local fx = EffectEx:create(model, startX, startY, z)
    if not fx then
        log:error("创建冲击波特效失败")
        return
    end
    local t = Timer:create()
    t:start(
        interval,
        true,
        function()
            elapsed = elapsed + interval
            theta = theta + angularSpeed * interval
            local x = centerX + math.cos(theta) * radius
            local y = centerY + math.sin(theta) * radius
            fx:setXY(x, y):setZ(z)
            local facingRad = theta + math.pi / 2
            fx:faceByRadians(facingRad)
            if elapsed >= duration then
                t:destroy()
                fx:destroy()
                log:info("冲击波圆轨迹测试结束")
            end
        end
    )
    log:info("已启动：冲击波特效沿圆轨迹移动并更新面向")
end
return ____exports

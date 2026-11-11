local ____exports = {}
local _____2A = require("lua_modules.@eiriksgata.wc3ts.src.index")
local Players = _____2A.Players
local Timer = _____2A.Timer
local Unit = _____2A.Unit
local ____helper = require("src.utils.helper")
local FourCC = ____helper.FourCC
local ____skills = require("src.unit.skills.index")
local casterJumpToAndKnockEnemies = ____skills.casterJumpToAndKnockEnemies
local unitChargeToPoint = ____skills.unitChargeToPoint
local unitChargeToUnit = ____skills.unitChargeToUnit
local unitJumpTo = ____skills.unitJumpTo
local unitKnockUp = ____skills.unitKnockUp
local ____logger = require("src.utils.logger")
local createLogger = ____logger.createLogger
local log = createLogger("UnitMovementSkillsTest")
--- 在指定点创建单位，供本文件各测试复用。
local function safeCreate(owner, unitTypeId, x, y)
    local p = Players[owner + 1]
    if not p then
        return nil
    end
    return Unit:create(p, unitTypeId, x, y)
end
--- 测试「跳跃位移」`unitJumpTo`：水平插值 + 飞行高度抛物线（需风暴乌鸦解锁链，见 `flyheight.ts`）。
-- 延迟 1 秒后执行；1 号玩家圣骑士从 (0,0) 跳到 (500,500)，带 `jumpMaxHeight` / `duration`。
function ____exports.testUnitJumpToSkill()
    log:info("开始：创建单位…")
    local caster = safeCreate(
        0,
        FourCC("Hpal"),
        0,
        0
    )
    if not caster then
        log:error("失败：Players[0] 或 Unit.create 未成功")
        return
    end
    Timer:create():start(
        1,
        false,
        function()
            log:info("1s 后调用 unitJumpTo（以下为每 tick 高度）")
            unitJumpTo(caster.handle, 500, 500, {jumpMaxHeight = 200, duration = 1})
        end
    )
end
--- 测试「冲向固定点」`unitChargeToPoint`：纯地面位移，不改 `SetUnitFlyHeight`。
-- 延迟 1 秒后执行；1 号玩家单位从 (0,0) 沿直线冲向 (500,0)。
function ____exports.testUnitChargeToPointSkill()
    local caster = safeCreate(
        0,
        FourCC("Hpal"),
        0,
        0
    )
    if not caster then
        return
    end
    Timer:create():start(
        1,
        false,
        function()
            unitChargeToPoint(caster.handle, 500, 0, {speed = 1000})
        end
    )
end
--- 测试「追向目标单位」`unitChargeToUnit`：追踪移动至与目标相距 `stopDist`，纯地面、无高度变化。
-- 延迟 1 秒后执行；0 号玩家追击 1 号玩家英雄，停在约 90 距离处。
function ____exports.testUnitChargeToUnitSkill()
    local charger = safeCreate(
        0,
        FourCC("Hpal"),
        0,
        0
    )
    local target = safeCreate(
        1,
        FourCC("Hpal"),
        450,
        0
    )
    if not charger or not target then
        return
    end
    Timer:create():start(
        1,
        false,
        function()
            unitChargeToUnit(charger.handle, target.handle, {speed = 900, stopDist = 90})
        end
    )
end
--- 测试「击飞」`unitKnockUp`：抛物线高度 + 可选水平推开，与跳跃共用飞行高度管线。
-- 延迟 1 秒后执行；以 `from` 决定推开方向，击飞 1 号玩家目标单位。
function ____exports.testUnitKnockUpSkill()
    local caster = safeCreate(
        0,
        FourCC("Hpal"),
        0,
        0
    )
    local target = safeCreate(
        1,
        FourCC("Hpal"),
        350,
        0
    )
    if not caster or not target then
        return
    end
    Timer:create():start(
        1,
        false,
        function()
            unitKnockUp(target.handle, {from = caster.handle, maxHeight = 200, pushDist = 180, duration = 0.5})
        end
    )
end
--- 测试「施法者起跳落地 + 范围击飞」`casterJumpToAndKnockEnemies`：
-- 先完成施法者带高度的跳跃，落地后以落点为圆心击飞敌方非建筑单位（内部再调 `unitKnockUp`）。
-- 延迟 1 秒后执行；含两名敌方英雄与一座建筑用于验证过滤。
function ____exports.testCasterJumpAndKnockEnemiesSkill()
    local caster = safeCreate(
        0,
        FourCC("Hpal"),
        0,
        0
    )
    local enemy1 = safeCreate(
        1,
        FourCC("Hpal"),
        380,
        0
    )
    local enemy2 = safeCreate(
        1,
        FourCC("Hpal"),
        320,
        220
    )
    local enemyBuilding = safeCreate(
        1,
        FourCC("hbar"),
        420,
        180
    )
    if not caster or not enemy1 or not enemy2 or not enemyBuilding then
        return
    end
    Timer:create():start(
        1,
        false,
        function()
            casterJumpToAndKnockEnemies(caster.handle, 300, 80, {
                jumpMaxHeight = 240,
                jumpDuration = 0.5,
                knockRadius = 360,
                knockMaxHeight = 220,
                knockPushDist = 200
            })
        end
    )
end
return ____exports

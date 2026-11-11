local ____exports = {}
local ____helper = require("src.utils.helper")
local FourCC = ____helper.FourCC
local ____units = require("src.constants.game.units")
local UNIT_TYPE_DEAD = ____units.UNIT_TYPE_DEAD
local ____logger = require("src.utils.logger")
local createLogger = ____logger.createLogger
local STORM_CROW_ABILITY = FourCC("Arav")
--- 设为 true 可打印解锁前后 GetUnitFlyHeight（排错时用）
local DEBUG_FLY_HEIGHT = false
local log = createLogger("flyheight")
local function dbgFlyHeight(msg)
    if DEBUG_FLY_HEIGHT then
        log:debug(msg)
    end
end
local function isUnitAlive(u)
    return not IsUnitType(u, UNIT_TYPE_DEAD) and GetWidgetLife(u) > 0.405
end
--- 以“风暴乌鸦形态（Arav）”解锁地面单位的 SetUnitFlyHeight（常见写法见 Hive 等教程）：
-- - 先 UnitAddAbility(Arav) 再立刻 UnitRemoveAbility(Arav)，用于“解锁”高度修改
-- - 不要长期保留 Arav：仅添加不移除时，部分单位/环境下高度仍不生效
-- - 正常流程：执行 fn，由调用方在每帧 SetUnitFlyHeight；结束时必须调用 dispose() 把高度恢复为 baseFlyHeight
-- 
-- 关于「不设置高度」的唯一分支：
-- - 下面 if (!isUnitAlive(u)) 仅表示「当前单位已死或生命过低」，不是「解锁失败」。
-- - 解锁成功与否这里没有单独判断；只要还活着，就会进入 fn 去设置高度。
-- - 已死单位不调用 fn：不对尸体做跳跃/击飞高度动画；仍会 dispose() 一次，尽量把高度写回基准（尸体上是否可见由引擎决定）。
function ____exports.ensureStormCrowFlyHeight(u, fn)
    local baseBefore = GetUnitFlyHeight(u)
    dbgFlyHeight("before unlock: GetUnitFlyHeight=" .. tostring(baseBefore))
    UnitAddAbility(u, STORM_CROW_ABILITY)
    UnitRemoveAbility(u, STORM_CROW_ABILITY)
    local afterUnlock = GetUnitFlyHeight(u)
    dbgFlyHeight("after Arav add+remove: GetUnitFlyHeight=" .. tostring(afterUnlock))
    --- 抛物线起算的基准高度：用解锁前的值，与 afterUnlock 无关（解锁可能短暂改变读数）
    local baseFlyHeight = baseBefore
    local function dispose()
        SetUnitFlyHeight(
            u,
            math.floor(baseFlyHeight + 0.5),
            0
        )
    end
    if not isUnitAlive(u) then
        dispose()
        return
    end
    fn(baseFlyHeight, dispose)
end
--- 在「本帧已经 SetUnitPosition」之后调用：部分环境下位移会抵消乌鸦解锁状态，
-- 再执行一次加/删 Arav，下一帧 SetUnitFlyHeight 才作用到模型。
function ____exports.reapplyStormCrowHeightUnlock(u)
    UnitAddAbility(u, STORM_CROW_ABILITY)
    UnitRemoveAbility(u, STORM_CROW_ABILITY)
end
--- 小封装：设置飞行高度（相当于 SetUnitFlyHeight）
function ____exports.setFlyHeight(u, height, rate)
    SetUnitFlyHeight(u, height, rate)
end
--- 高度先四舍五入为整数再 SetUnitFlyHeight。
-- 引擎本身支持 real，小数并非失败原因；取整仅为减少浮点尾数、与物编里常见整数习惯一致。
function ____exports.setFlyHeightInt(u, height, rate)
    SetUnitFlyHeight(
        u,
        math.floor(height + 0.5),
        rate
    )
end
return ____exports

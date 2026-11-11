local ____exports = {}
local _____2A = require("lua_modules.@eiriksgata.wc3ts.src.index")
local Timer = _____2A.Timer
local bj_RADTODEG = _____2A.bj_RADTODEG
local ____units = require("src.constants.game.units")
local UNIT_TYPE_DEAD = ____units.UNIT_TYPE_DEAD
local UNIT_TYPE_STRUCTURE = ____units.UNIT_TYPE_STRUCTURE
local ____physics = require("src.unit.skills.physics")
local easeInOutQuad = ____physics.easeInOutQuad
local lerp = ____physics.lerp
local parabolaArc = ____physics.parabolaArc
local unitVector2 = ____physics.unitVector2
local clamp01 = ____physics.clamp01
local ____flyheight = require("src.unit.skills.flyheight")
local ensureStormCrowFlyHeight = ____flyheight.ensureStormCrowFlyHeight
local reapplyStormCrowHeightUnlock = ____flyheight.reapplyStormCrowHeightUnlock
local setFlyHeightInt = ____flyheight.setFlyHeightInt
local ____logger = require("src.utils.logger")
local createLogger = ____logger.createLogger
--- 设为 true 可打印 unitJumpTo 每 tick 的 wantH / GetUnitFlyHeight（排错时用）
local DEBUG_UNIT_JUMP_TO = false
local log = createLogger("unitJumpTo")
local function dbgUnitJumpTo(msg)
    if DEBUG_UNIT_JUMP_TO then
        log:debug(msg)
    end
end
local function unitAlive(u)
    return not IsUnitType(u, UNIT_TYPE_DEAD) and GetWidgetLife(u) > 0.405
end
local function lockUnit(u)
    local savedSpeed = GetUnitMoveSpeed(u)
    PauseUnit(u, true)
    SetUnitPathing(u, false)
    SetUnitMoveSpeed(u, 0)
    return savedSpeed
end
local function unlockUnit(u, savedSpeed)
    PauseUnit(u, false)
    SetUnitPathing(u, true)
    SetUnitMoveSpeed(u, savedSpeed)
end
--- 带垂直位移时不要 PauseUnit；且不要把移速设为 0：
-- 物编/运行时移速为 0 时，常见现象是 GetUnitFlyHeight 有读数但模型不离地（Hive 等讨论过）。
-- 仅用关碰撞防止乱跑，移速保持原值，由寻路关闭限制位移。
local function lockUnitForVerticalMotion(u)
    local savedSpeed = GetUnitMoveSpeed(u)
    SetUnitPathing(u, false)
    return savedSpeed
end
local function unlockUnitForVerticalMotion(u, savedSpeed)
    SetUnitPathing(u, true)
    SetUnitMoveSpeed(u, savedSpeed)
end
--- 水平位移 + SetUnitFlyHeight 抛物线。引擎里高度会按日志与 wantH 一致；
-- 若「看起来」像贴地平移，多为俯视角、阴影仍在地面或模型姿态不明显，可加大 jumpMaxHeight 或配合特效/镜头。
function ____exports.unitJumpTo(target, x, y, opts)
    if not unitAlive(target) then
        return
    end
    local duration = opts and opts.duration or 0.35
    local tickInterval = opts and opts.tickInterval or 0.03
    local maxHeight = opts and opts.jumpMaxHeight or 250
    --- 由 Timer 逐帧驱动时用 0 瞬时到位；若需引擎平滑爬升可传正数 rate
    local flyRate = opts and opts.flyRate or 0
    local onHeightTick = opts and opts.onHeightTick
    local savedSpeed = lockUnitForVerticalMotion(target)
    local startX = GetUnitX(target)
    local startY = GetUnitY(target)
    local dir = unitVector2(x - startX, y - startY)
    if dir.dist > 0.001 then
        SetUnitFacing(
            target,
            math.atan(dir.ny, dir.nx) * bj_RADTODEG
        )
    end
    ensureStormCrowFlyHeight(
        target,
        function(baseFlyHeight, dispose)
            dbgUnitJumpTo((((((((((("init: baseFlyHeight=" .. tostring(baseFlyHeight)) .. " maxHeight=") .. tostring(maxHeight)) .. " duration=") .. tostring(duration)) .. " tick=") .. tostring(tickInterval)) .. " flyRate=") .. tostring(flyRate)) .. " ") .. (((((((("start=(" .. tostring(startX)) .. ",") .. tostring(startY)) .. ") end=(") .. tostring(x)) .. ",") .. tostring(y)) .. ") dist=") .. tostring(dir.dist))
            local ended = false
            local function endSkill(timer)
                if ended then
                    return
                end
                ended = true
                timer:destroy()
                if unitAlive(target) then
                    unlockUnitForVerticalMotion(target, savedSpeed)
                    SetUnitPosition(target, x, y)
                    dbgUnitJumpTo("end: SetUnitPosition done, GetUnitFlyHeight(after unlock)=" .. tostring(GetUnitFlyHeight(target)))
                end
                dispose()
            end
            local elapsed = 0
            local tickIndex = 0
            local timer = Timer:create()
            timer:start(
                tickInterval,
                true,
                function()
                    if not unitAlive(target) then
                        endSkill(timer)
                        return
                    end
                    elapsed = elapsed + tickInterval
                    local t = clamp01(elapsed / duration)
                    local e = easeInOutQuad(t)
                    local arc = parabolaArc(t)
                    local wantH = baseFlyHeight + arc * maxHeight
                    local wantHInt = math.floor(wantH + 0.5)
                    SetUnitPosition(
                        target,
                        lerp(startX, x, e),
                        lerp(startY, y, e)
                    )
                    reapplyStormCrowHeightUnlock(target)
                    setFlyHeightInt(target, wantHInt, flyRate)
                    tickIndex = tickIndex + 1
                    local actualH = GetUnitFlyHeight(target)
                    if onHeightTick then
                        onHeightTick(nil, {tickIndex = tickIndex, t = t, wantHeight = wantHInt, actualHeight = actualH})
                    end
                    dbgUnitJumpTo((((((((((((("#" .. tostring(tickIndex)) .. " t=") .. tostring(t)) .. " easeXY=") .. tostring(e)) .. " arc=") .. tostring(arc)) .. " wantH=") .. tostring(wantHInt)) .. " GetUnitFlyHeight=") .. tostring(actualH)) .. " savedSpeed=") .. tostring(savedSpeed))
                    if t >= 1 then
                        endSkill(timer)
                    end
                end
            )
        end
    )
end
function ____exports.unitChargeToPoint(target, x, y, opts)
    if not unitAlive(target) then
        return
    end
    local tickInterval = opts and opts.tickInterval or 0.03
    local stopEps = opts and opts.stopEps or 20
    local startX = GetUnitX(target)
    local startY = GetUnitY(target)
    local dir = unitVector2(x - startX, y - startY)
    if dir.dist <= stopEps then
        SetUnitPosition(target, x, y)
        return
    end
    local savedSpeed = lockUnit(target)
    local speed = opts and opts.speed or 900
    local duration = opts and opts.duration or dir.dist / speed
    local timer = Timer:create()
    local elapsed = 0
    local ended = false
    local function endSkill()
        if ended then
            return
        end
        ended = true
        timer:destroy()
        if unitAlive(target) then
            unlockUnit(target, savedSpeed)
            SetUnitPosition(target, x, y)
        end
    end
    if dir.dist > 0.001 then
        SetUnitFacing(
            target,
            math.atan(dir.ny, dir.nx) * bj_RADTODEG
        )
    end
    timer:start(
        tickInterval,
        true,
        function()
            if not unitAlive(target) then
                endSkill()
                return
            end
            elapsed = elapsed + tickInterval
            local t = clamp01(elapsed / duration)
            local traveled = dir.dist * t
            local cx = startX + dir.nx * traveled
            local cy = startY + dir.ny * traveled
            SetUnitPosition(target, cx, cy)
            if t >= 1 or traveled >= dir.dist - stopEps then
                endSkill()
            end
        end
    )
end
function ____exports.unitChargeToUnit(target, toUnit, opts)
    if not unitAlive(target) or not unitAlive(toUnit) then
        return
    end
    local tickInterval = opts and opts.tickInterval or 0.03
    local stopDist = opts and opts.stopDist or 90
    local stopEps = opts and opts.stopEps or 0.01
    local savedSpeed = lockUnit(target)
    local speedDefault = opts and opts.speed or 900
    local duration = opts and opts.duration or (function()
        local dx0 = GetUnitX(toUnit) - GetUnitX(target)
        local dy0 = GetUnitY(toUnit) - GetUnitY(target)
        local dist0 = math.sqrt(dx0 * dx0 + dy0 * dy0)
        return dist0 / speedDefault
    end)()
    local dxInit = GetUnitX(toUnit) - GetUnitX(target)
    local dyInit = GetUnitY(toUnit) - GetUnitY(target)
    local distInit = math.sqrt(dxInit * dxInit + dyInit * dyInit)
    local speed = opts and opts.speed or distInit / math.max(0.0001, duration)
    local elapsed = 0
    local ended = false
    local timer = Timer:create()
    local function endSkill()
        if ended then
            return
        end
        ended = true
        timer:destroy()
        if unitAlive(target) then
            unlockUnit(target, savedSpeed)
        end
        if not unitAlive(target) or not unitAlive(toUnit) then
            return
        end
        local dx = GetUnitX(toUnit) - GetUnitX(target)
        local dy = GetUnitY(toUnit) - GetUnitY(target)
        local dir = unitVector2(dx, dy)
        if dir.dist > stopEps then
            SetUnitPosition(
                target,
                GetUnitX(toUnit) - dir.nx * stopDist,
                GetUnitY(toUnit) - dir.ny * stopDist
            )
        end
    end
    timer:start(
        tickInterval,
        true,
        function()
            if not unitAlive(target) or not unitAlive(toUnit) then
                endSkill()
                return
            end
            elapsed = elapsed + tickInterval
            local cx = GetUnitX(target)
            local cy = GetUnitY(target)
            local tx = GetUnitX(toUnit)
            local ty = GetUnitY(toUnit)
            local dx = tx - cx
            local dy = ty - cy
            local dist = math.sqrt(dx * dx + dy * dy)
            if dist <= stopDist then
                endSkill()
                return
            end
            if dist <= stopEps then
                endSkill()
                return
            end
            local dir = unitVector2(dx, dy)
            SetUnitFacing(
                target,
                math.atan(dir.ny, dir.nx) * bj_RADTODEG
            )
            local step = speed * tickInterval
            local moveDist = math.min(step, dist - stopDist)
            if moveDist <= stopEps then
                endSkill()
                return
            end
            SetUnitPosition(target, cx + dir.nx * moveDist, cy + dir.ny * moveDist)
            if elapsed >= duration then
                endSkill()
            end
        end
    )
end
function ____exports.unitKnockUp(target, opts)
    if not unitAlive(target) then
        return
    end
    local maxHeight = opts and opts.maxHeight or 180
    local duration = opts and opts.duration or 0.45
    local tickInterval = opts and opts.tickInterval or 0.03
    local flyRate = opts and opts.flyRate or 0
    local pushDist = opts and opts.pushDist or 0
    local savedSpeed = lockUnitForVerticalMotion(target)
    local startX = GetUnitX(target)
    local startY = GetUnitY(target)
    local dir = {nx = 0, ny = 0, dist = 0}
    if opts and opts.from and unitAlive(opts.from) then
        dir = unitVector2(
            startX - GetUnitX(opts.from),
            startY - GetUnitY(opts.from)
        )
    elseif (opts and opts.pushDirX) ~= nil and (opts and opts.pushDirY) ~= nil then
        dir = unitVector2(opts.pushDirX, opts.pushDirY)
    end
    if dir.dist > 0.001 then
        SetUnitFacing(
            target,
            math.atan(dir.ny, dir.nx) * bj_RADTODEG
        )
    end
    ensureStormCrowFlyHeight(
        target,
        function(baseFlyHeight, dispose)
            local ended = false
            local function endSkill(timer)
                if ended then
                    return
                end
                ended = true
                timer:destroy()
                if unitAlive(target) then
                    unlockUnitForVerticalMotion(target, savedSpeed)
                end
                dispose()
            end
            local elapsed = 0
            local timer = Timer:create()
            timer:start(
                tickInterval,
                true,
                function()
                    if not unitAlive(target) then
                        endSkill(timer)
                        return
                    end
                    elapsed = elapsed + tickInterval
                    local t = clamp01(elapsed / duration)
                    local e = easeInOutQuad(t)
                    local cx = lerp(startX, startX + dir.nx * pushDist, e)
                    local cy = lerp(startY, startY + dir.ny * pushDist, e)
                    SetUnitPosition(target, cx, cy)
                    reapplyStormCrowHeightUnlock(target)
                    setFlyHeightInt(
                        target,
                        baseFlyHeight + parabolaArc(t) * maxHeight,
                        flyRate
                    )
                    if t >= 1 then
                        SetUnitPosition(target, startX + dir.nx * pushDist, startY + dir.ny * pushDist)
                        endSkill(timer)
                    end
                end
            )
        end
    )
end
function ____exports.casterJumpToAndKnockEnemies(caster, x, y, opts)
    if not unitAlive(caster) then
        return
    end
    local tickInterval = opts and opts.tickInterval or 0.03
    local jumpDuration = opts and opts.jumpDuration or 0.35
    local jumpMaxHeight = opts and opts.jumpMaxHeight or 220
    local flyRate = opts and opts.flyRate or 0
    local knockRadius = opts and opts.knockRadius or 350
    local knockMaxHeight = opts and opts.knockMaxHeight or 220
    local knockDuration = opts and opts.knockDuration or 0.55
    local knockPushDist = opts and opts.knockPushDist or 180
    local knockFlyRate = opts and opts.knockFlyRate or 0
    local savedSpeed = lockUnitForVerticalMotion(caster)
    local startX = GetUnitX(caster)
    local startY = GetUnitY(caster)
    local dir = unitVector2(x - startX, y - startY)
    if dir.dist > 0.001 then
        SetUnitFacing(
            caster,
            math.atan(dir.ny, dir.nx) * bj_RADTODEG
        )
    end
    ensureStormCrowFlyHeight(
        caster,
        function(baseFlyHeight, disposeCaster)
            local ended = false
            local function endCasterJump(timer)
                if ended then
                    return
                end
                ended = true
                timer:destroy()
                if unitAlive(caster) then
                    unlockUnitForVerticalMotion(caster, savedSpeed)
                    SetUnitPosition(caster, x, y)
                end
                disposeCaster()
                if not unitAlive(caster) then
                    return
                end
                local owner = GetOwningPlayer(caster)
                local g = CreateGroup()
                GroupEnumUnitsInRange(
                    g,
                    x,
                    y,
                    knockRadius,
                    nil
                )
                local u = FirstOfGroup(g)
                while u ~= nil do
                    local huX = GetUnitX(u)
                    local huY = GetUnitY(u)
                    local alive = unitAlive(u)
                    local isStructure = IsUnitType(u, UNIT_TYPE_STRUCTURE)
                    if alive and not isStructure and IsUnitEnemy(u, owner) then
                        local v = unitVector2(huX - x, huY - y)
                        ____exports.unitKnockUp(u, {
                            maxHeight = knockMaxHeight,
                            duration = knockDuration,
                            tickInterval = tickInterval,
                            flyRate = knockFlyRate,
                            pushDist = knockPushDist,
                            pushDirX = v.nx,
                            pushDirY = v.ny
                        })
                    end
                    GroupRemoveUnit(g, u)
                    u = FirstOfGroup(g)
                end
                DestroyGroup(g)
            end
            local elapsed = 0
            local timer = Timer:create()
            timer:start(
                tickInterval,
                true,
                function()
                    if not unitAlive(caster) then
                        endCasterJump(timer)
                        return
                    end
                    elapsed = elapsed + tickInterval
                    local t = clamp01(elapsed / jumpDuration)
                    local e = easeInOutQuad(t)
                    SetUnitPosition(
                        caster,
                        lerp(startX, x, e),
                        lerp(startY, y, e)
                    )
                    reapplyStormCrowHeightUnlock(caster)
                    setFlyHeightInt(
                        caster,
                        baseFlyHeight + parabolaArc(t) * jumpMaxHeight,
                        flyRate
                    )
                    if t >= 1 then
                        endCasterJump(timer)
                    end
                end
            )
        end
    )
end
return ____exports

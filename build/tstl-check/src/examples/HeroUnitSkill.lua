local ____exports = {}
local UnitAlive
local _____2A = require("lua_modules.@eiriksgata.wc3ts.src.index")
local ATTACK_TYPE_HERO = _____2A.ATTACK_TYPE_HERO
local ATTACK_TYPE_MAGIC = _____2A.ATTACK_TYPE_MAGIC
local bj_RADTODEG = _____2A.bj_RADTODEG
local DAMAGE_TYPE_COLD = _____2A.DAMAGE_TYPE_COLD
local DAMAGE_TYPE_NORMAL = _____2A.DAMAGE_TYPE_NORMAL
local Timer = _____2A.Timer
local UNIT_TYPE_DEAD = _____2A.UNIT_TYPE_DEAD
local WEAPON_TYPE_WHOKNOWS = _____2A.WEAPON_TYPE_WHOKNOWS
function UnitAlive(u)
    return not IsUnitType(
        u,
        UNIT_TYPE_DEAD()
    ) and GetWidgetLife(u) > 0.405
end
--- 暴风雪技能：对目标点周围的区域持续造成伤害，并使用暴风雪特效
-- 
-- @param caster 施法者单位
-- @param targetX 目标点X
-- @param targetY 目标点Y
-- @param opts 技能参数（可配置）
-- damage 每次落点伤害
-- radius 技能作用半径
-- duration 持续时间
-- interval 每次落点的间隔
-- stormCount 每次落点的数量
function ____exports.castBlizzardSkill(caster, targetX, targetY, opts)
    local damage = opts and opts.damage or 50
    local radius = opts and opts.radius or 400
    local duration = opts and opts.duration or 3
    local interval = opts and opts.interval or 0.33
    local stormCount = opts and opts.stormCount or 5
    local effectModel = "Abilities\\Spells\\Human\\Blizzard\\BlizzardTarget.mdl"
    --- 单次落点特效保留时长（秒），避免同帧 Destroy 导致几乎不可见
    local effectLifetime = 0.5
    local elapsed = 0
    local GROUP_RADIUS = 120
    local timer
    timer = Timer:create():start(
        interval,
        true,
        function()
            elapsed = elapsed + interval
            do
                local i = 0
                while i < stormCount do
                    local angle = GetRandomReal(0, 2 * math.pi)
                    local dist = math.sqrt(GetRandomReal(0, 1)) * radius
                    local x = targetX + dist * math.cos(angle)
                    local y = targetY + dist * math.sin(angle)
                    local sfx = AddSpecialEffect(effectModel, x, y)
                    local sfxTimer = Timer:create()
                    sfxTimer:start(
                        effectLifetime,
                        false,
                        function()
                            DestroyEffect(sfx)
                            sfxTimer:destroy()
                        end
                    )
                    local g = CreateGroup()
                    GroupEnumUnitsInRange(
                        g,
                        x,
                        y,
                        GROUP_RADIUS,
                        nil
                    )
                    local u = FirstOfGroup(g)
                    while u ~= nil do
                        if IsUnitEnemy(
                            u,
                            GetOwningPlayer(caster)
                        ) and UnitAlive(u) then
                            UnitDamageTarget(
                                caster,
                                u,
                                damage,
                                true,
                                false,
                                ATTACK_TYPE_MAGIC(),
                                DAMAGE_TYPE_COLD(),
                                WEAPON_TYPE_WHOKNOWS()
                            )
                        end
                        GroupRemoveUnit(g, u)
                        u = FirstOfGroup(g)
                    end
                    DestroyGroup(g)
                    i = i + 1
                end
            end
            if elapsed >= duration then
                timer:destroy()
            end
        end
    )
end
--- 冲刺猛攻：瞬移到目标近战距离 → 连续攻击若干次（攻击动画 + 受击特效 + 短击退与自身前冲）。
-- 施法者在整套动作中通过 Pause + 移速 0 + 禁寻路 锁定，避免玩家打断位移。
-- 单次攻击内短暂解除暂停以便播放「attack」动画（全暂停时引擎往往不播模型动画）。
function ____exports.castRushBarrageSkill(caster, target, opts)
    if not UnitAlive(caster) or not UnitAlive(target) then
        return
    end
    if not IsUnitEnemy(
        target,
        GetOwningPlayer(caster)
    ) then
        return
    end
    local hitCount = opts and opts.hitCount or 10
    local hitInterval = opts and opts.hitInterval or 0.14
    local damagePerHit = opts and opts.damagePerHit or 40
    local knockbackDist = opts and opts.knockbackDist or 42
    local selfLungeDist = opts and opts.selfLungeDist or 28
    local standDist = opts and opts.standDist or 90
    local attackAnimUnpauseSec = opts and opts.attackAnimUnpauseSec or 0.09
    local hitEffect = "Abilities\\Weapons\\HydraliskImpact\\HydraliskImpact.mdl"
    local savedSpeed = GetUnitMoveSpeed(caster)
    do
        local tx = GetUnitX(target)
        local ty = GetUnitY(target)
        local cx = GetUnitX(caster)
        local cy = GetUnitY(caster)
        local dx = tx - cx
        local dy = ty - cy
        local dist = math.sqrt(dx * dx + dy * dy)
        if dist > 0.01 then
            local nx = dx / dist
            local ny = dy / dist
            SetUnitPosition(caster, tx - nx * standDist, ty - ny * standDist)
        end
    end
    local tcx = GetUnitX(target)
    local tcy = GetUnitY(target)
    local ccx = GetUnitX(caster)
    local ccy = GetUnitY(caster)
    SetUnitFacing(
        caster,
        math.atan(tcy - ccy, tcx - ccx) * bj_RADTODEG
    )
    PauseUnit(caster, true)
    SetUnitPathing(caster, false)
    SetUnitMoveSpeed(caster, 0)
    local hitsDone = 0
    local ended = false
    local attackTimer
    local function endSkill()
        if ended then
            return
        end
        ended = true
        PauseUnit(caster, false)
        SetUnitPathing(caster, true)
        SetUnitMoveSpeed(caster, savedSpeed)
        if attackTimer ~= nil then
            attackTimer:destroy()
        end
        attackTimer = nil
    end
    local function playAttackAnimPulse()
        PauseUnit(caster, false)
        SetUnitAnimation(caster, "attack")
        local animTimer = Timer:create()
        animTimer:start(
            attackAnimUnpauseSec,
            false,
            function()
                if not ended then
                    PauseUnit(caster, true)
                end
                animTimer:destroy()
            end
        )
    end
    local function oneHit()
        if not UnitAlive(caster) or not UnitAlive(target) then
            endSkill()
            return
        end
        playAttackAnimPulse()
        UnitDamageTarget(
            caster,
            target,
            damagePerHit,
            true,
            false,
            ATTACK_TYPE_HERO(),
            DAMAGE_TYPE_NORMAL(),
            WEAPON_TYPE_WHOKNOWS()
        )
        local tx = GetUnitX(target)
        local ty = GetUnitY(target)
        local cx = GetUnitX(caster)
        local cy = GetUnitY(caster)
        local dx = tx - cx
        local dy = ty - cy
        local dist = math.sqrt(dx * dx + dy * dy)
        if dist > 1 then
            local nx = dx / dist
            local ny = dy / dist
            SetUnitPosition(target, tx + nx * knockbackDist, ty + ny * knockbackDist)
            SetUnitPosition(caster, cx + nx * selfLungeDist, cy + ny * selfLungeDist)
            SetUnitFacing(
                caster,
                math.atan(
                    GetUnitY(target) - GetUnitY(caster),
                    GetUnitX(target) - GetUnitX(caster)
                ) * bj_RADTODEG
            )
        end
        local hx = GetUnitX(target)
        local hy = GetUnitY(target)
        local sfx = AddSpecialEffect(hitEffect, hx, hy)
        local sfxTimer = Timer:create()
        sfxTimer:start(
            0.45,
            false,
            function()
                DestroyEffect(sfx)
                sfxTimer:destroy()
            end
        )
        hitsDone = hitsDone + 1
    end
    oneHit()
    if hitsDone >= hitCount then
        endSkill()
        return
    end
    attackTimer = Timer:create():start(
        hitInterval,
        true,
        function()
            if ended then
                if attackTimer ~= nil then
                    attackTimer:destroy()
                end
                attackTimer = nil
                return
            end
            if not UnitAlive(caster) or not UnitAlive(target) then
                endSkill()
                return
            end
            oneHit()
            if hitsDone >= hitCount then
                endSkill()
            end
        end
    )
end
return ____exports

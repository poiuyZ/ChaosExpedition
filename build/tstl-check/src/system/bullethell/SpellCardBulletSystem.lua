local ____lualib = require("lualib_bundle")
local __TS__Class = ____lualib.__TS__Class
local __TS__New = ____lualib.__TS__New
local __TS__ObjectAssign = ____lualib.__TS__ObjectAssign
local __TS__Delete = ____lualib.__TS__Delete
local ____exports = {}
local _____2A = require("lua_modules.@eiriksgata.wc3ts.src.index")
local ATTACK_TYPE_MAGIC = _____2A.ATTACK_TYPE_MAGIC
local DAMAGE_TYPE_NORMAL = _____2A.DAMAGE_TYPE_NORMAL
local Timer = _____2A.Timer
local UNIT_TYPE_DEAD = _____2A.UNIT_TYPE_DEAD
local WEAPON_TYPE_WHOKNOWS = _____2A.WEAPON_TYPE_WHOKNOWS
local ____EffectEx = require("src.system.EffectEx")
local EffectEx = ____EffectEx.EffectEx
local ____types = require("src.system.bullethell.types")
local SpellCardId = ____types.SpellCardId
local ____logger = require("src.utils.logger")
local createLogger = ____logger.createLogger
local log = createLogger("BulletHell")
local DEFAULT_CONFIG = {
    bulletModel = "Abilities\\Weapons\\LichMissile\\LichMissile.mdl",
    impactModel = "Abilities\\Weapons\\LichMissile\\LichMissile.mdl",
    tickInterval = 0.02,
    maxBullets = 320,
    maxImpacts = 72,
    collisionChecksPerTick = 84,
    collisionTickStride = 2
}
local DEFAULT_OPTIONS = {
    duration = 10,
    emissionInterval = 0.08,
    baseSpeed = 620,
    bulletLife = 4,
    bulletRadius = 90,
    bulletDamage = 15,
    maxDistance = 1700
}
local PLAYABLE_PLAYER_SLOTS = 12
____exports.SpellCardBulletSystem = __TS__Class()
local SpellCardBulletSystem = ____exports.SpellCardBulletSystem
SpellCardBulletSystem.name = "SpellCardBulletSystem"
function SpellCardBulletSystem.prototype.____constructor(self)
    self.config = DEFAULT_CONFIG
    self.timer = nil
    self.collisionGroup = CreateGroup()
    self.bullets = {}
    self.bulletFx = {}
    self.freeBulletIndices = {}
    self.activeBulletIndices = {}
    self.impacts = {}
    self.impactFx = {}
    self.emitters = {}
    self.nextEmitterId = 1
    self.updateTick = 0
    self.collisionCursor = 0
    self.totalSpawned = 0
    self.totalDropped = 0
    self.totalHit = 0
    self.totalRecycled = 0
end
function SpellCardBulletSystem.getInstance(self)
    if not ____exports.SpellCardBulletSystem.instance then
        ____exports.SpellCardBulletSystem.instance = __TS__New(____exports.SpellCardBulletSystem)
    end
    return ____exports.SpellCardBulletSystem.instance
end
function SpellCardBulletSystem.prototype.initialize(self, custom)
    if custom then
        self.config = __TS__ObjectAssign({}, DEFAULT_CONFIG, custom)
    end
    if #self.bullets == 0 then
        self:allocateBulletPool()
        self:allocateImpactPool()
        log:info("initialized, bullet pool=" .. tostring(self.config.maxBullets))
    end
end
function SpellCardBulletSystem.prototype.ensureTimer(self)
    if self.timer ~= nil then
        return
    end
    self.timer = Timer:create()
    self.timer:start(
        self.config.tickInterval,
        true,
        function()
            self:update(self.config.tickInterval)
            self:stopTimerIfIdle()
        end
    )
end
function SpellCardBulletSystem.prototype.hasWork(self)
    for id in pairs(self.emitters) do
        if self.emitters[id] ~= nil and self.emitters[id].active then
            return true
        end
    end
    if #self.activeBulletIndices > 0 then
        return true
    end
    for ____, impact in ipairs(self.impacts) do
        if impact.active then
            return true
        end
    end
    return false
end
function SpellCardBulletSystem.prototype.stopTimerIfIdle(self)
    if self:hasWork() then
        return
    end
    if self.timer ~= nil then
        self.timer:destroy()
        self.timer = nil
    end
end
function SpellCardBulletSystem.prototype.startCardFromCaster(self, caster, cardId, options)
    if not caster or not self:isUnitAlive(caster) then
        return nil
    end
    self:initialize()
    self:ensureTimer()
    local merged = __TS__ObjectAssign({}, DEFAULT_OPTIONS, options)
    local ____self_0, ____nextEmitterId_1 = self, "nextEmitterId"
    local ____self_nextEmitterId_2 = ____self_0[____nextEmitterId_1]
    ____self_0[____nextEmitterId_1] = ____self_nextEmitterId_2 + 1
    local id = ____self_nextEmitterId_2
    self.emitters[id] = {
        id = id,
        active = true,
        caster = caster,
        cardId = cardId,
        duration = merged.duration,
        elapsed = 0,
        emissionInterval = merged.emissionInterval,
        emissionElapsed = 0,
        baseSpeed = merged.baseSpeed,
        bulletLife = merged.bulletLife,
        bulletRadius = merged.bulletRadius,
        bulletDamage = merged.bulletDamage,
        maxDistance = merged.maxDistance,
        phase = 0,
        wave = 0
    }
    return id
end
function SpellCardBulletSystem.prototype.stopCard(self, emitterId)
    local emitter = self.emitters[emitterId]
    if not emitter then
        return
    end
    emitter.active = false
    __TS__Delete(self.emitters, emitterId)
end
function SpellCardBulletSystem.prototype.stopAllCards(self)
    for id in pairs(self.emitters) do
        __TS__Delete(self.emitters, id)
    end
end
function SpellCardBulletSystem.prototype.getStats(self)
    local activeEmitters = 0
    for id in pairs(self.emitters) do
        local ____opt_3 = self.emitters[id]
        if ____opt_3 and ____opt_3.active then
            activeEmitters = activeEmitters + 1
        end
    end
    return {
        activeBullets = #self.activeBulletIndices,
        activeEmitters = activeEmitters,
        totalSpawned = self.totalSpawned,
        totalDropped = self.totalDropped,
        totalHit = self.totalHit,
        totalRecycled = self.totalRecycled
    }
end
function SpellCardBulletSystem.prototype.destroy(self)
    self:stopAllCards()
    if self.timer then
        self.timer:destroy()
        self.timer = nil
    end
    for ____, fx in ipairs(self.bulletFx) do
        if fx ~= nil then
            fx:destroy()
        end
    end
    self.bulletFx = {}
    for ____, fx in ipairs(self.impactFx) do
        if fx ~= nil then
            fx:destroy()
        end
    end
    self.impactFx = {}
    self.bullets = {}
    self.impacts = {}
    self.freeBulletIndices = {}
    self.activeBulletIndices = {}
    DestroyGroup(self.collisionGroup)
    self.collisionGroup = CreateGroup()
end
function SpellCardBulletSystem.prototype.allocateBulletPool(self)
    do
        local i = 0
        while i < self.config.maxBullets do
            self.bullets[i + 1] = {
                id = i,
                active = false,
                activeSlot = -1,
                owner = nil,
                cardId = SpellCardId.RING_BURST,
                x = 0,
                y = 0,
                z = -2000,
                startX = 0,
                startY = 0,
                vx = 0,
                vy = 0,
                life = 0,
                elapsed = 0,
                radius = 0,
                damage = 0,
                maxDistanceSq = 0
            }
            self.bulletFx[i + 1] = EffectEx:create(self.config.bulletModel, 0, 0, -2000)
            local ____opt_9 = self.bulletFx[i + 1]
            if ____opt_9 ~= nil then
                ____opt_9:setUniformScale(0.01)
            end
            local ____self_freeBulletIndices_11 = self.freeBulletIndices
            ____self_freeBulletIndices_11[#____self_freeBulletIndices_11 + 1] = i
            i = i + 1
        end
    end
end
function SpellCardBulletSystem.prototype.allocateImpactPool(self)
    do
        local i = 0
        while i < self.config.maxImpacts do
            self.impacts[i + 1] = {active = false, life = 0, elapsed = 0}
            self.impactFx[i + 1] = EffectEx:create(self.config.impactModel, 0, 0, -2000)
            local ____opt_12 = self.impactFx[i + 1]
            if ____opt_12 ~= nil then
                ____opt_12:setUniformScale(0.01)
            end
            i = i + 1
        end
    end
end
function SpellCardBulletSystem.prototype.update(self, delta)
    self:updateEmitters(delta)
    self:updateBullets(delta)
    self:updateImpacts(delta)
    self.updateTick = self.updateTick + 1
    if self.updateTick % self.config.collisionTickStride == 0 then
        self:updateCollisions()
    end
end
function SpellCardBulletSystem.prototype.updateEmitters(self, delta)
    for id in pairs(self.emitters) do
        do
            local emitter = self.emitters[id]
            if not emitter or not emitter.active then
                goto __continue48
            end
            if not self:isUnitAlive(emitter.caster) then
                __TS__Delete(self.emitters, id)
                goto __continue48
            end
            emitter.elapsed = emitter.elapsed + delta
            emitter.emissionElapsed = emitter.emissionElapsed + delta
            while emitter.emissionElapsed >= emitter.emissionInterval do
                emitter.emissionElapsed = emitter.emissionElapsed - emitter.emissionInterval
                self:emitByCard(emitter)
                emitter.wave = emitter.wave + 1
            end
            if emitter.elapsed >= emitter.duration then
                __TS__Delete(self.emitters, id)
            end
        end
        ::__continue48::
    end
end
function SpellCardBulletSystem.prototype.emitByCard(self, emitter)
    local cx = GetUnitX(emitter.caster)
    local cy = GetUnitY(emitter.caster)
    if emitter.cardId == SpellCardId.RING_BURST then
        local count = 12
        local step = 2 * math.pi / count
        emitter.phase = emitter.phase + 0.17
        do
            local i = 0
            while i < count do
                local angle = emitter.phase + step * i
                self:spawnBullet(
                    emitter,
                    cx,
                    cy,
                    math.cos(angle) * emitter.baseSpeed,
                    math.sin(angle) * emitter.baseSpeed
                )
                i = i + 1
            end
        end
        return
    end
    if emitter.cardId == SpellCardId.DUAL_SPIRAL then
        emitter.phase = emitter.phase + 0.26
        local speed = emitter.baseSpeed * 0.95
        local angleA = emitter.phase
        local angleB = emitter.phase + math.pi
        self:spawnBullet(
            emitter,
            cx,
            cy,
            math.cos(angleA) * speed,
            math.sin(angleA) * speed
        )
        self:spawnBullet(
            emitter,
            cx,
            cy,
            math.cos(angleB) * speed,
            math.sin(angleB) * speed
        )
        local sidePhase = emitter.phase + math.pi / 2
        local sideSpeed = emitter.baseSpeed * 0.7
        self:spawnBullet(
            emitter,
            cx,
            cy,
            math.cos(sidePhase) * sideSpeed,
            math.sin(sidePhase) * sideSpeed
        )
        self:spawnBullet(
            emitter,
            cx,
            cy,
            math.cos(sidePhase + math.pi) * sideSpeed,
            math.sin(sidePhase + math.pi) * sideSpeed
        )
        return
    end
    if emitter.cardId == SpellCardId.FAN_PULSE then
        local fanCount = 10
        local fanAngle = 1.5
        emitter.phase = emitter.phase + 0.21
        local forward = emitter.phase
        do
            local i = 0
            while i < fanCount do
                local t = fanCount <= 1 and 0 or i / (fanCount - 1)
                local angle = forward - fanAngle / 2 + fanAngle * t
                local speed = emitter.baseSpeed * (0.75 + t * 0.45)
                self:spawnBullet(
                    emitter,
                    cx,
                    cy,
                    math.cos(angle) * speed,
                    math.sin(angle) * speed
                )
                i = i + 1
            end
        end
        return
    end
    if emitter.cardId == SpellCardId.ROSE_BLOOM then
        local petalCount = 6
        local step = 2 * math.pi / petalCount
        emitter.phase = emitter.phase + 0.18
        do
            local i = 0
            while i < petalCount do
                local angle = emitter.phase + step * i
                local speed = emitter.baseSpeed * (0.82 + 0.18 * math.sin(emitter.phase * 2))
                self:spawnBullet(
                    emitter,
                    cx,
                    cy,
                    math.cos(angle) * speed,
                    math.sin(angle) * speed
                )
                i = i + 1
            end
        end
        do
            local i = 0
            while i < petalCount do
                local angle = emitter.phase + math.pi / petalCount + step * i
                local speed = emitter.baseSpeed * 0.56
                self:spawnBullet(
                    emitter,
                    cx,
                    cy,
                    math.cos(angle) * speed,
                    math.sin(angle) * speed
                )
                i = i + 1
            end
        end
        return
    end
    if emitter.cardId == SpellCardId.ECHO_FAN then
        local fanCount = 8
        local reverseCount = 5
        local fanAngle = 1.18
        local reverseAngle = 0.76
        local waveSwing = emitter.wave % 4 >= 2 and math.pi / 10 or 0
        emitter.phase = emitter.phase + 0.2
        local forward = emitter.phase + waveSwing
        local backward = forward + math.pi
        do
            local i = 0
            while i < fanCount do
                local t = fanCount <= 1 and 0 or i / (fanCount - 1)
                local angle = forward - fanAngle / 2 + fanAngle * t
                local speed = emitter.baseSpeed * (0.78 + t * 0.28)
                self:spawnBullet(
                    emitter,
                    cx,
                    cy,
                    math.cos(angle) * speed,
                    math.sin(angle) * speed
                )
                i = i + 1
            end
        end
        do
            local i = 0
            while i < reverseCount do
                local t = reverseCount <= 1 and 0 or i / (reverseCount - 1)
                local angle = backward - reverseAngle / 2 + reverseAngle * t
                local speed = emitter.baseSpeed * (0.54 + t * 0.12)
                self:spawnBullet(
                    emitter,
                    cx,
                    cy,
                    math.cos(angle) * speed,
                    math.sin(angle) * speed
                )
                i = i + 1
            end
        end
        return
    end
    if emitter.cardId == SpellCardId.LATTICE_SPIN then
        emitter.phase = emitter.phase + 0.24
        do
            local i = 0
            while i < 4 do
                local angle = emitter.phase + math.pi / 2 * i
                local speed = emitter.baseSpeed * 0.88
                self:spawnBullet(
                    emitter,
                    cx,
                    cy,
                    math.cos(angle) * speed,
                    math.sin(angle) * speed
                )
                i = i + 1
            end
        end
        do
            local i = 0
            while i < 4 do
                local angle = emitter.phase * 1.45 + math.pi / 4 + math.pi / 2 * i
                local speed = emitter.baseSpeed * 0.66
                self:spawnBullet(
                    emitter,
                    cx,
                    cy,
                    math.cos(angle) * speed,
                    math.sin(angle) * speed
                )
                i = i + 1
            end
        end
        return
    end
    local count = 12
    local step = 2 * math.pi / count
    emitter.phase = emitter.phase + 0.17
    do
        local i = 0
        while i < count do
            local angle = emitter.phase + step * i
            self:spawnBullet(
                emitter,
                cx,
                cy,
                math.cos(angle) * emitter.baseSpeed,
                math.sin(angle) * emitter.baseSpeed
            )
            i = i + 1
        end
    end
end
function SpellCardBulletSystem.prototype.spawnBullet(self, emitter, x, y, vx, vy)
    local idx = table.remove(self.freeBulletIndices)
    if idx == nil then
        self.totalDropped = self.totalDropped + 1
        return
    end
    local bullet = self.bullets[idx + 1]
    bullet.active = true
    bullet.owner = emitter.caster
    bullet.cardId = emitter.cardId
    bullet.x = x
    bullet.y = y
    bullet.z = 85
    bullet.startX = x
    bullet.startY = y
    bullet.vx = vx
    bullet.vy = vy
    bullet.life = emitter.bulletLife
    bullet.elapsed = 0
    bullet.radius = emitter.bulletRadius
    bullet.damage = emitter.bulletDamage
    bullet.maxDistanceSq = emitter.maxDistance * emitter.maxDistance
    bullet.activeSlot = #self.activeBulletIndices
    local ____self_activeBulletIndices_14 = self.activeBulletIndices
    ____self_activeBulletIndices_14[#____self_activeBulletIndices_14 + 1] = idx
    local fx = self.bulletFx[idx + 1]
    if fx then
        fx:setUniformScale(0.9)
        fx:setSpeed(1)
        fx:setXYZ(x, y, bullet.z)
        fx:faceByRadians(math.atan(vy, vx))
    end
    self.totalSpawned = self.totalSpawned + 1
end
function SpellCardBulletSystem.prototype.updateBullets(self, delta)
    do
        local i = #self.activeBulletIndices - 1
        while i >= 0 do
            do
                local idx = self.activeBulletIndices[i + 1]
                local bullet = self.bullets[idx + 1]
                if not bullet.active then
                    goto __continue84
                end
                bullet.elapsed = bullet.elapsed + delta
                bullet.x = bullet.x + bullet.vx * delta
                bullet.y = bullet.y + bullet.vy * delta
                local dx = bullet.x - bullet.startX
                local dy = bullet.y - bullet.startY
                local distSq = dx * dx + dy * dy
                local fx = self.bulletFx[idx + 1]
                if fx then
                    fx:setXY(bullet.x, bullet.y)
                end
                if bullet.elapsed >= bullet.life or distSq >= bullet.maxDistanceSq then
                    self:recycleBulletByIndex(idx)
                end
            end
            ::__continue84::
            i = i - 1
        end
    end
end
function SpellCardBulletSystem.prototype.updateCollisions(self)
    local activeCount = #self.activeBulletIndices
    if activeCount <= 0 then
        self.collisionCursor = 0
        return
    end
    do
        local check = 0
        while check < self.config.collisionChecksPerTick do
            do
                if #self.activeBulletIndices <= 0 then
                    break
                end
                if self.collisionCursor >= #self.activeBulletIndices then
                    self.collisionCursor = 0
                end
                local idx = self.activeBulletIndices[self.collisionCursor + 1]
                self.collisionCursor = self.collisionCursor + 1
                local bullet = self.bullets[idx + 1]
                if not bullet.active or not bullet.owner then
                    goto __continue91
                end
                if self:checkBulletHit(bullet) then
                    self:recycleBulletByIndex(idx)
                end
            end
            ::__continue91::
            check = check + 1
        end
    end
end
function SpellCardBulletSystem.prototype.checkBulletHit(self, bullet)
    local owner = bullet.owner
    if not owner or not self:isUnitAlive(owner) then
        return false
    end
    GroupEnumUnitsInRange(
        self.collisionGroup,
        bullet.x,
        bullet.y,
        bullet.radius,
        nil
    )
    local u = FirstOfGroup(self.collisionGroup)
    while u ~= nil do
        GroupRemoveUnit(self.collisionGroup, u)
        if self:isUnitAlive(u) and self:isPlayablePlayerUnit(u) and IsUnitEnemy(
            u,
            GetOwningPlayer(owner)
        ) then
            UnitDamageTarget(
                owner,
                u,
                bullet.damage,
                true,
                false,
                ATTACK_TYPE_MAGIC(),
                DAMAGE_TYPE_NORMAL(),
                WEAPON_TYPE_WHOKNOWS()
            )
            self:spawnImpact(bullet.cardId, bullet.x, bullet.y, bullet.z)
            self.totalHit = self.totalHit + 1
            return true
        end
        u = FirstOfGroup(self.collisionGroup)
    end
    return false
end
function SpellCardBulletSystem.prototype.updateImpacts(self, delta)
    do
        local i = 0
        while i < #self.impacts do
            do
                local impact = self.impacts[i + 1]
                if not impact.active then
                    goto __continue102
                end
                impact.elapsed = impact.elapsed + delta
                if impact.elapsed >= impact.life then
                    impact.active = false
                    impact.elapsed = 0
                    impact.life = 0
                    local fx = self.impactFx[i + 1]
                    if fx ~= nil then
                        fx:setUniformScale(0.01)
                    end
                    if fx ~= nil then
                        fx:setZ(-2000)
                    end
                end
            end
            ::__continue102::
            i = i + 1
        end
    end
end
function SpellCardBulletSystem.prototype.spawnImpact(self, cardId, x, y, z)
    do
        local i = 0
        while i < #self.impacts do
            do
                local impact = self.impacts[i + 1]
                if impact.active then
                    goto __continue107
                end
                local fx = self.impactFx[i + 1]
                if not fx then
                    return
                end
                impact.active = true
                impact.elapsed = 0
                if cardId == SpellCardId.RING_BURST then
                    impact.life = 0.12
                    fx:setUniformScale(1.05):setSpeed(1):setXYZ(x, y, z + 10)
                    return
                end
                if cardId == SpellCardId.DUAL_SPIRAL then
                    impact.life = 0.16
                    fx:setUniformScale(0.85):setSpeed(1.35):setXYZ(x, y, z + 25)
                    return
                end
                if cardId == SpellCardId.FAN_PULSE then
                    impact.life = 0.2
                    fx:setUniformScale(1.2):setSpeed(0.8):setXYZ(x, y, z + 35)
                    return
                end
                if cardId == SpellCardId.ROSE_BLOOM then
                    impact.life = 0.14
                    fx:setUniformScale(0.95):setSpeed(1.15):setXYZ(x, y, z + 18)
                    return
                end
                if cardId == SpellCardId.ECHO_FAN then
                    impact.life = 0.18
                    fx:setUniformScale(1.1):setSpeed(1.05):setXYZ(x, y, z + 28)
                    return
                end
                if cardId == SpellCardId.LATTICE_SPIN then
                    impact.life = 0.22
                    fx:setUniformScale(0.78):setSpeed(1.5):setXYZ(x, y, z + 22)
                    return
                end
                impact.life = 0.16
                fx:setUniformScale(1):setSpeed(1):setXYZ(x, y, z + 20)
                return
            end
            ::__continue107::
            i = i + 1
        end
    end
end
function SpellCardBulletSystem.prototype.recycleBulletByIndex(self, idx)
    local bullet = self.bullets[idx + 1]
    if not bullet.active then
        return
    end
    local slot = bullet.activeSlot
    local lastIndex = self.activeBulletIndices[#self.activeBulletIndices]
    if slot >= 0 and slot < #self.activeBulletIndices then
        self.activeBulletIndices[slot + 1] = lastIndex
        self.bullets[lastIndex + 1].activeSlot = slot
        table.remove(self.activeBulletIndices)
    end
    bullet.active = false
    bullet.activeSlot = -1
    bullet.owner = nil
    local ____self_freeBulletIndices_19 = self.freeBulletIndices
    ____self_freeBulletIndices_19[#____self_freeBulletIndices_19 + 1] = idx
    local fx = self.bulletFx[idx + 1]
    if fx ~= nil then
        fx:setUniformScale(0.01)
    end
    if fx ~= nil then
        fx:setZ(-2000)
    end
    self.totalRecycled = self.totalRecycled + 1
    if self.collisionCursor > #self.activeBulletIndices then
        self.collisionCursor = #self.activeBulletIndices
    end
end
function SpellCardBulletSystem.prototype.isPlayablePlayerUnit(self, u)
    local owner = GetOwningPlayer(u)
    local playerId = GetPlayerId(owner)
    return playerId >= 0 and playerId < PLAYABLE_PLAYER_SLOTS
end
function SpellCardBulletSystem.prototype.isUnitAlive(self, u)
    return not IsUnitType(
        u,
        UNIT_TYPE_DEAD()
    ) and GetWidgetLife(u) > 0.405
end
SpellCardBulletSystem.instance = nil
return ____exports

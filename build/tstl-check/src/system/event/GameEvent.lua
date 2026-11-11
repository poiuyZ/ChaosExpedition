local ____lualib = require("lualib_bundle")
local __TS__Class = ____lualib.__TS__Class
local __TS__ClassExtends = ____lualib.__TS__ClassExtends
local Set = ____lualib.Set
local __TS__New = ____lualib.__TS__New
local ____exports = {}
local ____define = require("lua_modules.@eiriksgata.wc3ts.src.index")
local bj_MAX_PLAYER_SLOTS = ____define.bj_MAX_PLAYER_SLOTS
local EVENT_PLAYER_UNIT_ATTACKED = ____define.EVENT_PLAYER_UNIT_ATTACKED
local EVENT_PLAYER_UNIT_DEATH = ____define.EVENT_PLAYER_UNIT_DEATH
local EVENT_PLAYER_UNIT_DESELECTED = ____define.EVENT_PLAYER_UNIT_DESELECTED
local EVENT_PLAYER_UNIT_SELECTED = ____define.EVENT_PLAYER_UNIT_SELECTED
local EVENT_PLAYER_UNIT_SPELL_EFFECT = ____define.EVENT_PLAYER_UNIT_SPELL_EFFECT
local EVENT_PLAYER_UNIT_SUMMON = ____define.EVENT_PLAYER_UNIT_SUMMON
local ____EventEmitter = require("src.system.event.EventEmitter")
local EventEmitter = ____EventEmitter.EventEmitter
local ____actor = require("src.system.actor")
local Actor = ____actor.Actor
local ____logger = require("src.utils.logger")
local createLogger = ____logger.createLogger
local log = createLogger("GameEventManager")
--- 单位伤害事件数据（类，便于持有源伤害/当前伤害并对外提供设置方法）
____exports.UnitDamageEventData = __TS__Class()
local UnitDamageEventData = ____exports.UnitDamageEventData
UnitDamageEventData.name = "UnitDamageEventData"
function UnitDamageEventData.prototype.____constructor(self, Actor, unitTypeId, owner, source, damageAmount, attackType, damageType)
    self.Actor = Actor
    self.unitTypeId = unitTypeId
    self.owner = owner
    self.source = source
    self.originalDamage = damageAmount
    self.damage = damageAmount
    self.attackType = attackType
    self.damageType = damageType
end
function UnitDamageEventData.prototype.setEventDamage(self, amount)
    EXSetEventDamage(amount)
    self.damage = amount
end
--- 辅助函数：为所有玩家注册单位事件
-- 模拟 TriggerRegisterAnyUnitEventBJ
local function registerAnyUnitEvent(trig, event)
    do
        local i = 0
        while i < bj_MAX_PLAYER_SLOTS do
            TriggerRegisterPlayerUnitEvent(
                trig,
                Player(i),
                event,
                nil
            )
            i = i + 1
        end
    end
end
--- 游戏事件管理器
____exports.GameEventManager = __TS__Class()
local GameEventManager = ____exports.GameEventManager
GameEventManager.name = "GameEventManager"
__TS__ClassExtends(GameEventManager, EventEmitter)
function GameEventManager.prototype.____constructor(self)
    EventEmitter.prototype.____constructor(self, "GameEventManager")
    self.nativeTriggers = {}
    self.registeredEvents = __TS__New(Set)
end
function GameEventManager.getInstance(self)
    if not ____exports.GameEventManager.instance then
        ____exports.GameEventManager.instance = __TS__New(____exports.GameEventManager)
    end
    return ____exports.GameEventManager.instance
end
function GameEventManager.prototype.initialize(self)
    log:info("初始化完成")
end
function GameEventManager.prototype.registerUnitDeathEvent(self)
    if self.registeredEvents:has("game:Actor:death") then
        return
    end
    local trig = CreateTrigger()
    local ____self_nativeTriggers_0 = self.nativeTriggers
    ____self_nativeTriggers_0[#____self_nativeTriggers_0 + 1] = trig
    registerAnyUnitEvent(
        trig,
        EVENT_PLAYER_UNIT_DEATH()
    )
    TriggerAddAction(
        trig,
        function()
            local dyingUnit = GetTriggerUnit()
            local killingUnit = GetKillingUnit()
            local data = {
                Actor = Actor:fromHandle(dyingUnit),
                unitTypeId = GetUnitTypeId(dyingUnit),
                owner = GetOwningPlayer(dyingUnit),
                killer = Actor:fromHandle(killingUnit)
            }
            self:emit("game:Actor:death", data)
        end
    )
    self.registeredEvents:add("game:Actor:death")
end
function GameEventManager.prototype.registerUnitSummonedEvent(self)
    if self.registeredEvents:has("game:Actor:summoned") then
        return
    end
    local trig = CreateTrigger()
    local ____self_nativeTriggers_1 = self.nativeTriggers
    ____self_nativeTriggers_1[#____self_nativeTriggers_1 + 1] = trig
    registerAnyUnitEvent(
        trig,
        EVENT_PLAYER_UNIT_SUMMON()
    )
    TriggerAddAction(
        trig,
        function()
            local summonedUnit = GetTriggerUnit()
            local summoningUnit = GetSummoningUnit()
            local data = {
                Actor = Actor:fromHandle(summonedUnit),
                unitTypeId = GetUnitTypeId(summonedUnit),
                owner = GetOwningPlayer(summonedUnit),
                SummoningUnit = Actor:fromHandle(summoningUnit),
                SummonedUnit = Actor:fromHandle(summonedUnit)
            }
            self:emit("game:Actor:summoned", data)
        end
    )
    self.registeredEvents:add("game:Actor:summoned")
end
function GameEventManager.prototype.registerSpellEvent(self)
    if self.registeredEvents:has("game:Actor:spellEffect") then
        return
    end
    local trig = CreateTrigger()
    local ____self_nativeTriggers_2 = self.nativeTriggers
    ____self_nativeTriggers_2[#____self_nativeTriggers_2 + 1] = trig
    registerAnyUnitEvent(
        trig,
        EVENT_PLAYER_UNIT_SPELL_EFFECT()
    )
    TriggerAddAction(
        trig,
        function()
            local caster = GetTriggerUnit()
            local targetUnit = GetSpellTargetUnit()
            local data = {
                Actor = Actor:fromHandle(caster),
                unitTypeId = GetUnitTypeId(caster),
                owner = GetOwningPlayer(caster),
                abilityId = GetSpellAbilityId(),
                targetUnit = Actor:fromHandle(targetUnit),
                targetX = GetSpellTargetX(),
                targetY = GetSpellTargetY()
            }
            self:emit("game:Actor:spellEffect", data)
            self:emit(
                ("game:Actor:spellEffect" .. ":") .. tostring(data.abilityId),
                data
            )
        end
    )
    self.registeredEvents:add("game:Actor:spellEffect")
end
function GameEventManager.prototype.registerUnitAttackedEvent(self)
    if self.registeredEvents:has("game:Actor:attacked") then
        return
    end
    local trig = CreateTrigger()
    local ____self_nativeTriggers_3 = self.nativeTriggers
    ____self_nativeTriggers_3[#____self_nativeTriggers_3 + 1] = trig
    registerAnyUnitEvent(
        trig,
        EVENT_PLAYER_UNIT_ATTACKED()
    )
    TriggerAddAction(
        trig,
        function()
            local attacked = GetTriggerUnit()
            local attacker = GetAttacker()
            local data = __TS__New(
                ____exports.UnitDamageEventData,
                Actor:fromHandle(attacked),
                GetUnitTypeId(attacked),
                GetOwningPlayer(attacked),
                Actor:fromHandle(attacker),
                0
            )
            self:emit("game:Actor:attacked", data)
        end
    )
    self.registeredEvents:add("game:Actor:attacked")
end
function GameEventManager.prototype.registerUnitSelectionEvents(self)
    if self.registeredEvents:has("game:Actor:selected") then
        return
    end
    local trigSel = CreateTrigger()
    local trigDes = CreateTrigger()
    local ____self_nativeTriggers_4 = self.nativeTriggers
    ____self_nativeTriggers_4[#____self_nativeTriggers_4 + 1] = trigSel
    local ____self_nativeTriggers_5 = self.nativeTriggers
    ____self_nativeTriggers_5[#____self_nativeTriggers_5 + 1] = trigDes
    registerAnyUnitEvent(
        trigSel,
        EVENT_PLAYER_UNIT_SELECTED()
    )
    registerAnyUnitEvent(
        trigDes,
        EVENT_PLAYER_UNIT_DESELECTED()
    )
    TriggerAddAction(
        trigSel,
        function()
            local selected = GetTriggerUnit()
            local data = {
                Actor = Actor:fromHandle(selected),
                unitTypeId = GetUnitTypeId(selected),
                owner = GetOwningPlayer(selected)
            }
            self:emit("game:Actor:selected", data)
        end
    )
    TriggerAddAction(
        trigDes,
        function()
            local deselected = GetTriggerUnit()
            local data = {
                Actor = Actor:fromHandle(deselected),
                unitTypeId = GetUnitTypeId(deselected),
                owner = GetOwningPlayer(deselected)
            }
            self:emit("game:Actor:deselected", data)
        end
    )
    self.registeredEvents:add("game:Actor:selected")
    self.registeredEvents:add("game:Actor:deselected")
end
function GameEventManager.prototype.registerPlayerChatEvent(self, prefix, exactMatch)
    if prefix == nil then
        prefix = ""
    end
    if exactMatch == nil then
        exactMatch = false
    end
    local trig = CreateTrigger()
    local ____self_nativeTriggers_6 = self.nativeTriggers
    ____self_nativeTriggers_6[#____self_nativeTriggers_6 + 1] = trig
    do
        local i = 0
        while i < bj_MAX_PLAYER_SLOTS do
            TriggerRegisterPlayerChatEvent(
                trig,
                Player(i),
                prefix,
                exactMatch
            )
            i = i + 1
        end
    end
    TriggerAddAction(
        trig,
        function()
            local chatPlayer = GetTriggerPlayer()
            local data = {
                player = chatPlayer,
                playerId = GetPlayerId(chatPlayer),
                message = GetEventPlayerChatString()
            }
            self:emit("game:player:chat", data)
        end
    )
    self.registeredEvents:add("game:player:chat")
end
function GameEventManager.prototype.onUnitDeath(self, handler, options)
    self:registerUnitDeathEvent()
    return self:on("game:Actor:death", handler, options)
end
function GameEventManager.prototype.onUnitAttacked(self, handler, options)
    self:registerUnitAttackedEvent()
    return self:on("game:Actor:attacked", handler, options)
end
function GameEventManager.prototype.onUnitSelected(self, handler, options)
    self:registerUnitSelectionEvents()
    return self:on("game:Actor:selected", handler, options)
end
function GameEventManager.prototype.onUnitDeselected(self, handler, options)
    self:registerUnitSelectionEvents()
    return self:on("game:Actor:deselected", handler, options)
end
function GameEventManager.prototype.onUnitDamaged(self, handler, options)
    return self:on("game:Actor:damaged", handler, options)
end
function GameEventManager.prototype.onUnitSummoned(self, handler, options)
    self:registerUnitSummonedEvent()
    return self:on("game:Actor:summoned", handler, options)
end
function GameEventManager.prototype.onSpellEffect(self, handler, abilityId, options)
    self:registerSpellEvent()
    local eventName = abilityId and ("game:Actor:spellEffect" .. ":") .. tostring(abilityId) or "game:Actor:spellEffect"
    return self:on(eventName, handler, options)
end
function GameEventManager.prototype.onPlayerChat(self, handler, options)
    if not self.registeredEvents:has("game:player:chat") then
        self:registerPlayerChatEvent()
    end
    return self:on("game:player:chat", handler, options)
end
function GameEventManager.prototype.destroy(self)
    EventEmitter.prototype.destroy(self)
    for ____, trig in ipairs(self.nativeTriggers) do
        DestroyTrigger(trig)
    end
    self.nativeTriggers = {}
    self.registeredEvents:clear()
end
--- 快捷访问游戏事件管理器
____exports.gameEvents = ____exports.GameEventManager:getInstance()
return ____exports

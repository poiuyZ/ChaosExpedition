local ____lualib = require("lualib_bundle")
local __TS__Class = ____lualib.__TS__Class
local __TS__New = ____lualib.__TS__New
local Map = ____lualib.Map
local __TS__ArrayFind = ____lualib.__TS__ArrayFind
local __TS__ArrayFindIndex = ____lualib.__TS__ArrayFindIndex
local __TS__ArraySplice = ____lualib.__TS__ArraySplice
local __TS__ArrayMap = ____lualib.__TS__ArrayMap
local __TS__ArraySome = ____lualib.__TS__ArraySome
local ____exports = {}
local ____EventBus = require("src.system.event.EventBus")
local eventBus = ____EventBus.eventBus
local ____event = require("src.system.event.index")
local gameEvents = ____event.gameEvents
local ____RelicPool = require("src.system.relic.RelicPool")
local RelicPool = ____RelicPool.RelicPool
local ____RelicRegistry = require("src.system.relic.RelicRegistry")
local RelicRegistry = ____RelicRegistry.RelicRegistry
local ____logger = require("src.utils.logger")
local createLogger = ____logger.createLogger
local log = createLogger("RelicSystem")
local EVENT_ADDED = "relic:added"
local EVENT_REMOVED = "relic:removed"
local EVENT_INVENTORY_CHANGED = "relic:inventoryChanged"
--- 遗物运行时：注册表、命名池、单位库存
____exports.RelicSystem = __TS__Class()
local RelicSystem = ____exports.RelicSystem
RelicSystem.name = "RelicSystem"
function RelicSystem.prototype.____constructor(self)
    self.registry = __TS__New(RelicRegistry)
    self.pools = __TS__New(Map)
    self.inventory = __TS__New(Map)
    self.deathCleanupBound = false
end
function RelicSystem.getInstance(self)
    if not ____exports.RelicSystem.instance then
        ____exports.RelicSystem.instance = __TS__New(____exports.RelicSystem)
    end
    return ____exports.RelicSystem.instance
end
function RelicSystem.prototype.registerDefinition(self, def)
    self.registry:register(def)
end
function RelicSystem.prototype.registerDefinitions(self, defs)
    self.registry:registerAll(defs)
end
function RelicSystem.prototype.registerPool(self, name, entries)
    self.pools:set(
        name,
        __TS__New(RelicPool, entries)
    )
end
function RelicSystem.prototype.getPool(self, name)
    return self.pools:get(name)
end
function RelicSystem.prototype.drawFromPool(self, poolName)
    local pool = self.pools:get(poolName)
    if not pool then
        log:warn("drawFromPool: pool not found: " .. poolName)
        return nil
    end
    return pool:draw()
end
function RelicSystem.prototype.getDefinition(self, id)
    return self.registry:get(id)
end
function RelicSystem.prototype.addRelic(self, target, id, options)
    local def = self.registry:get(id)
    if not def then
        log:warn("addRelic: unknown relic id: " .. id)
        return false
    end
    local uid = target.id
    local maxStacks = def.maxStacks or 1
    local list = self.inventory:get(uid)
    if not list then
        list = {}
        self.inventory:set(uid, list)
    end
    local existing = __TS__ArrayFind(
        list,
        function(____, e) return e.id == id end
    )
    if existing then
        if existing.stacks >= maxStacks then
            return false
        end
        existing.stacks = existing.stacks + 1
        if def.onStack then
            def:onStack(target, existing.stacks)
        end
        if not (options and options.silent) then
            self:emitAdded(target, id, existing.stacks)
            self:emitInventoryChanged(target)
        end
        return true
    end
    list[#list + 1] = {id = id, stacks = 1}
    def:onAcquire(target)
    if not (options and options.silent) then
        self:emitAdded(target, id, 1)
        self:emitInventoryChanged(target)
    end
    return true
end
function RelicSystem.prototype.removeRelic(self, target, id, options)
    local def = self.registry:get(id)
    if not def then
        return false
    end
    local list = self.inventory:get(target.id)
    if not list then
        return false
    end
    local idx = __TS__ArrayFindIndex(
        list,
        function(____, e) return e.id == id end
    )
    if idx < 0 then
        return false
    end
    local entry = list[idx + 1]
    local removeAll = (options and options.all) == true
    local delta = removeAll and entry.stacks or 1
    entry.stacks = entry.stacks - delta
    if entry.stacks <= 0 then
        __TS__ArraySplice(list, idx, 1)
        if def.onRemove then
            def:onRemove(target, delta)
        end
    elseif def.onStack then
        def:onStack(target, entry.stacks)
    end
    if not (options and options.silent) then
        self:emitRemoved(target, id, delta)
        self:emitInventoryChanged(target)
    end
    return true
end
function RelicSystem.prototype.clearUnit(self, target, options)
    local uid = target.id
    local list = self.inventory:get(uid)
    if not list or #list == 0 then
        return
    end
    local copy = {table.unpack(list)}
    self.inventory:delete(uid)
    for ____, e in ipairs(copy) do
        local def = self.registry:get(e.id)
        if def and def.onRemove then
            def:onRemove(target, e.stacks)
        end
    end
    if not (options and options.silent) then
        for ____, e in ipairs(copy) do
            self:emitRemoved(target, e.id, e.stacks)
        end
        self:emitInventoryChanged(target)
    end
end
function RelicSystem.prototype.getRelics(self, target)
    local list = self.inventory:get(target.id)
    if not list then
        return {}
    end
    return __TS__ArrayMap(
        list,
        function(____, e) return {id = e.id, stacks = e.stacks} end
    )
end
function RelicSystem.prototype.hasRelic(self, target, id)
    local list = self.inventory:get(target.id)
    return list ~= nil and __TS__ArraySome(
        list,
        function(____, e) return e.id == id end
    )
end
function RelicSystem.prototype.bindDeathCleanup(self)
    if self.deathCleanupBound then
        return
    end
    self.deathCleanupBound = true
    gameEvents:onUnitDeath(function(data)
        local actor = data.Actor
        if actor == nil then
            return
        end
        self:clearUnit(actor)
        actor:detach()
    end)
end
function RelicSystem.prototype.emitAdded(self, target, relicId, stacks)
    eventBus:emit(EVENT_ADDED, {actor = target, relicId = relicId, stacks = stacks})
end
function RelicSystem.prototype.emitRemoved(self, target, relicId, stacks)
    eventBus:emit(EVENT_REMOVED, {actor = target, relicId = relicId, stacks = stacks})
end
function RelicSystem.prototype.emitInventoryChanged(self, target)
    eventBus:emit(EVENT_INVENTORY_CHANGED, {actor = target})
end
____exports.RELIC_EVENT_ADDED = EVENT_ADDED
____exports.RELIC_EVENT_REMOVED = EVENT_REMOVED
____exports.RELIC_EVENT_INVENTORY_CHANGED = EVENT_INVENTORY_CHANGED
return ____exports

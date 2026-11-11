local ____lualib = require("lualib_bundle")
local __TS__Class = ____lualib.__TS__Class
local Map = ____lualib.Map
local __TS__New = ____lualib.__TS__New
local __TS__ArraySplice = ____lualib.__TS__ArraySplice
local __TS__ArrayFindIndex = ____lualib.__TS__ArrayFindIndex
local __TS__Iterator = ____lualib.__TS__Iterator
local __TS__ArrayFilter = ____lualib.__TS__ArrayFilter
local __TS__ArrayFrom = ____lualib.__TS__ArrayFrom
local ____exports = {}
local ____logger = require("src.utils.logger")
local createLogger = ____logger.createLogger
local log = createLogger("EventEmitter")
--- 事件发射器
-- 通用的事件订阅/发布基类，可用于任何需要事件机制的场景
____exports.EventEmitter = __TS__Class()
local EventEmitter = ____exports.EventEmitter
EventEmitter.name = "EventEmitter"
function EventEmitter.prototype.____constructor(self, name)
    if name == nil then
        name = "EventEmitter"
    end
    self.subscriptions = __TS__New(Map)
    self.nextId = 1
    self.name = name
end
function EventEmitter.prototype.on(self, eventName, handler, options)
    local ____self_0, ____nextId_1 = self, "nextId"
    local ____self_nextId_2 = ____self_0[____nextId_1]
    ____self_0[____nextId_1] = ____self_nextId_2 + 1
    local id = ____self_nextId_2
    local ____id_10 = id
    local ____eventName_11 = eventName
    local ____handler_12 = handler
    local ____temp_13 = options and options.priority or 0
    local ____temp_7 = options and options.once
    if ____temp_7 == nil then
        ____temp_7 = false
    end
    local subscription = {
        id = ____id_10,
        eventName = ____eventName_11,
        handler = ____handler_12,
        priority = ____temp_13,
        once = ____temp_7,
        tag = options and options.tag
    }
    if not self.subscriptions:has(eventName) then
        self.subscriptions:set(eventName, {})
    end
    local subs = self.subscriptions:get(eventName)
    local insertAt = #subs
    do
        local i = 0
        while i < #subs do
            if subs[i + 1].priority < subscription.priority then
                insertAt = i
                break
            end
            i = i + 1
        end
    end
    __TS__ArraySplice(subs, insertAt, 0, subscription)
    return id
end
function EventEmitter.prototype.once(self, eventName, handler, priority)
    return self:on(eventName, handler, {once = true, priority = priority})
end
function EventEmitter.prototype.off(self, subscriptionId)
    for ____, ____value in __TS__Iterator(self.subscriptions) do
        local _eventName = ____value[1]
        local subs = ____value[2]
        local index = __TS__ArrayFindIndex(
            subs,
            function(____, sub) return sub.id == subscriptionId end
        )
        if index ~= -1 then
            __TS__ArraySplice(subs, index, 1)
            return true
        end
    end
    return false
end
function EventEmitter.prototype.offAll(self, eventName)
    self.subscriptions:delete(eventName)
end
function EventEmitter.prototype.offByTag(self, tag)
    local count = 0
    for ____, ____value in __TS__Iterator(self.subscriptions) do
        local _eventName = ____value[1]
        local subs = ____value[2]
        local filtered = __TS__ArrayFilter(
            subs,
            function(____, sub)
                if sub.tag == tag then
                    count = count + 1
                    return false
                end
                return true
            end
        )
        self.subscriptions:set(_eventName, filtered)
    end
    return count
end
function EventEmitter.prototype.emit(self, eventName, data)
    local subs = self.subscriptions:get(eventName)
    if not subs or #subs == 0 then
        return
    end
    local toRemove = {}
    for ____, sub in ipairs(subs) do
        do
            local function ____catch(e)
                log:error((((self.name .. " handler \"") .. eventName) .. "\": ") .. tostring(e))
            end
            local ____try, ____hasReturned = pcall(function()
                sub.handler(data)
            end)
            if not ____try then
                ____catch(____hasReturned)
            end
        end
        if sub.once then
            toRemove[#toRemove + 1] = sub.id
        end
    end
    for ____, id in ipairs(toRemove) do
        self:off(id)
    end
end
function EventEmitter.prototype.hasSubscribers(self, eventName)
    local subs = self.subscriptions:get(eventName)
    return subs ~= nil and #subs > 0
end
function EventEmitter.prototype.getSubscriberCount(self, eventName)
    if eventName then
        local ____opt_14 = self.subscriptions:get(eventName)
        return ____opt_14 and #____opt_14 or 0
    end
    local total = 0
    for ____, subs in __TS__Iterator(self.subscriptions:values()) do
        total = total + #subs
    end
    return total
end
function EventEmitter.prototype.getEventNames(self)
    return __TS__ArrayFrom(self.subscriptions:keys())
end
function EventEmitter.prototype.clear(self)
    self.subscriptions:clear()
end
function EventEmitter.prototype.destroy(self)
    self:clear()
end
return ____exports

local ____lualib = require("lualib_bundle")
local __TS__Class = ____lualib.__TS__Class
local __TS__New = ____lualib.__TS__New
local ____exports = {}
local ____EventEmitter = require("src.system.event.EventEmitter")
local EventEmitter = ____EventEmitter.EventEmitter
--- 全局事件总线
-- 单例模式，用于全局事件通信
____exports.EventBus = __TS__Class()
local EventBus = ____exports.EventBus
EventBus.name = "EventBus"
function EventBus.prototype.____constructor(self)
    self.emitter = __TS__New(EventEmitter, "GlobalEventBus")
end
function EventBus.getInstance(self)
    if not ____exports.EventBus.instance then
        ____exports.EventBus.instance = __TS__New(____exports.EventBus)
    end
    return ____exports.EventBus.instance
end
function EventBus.prototype.on(self, eventName, handler, options)
    return self.emitter:on(eventName, handler, options)
end
function EventBus.prototype.once(self, eventName, handler, priority)
    return self.emitter:once(eventName, handler, priority)
end
function EventBus.prototype.off(self, subscriptionId)
    return self.emitter:off(subscriptionId)
end
function EventBus.prototype.offAll(self, eventName)
    self.emitter:offAll(eventName)
end
function EventBus.prototype.offByTag(self, tag)
    return self.emitter:offByTag(tag)
end
function EventBus.prototype.emit(self, eventName, data)
    self.emitter:emit(eventName, data)
end
function EventBus.prototype.hasSubscribers(self, eventName)
    return self.emitter:hasSubscribers(eventName)
end
function EventBus.prototype.getSubscriberCount(self, eventName)
    return self.emitter:getSubscriberCount(eventName)
end
function EventBus.prototype.getEventNames(self)
    return self.emitter:getEventNames()
end
function EventBus.prototype.clear(self)
    self.emitter:clear()
end
--- 快捷访问全局事件总线
____exports.eventBus = ____exports.EventBus:getInstance()
return ____exports

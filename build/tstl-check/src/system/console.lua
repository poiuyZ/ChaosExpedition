local ____lualib = require("lualib_bundle")
local __TS__Class = ____lualib.__TS__Class
local __TS__New = ____lualib.__TS__New
local ____exports = {}
local ____MessageList = require("src.system.ui.component.MessageList")
local MessageList = ____MessageList.MessageList
local ____queue = require("src.utils.queue")
local Queue = ____queue.Queue
--- 控制台类
-- 使用队列存储消息，通过定时器每0.1秒处理一条消息
-- 
-- 多玩家支持说明：
-- - UI是本地客户端的，每个玩家看到的UI是独立的
-- - init()方法应该在每个玩家的客户端都调用，但只有本地玩家会创建UI
-- - log/error/warn方法：
--   - 如果不指定player，消息会显示给所有玩家（每个玩家在自己的客户端看到）
--   - 如果指定了player，只有当该player是本地玩家时才会显示
____exports.Console = __TS__Class()
local Console = ____exports.Console
Console.name = "Console"
function Console.prototype.____constructor(self)
end
function Console.getMessageList(self)
    return ____exports.Console.messageList
end
function Console.init(self, x, y, width, height, config)
    if x == nil then
        x = 300
    end
    if y == nil then
        y = 200
    end
    if width == nil then
        width = 400
    end
    if height == nil then
        height = 300
    end
    if ____exports.Console.isInitialized then
        return
    end
    ____exports.Console.messageList = MessageList:createInstance(
        x,
        y,
        width,
        height,
        config
    )
    ____exports.Console.processTimer = CreateTimer()
    TimerStart(
        ____exports.Console.processTimer,
        0.1,
        true,
        function()
            ____exports.Console:processNextMessage()
        end
    )
    ____exports.Console.isInitialized = true
end
function Console.processNextMessage(self)
    if not ____exports.Console.messageList or ____exports.Console.messageQueue:isEmpty() then
        return
    end
    local message = ____exports.Console.messageQueue:dequeue()
    if not message then
        return
    end
    ____exports.Console.messageList:addMessage(message.text, message.duration, message.color, message.player)
end
function Console.log(self, message, duration, player)
    if duration == nil then
        duration = 5
    end
    ____exports.Console.messageQueue:enqueue({text = message, duration = duration, color = "00FF00", player = player})
end
function Console.error(self, message, duration, player)
    if duration == nil then
        duration = 5
    end
    ____exports.Console.messageQueue:enqueue({text = message, duration = duration, color = "FF0000", player = player})
end
function Console.warn(self, message, duration, player)
    if duration == nil then
        duration = 5
    end
    ____exports.Console.messageQueue:enqueue({text = message, duration = duration, color = "FFFF00", player = player})
end
function Console.getQueueLength(self)
    return ____exports.Console.messageQueue:length()
end
function Console.clearQueue(self)
    ____exports.Console.messageQueue:clear()
end
function Console.destroy(self)
    if ____exports.Console.processTimer then
        PauseTimer(____exports.Console.processTimer)
        DestroyTimer(____exports.Console.processTimer)
        ____exports.Console.processTimer = nil
    end
    ____exports.Console.messageQueue:clear()
    ____exports.Console.messageList = nil
    ____exports.Console.isInitialized = false
end
Console.messageQueue = __TS__New(Queue)
Console.messageList = nil
Console.processTimer = nil
Console.isInitialized = false
return ____exports

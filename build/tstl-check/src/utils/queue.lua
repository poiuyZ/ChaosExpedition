local ____lualib = require("lualib_bundle")
local __TS__Class = ____lualib.__TS__Class
local ____exports = {}
--- 队列数据结构实现
-- 参考 demo/Queue.lua 的实现逻辑
-- 支持泛型，适用于 tstl 项目
____exports.Queue = __TS__Class()
local Queue = ____exports.Queue
Queue.name = "Queue"
function Queue.prototype.____constructor(self, initialItems)
    self.items = {}
    if initialItems then
        self.items = {table.unpack(initialItems)}
    end
end
function Queue.prototype.enqueue(self, element)
    local ____self_items_0 = self.items
    ____self_items_0[#____self_items_0 + 1] = element
end
function Queue.prototype.dequeue(self)
    return table.remove(self.items, 1)
end
function Queue.prototype.length(self)
    return #self.items
end
function Queue.prototype.isEmpty(self)
    return #self.items == 0
end
function Queue.prototype.peek(self)
    local ____temp_1
    if #self.items > 0 then
        ____temp_1 = self.items[1]
    else
        ____temp_1 = nil
    end
    return ____temp_1
end
function Queue.prototype.clear(self)
    self.items = {}
end
function Queue.prototype.toArray(self)
    return {table.unpack(self.items)}
end
____exports.default = ____exports.Queue
return ____exports

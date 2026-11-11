local ____lualib = require("lualib_bundle")
local __TS__Class = ____lualib.__TS__Class
local __TS__Iterator = ____lualib.__TS__Iterator
local __TS__ObjectKeys = ____lualib.__TS__ObjectKeys
local __TS__ArraySort = ____lualib.__TS__ArraySort
local Map = ____lualib.Map
local __TS__New = ____lualib.__TS__New
local ____exports = {}
local ____logger = require("src.utils.logger")
local createLogger = ____logger.createLogger
local log = createLogger("LeakDetector")
____exports.LeakDetector = __TS__Class()
local LeakDetector = ____exports.LeakDetector
LeakDetector.name = "LeakDetector"
function LeakDetector.prototype.____constructor(self)
end
function LeakDetector.install(self)
    if self.installed then
        return
    end
    self.installed = true
    self:hookTimer()
    self:hookTrigger()
    log:info("已安装句柄跟踪钩子")
end
function LeakDetector.setEnabled(self, enabled)
    self.enabled = enabled
end
function LeakDetector.setShowDetails(self, show)
    self.showDetails = show
end
function LeakDetector.dump(self, minLifetimeSec)
    if minLifetimeSec == nil then
        minLifetimeSec = 0
    end
    local now = self:now()
    local count = 0
    local kindCounts = {}
    log:info("|cff00ff00========== LeakDetector Report ==========|r")
    for ____, ____value in __TS__Iterator(self.records:entries()) do
        local obj = ____value[1]
        local info = ____value[2]
        do
            local life = now - info.createdAt
            if life < minLifetimeSec then
                goto __continue8
            end
            kindCounts[info.kind] = (kindCounts[info.kind] or 0) + 1
            count = count + 1
            if self.showDetails then
                log:info(string.format(
                    "#%d [%s] 存活时间: %.2fs 对象: %s",
                    count,
                    info.kind,
                    life,
                    tostring(obj)
                ))
                if info.stack then
                    log:debug(info.stack)
                end
            end
        end
        ::__continue8::
    end
    if #__TS__ObjectKeys(kindCounts) > 0 then
        local parts = {}
        for ____, kind in ipairs(__TS__ObjectKeys(kindCounts)) do
            local current = kindCounts[kind]
            local ____opt_0 = self.lastKindCounts
            local prev = ____opt_0 and ____opt_0[kind] or 0
            local diff = current - prev
            local label = self:kindLabel(kind)
            local part = (label .. ":") .. tostring(current)
            if diff ~= 0 then
                part = part .. string.format("(%+d)", diff)
            end
            parts[#parts + 1] = part
        end
        __TS__ArraySort(parts)
        log:info(table.concat(parts, "，"))
        self.lastKindCounts = kindCounts
    end
    if count == 0 then
        log:info(string.format("未发现疑似泄露对象（阈值 %.2fs）", minLifetimeSec))
    else
        log:info(string.format("共发现 %d 个疑似泄露对象（阈值 %.2fs）", count, minLifetimeSec))
    end
    log:info("|cff00ff00=========================================|r")
end
function LeakDetector.kindLabel(self, kind)
    repeat
        local ____switch20 = kind
        local ____cond20 = ____switch20 == "timer"
        if ____cond20 then
            return "计时器"
        end
        ____cond20 = ____cond20 or ____switch20 == "trigger"
        if ____cond20 then
            return "触发器"
        end
        ____cond20 = ____cond20 or ____switch20 == "triggerDialog"
        if ____cond20 then
            return "触发器对话框"
        end
        ____cond20 = ____cond20 or ____switch20 == "timerDialog"
        if ____cond20 then
            return "计时器对话框"
        end
        ____cond20 = ____cond20 or ____switch20 == "group"
        if ____cond20 then
            return "单位组"
        end
        ____cond20 = ____cond20 or ____switch20 == "force"
        if ____cond20 then
            return "玩家组"
        end
        ____cond20 = ____cond20 or ____switch20 == "location"
        if ____cond20 then
            return "点"
        end
        ____cond20 = ____cond20 or ____switch20 == "region"
        if ____cond20 then
            return "范围"
        end
        ____cond20 = ____cond20 or ____switch20 == "unit"
        if ____cond20 then
            return "单位"
        end
        ____cond20 = ____cond20 or ____switch20 == "unitAtLoc"
        if ____cond20 then
            return "单位(点)"
        end
        ____cond20 = ____cond20 or ____switch20 == "corpse"
        if ____cond20 then
            return "尸体"
        end
        ____cond20 = ____cond20 or ____switch20 == "item"
        if ____cond20 then
            return "物品"
        end
        ____cond20 = ____cond20 or (____switch20 == "destructable" or ____switch20 == "destructableZ")
        if ____cond20 then
            return "可破坏物"
        end
        ____cond20 = ____cond20 or ____switch20 == "fogRect"
        if ____cond20 then
            return "矩形区域雾效"
        end
        ____cond20 = ____cond20 or ____switch20 == "fogRadius"
        if ____cond20 then
            return "范围雾效"
        end
        ____cond20 = ____cond20 or ____switch20 == "texttag"
        if ____cond20 then
            return "文本"
        end
        ____cond20 = ____cond20 or (____switch20 == "effect" or ____switch20 == "effectTarget")
        if ____cond20 then
            return "特效"
        end
        ____cond20 = ____cond20 or ____switch20 == "hashtable"
        if ____cond20 then
            return "哈希表"
        end
        ____cond20 = ____cond20 or ____switch20 == "sound"
        if ____cond20 then
            return "声音"
        end
        ____cond20 = ____cond20 or ____switch20 == "condition"
        if ____cond20 then
            return "触发器条件"
        end
        ____cond20 = ____cond20 or ____switch20 == "filter"
        if ____cond20 then
            return "过滤器"
        end
        do
            return kind
        end
    until true
end
function LeakDetector.reset(self)
    self.records:clear()
end
function LeakDetector.hookHandlePair(self, createName, destroyName, kind)
    local createFn = _G[createName]
    local destroyFn = _G[destroyName]
    if type(createFn) ~= "function" or type(destroyFn) ~= "function" then
        return
    end
    local ____self = self
    _G[createName] = function(...)
        local handle = createFn(...)
        if handle ~= nil then
            ____self:registerHandle(handle, kind)
        end
        return handle
    end
    _G[destroyName] = function(handle, ...)
        ____self:unregisterHandle(handle)
        return destroyFn(handle, ...)
    end
end
function LeakDetector.hookTimer(self)
    self:hookHandlePair("CreateTimer", "DestroyTimer", "timer")
end
function LeakDetector.hookTrigger(self)
    self:hookHandlePair("CreateTrigger", "DestroyTrigger", "trigger")
    self:hookHandlePair("CreateTriggerDialog", "DestroyTriggerDialog", "triggerDialog")
    self:hookHandlePair("CreateTimerDialog", "DestroyTimerDialog", "timerDialog")
    self:hookHandlePair("CreateGroup", "DestroyGroup", "group")
    self:hookHandlePair("CreateForce", "DestroyForce", "force")
    self:hookHandlePair("Location", "RemoveLocation", "location")
    self:hookHandlePair("CreateRegion", "RemoveRegion", "region")
    self:hookHandlePair("CreateUnit", "RemoveUnit", "unit")
    self:hookHandlePair("CreateUnitAtLoc", "RemoveUnit", "unitAtLoc")
    self:hookHandlePair("CreateCorpse", "RemoveUnit", "corpse")
    self:hookHandlePair("CreateItem", "RemoveItem", "item")
    self:hookHandlePair("CreateDestructable", "RemoveDestructable", "destructable")
    self:hookHandlePair("CreateDestructableZ", "RemoveDestructable", "destructableZ")
    self:hookHandlePair("CreateFogModifierRect", "DestroyFogModifier", "fogRect")
    self:hookHandlePair("CreateFogModifierRadius", "DestroyFogModifier", "fogRadius")
    self:hookHandlePair("CreateTextTag", "DestroyTextTag", "texttag")
    self:hookHandlePair("AddSpecialEffect", "DestroyEffect", "effect")
    self:hookHandlePair("AddSpecialEffectTarget", "DestroyEffect", "effectTarget")
    self:hookHandlePair("InitHashtable", "DestroyHashtable", "hashtable")
    self:hookHandlePair("CreateSound", "DestroySound", "sound")
    self:hookHandlePair("Condition", "DestroyCondition", "condition")
    self:hookHandlePair("Filter", "DestroyFilter", "filter")
end
function LeakDetector.registerHandle(self, handle, kind)
    if not self.enabled then
        return
    end
    local createdAt = self:now()
    local stack = self:captureStack()
    self.records:set(handle, {kind = kind, createdAt = createdAt, stack = stack})
end
function LeakDetector.unregisterHandle(self, handle)
    if not self.enabled then
        return
    end
    self.records:delete(handle)
end
function LeakDetector.now(self)
    do
        local ____try, ____hasReturned, ____returnValue = pcall(function()
            if os and type(os.clock) == "function" then
                return true, os:clock()
            end
        end)
        if ____try and ____hasReturned then
            return ____returnValue
        end
    end
    return 0
end
function LeakDetector.captureStack(self)
    do
        local ____try, ____hasReturned, ____returnValue = pcall(function()
            if debug and type(debug.traceback) == "function" then
                return true, debug:traceback("", 3)
            end
        end)
        if ____try and ____hasReturned then
            return ____returnValue
        end
    end
    return nil
end
LeakDetector.installed = false
LeakDetector.enabled = true
LeakDetector.records = __TS__New(Map)
LeakDetector.lastKindCounts = nil
LeakDetector.showDetails = false
return ____exports

local ____lualib = require("lualib_bundle")
local __TS__Class = ____lualib.__TS__Class
local __TS__New = ____lualib.__TS__New
local __TS__ArrayMap = ____lualib.__TS__ArrayMap
local __TS__StringCharAt = ____lualib.__TS__StringCharAt
local __TS__StringSubstring = ____lualib.__TS__StringSubstring
local __TS__ParseInt = ____lualib.__TS__ParseInt
local ____exports = {}
local _____2A = require("lua_modules.@eiriksgata.wc3ts.src.index")
local Timer = _____2A.Timer
local ____ModuleManager = require("src.system.ModuleManager")
local ModuleManager = ____ModuleManager.ModuleManager
local ____logger = require("src.utils.logger")
local createLogger = ____logger.createLogger
local log = createLogger("HotReload")
--- 检查是否为开发模式
local function isDevMode()
    return type(PROJECT_PATH) ~= "nil" and PROJECT_PATH ~= nil
end
--- 热更新管理器
-- 负责检测外部热更新通知并重新加载指定模块
-- 注意：仅在开发模式下有效，生产环境会自动禁用
____exports.HotReload = __TS__Class()
local HotReload = ____exports.HotReload
HotReload.name = "HotReload"
function HotReload.prototype.____constructor(self)
    self.timer = nil
    self.checkInterval = 1
    self.lastProcessedTimestamp = 0
    self.gameStartTimestamp = 0
    self.enabled = true
end
function HotReload.getInstance(self)
    if not ____exports.HotReload.instance then
        ____exports.HotReload.instance = __TS__New(____exports.HotReload)
    end
    return ____exports.HotReload.instance
end
function HotReload.prototype.start(self)
    if not isDevMode() then
        log:info("Production mode detected, hot reload disabled")
        self.enabled = false
        return
    end
    if not self.enabled then
        log:info("Hot reload is disabled")
        return
    end
    if self.timer then
        log:info("Hot reload is already running")
        return
    end
    do
        local function ____catch(____error)
            self.gameStartTimestamp = 0
            log:warn("os.time() not available, fallback to 0, error: " .. tostring(____error))
        end
        local ____try, ____hasReturned = pcall(function()
            self.gameStartTimestamp = os.time()
        end)
        if not ____try then
            ____catch(____hasReturned)
        end
    end
    log:info("Starting hot reload system...")
    log:info(("Game start timestamp: " .. tostring(self.gameStartTimestamp)) .. " (seconds, 10 digits)")
    log:info(("Check interval: " .. tostring(self.checkInterval)) .. " seconds")
    log:info("PROJECT_PATH: " .. tostring(PROJECT_PATH))
    self.timer = Timer:create()
    self.timer:start(
        self.checkInterval,
        true,
        function()
            self:checkForUpdates()
        end
    )
    log:info("Hot reload system started successfully")
end
function HotReload.prototype.stop(self)
    if self.timer then
        self.timer:destroy()
        self.timer = nil
        log:info("Hot reload system stopped")
    end
end
function HotReload.prototype.setEnabled(self, enabled)
    self.enabled = enabled
    if not enabled then
        self:stop()
    end
    log:info("Hot reload " .. (enabled and "enabled" or "disabled"))
end
function HotReload.prototype.checkForUpdates(self)
    do
        local function ____catch(____error)
            log:error("Error in checkForUpdates: " .. tostring(____error))
        end
        local ____try, ____hasReturned, ____returnValue = pcall(function()
            local notificationContent = self:readHotReloadFile()
            if not notificationContent then
                return true
            end
            local notification = self:parseNotification(notificationContent)
            if not notification then
                log:error("Failed to parse notification")
                return true
            end
            local notificationTimestampSeconds = notification.timestamp
            if notificationTimestampSeconds > 10000000000 then
                notificationTimestampSeconds = math.floor(notificationTimestampSeconds / 1000)
            end
            if notificationTimestampSeconds < self.gameStartTimestamp then
                return true
            end
            if notificationTimestampSeconds <= self.lastProcessedTimestamp then
                return true
            end
            log:info("New notification detected!")
            log:info(((("Notification timestamp: " .. tostring(notificationTimestampSeconds)) .. " (original: ") .. tostring(notification.timestamp)) .. ")")
            log:info("Game start timestamp: " .. tostring(self.gameStartTimestamp))
            log:info("Last processed: " .. tostring(self.lastProcessedTimestamp))
            log:info("Action: " .. notification.action)
            log:info("Modules: " .. table.concat(
                __TS__ArrayMap(
                    notification.modules,
                    function(____, m) return m.name end
                ),
                ", "
            ))
            self:processHotReload(notification)
            self:markAsProcessed(notificationTimestampSeconds)
        end)
        if not ____try then
            ____hasReturned, ____returnValue = ____catch(____hasReturned)
        end
        if ____hasReturned then
            return ____returnValue
        end
    end
end
function HotReload.prototype.readHotReloadFile(self)
    do
        local function ____catch(____error)
            log:error("Error reading hot reload file: " .. tostring(____error))
            return true, nil
        end
        local ____try, ____hasReturned, ____returnValue = pcall(function()
            local filePath = tostring(PROJECT_PATH) .. "/hot-reload.json"
            local file = {io.open(filePath, "r")}
            if not file then
                return true, nil
            end
            local content = ""
            local line
            while true do
                local ____opt_0 = file[1]
                line = ____opt_0 and ____opt_0:read("l") or nil
                if not line then
                    break
                end
                content = content .. line .. "\n"
            end
            local ____opt_2 = file[1]
            if ____opt_2 ~= nil then
                ____opt_2:close()
            end
            return true, content
        end)
        if not ____try then
            ____hasReturned, ____returnValue = ____catch(____hasReturned)
        end
        if ____hasReturned then
            return ____returnValue
        end
    end
end
function HotReload.prototype.parseNotification(self, content)
    do
        local function ____catch(____error)
            return true, nil
        end
        local ____try, ____hasReturned, ____returnValue = pcall(function()
            return true, self:parseJsonManually(content)
        end)
        if not ____try then
            ____hasReturned, ____returnValue = ____catch(____hasReturned)
        end
        if ____hasReturned then
            return ____returnValue
        end
    end
end
function HotReload.prototype.parseJsonManually(self, jsonStr)
    do
        local function ____catch(____error)
            return true, nil
        end
        local ____try, ____hasReturned, ____returnValue = pcall(function()
            local str = self:removeWhitespace(jsonStr)
            local timestamp = self:extractNumber(str, "\"timestamp\":")
            local action = self:extractString(str, "\"action\":\"")
            local modules = self:extractModules(str)
            local processed = self:extractBoolean(str, "\"processed\":")
            return true, {timestamp = timestamp or 0, action = action or "", modules = modules or ({}), processed = processed or false}
        end)
        if not ____try then
            ____hasReturned, ____returnValue = ____catch(____hasReturned)
        end
        if ____hasReturned then
            return ____returnValue
        end
    end
end
function HotReload.prototype.removeWhitespace(self, str)
    local result = ""
    do
        local i = 0
        while i < #str do
            local char = __TS__StringCharAt(str, i)
            if char ~= " " and char ~= "\n" and char ~= "\r" and char ~= "\t" then
                result = result .. char
            end
            i = i + 1
        end
    end
    return result
end
function HotReload.prototype.extractNumber(self, str, key)
    local startIndex = (string.find(str, key, nil, true) or 0) - 1
    if startIndex == -1 then
        return nil
    end
    local valueStart = startIndex + #key
    local valueEnd = valueStart
    while valueEnd < #str do
        local char = __TS__StringCharAt(str, valueEnd)
        if char >= "0" and char <= "9" then
            valueEnd = valueEnd + 1
        else
            break
        end
    end
    local numberStr = __TS__StringSubstring(str, valueStart, valueEnd)
    return numberStr ~= "" and __TS__ParseInt(numberStr) or nil
end
function HotReload.prototype.extractString(self, str, key)
    local startIndex = (string.find(str, key, nil, true) or 0) - 1
    if startIndex == -1 then
        return nil
    end
    local valueStart = startIndex + #key
    local valueEnd = (string.find(
        str,
        "\"",
        math.max(valueStart + 1, 1),
        true
    ) or 0) - 1
    if valueEnd == -1 then
        return nil
    end
    return __TS__StringSubstring(str, valueStart, valueEnd)
end
function HotReload.prototype.extractModules(self, str)
    local modules = {}
    local startKey = "\"modules\":["
    local startIndex = (string.find(str, startKey, nil, true) or 0) - 1
    if startIndex == -1 then
        return modules
    end
    local arrayStart = startIndex + #startKey
    local depth = 1
    local arrayEnd = arrayStart
    do
        local i = arrayStart
        while i < #str and depth > 0 do
            local char = __TS__StringCharAt(str, i)
            if char == "[" or char == "{" then
                depth = depth + 1
            elseif char == "]" or char == "}" then
                depth = depth - 1
            end
            if depth == 0 then
                arrayEnd = i
            end
            i = i + 1
        end
    end
    if arrayEnd == arrayStart then
        return modules
    end
    local arrayContent = __TS__StringSubstring(str, arrayStart, arrayEnd)
    local i = 0
    while i < #arrayContent do
        local objStart = (string.find(
            arrayContent,
            "{",
            math.max(i + 1, 1),
            true
        ) or 0) - 1
        if objStart == -1 then
            break
        end
        local objEnd = (string.find(
            arrayContent,
            "}",
            math.max(objStart + 1, 1),
            true
        ) or 0) - 1
        if objEnd == -1 then
            break
        end
        local objContent = __TS__StringSubstring(arrayContent, objStart, objEnd + 1)
        local name = self:extractStringFromObject(objContent, "\"name\":\"")
        local path = self:extractStringFromObject(objContent, "\"path\":\"")
        if name and path then
            modules[#modules + 1] = {name = name, path = path}
        end
        i = objEnd + 1
    end
    return modules
end
function HotReload.prototype.extractStringFromObject(self, objStr, key)
    local startIndex = (string.find(objStr, key, nil, true) or 0) - 1
    if startIndex == -1 then
        return nil
    end
    local valueStart = startIndex + #key
    local valueEnd = (string.find(
        objStr,
        "\"",
        math.max(valueStart + 1, 1),
        true
    ) or 0) - 1
    if valueEnd == -1 then
        return nil
    end
    return __TS__StringSubstring(objStr, valueStart, valueEnd)
end
function HotReload.prototype.extractBoolean(self, str, key)
    local startIndex = (string.find(str, key, nil, true) or 0) - 1
    if startIndex == -1 then
        return nil
    end
    local valueStart = startIndex + #key
    if __TS__StringSubstring(str, valueStart, valueStart + 4) == "true" then
        return true
    elseif __TS__StringSubstring(str, valueStart, valueStart + 5) == "false" then
        return false
    end
    return nil
end
function HotReload.prototype.processHotReload(self, notification)
    log:info(("Processing hot reload for " .. tostring(#notification.modules)) .. " modules...")
    local moduleManager = ModuleManager:getInstance()
    local registeredModules = moduleManager:getRegisteredModules()
    log:info("All registered modules: " .. table.concat(registeredModules, ", "))
    local matchedModules = {}
    for ____, moduleInfo in ipairs(notification.modules) do
        log:info(((("Checking module: " .. moduleInfo.name) .. " (") .. moduleInfo.path) .. ")")
        if moduleManager:isModuleRegistered(moduleInfo.name) then
            log:info("✓ Matched: " .. moduleInfo.name)
            matchedModules[#matchedModules + 1] = moduleInfo
        else
            log:warn("✗ Not registered: " .. moduleInfo.name)
        end
    end
    local matchedNames = table.concat(
        __TS__ArrayMap(
            matchedModules,
            function(____, m) return m.name end
        ),
        ", "
    )
    log:info("Matched registered modules: " .. matchedNames)
    if #matchedModules == 0 then
        log:warn("No registered modules to hot reload")
        return
    end
    log:info("Calling ModuleManager.hotReloadModules...")
    moduleManager:hotReloadModulesWithPath(matchedModules)
end
function HotReload.prototype.reloadModule(self, moduleName)
    _G.package.loaded[moduleName] = nil
    local newModule = require(moduleName)
    if newModule and type(newModule.initialize) == "function" then
        newModule.initialize()
    end
    if newModule and type(newModule.onHotReload) == "function" then
        newModule.onHotReload()
    end
end
function HotReload.prototype.markAsProcessed(self, timestampSeconds)
    self.lastProcessedTimestamp = timestampSeconds
    log:info(("Marked notification with timestamp " .. tostring(timestampSeconds)) .. " as processed in memory")
end
return ____exports

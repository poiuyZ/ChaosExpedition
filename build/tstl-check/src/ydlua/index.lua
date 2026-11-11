local ____lualib = require("lualib_bundle")
local __TS__Class = ____lualib.__TS__Class
local __TS__New = ____lualib.__TS__New
local ____exports = {}
local ____config = require("src.config.index")
local ConfigManager = ____config.ConfigManager
local ____logger = require("src.utils.logger")
local createLogger = ____logger.createLogger
local log = createLogger("ydlua")
local runtimeLog = createLogger("LuaRuntime")
local ydcommon = require("jass.common")
local ydai = require("jass.ai")
local ydglobals = require("jass.globals")
local ydjapi = require("jass.japi")
local ydhook = require("jass.hook")
local ydruntime = require("jass.runtime")
local ydslk = require("jass.slk")
local ydconsole = require("jass.console")
local yddebug = require("jass.debug")
local ydlog = require("jass.log")
local ydmessage = require("jass.message")
local ydbignum = require("jass.bignum")
____exports.ydlua = __TS__Class()
local ydlua = ____exports.ydlua
ydlua.name = "ydlua"
function ydlua.prototype.____constructor(self)
    self.configManager = ConfigManager:getInstance()
end
function ydlua.getInstance(self)
    if not ____exports.ydlua.instance then
        ____exports.ydlua.instance = __TS__New(____exports.ydlua)
    end
    return ____exports.ydlua.instance
end
function ydlua.prototype.initializeRuntime(self)
    local config = self.configManager:getConfig()
    local runtimeConfig = config.runtime
    ydruntime.console = config.console
    ydruntime.sleep = runtimeConfig.sleep
    ydruntime.debugger = runtimeConfig.debuggerPort
    ydruntime.catch_crash = runtimeConfig.catchCrash
    ydruntime.error_hanlde = function(self, msg)
        runtimeLog:error("======== lua-err ========")
        runtimeLog:error(tostring(msg))
        runtimeLog:error("=========================")
    end
    log:info((("Runtime configured: debugger=" .. tostring(runtimeConfig.debuggerPort)) .. ", crash_catch=") .. tostring(runtimeConfig.catchCrash))
end
function ydlua.prototype.initialize(self)
    self:initializeConsole()
    self:installErrorHandler()
    self:registerGlobals()
end
function ydlua.prototype.installErrorHandler(self)
    ydruntime.error_hanlde = function(self, msg)
        runtimeLog:error("======== lua-err ========")
        runtimeLog:error(tostring(msg))
        runtimeLog:error("=========================")
    end
end
function ydlua.prototype.initializeConsole(self)
    local isConsoleEnabled = self.configManager:isConsoleEnabled()
    ydconsole.enable = isConsoleEnabled
    if isConsoleEnabled then
        _G.print = function(message) return ydconsole.write(message) end
        log:info("print enabled")
    end
end
function ydlua.prototype.registerGlobals(self)
    log:info("Global APIs registered")
end
return ____exports

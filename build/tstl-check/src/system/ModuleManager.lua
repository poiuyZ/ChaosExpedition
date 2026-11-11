local ____lualib = require("lualib_bundle")
local __TS__Class = ____lualib.__TS__Class
local Map = ____lualib.Map
local __TS__New = ____lualib.__TS__New
local Set = ____lualib.Set
local Error = ____lualib.Error
local RangeError = ____lualib.RangeError
local ReferenceError = ____lualib.ReferenceError
local SyntaxError = ____lualib.SyntaxError
local TypeError = ____lualib.TypeError
local URIError = ____lualib.URIError
local __TS__Iterator = ____lualib.__TS__Iterator
local __TS__ArrayFrom = ____lualib.__TS__ArrayFrom
local ____exports = {}
local ____logger = require("src.utils.logger")
local createLogger = ____logger.createLogger
local log = createLogger("ModuleManager")
____exports.ModuleManager = __TS__Class()
local ModuleManager = ____exports.ModuleManager
ModuleManager.name = "ModuleManager"
function ModuleManager.prototype.____constructor(self)
    self.modules = __TS__New(Map)
    self.initializationOrder = {}
    log:info("Instance created")
end
function ModuleManager.getInstance(self)
    if not ____exports.ModuleManager.instance then
        log:info("Creating new instance")
        ____exports.ModuleManager.instance = __TS__New(____exports.ModuleManager)
    end
    return ____exports.ModuleManager.instance
end
function ModuleManager.prototype.registerModule(self, module, options)
    if options == nil then
        options = {}
    end
    local name = module.name
    if not name then
        log:error("module has no name property")
        return
    end
    local moduleInfo = {
        name = name,
        module = module,
        initializeFunction = options.initialize,
        cleanupFunction = options.cleanup,
        hotReloadFunction = options.onHotReload,
        dependencies = options.dependencies or ({}),
        initialized = false
    }
    self.modules:set(name, moduleInfo)
    log:info("Module registered: " .. name)
    log:info("Total registered modules: " .. tostring(self.modules.size))
end
function ModuleManager.prototype.initializeAllModules(self)
    self:calculateInitializationOrder()
    for ____, moduleName in ipairs(self.initializationOrder) do
        self:initializeModule(moduleName)
    end
end
function ModuleManager.prototype.initializeModule(self, name)
    local moduleInfo = self.modules:get(name)
    if not moduleInfo then
        log:warn(("Module " .. name) .. " not found")
        return
    end
    if moduleInfo.initialized then
        return
    end
    for ____, depName in ipairs(moduleInfo.dependencies or ({})) do
        self:initializeModule(depName)
    end
    do
        local function ____catch(____error)
            log:error((("initializing module " .. name) .. ": ") .. tostring(____error))
        end
        local ____try, ____hasReturned = pcall(function()
            if moduleInfo.initializeFunction then
                moduleInfo:initializeFunction()
            end
            moduleInfo.initialized = true
            log:info("Module initialized: " .. name)
        end)
        if not ____try then
            ____catch(____hasReturned)
        end
    end
end
function ModuleManager.prototype.hotReloadModuleWithPath(self, name, requirePath)
    local moduleInfo = self.modules:get(name)
    if not moduleInfo then
        log:warn(("Module " .. name) .. " not registered for hot reload")
        return
    end
    do
        local function ____catch(____error)
            log:error((("during hot reload of module " .. name) .. ": ") .. tostring(____error))
        end
        local ____try, ____hasReturned = pcall(function()
            if moduleInfo.cleanupFunction then
                moduleInfo:cleanupFunction()
                log:info("Cleaned up module: " .. name)
            end
            _G.package.loaded[requirePath] = nil
            local newModule = require(requirePath)
            moduleInfo.module = newModule
            log:info((("Reloaded module: " .. name) .. " from ") .. requirePath)
            if moduleInfo.hotReloadFunction then
                moduleInfo:hotReloadFunction()
                log:info("Hot reload handled for module: " .. name)
            end
            if moduleInfo.initializeFunction then
                moduleInfo.initialized = false
                self:initializeModule(name)
            end
        end)
        if not ____try then
            ____catch(____hasReturned)
        end
    end
end
function ModuleManager.prototype.hotReloadModulesWithPath(self, modules)
    log:info(("Hot reloading " .. tostring(#modules)) .. " modules...")
    local successCount = 0
    local failCount = 0
    for ____, mod in ipairs(modules) do
        do
            local function ____catch(____error)
                failCount = failCount + 1
                log:error((("Failed to hot reload module " .. mod.name) .. ": ") .. tostring(____error))
            end
            local ____try, ____hasReturned = pcall(function()
                self:hotReloadModuleWithPath(mod.name, mod.path)
                successCount = successCount + 1
            end)
            if not ____try then
                ____catch(____hasReturned)
            end
        end
    end
    log:info(((("Hot reload completed: " .. tostring(successCount)) .. " succeeded, ") .. tostring(failCount)) .. " failed")
end
function ModuleManager.prototype.hotReloadModule(self, name)
    local modulePath = self:getModulePathFromName(name)
    if modulePath then
        self:hotReloadModuleWithPath(name, modulePath)
    else
        log:warn("Cannot find path for module " .. name)
    end
end
function ModuleManager.prototype.hotReloadModules(self, moduleNames)
    log:info(("Hot reloading " .. tostring(#moduleNames)) .. " modules...")
    local successCount = 0
    local failCount = 0
    for ____, moduleName in ipairs(moduleNames) do
        do
            local function ____catch(____error)
                failCount = failCount + 1
                log:error((("Failed to hot reload module " .. moduleName) .. ": ") .. tostring(____error))
            end
            local ____try, ____hasReturned = pcall(function()
                self:hotReloadModule(moduleName)
                successCount = successCount + 1
            end)
            if not ____try then
                ____catch(____hasReturned)
            end
        end
    end
    log:info(((("Hot reload completed: " .. tostring(successCount)) .. " succeeded, ") .. tostring(failCount)) .. " failed")
end
function ModuleManager.prototype.getModulePathFromName(self, name)
    local possiblePaths = {
        "src.examples." .. name,
        "src.system.ui.component." .. name,
        "src.system.ui." .. name,
        "src.system." .. name,
        "src.utils." .. name,
        "src.config." .. name,
        "src." .. name
    }
    return possiblePaths[1]
end
function ModuleManager.prototype.calculateInitializationOrder(self)
    local visited = __TS__New(Set)
    local visiting = __TS__New(Set)
    local order = {}
    local visit
    visit = function(name)
        if visiting:has(name) then
            error(
                __TS__New(Error, "Circular dependency detected involving " .. name),
                0
            )
        end
        if visited:has(name) then
            return
        end
        visiting:add(name)
        local moduleInfo = self.modules:get(name)
        if moduleInfo then
            for ____, depName in ipairs(moduleInfo.dependencies or ({})) do
                visit(depName)
            end
        end
        visiting:delete(name)
        visited:add(name)
        order[#order + 1] = name
    end
    for ____, moduleName in __TS__Iterator(self.modules:keys()) do
        if not visited:has(moduleName) then
            visit(moduleName)
        end
    end
    self.initializationOrder = order
end
function ModuleManager.prototype.getRegisteredModules(self)
    return __TS__ArrayFrom(self.modules:keys())
end
function ModuleManager.prototype.isModuleRegistered(self, name)
    return self.modules:has(name)
end
return ____exports

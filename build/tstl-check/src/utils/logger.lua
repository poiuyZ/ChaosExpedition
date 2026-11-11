local ____exports = {}
local function write(module, level, message)
    if level == "INFO" then
        print((("[" .. module) .. "] ") .. message)
        return
    end
    print((((("[" .. module) .. "][") .. level) .. "] ") .. message)
end
--- 一次性日志（无 logger 实例时）
function ____exports.log(module, message)
    write(module, "INFO", message)
end
function ____exports.logWarn(module, message)
    write(module, "WARN", message)
end
function ____exports.logError(module, message)
    write(module, "ERROR", message)
end
function ____exports.createLogger(module)
    return {
        info = function(____, message) return write(module, "INFO", message) end,
        warn = function(____, message) return write(module, "WARN", message) end,
        error = function(____, message) return write(module, "ERROR", message) end,
        debug = function(____, message) return write(module, "DEBUG", message) end
    }
end
return ____exports

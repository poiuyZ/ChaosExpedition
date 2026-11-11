local ____exports = {}
do
    local ____Buff = require("src.system.buff.Buff")
    ____exports.Buff = ____Buff.Buff
end
do
    local ____BuffManager = require("src.system.buff.BuffManager")
    ____exports.BuffManager = ____BuffManager.BuffManager
end
do
    local ____ShieldBuff = require("src.system.buff.ShieldBuff")
    ____exports.ShieldBuff = ____ShieldBuff.ShieldBuff
end
do
    local ____BuffSystem = require("src.system.buff.BuffSystem")
    ____exports.BuffSystem = ____BuffSystem.BuffSystem
end
do
    local ____types = require("src.system.buff.types")
    ____exports.BuffTypeId = ____types.BuffTypeId
    ____exports.BUFF_DURATION_PERMANENT = ____types.BUFF_DURATION_PERMANENT
    ____exports.BUFF_EVENT_BUFFS_CHANGED = ____types.BUFF_EVENT_BUFFS_CHANGED
end
do
    local ____BuffDisplayRegistry = require("src.system.buff.BuffDisplayRegistry")
    ____exports.registerBuffDisplay = ____BuffDisplayRegistry.registerBuffDisplay
    ____exports.registerDefaultBuffDisplays = ____BuffDisplayRegistry.registerDefaultBuffDisplays
    ____exports.getBuffDisplay = ____BuffDisplayRegistry.getBuffDisplay
    ____exports.resolveBuffDisplay = ____BuffDisplayRegistry.resolveBuffDisplay
    ____exports.getRemainingSeconds = ____BuffDisplayRegistry.getRemainingSeconds
    ____exports.formatSlotTimeShort = ____BuffDisplayRegistry.formatSlotTimeShort
    ____exports.buildBuffTooltipText = ____BuffDisplayRegistry.buildBuffTooltipText
end
return ____exports

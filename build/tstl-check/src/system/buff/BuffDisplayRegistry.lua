local ____lualib = require("lualib_bundle")
local Map = ____lualib.Map
local __TS__New = ____lualib.__TS__New
local __TS__ObjectAssign = ____lualib.__TS__ObjectAssign
local __TS__NumberToFixed = ____lualib.__TS__NumberToFixed
local __TS__InstanceOf = ____lualib.__TS__InstanceOf
local ____exports = {}
local ____ShieldBuff = require("src.system.buff.ShieldBuff")
local ShieldBuff = ____ShieldBuff.ShieldBuff
local ____types = require("src.system.buff.types")
local BuffTypeId = ____types.BuffTypeId
local FALLBACK_ICON = "ReplaceableTextures\\CommandButtons\\BTNSelectHeroOn.blp"
local registry = __TS__New(Map)
local DEFAULT_UNKNOWN = {name = "未知 Buff", description = "", icon = FALLBACK_ICON}
function ____exports.registerBuffDisplay(key, def)
    registry:set(key, def)
end
--- 注册内置类型（护盾等）；可多次调用，后写覆盖
function ____exports.registerDefaultBuffDisplays()
    ____exports.registerBuffDisplay(BuffTypeId.SHIELD, {name = "护盾", description = "吸收一定伤害；护盾耗尽或持续时间结束时移除。", icon = "ReplaceableTextures\\CommandButtons\\BTNSpell_ShieldWall.blp"})
end
function ____exports.getBuffDisplay(key)
    return registry:get(key) or DEFAULT_UNKNOWN
end
--- 查找顺序：displayKey > typeId；未知时用 displayKey/typeId 作为标题
function ____exports.resolveBuffDisplay(buff)
    local key = buff.displayKey or buff.typeId
    local base = registry:get(key) or registry:get(buff.typeId)
    if base then
        return base
    end
    return __TS__ObjectAssign({}, DEFAULT_UNKNOWN, {name = key})
end
--- 剩余秒数；永久 Buff 为 null
function ____exports.getRemainingSeconds(buff)
    if buff.duration < 0 then
        return nil
    end
    return math.max(0, buff.duration - buff.elapsed)
end
--- 槽位角标：简短时间或 ∞
function ____exports.formatSlotTimeShort(buff)
    if buff.duration < 0 then
        return "∞"
    end
    local r = ____exports.getRemainingSeconds(buff)
    if r >= 100 then
        return tostring(math.floor(r))
    end
    if r >= 10 then
        return tostring(math.floor(r))
    end
    return __TS__NumberToFixed(r, 1)
end
--- Tips 正文：名称、描述、剩余时间、护盾数值
function ____exports.buildBuffTooltipText(buff)
    local d = ____exports.resolveBuffDisplay(buff)
    local t = (d.name .. "\n\n") .. d.description
    local rem = ____exports.getRemainingSeconds(buff)
    if rem ~= nil then
        t = t .. ("\n\n剩余时间：" .. __TS__NumberToFixed(rem, 1)) .. " 秒"
    else
        t = t .. "\n\n剩余时间：永久"
    end
    if __TS__InstanceOf(buff, ShieldBuff) then
        t = t .. (("\n护盾：" .. tostring(math.floor(buff.current))) .. " / ") .. tostring(math.floor(buff.max))
    end
    return t
end
return ____exports

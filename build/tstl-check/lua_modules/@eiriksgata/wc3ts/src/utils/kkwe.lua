local ____lualib = require("lualib_bundle")
local Map = ____lualib.Map
local __TS__New = ____lualib.__TS__New
local __TS__StringSplit = ____lualib.__TS__StringSplit
local __TS__ParseInt = ____lualib.__TS__ParseInt
local ____exports = {}
function ____exports.DzSetHeroTypeProperName(uid, name)
    EXSetUnitArrayString(uid, 61, 0, name)
    EXSetUnitInteger(uid, 61, 1)
end
--- 设置单位类型名称
-- 设置单位类型ID${单位ID}的名称为${名称}
-- 修改单位类型的显示名称
function ____exports.DzSetUnitTypeName(uid, name)
    EXSetUnitArrayString(uid, 10, 0, name)
    EXSetUnitInteger(uid, 10, 1)
end
--- 判断单位攻击类型
-- 判断${单位}的第${索引}个攻击是否为${攻击类型}
-- 检查单位指定索引的攻击类型
function ____exports.DzIsUnitAttackType(whichUnit, index, attackType)
    return ConvertAttackType(math.floor(GetUnitState(
        whichUnit,
        ConvertUnitState(16 + 19 * index)
    ))) == attackType
end
--- 设置单位攻击类型
-- 设置${单位}的第${索引}个攻击类型为${攻击类型}
-- 修改单位指定索引的攻击类型
function ____exports.DzSetUnitAttackType(whichUnit, index, attackType)
    SetUnitState(
        whichUnit,
        ConvertUnitState(16 + 19 * index),
        GetHandleId(attackType)
    )
end
--- 判断单位防御类型
-- 判断${单位}的防御类型是否为${防御类型}
-- 检查单位的防御类型
function ____exports.DzIsUnitDefenseType(whichUnit, defenseType)
    return math.floor(GetUnitState(
        whichUnit,
        ConvertUnitState(80)
    )) == defenseType
end
--- 设置单位防御类型
-- 设置${单位}的防御类型为${防御类型}
-- 修改单位的防御类型
function ____exports.DzSetUnitDefenseType(whichUnit, defenseType)
    SetUnitState(
        whichUnit,
        ConvertUnitState(80),
        defenseType
    )
end
--- 设置单位数据缓存整数 - 简化版
-- 设置单位ID${单位ID}的数据ID${数据ID}值为${值}
-- 简化版的单位数据缓存设置函数，索引固定为0
function ____exports.KKWESetUnitDataCacheInteger(uid, id, v)
    DzSetUnitDataCacheInteger(uid, id, 0, v)
end
--- 单位UI添加升级IDs
-- 为单位ID${单位ID}在索引${索引}添加升级ID${值}
-- 向单位的升级列表添加新的升级ID
function ____exports.KKWEUnitUIAddUpgradesIds(uid, id, v)
    DzUnitUIAddLevelArrayInteger(uid, 94, id, v)
end
--- 单位UI添加建造IDs
-- 为单位ID${单位ID}在索引${索引}添加建造ID${值}
-- 向单位的建造列表添加新的建造ID
function ____exports.KKWEUnitUIAddBuildsIds(uid, id, v)
    DzUnitUIAddLevelArrayInteger(uid, 100, id, v)
end
--- 单位UI添加研究IDs
-- 为单位ID${单位ID}在索引${索引}添加研究ID${值}
-- 向单位的研究列表添加新的研究ID
function ____exports.KKWEUnitUIAddResearchesIds(uid, id, v)
    DzUnitUIAddLevelArrayInteger(uid, 112, id, v)
end
--- 单位UI添加训练IDs
-- 为单位ID${单位ID}在索引${索引}添加训练ID${值}
-- 向单位的训练列表添加新的训练ID
function ____exports.KKWEUnitUIAddTrainsIds(uid, id, v)
    DzUnitUIAddLevelArrayInteger(uid, 106, id, v)
end
--- 单位UI添加出售单位IDs
-- 为单位ID${单位ID}在索引${索引}添加出售单位ID${值}
-- 向单位的出售单位列表添加新的单位ID
function ____exports.KKWEUnitUIAddSellsUnitIds(uid, id, v)
    DzUnitUIAddLevelArrayInteger(uid, 118, id, v)
end
--- 单位UI添加出售物品IDs
-- 为单位ID${单位ID}在索引${索引}添加出售物品ID${值}
-- 向单位的出售物品列表添加新的物品ID
function ____exports.KKWEUnitUIAddSellsItemIds(uid, id, v)
    DzUnitUIAddLevelArrayInteger(uid, 124, id, v)
end
--- 单位UI添加制造物品IDs
-- 为单位ID${单位ID}在索引${索引}添加制造物品ID${值}
-- 向单位的制造物品列表添加新的物品ID
function ____exports.KKWEUnitUIAddMakesItemIds(uid, id, v)
    DzUnitUIAddLevelArrayInteger(uid, 130, id, v)
end
--- 单位UI添加需求单位代码
-- 为单位ID${单位ID}在索引${索引}添加需求单位代码${值}
-- 向单位的需求列表添加新的单位代码
function ____exports.KKWEUnitUIAddRequiresUnitCode(uid, id, v)
    DzUnitUIAddLevelArrayInteger(uid, 166, id, v)
end
--- 单位UI添加需求科技代码
-- 为单位ID${单位ID}在索引${索引}添加需求科技代码${值}
-- 向单位的需求列表添加新的科技代码
function ____exports.KKWEUnitUIAddRequiresTechcode(uid, id, v)
    DzUnitUIAddLevelArrayInteger(uid, 166, id, v)
end
--- 单位UI添加需求数量
-- 为单位ID${单位ID}在索引${索引}添加需求数量${值}
-- 向单位的需求数量列表添加新的数量值
function ____exports.KKWEUnitUIAddRequiresAmounts(uid, id, v)
    DzUnitUIAddLevelArrayInteger(uid, 172, id, v)
end
--- 判断是否为闰年
-- 判断年份${年份}是否为闰年
-- 根据闰年规则判断指定年份是否为闰年
function ____exports.DzIsLeapYear(year)
    return year % 4 == 0 and year % 100 ~= 0 or year % 400 == 0
end
--- 从时间戳获取时间日期字符串（内部实现）
-- 从时间戳${时间戳}获取时间日期字符串
-- 将UNIX时间戳转换为可读的日期时间字符串
function ____exports.DzGetTimeDateFromTimestamp(timestamp)
    local totalSeconds = timestamp + 28800
    local secondsInDay = 86400
    local remainingSeconds = totalSeconds % secondsInDay
    local year = 1970
    local totalDays = math.floor((totalSeconds + 86399) / secondsInDay)
    local num = 0
    local month = 0
    local days = 0
    while true do
        if ____exports.DzIsLeapYear(year) then
            num = num + 366
        else
            num = num + 365
        end
        if num > totalDays then
            break
        end
        days = num
        year = year + 1
    end
    month = 1
    num = 0
    days = totalDays - days
    local monthDays = ____exports.DzIsLeapYear(year) and ({
        31,
        29,
        31,
        30,
        31,
        30,
        31,
        31,
        30,
        31,
        30,
        31
    }) or ({
        31,
        28,
        31,
        30,
        31,
        30,
        31,
        31,
        30,
        31,
        30,
        31
    })
    do
        local i = 0
        while i < 12 do
            if num + monthDays[i + 1] >= days then
                break
            end
            num = num + monthDays[i + 1]
            month = month + 1
            i = i + 1
        end
    end
    local day = days - num or 1
    local hour = math.floor(remainingSeconds / 3600)
    local minute = math.floor(remainingSeconds % 3600 / 60)
    local second = remainingSeconds % 60
    return (((((((((tostring(year) .. "-") .. tostring(month)) .. "-") .. tostring(day)) .. " ") .. tostring(hour)) .. ":") .. tostring(minute)) .. ":") .. tostring(second)
end
local timestampCache = __TS__New(Map)
--- 从时间戳获取时间日期字符串（缓存版）
-- 从时间戳${时间戳}获取时间日期字符串
-- 带缓存的时间戳转换函数，提高性能
function ____exports.KKAPIGetTimeDateFromTimestamp(timestamp)
    timestamp = math.max(timestamp, 0)
    local cached = timestampCache:get(timestamp)
    if cached then
        return cached.str
    end
    local str = ____exports.DzGetTimeDateFromTimestamp(timestamp)
    local parts = __TS__StringSplit(
        __TS__StringSplit(str, " ")[1],
        "-"
    )
    timestampCache:set(
        timestamp,
        {
            year = __TS__ParseInt(parts[1], 10),
            month = __TS__ParseInt(parts[2], 10),
            day = __TS__ParseInt(parts[3], 10),
            str = str
        }
    )
    return str
end
--- 从时间戳获取年份
-- 从时间戳${时间戳}获取年份
-- 从UNIX时间戳中提取年份信息
function ____exports.KKAPIGetTimestampYear(timestamp)
    timestamp = math.max(timestamp, 0)
    local date = __TS__New(Date, timestamp * 1000)
    return date:getFullYear()
end
--- 从时间戳获取月份
-- 从时间戳${时间戳}获取月份
-- 从UNIX时间戳中提取月份信息
function ____exports.KKAPIGetTimestampMonth(timestamp)
    timestamp = math.max(timestamp, 0)
    local date = __TS__New(Date, timestamp * 1000)
    return date:getMonth() + 1
end
--- 从时间戳获取日期
-- 从时间戳${时间戳}获取日期
-- 从UNIX时间戳中提取日期信息
function ____exports.KKAPIGetTimestampDay(timestamp)
    timestamp = math.max(timestamp, 0)
    local date = __TS__New(Date, timestamp * 1000)
    return date:getDate()
end
--- 整数转技能ID
-- 将整数${整数}转换为技能ID
-- 简单的类型转换函数
function ____exports.KKConvertInt2AbilId(i)
    return i
end
--- 技能ID转整数
-- 将技能ID${技能ID}转换为整数
-- 简单的类型转换函数
function ____exports.KKConvertAbilId2Int(i)
    return i
end
--- 整数转颜色
-- 将整数${整数}转换为颜色
-- 简单的类型转换函数
function ____exports.KKConvertInt2Color(i)
    return i
end
--- 颜色转整数
-- 将颜色${颜色}转换为整数
-- 简单的类型转换函数
function ____exports.KKConvertColor2Int(i)
    return i
end
--- 防御类型：小型
____exports.DEFENSE_TYPE_SMALL = 0
--- 防御类型：中型
____exports.DEFENSE_TYPE_MEDIUM = 1
--- 防御类型：大型
____exports.DEFENSE_TYPE_LARGE = 2
--- 防御类型：要塞
____exports.DEFENSE_TYPE_FORT = 3
--- 防御类型：普通
____exports.DEFENSE_TYPE_NORMAL = 4
--- 防御类型：英雄
____exports.DEFENSE_TYPE_HERO = 5
--- 防御类型：神圣
____exports.DEFENSE_TYPE_DIVINE = 6
--- 防御类型：无
____exports.DEFENSE_TYPE_NONE = 7
--- 保存服务器数值
-- 保存${玩家}的服务器数值${键名}为${数值}
-- 本质调用 RequestExtraBooleanData(4, ...)
function ____exports.DzAPI_Map_SaveServerValue(whichPlayer, key, value)
    return RequestExtraBooleanData(
        4,
        whichPlayer,
        key,
        value,
        false,
        0,
        0,
        0
    )
end
--- 读取服务器数值
-- 读取${玩家}的服务器数值${键名}
function ____exports.DzAPI_Map_GetServerValue(whichPlayer, key)
    return RequestExtraStringData(
        5,
        whichPlayer,
        key,
        nil,
        false,
        0,
        0,
        0
    )
end
--- 获取游戏开始时间
-- 返回服务器记录的游戏开始时间戳
function ____exports.DzAPI_Map_GetGameStartTime()
    return RequestExtraIntegerData(
        11,
        nil,
        nil,
        nil,
        false,
        0,
        0,
        0
    )
end
--- 是否为RPG天梯
-- 判断当前是否为RPG天梯模式
function ____exports.DzAPI_Map_IsRPGLadder()
    return RequestExtraBooleanData(
        12,
        nil,
        nil,
        nil,
        false,
        0,
        0,
        0
    )
end
--- 获取匹配类型
-- 返回当前匹配模式类型
function ____exports.DzAPI_Map_GetMatchType()
    return RequestExtraIntegerData(
        13,
        nil,
        nil,
        nil,
        false,
        0,
        0,
        0
    )
end
--- 设置统计数据
-- 统计-提交地图数据
function ____exports.DzAPI_Map_Stat_SetStat(whichPlayer, key, value)
    RequestExtraIntegerData(
        7,
        whichPlayer,
        key,
        value,
        false,
        0,
        0,
        0
    )
end
--- 设置天梯统计
-- 天梯-统计数据
function ____exports.DzAPI_Map_Ladder_SetStat(whichPlayer, key, value)
    RequestExtraIntegerData(
        8,
        whichPlayer,
        key,
        value,
        false,
        0,
        0,
        0
    )
end
--- 设置玩家天梯统计
-- 天梯-统计玩家数据
function ____exports.DzAPI_Map_Ladder_SetPlayerStat(whichPlayer, key, value)
    RequestExtraIntegerData(
        9,
        whichPlayer,
        key,
        value,
        false,
        0,
        0,
        0
    )
end
--- 获取服务器数值错误码
-- 读取加载服务器存档时的错误码
function ____exports.DzAPI_Map_GetServerValueErrorCode(whichPlayer)
    return RequestExtraIntegerData(
        6,
        whichPlayer,
        nil,
        nil,
        false,
        0,
        0,
        0
    )
end
--- 获取天梯等级
-- 提供给地图的接口，用于取天梯等级
function ____exports.DzAPI_Map_GetLadderLevel(whichPlayer)
    return RequestExtraIntegerData(
        14,
        whichPlayer,
        nil,
        nil,
        false,
        0,
        0,
        0
    )
end
--- 玩家身份类型
-- dataType=92 的通用身份判断封装
function ____exports.KKApiPlayerIdentityType(whichPlayer, id)
    return RequestExtraBooleanData(
        92,
        whichPlayer,
        nil,
        nil,
        false,
        id,
        0,
        0
    )
end
--- 是否为红钻VIP
function ____exports.DzAPI_Map_IsRedVIP(whichPlayer)
    return ____exports.KKApiPlayerIdentityType(whichPlayer, 4)
end
--- 是否为蓝钻VIP
function ____exports.DzAPI_Map_IsBlueVIP(whichPlayer)
    return ____exports.KKApiPlayerIdentityType(whichPlayer, 3)
end
--- 获取天梯排名
function ____exports.DzAPI_Map_GetLadderRank(whichPlayer)
    return RequestExtraIntegerData(
        17,
        whichPlayer,
        nil,
        nil,
        false,
        0,
        0,
        0
    )
end
--- 获取地图等级排名
function ____exports.DzAPI_Map_GetMapLevelRank(whichPlayer)
    return RequestExtraIntegerData(
        18,
        whichPlayer,
        nil,
        nil,
        false,
        0,
        0,
        0
    )
end
--- 获取公会职责
-- Member=10 Admin=20 Leader=30
function ____exports.DzAPI_Map_GetGuildRole(whichPlayer)
    return RequestExtraIntegerData(
        20,
        whichPlayer,
        nil,
        nil,
        false,
        0,
        0,
        0
    )
end
--- 是否为RPG大厅
function ____exports.DzAPI_Map_IsRPGLobby()
    return RequestExtraBooleanData(
        10,
        nil,
        nil,
        nil,
        false,
        0,
        0,
        0
    )
end
--- 任务完成
-- 用作完成某个任务，发奖励
function ____exports.DzAPI_Map_MissionComplete(whichPlayer, key, value)
    RequestExtraIntegerData(
        1,
        whichPlayer,
        key,
        value,
        false,
        0,
        0,
        0
    )
end
--- 获取活动数据
-- 提供给地图的接口，用作取服务器上的活动数据
function ____exports.DzAPI_Map_GetActivityData()
    return RequestExtraStringData(
        2,
        nil,
        nil,
        nil,
        false,
        0,
        0,
        0
    )
end
--- 获取地图配置
-- 根据 key 读取地图配置
function ____exports.DzAPI_Map_GetMapConfig(key)
    return RequestExtraStringData(
        21,
        nil,
        key,
        nil,
        false,
        0,
        0,
        0
    )
end
--- 保存公共存档
function ____exports.DzAPI_Map_SavePublicArchive(whichPlayer, key, value)
    return RequestExtraBooleanData(
        31,
        whichPlayer,
        key,
        value,
        false,
        0,
        0,
        0
    )
end
--- 获取公共存档
function ____exports.DzAPI_Map_GetPublicArchive(whichPlayer, key)
    return RequestExtraStringData(
        32,
        whichPlayer,
        key,
        nil,
        false,
        0,
        0,
        0
    )
end
--- 使用消耗品
function ____exports.DzAPI_Map_UseConsumablesItem(whichPlayer, key)
    RequestExtraIntegerData(
        33,
        whichPlayer,
        key,
        nil,
        false,
        0,
        0,
        0
    )
end
--- ORPG触发器
-- 触发boss击杀等事件
function ____exports.DzAPI_Map_OrpgTrigger(whichPlayer, key)
    RequestExtraIntegerData(
        28,
        whichPlayer,
        key,
        nil,
        false,
        0,
        0,
        0
    )
end
--- 获取服务器掉落数据
function ____exports.DzAPI_Map_GetServerArchiveDrop(whichPlayer, key)
    return RequestExtraStringData(
        27,
        whichPlayer,
        key,
        nil,
        false,
        0,
        0,
        0
    )
end
--- 获取服务器装备数据
function ____exports.DzAPI_Map_GetServerArchiveEquip(whichPlayer, key)
    return RequestExtraIntegerData(
        26,
        whichPlayer,
        key,
        nil,
        false,
        0,
        0,
        0
    )
end
--- 获取平台VIP等级
function ____exports.DzAPI_Map_GetPlatformVIP(whichPlayer)
    return RequestExtraIntegerData(
        30,
        whichPlayer,
        nil,
        nil,
        false,
        0,
        0,
        0
    )
end
--- 是否为平台VIP
function ____exports.DzAPI_Map_IsPlatformVIP(whichPlayer)
    return ____exports.DzAPI_Map_GetPlatformVIP(whichPlayer) > 0
end
--- 读取本地全局字符串存档
function ____exports.DzAPI_Map_Global_GetStoreString(key)
    return RequestExtraStringData(
        36,
        GetLocalPlayer(),
        key,
        nil,
        false,
        0,
        0,
        0
    )
end
--- 保存本地全局字符串存档
function ____exports.DzAPI_Map_Global_StoreString(key, value)
    RequestExtraBooleanData(
        37,
        GetLocalPlayer(),
        key,
        value,
        false,
        0,
        0,
        0
    )
end
--- 地图全局消息同步注册
-- 等价于 DzAPI_Map_Global_ChangeMsg
function ____exports.DzAPI_Map_Global_ChangeMsg(trig)
    DzTriggerRegisterSyncData(trig, "DZGAU", true)
end
--- 获取服务器存档
function ____exports.DzAPI_Map_ServerArchive(whichPlayer, key)
    return RequestExtraStringData(
        38,
        whichPlayer,
        key,
        nil,
        false,
        0,
        0,
        0
    )
end
--- 保存服务器存档
function ____exports.DzAPI_Map_SaveServerArchive(whichPlayer, key, value)
    RequestExtraBooleanData(
        39,
        whichPlayer,
        key,
        value,
        false,
        0,
        0,
        0
    )
end
--- 是否为RPG快速匹配
function ____exports.DzAPI_Map_IsRPGQuickMatch()
    return RequestExtraBooleanData(
        40,
        nil,
        nil,
        nil,
        false,
        0,
        0,
        0
    )
end
--- 获取商城道具数量
function ____exports.DzAPI_Map_GetMallItemCount(whichPlayer, key)
    return RequestExtraIntegerData(
        41,
        whichPlayer,
        key,
        nil,
        false,
        0,
        0,
        0
    )
end
--- 消耗商城道具
function ____exports.DzAPI_Map_ConsumeMallItem(whichPlayer, key, count)
    return RequestExtraBooleanData(
        42,
        whichPlayer,
        key,
        nil,
        false,
        count,
        0,
        0
    )
end
--- 启用/禁用平台设置
function ____exports.DzAPI_Map_EnablePlatformSettings(whichPlayer, option, enable)
    return RequestExtraBooleanData(
        43,
        whichPlayer,
        nil,
        nil,
        enable,
        option,
        0,
        0
    )
end
--- 获取读取服务器存档是否成功
function ____exports.GetPlayerServerValueSuccess(whichPlayer)
    return ____exports.DzAPI_Map_GetServerValueErrorCode(whichPlayer) == 0
end
--- 判断单位能否在指定位置放置（基于 location）
function ____exports.KKUnitCanPlaceAroundLoc(obj, loc)
    return DzUnitCanPlaceAround(
        obj,
        GetLocationX(loc),
        GetLocationY(loc)
    )
end
--- 判断单位能否在指定坐标放置
function ____exports.kkUnitCanPlaceAroundItem(obj, x, y)
    return DzUnitCanPlaceAround(obj, x, y)
end
--- 判断单位能否在指定 location 放置（同 KKUnitCanPlaceAroundLoc）
function ____exports.KKUnitCanPlaceAroundLocItem(obj, loc)
    return DzUnitCanPlaceAround(
        obj,
        GetLocationX(loc),
        GetLocationY(loc)
    )
end
--- 判断指定位置是否可放置单位（带碰撞体积和类型）
function ____exports.KKPositionCanPlaceAroundLoc(loc, collision_size, collision_type)
    return DzPositionCanPlaceAround(
        GetLocationX(loc),
        GetLocationY(loc),
        collision_size,
        collision_type
    )
end
--- KKWE DzUnitSetMoveType 使用的移动类型字符串
____exports.KK_MOVE_TYPE_NONE = "none"
____exports.KK_MOVE_TYPE_FOOT = "foot"
____exports.KK_MOVE_TYPE_HORSE = "horse"
____exports.KK_MOVE_TYPE_FLY = "fly"
____exports.KK_MOVE_TYPE_HOVER = "hover"
____exports.KK_MOVE_TYPE_FLOAT = "float"
____exports.KK_MOVE_TYPE_AMPH = "amph"
____exports.KK_MOVE_TYPE_UNBUILD = "unbuild"
--- 转化 - 字符串转目标允许
-- 转换 ${字符串} 为目标允许
-- 例如“ground,friend,vuln,invu”
function ____exports.KKConvertStr2Targs(s)
    return DzConvertStr2Targs(s)
end
--- 特效组 - 创建空的特效组
-- 创建空的特效组
-- 会创建特效组,需要排泄,可以用最后创建的特效组
function ____exports.DzEffectGroupCreateBJ()
    ____exports.bj_lastCreatedDzEffectGroup = DzEffectGroupCreate()
    return ____exports.bj_lastCreatedDzEffectGroup
end
--- 特效组 - 选取范围内的特效
-- 选取 X:${x} Y:${y} 范围:${range} 内的特效
-- 会创建特效组,需要排泄,可以用最后创建的特效组
function ____exports.DzEffectGroupCreateEnumRangeBJ(x, y, range)
    ____exports.bj_lastCreatedDzEffectGroup = DzEffectGroupCreate()
    DzEffectGroupEnumRange(
        ____exports.bj_lastCreatedDzEffectGroup,
        x,
        y,
        range,
        false,
        false
    )
    return ____exports.bj_lastCreatedDzEffectGroup
end
--- 特效组 - 选取区域内的特效
-- 选取 ${rect} 内的特效到新建特效组
-- 会创建特效组,需要排泄,可以用最后创建的特效组
function ____exports.DzEffectGroupCreateEnumRectBJ(whichRect)
    ____exports.bj_lastCreatedDzEffectGroup = DzEffectGroupCreate()
    DzEffectGroupEnumRect(____exports.bj_lastCreatedDzEffectGroup, whichRect, false, false)
    return ____exports.bj_lastCreatedDzEffectGroup
end
--- 特效组 - 添加
-- 添加 ${特效} 到 ${特效组} 允许重复 ${flag}
function ____exports.DzEffectGroupAddBJ(whichEffect, whichEffectGroup, allowDuplicate)
    return DzEffectGroupAdd(whichEffectGroup, whichEffect, allowDuplicate)
end
--- 特效组 - 添加范围内的特效
-- 选取 X:${x} Y:${y} 范围:${range} 内的特效添加到 ${特效组} (清空${clear} 允许重复${duplicate})
function ____exports.DzEffectGroupEnumRangeBJ(x, y, range, whichEffectGroup, clear, allowDuplicate)
    return DzEffectGroupEnumRange(
        whichEffectGroup,
        x,
        y,
        range,
        clear,
        allowDuplicate
    )
end
--- 特效组 - 添加区域内的特效
-- 选取 ${rect} 内的特效添加到 ${特效组} (清空${clear} 允许重复${duplicate})
function ____exports.DzEffectGroupEnumRectBJ(whichRect, whichEffectGroup, clear, allowDuplicate)
    return DzEffectGroupEnumRect(whichEffectGroup, whichRect, clear, allowDuplicate)
end
--- 特效 - 延迟立即删除(不播放死亡动画)
-- 在 ${duration} 秒延迟后, 立即删除 ${特效}
-- 不会播放死亡动画且时间到会立即删除特效
function ____exports.DzRemoveEffectTimedBJ(time, whichEffect)
    return DzRemoveEffectTimed(whichEffect, time)
end
--- 特效 - 延迟删除
-- 在 ${duration} 秒延迟后, 删除 ${特效}
-- 时间到后会播放死亡动画并在平衡性常数时间后删除特效
function ____exports.DzDieEffectTimedBJ(time, whichEffect)
    return DzDieEffectTimed(whichEffect, time)
end
--- 特效组 - 获取 特效组 的整数地址
-- 获取 ${特效组} 的整数地址
-- 可以把一个特效组转成整数，方便存入缓存或Hash表。
function ____exports.DzGetEffectGroupIdBJ(g)
    return GetHandleId(g)
end
--- 服务器存储整数（区分大小写）
-- 服务器存储整数（区分大小写） 玩家 ${player} 名称 ${key} 值 ${value}
-- 这是经过封装的接口，实际Key会在原Key前面加”I”，与普通存档共用KEY
function ____exports.DzAPI_Map_StoreIntegerEX(whichPlayer, key, value)
    key = "I" .. key
    RequestExtraBooleanData(
        39,
        whichPlayer,
        key,
        I2S(value),
        false,
        0,
        0,
        0
    )
end
--- 获取服务器存储的整数（区分大小写）
-- 获取服务器存储的整数（区分大小写） 玩家 ${player} 名称 ${key}
-- 这是经过封装的接口，实际Key会在原Key前面加”I”，用于开发者平台设置的防刷分存档，与普通存档共用KEY
function ____exports.DzAPI_Map_GetStoredIntegerEX(whichPlayer, key)
    local value
    key = "I" .. key
    value = S2I(RequestExtraStringData(
        38,
        whichPlayer,
        key,
        nil,
        false,
        0,
        0,
        0
    ))
    return value
end
--- 保存整数变量至服务器
-- 服务器存档:存储 ${whichPlayer} 数据,名称： ${key} ,值: ${value} 最大长度63位
-- 这是经过封装的接口，实际Key会在原Key前面加”I,（如您的key是AA，实际key为IAA。【IAA用于开发者平台填写，在编辑器上获取和读都填写AA就可以了】）”
function ____exports.DzAPI_Map_StoreInteger(whichPlayer, key, value)
    key = "I" .. key
    ____exports.DzAPI_Map_SaveServerValue(
        whichPlayer,
        key,
        I2S(value)
    )
end
--- 读取服务器上的整数变量
-- 获取 ${whichPlayer} 数据名称: ${key} 里存储的整数.
-- 这是经过封装的接口，实际Key会在原Key前面加”I”
function ____exports.DzAPI_Map_GetStoredInteger(whichPlayer, key)
    local value
    key = "I" .. key
    value = S2I(____exports.DzAPI_Map_GetServerValue(whichPlayer, key))
    return value
end
--- 玩家在地图自定义排行榜上的排名
-- 获取玩家 ${whichPlayer} 自定义排行榜KEY(开发者平台填写)： ${key} 的排名，【请注意100名以外的玩家获取的值为0！】
-- 【100名以外的玩家排名为0】该功能适用于开发者平台-服务器存档-自定义排行榜
function ____exports.DzAPI_Map_CommentTotalCount1(whichPlayer, id)
    return RequestExtraIntegerData(
        52,
        whichPlayer,
        nil,
        nil,
        false,
        id,
        0,
        0
    )
end
--- 保存实数变量至服务器
-- 服务器存档:存储 ${whichPlayer} 数据,名称： ${key} ,值: ${value} 最大长度63位
-- 这是经过封装的接口，实际Key会在原Key前面加”R,（如您的key是AA，实际key为RAA。【RAA用于开发者平台填写，在编辑器上获取和读都填写AA就可以了】”
function ____exports.DzAPI_Map_StoreReal(whichPlayer, key, value)
    key = "R" .. key
    ____exports.DzAPI_Map_SaveServerValue(
        whichPlayer,
        key,
        R2S(value)
    )
end
--- 读取服务器上的实数变量
-- 获取 ${whichPlayer} 数据名称: ${key} 里存储的实数
-- 这是经过封装的接口，实际Key会在原Key前面加”R”
function ____exports.DzAPI_Map_GetStoredReal(whichPlayer, key)
    local value
    key = "R" .. key
    value = S2R(____exports.DzAPI_Map_GetServerValue(whichPlayer, key))
    return value
end
--- 保存布尔值变量至服务器
-- 服务器存档:存储 ${whichPlayer} 数据,名称: ${key} ,值: ${value} 最大长度63位
-- 这是经过封装的接口，实际Key会在原Key前面加”B，（如您的key是AA，实际key为BAA。【BAA用于开发者平台填写，在编辑器上获取和读都填写AA就可以了】）”
function ____exports.DzAPI_Map_StoreBoolean(whichPlayer, key, value)
    key = "B" .. key
    if value then
        ____exports.DzAPI_Map_SaveServerValue(whichPlayer, key, "1")
    else
        ____exports.DzAPI_Map_SaveServerValue(whichPlayer, key, "0")
    end
end
--- 读取服务器上的布尔变量
-- 获取 ${whichPlayer} 数据名称: ${key} 里存储的布尔值
-- 这是经过封装的接口，实际Key会在原Key前面加”B”
function ____exports.DzAPI_Map_GetStoredBoolean(whichPlayer, key)
    local value
    key = "B" .. key
    key = ____exports.DzAPI_Map_GetServerValue(whichPlayer, key)
    if key == "1" then
        value = true
    else
        value = false
    end
    return value
end
--- 保存字符串变量至服务器
-- 服务器存档:存储 ${whichPlayer} 数据,名称: ${key} ,值: ${value} 最大长度63位
-- 这是经过封装的接口，实际Key会在原Key前面加”S,（如您的key是AA，实际key为SAA。【SAA用于开发者平台填写，在编辑器上获取和读都填写AA就可以了】”
function ____exports.DzAPI_Map_StoreString(whichPlayer, key, value)
    key = "S" .. key
    ____exports.DzAPI_Map_SaveServerValue(whichPlayer, key, value)
end
--- 读取服务器上的字符串变量
-- 获取 ${whichPlayer} 数据名称: ${key} 里存储的字符串
-- 这是经过封装的接口，实际Key会在原Key前面加”S”
function ____exports.DzAPI_Map_GetStoredString(whichPlayer, key)
    return ____exports.DzAPI_Map_GetServerValue(whichPlayer, "S" .. key)
end
--- 服务器存储字符串（区分大小写）
-- 服务器存储字符串（区分大小写） 玩家 ${player} 名称 ${key} 值 ${value}
-- 这是经过封装的接口，实际Key会在原Key前面加”S”，与普通存档共用KEY
function ____exports.DzAPI_Map_StoreStringEX(whichPlayer, key, value)
    key = "S" .. key
    RequestExtraBooleanData(
        39,
        whichPlayer,
        key,
        value,
        false,
        0,
        0,
        0
    )
end
--- 获取服务器存储的字符串（区分大小写）
-- 获取服务器存储的字符串（区分大小写） 玩家 ${player} 名称 ${key}
-- 这是经过封装的接口，实际Key会在原Key前面加”S”，用于开发者平台设置的防刷分存档，与普通存档共用KEY
function ____exports.DzAPI_Map_GetStoredStringEX(whichPlayer, key)
    return RequestExtraStringData(
        38,
        whichPlayer,
        "S" .. key,
        nil,
        false,
        0,
        0,
        0
    )
end
--- 读取服务器存储的单位类型
-- 获取 ${whichPlayer} 数据名称: ${key} 里存储的单位类型
-- 这是经过封装的接口，实际Key会在原Key前面加”I”
function ____exports.DzAPI_Map_GetStoredUnitType(whichPlayer, key)
    local value
    key = "I" .. key
    value = S2I(____exports.DzAPI_Map_GetServerValue(whichPlayer, key))
    return value
end
--- 读取服务器存储的技能类型
-- 获取 ${whichPlayer} 数据名称: ${key} 里存储的技能类型
-- 这是经过封装的接口，实际Key会在原Key前面加”I”
function ____exports.DzAPI_Map_GetStoredAbilityId(whichPlayer, key)
    local value
    key = "I" .. key
    value = S2I(____exports.DzAPI_Map_GetServerValue(whichPlayer, key))
    return value
end
--- 清理服务器数据
-- 服务器数据：清理 ${whichPlayer} 数据,名称： ${key}
-- 清理封装的接口记得在前面加对应的B、I、R、S
function ____exports.DzAPI_Map_FlushStoredMission(whichPlayer, key)
    ____exports.DzAPI_Map_SaveServerValue(whichPlayer, key, nil)
end
--- 天梯提交整数数据
-- 提交 ${whichPlayer} 天梯项目: ${key} 的值为: ${value}
function ____exports.DzAPI_Map_Ladder_SubmitIntegerData(whichPlayer, key, value)
    ____exports.DzAPI_Map_Ladder_SetStat(
        whichPlayer,
        key,
        I2S(value)
    )
end
--- 天梯提交单位类型数据
-- 提高 ${whichPlayer} 天梯项目: ${key} 的值为: ${value}
function ____exports.DzAPI_Map_Stat_SubmitUnitIdData(whichPlayer, key, value)
    if value == 0 then
    else
        ____exports.DzAPI_Map_Ladder_SetStat(
            whichPlayer,
            key,
            I2S(value)
        )
    end
end
--- DzAPI_Map_Stat_SubmitUnitData
function ____exports.DzAPI_Map_Stat_SubmitUnitData(whichPlayer, key, value)
    ____exports.DzAPI_Map_Stat_SubmitUnitIdData(
        whichPlayer,
        key,
        GetUnitTypeId(value)
    )
end
--- 天梯提交技能数据
-- 提交 ${whichPlayer} 天梯项目: ${key} 的值为: ${value}
function ____exports.DzAPI_Map_Ladder_SubmitAblityIdData(whichPlayer, key, value)
    if value == 0 then
    else
        ____exports.DzAPI_Map_Ladder_SetStat(
            whichPlayer,
            key,
            I2S(value)
        )
    end
end
--- 天梯提交物品数据
-- 提交 ${whichPlayer} 天梯项目: ${key} 的值为: ${value}
function ____exports.DzAPI_Map_Ladder_SubmitItemIdData(whichPlayer, key, value)
    local S
    if value == 0 then
        S = "0"
    else
        S = I2S(value)
        ____exports.DzAPI_Map_Ladder_SetStat(whichPlayer, key, S)
    end
end
--- DzAPI_Map_Ladder_SubmitItemData
function ____exports.DzAPI_Map_Ladder_SubmitItemData(whichPlayer, key, value)
    ____exports.DzAPI_Map_Ladder_SubmitItemIdData(
        whichPlayer,
        key,
        GetItemTypeId(value)
    )
end
--- 天梯提交布尔值数据
-- 提交 ${whichPlayer} 天梯项目: ${key} 的目的 ${value}
function ____exports.DzAPI_Map_Ladder_SubmitBooleanData(whichPlayer, key, value)
    if value then
        ____exports.DzAPI_Map_Ladder_SetStat(whichPlayer, key, "1")
    else
        ____exports.DzAPI_Map_Ladder_SetStat(whichPlayer, key, "0")
    end
end
--- 天梯提交获得称号
-- 提交 ${whichPlayer} 获得称号: ${key}
function ____exports.DzAPI_Map_Ladder_SubmitTitle(whichPlayer, value)
    ____exports.DzAPI_Map_Ladder_SetStat(whichPlayer, value, "1")
end
--- 天梯提交玩家排名
-- 设置 ${whichPlayer} 的游戏排名为: ${value}
function ____exports.DzAPI_Map_Ladder_SubmitPlayerRank(whichPlayer, value)
    ____exports.DzAPI_Map_Ladder_SetPlayerStat(
        whichPlayer,
        "RankIndex",
        I2S(value)
    )
end
--- 天梯设置玩家额外分
-- 设置 ${whichPlayer} 的额外分为 ${value}
-- 最多30分
function ____exports.DzAPI_Map_Ladder_SubmitPlayerExtraExp(whichPlayer, value)
    ____exports.DzAPI_Map_Ladder_SetStat(
        whichPlayer,
        "ExtraExp",
        I2S(value)
    )
end
--- 玩家累计游戏局数
-- 获取 ${whichPlayer} 游戏局数
-- 获取玩家中游戏局数
function ____exports.DzAPI_Map_PlayedGames(whichPlayer)
    return RequestExtraIntegerData(
        45,
        whichPlayer,
        nil,
        nil,
        false,
        0,
        0,
        0
    )
end
--- 评论次数【废弃】
-- 获取 ${whichPlayer} 评论次数
-- 获取玩家的评论次数，该功能已失效，始终返回1
function ____exports.DzAPI_Map_CommentCount(whichPlayer)
    return RequestExtraIntegerData(
        46,
        whichPlayer,
        nil,
        nil,
        false,
        0,
        0,
        0
    )
end
--- 玩家好友数量【废弃】
-- 获取 ${whichPlayer} 好友数量
-- 该功能废弃
function ____exports.DzAPI_Map_FriendCount(whichPlayer)
    return RequestExtraIntegerData(
        47,
        whichPlayer,
        nil,
        nil,
        false,
        0,
        0,
        0
    )
end
--- 玩家是否平台认证的鉴赏家[废弃]
--  ${whichPlayer} 是鉴赏家
-- 评论里的鉴赏家
function ____exports.DzAPI_Map_IsConnoisseur(whichPlayer)
    return RequestExtraBooleanData(
        48,
        whichPlayer,
        nil,
        nil,
        false,
        0,
        0,
        0
    )
end
--- 玩家是否当前地图作者
--  ${whichPlayer} 是本图作者
-- 判断指定玩家是否为本地图的作者。
function ____exports.DzAPI_Map_IsAuthor(whichPlayer)
    return RequestExtraBooleanData(
        50,
        whichPlayer,
        nil,
        nil,
        false,
        0,
        0,
        0
    )
end
--- 地图评论次数
-- 该图总评论次数
-- 获取该图总评论次数
function ____exports.DzAPI_Map_CommentTotalCount()
    return RequestExtraIntegerData(
        51,
        nil,
        nil,
        nil,
        false,
        0,
        0,
        0
    )
end
--- 是否回流/收藏过地图的用户
--  ${whichPlayer}  ${label}
-- 超过7天未玩地图的用户再次登录被称为地图回流用户，地图回流BUFF会存在7天，7天后消失。平台回流用户的BUFF存在15天，15天后消失。建议设置奖励，鼓励玩家回来玩地图！
function ____exports.DzAPI_Map_Returns(whichPlayer, label)
    return RequestExtraBooleanData(
        53,
        whichPlayer,
        nil,
        nil,
        false,
        label,
        0,
        0
    )
end
--- 玩家签到天数
--  ${whichPlayer}  ${label}
-- 获取玩家在指定地图的地图签到数据。
function ____exports.DzAPI_Map_ContinuousCount(whichPlayer, id)
    return RequestExtraIntegerData(
        54,
        whichPlayer,
        nil,
        nil,
        false,
        id,
        0,
        0
    )
end
--- 玩家是否为真实玩家
--  ${whichPlayer} 是否为真实玩家
-- 当作者开启匹配模式的虚拟电脑玩家(AI)补位功能后，可通过此接口判定是否真实玩家。
function ____exports.DzAPI_Map_IsPlayer(whichPlayer)
    return RequestExtraBooleanData(
        55,
        whichPlayer,
        nil,
        nil,
        false,
        0,
        0,
        0
    )
end
--- 玩家累计游戏时长
--  ${whichPlayer} 累计游戏时长
-- 获取玩家在当前地图的累计游戏时长
function ____exports.DzAPI_Map_MapsTotalPlayed(whichPlayer)
    return RequestExtraIntegerData(
        56,
        whichPlayer,
        nil,
        nil,
        false,
        0,
        0,
        0
    )
end
--- 玩家在指定地图的地图等级
--  ${whichPlayer} 在地图: ${mapId} 的地图等级
-- 获取玩家在指定地图的地图等级。
function ____exports.DzAPI_Map_MapsLevel(whichPlayer, mapId)
    return RequestExtraIntegerData(
        57,
        whichPlayer,
        nil,
        nil,
        false,
        mapId,
        0,
        0
    )
end
--- 玩家在指定地图累计消耗平台金币【已废弃】
--  ${whichPlayer} 在地图： ${mapId} 的平台金币消耗
-- 获取玩家在指定地图的累计消耗平台金币数量。
function ____exports.DzAPI_Map_MapsConsumeGold(whichPlayer, mapId)
    return RequestExtraIntegerData(
        58,
        whichPlayer,
        nil,
        nil,
        false,
        mapId,
        0,
        0
    )
end
--- 玩家在指定地图的平台木材消耗【已废弃】
--  ${whichPlayer} 地图： ${mapId} 的平台木材消耗
function ____exports.DzAPI_Map_MapsConsumeLumber(whichPlayer, mapId)
    return RequestExtraIntegerData(
        59,
        whichPlayer,
        nil,
        nil,
        false,
        mapId,
        0,
        0
    )
end
--- 玩家在指定地图累计消费金额区间（1~199）
--  ${whichPlayer} 在地图 ${地图id} 消费在（1~199）区间
-- 检测消费是否在（1~199）区间
function ____exports.DzAPI_Map_MapsConsumeLv1(whichPlayer, mapId)
    return RequestExtraBooleanData(
        60,
        whichPlayer,
        nil,
        nil,
        false,
        mapId,
        0,
        0
    )
end
--- 玩家在指定地图累计消费金额区间（200~499）
--  ${whichPlayer} 在地图 ${地图id} 消费在（200~499）区间
-- 检测消费是否在（200~499）区间
function ____exports.DzAPI_Map_MapsConsumeLv2(whichPlayer, mapId)
    return RequestExtraBooleanData(
        61,
        whichPlayer,
        nil,
        nil,
        false,
        mapId,
        0,
        0
    )
end
--- 玩家在指定地图累计消费金额区间（500~999）
--  ${whichPlayer} 在地图 ${地图id} 消费在（500~999）区间
-- 检测消费是否在（500~999）区间
function ____exports.DzAPI_Map_MapsConsumeLv3(whichPlayer, mapId)
    return RequestExtraBooleanData(
        62,
        whichPlayer,
        nil,
        nil,
        false,
        mapId,
        0,
        0
    )
end
--- 玩家在指定地图累计消费金额区间（1000+）
--  ${whichPlayer} 在地图 ${地图id} 消费在（1000+）区间
-- 检测消费是否在（1000+）区间
function ____exports.DzAPI_Map_MapsConsumeLv4(whichPlayer, mapId)
    return RequestExtraBooleanData(
        63,
        whichPlayer,
        nil,
        nil,
        false,
        mapId,
        0,
        0
    )
end
--- 玩家是否装备指定平台装饰
--  ${whichPlayer} 装备了 ${skinType} 的 ${id} 道具
-- 检查玩家是否装备着指定平台装饰（仅限平台和地图的合作装饰）。
function ____exports.DzAPI_Map_IsPlayerUsingSkin(whichPlayer, skinType, id)
    return RequestExtraBooleanData(
        64,
        whichPlayer,
        nil,
        nil,
        false,
        skinType,
        id,
        0
    )
end
--- 玩家在地图社区上的互动数据
--  ${whichPlayer}  ${whichData}
-- “获取玩家在当前地图的社区内的行为统计数据及身份数据。
function ____exports.DzAPI_Map_GetForumData(whichPlayer, whichData)
    return RequestExtraIntegerData(
        65,
        whichPlayer,
        nil,
        nil,
        false,
        whichData,
        0,
        0
    )
end
--- 玩家标记
--  ${whichPlayer} 是 ${label}
-- 获取玩家在当前地图上的身份标记（当前是否回流用户、是否收藏地图）。
function ____exports.DzAPI_Map_PlayerFlags(whichPlayer, label)
    return RequestExtraBooleanData(
        53,
        whichPlayer,
        nil,
        nil,
        false,
        label,
        0,
        0
    )
end
--- 玩家抽取指定地图宝箱次数
-- 获取 ${whichPlayer} 第 ${n} 个地图宝箱的累计抽取次数
-- 第二个参数为0代表第一个宝箱也为默认宝箱，为1代表第二个宝箱
function ____exports.DzAPI_Map_GetLotteryUsedCountEx(whichPlayer, index)
    return RequestExtraIntegerData(
        68,
        whichPlayer,
        nil,
        nil,
        false,
        index,
        0,
        0
    )
end
--- 玩家抽取地图宝箱总次数
--  ${whichPlayer} 玩家抽取地图宝箱总次数
function ____exports.DzAPI_Map_GetLotteryUsedCount(whichPlayer)
    return ____exports.DzAPI_Map_GetLotteryUsedCountEx(whichPlayer, 0) + ____exports.DzAPI_Map_GetLotteryUsedCountEx(whichPlayer, 1) + ____exports.DzAPI_Map_GetLotteryUsedCountEx(whichPlayer, 2)
end
--- 打开地图商城道具购买界面
--  ${whichPlayer} 打开地图商城道具 ${道具key} 购买界面
-- 打开游戏内置商城的道具购买页面，用于作者在地图内开发引导消费场景。购买成功后可通过玩家获得平台道具事件实现在游戏内立即生效。
function ____exports.DzAPI_Map_OpenMall(whichPlayer, whichkey)
    return RequestExtraBooleanData(
        66,
        whichPlayer,
        whichkey,
        nil,
        false,
        0,
        0,
        0
    )
end
--- 上报本局游戏玩家数据
-- 上报本局游戏： ${whichPlayer} 项目： ${key} 数据： ${value}
-- 上报本局游戏的玩家数据，比如战斗力、杀敌数等。
function ____exports.DzAPI_Map_GameResult_CommitData(whichPlayer, key, value)
    RequestExtraIntegerData(
        69,
        whichPlayer,
        key,
        value,
        false,
        0,
        0,
        0
    )
end
--- 上报本局游戏玩家称号
-- 上报本局游戏： ${whichPlayer} 称号： ${key}
-- 上报本局游戏玩家所获得的称号，请注意**称号Key**不能和[上报本局游戏玩家数据]的**数据项Key**重复。
function ____exports.DzAPI_Map_GameResult_CommitTitle(whichPlayer, value)
    ____exports.DzAPI_Map_GameResult_CommitData(whichPlayer, value, "1")
end
--- 上报本局游戏玩家排名
-- 上报本局游戏 ${whichPlayer} 的排名为： ${value}
-- 对于乱斗模式的地图，上报每一名玩家的名次。
function ____exports.DzAPI_Map_GameResult_CommitPlayerRank(whichPlayer, value)
    ____exports.DzAPI_Map_GameResult_CommitData(
        whichPlayer,
        "RankIndex",
        I2S(value)
    )
end
--- 上报本局游戏模式
-- 上报本局游戏模式： ${模式名}
-- 上报本局游戏所选择的地图模式名称。
function ____exports.DzAPI_Map_GameResult_CommitGameMode(value)
    ____exports.DzAPI_Map_GameResult_CommitData(
        GetLocalPlayer(),
        "InnerGameMode",
        value
    )
end
--- 上报本局游戏结果
-- 上报本局游戏结果： ${whichPlayer}  ${value}
-- 上报本局游戏玩家游戏结果（胜负），提交后会立即结束游戏。
function ____exports.DzAPI_Map_GameResult_CommitGameResult(whichPlayer, value)
    ____exports.DzAPI_Map_GameResult_CommitData(
        whichPlayer,
        "GameResult",
        I2S(value)
    )
end
--- 上报本局游戏结果（不结束游戏）
-- 上报本局游戏结果： ${whichPlayer}  ${value} [不结束游戏]
-- 上报本局游戏玩家游戏结果（胜负），提交后不会立即结束游戏，适用于游戏正常结束后还有奖励关的地图。
function ____exports.DzAPI_Map_GameResult_CommitGameResultNoEnd(whichPlayer, value)
    ____exports.DzAPI_Map_GameResult_CommitData(
        whichPlayer,
        "GameResultNoEnd",
        I2S(value)
    )
end
--- 玩家本局游戏距上一局游戏的时间差
--  ${whichPlayer} 本局游戏距上一局游戏的时间差
-- 返查询该玩家上次玩游戏时间至本次玩游戏时间的差值，可以利用此接口实现离线收益之类的功能。
function ____exports.DzAPI_Map_GetSinceLastPlayedSeconds(whichPlayer)
    return RequestExtraIntegerData(
        70,
        whichPlayer,
        nil,
        nil,
        false,
        0,
        0,
        0
    )
end
--- 使用U币快速购买地图商城道具
-- 向 ${whichPlayer} 弹出商品 ${key} 的购买窗口，购买数量 ${数量} 窗口持续时间 ${时间} 秒
-- 弹出提示框询问玩家是否使用U币直接购买指定道具，作者需已在商城上架对应商品（商品信息中的**道具和数量**与接口所请求的参数一致）。如果前一次购买的提示框未关闭的情况下再次调用此接口，后续请求无效。购买成功后可通过[玩家获得平台道具事件]实现在游戏内立即生效。
function ____exports.DzAPI_Map_QuickBuy(whichPlayer, key, count, seconds)
    return RequestExtraBooleanData(
        72,
        whichPlayer,
        key,
        nil,
        false,
        count,
        seconds,
        0
    )
end
--- 关闭U币快速购买界面
-- 关闭 ${whichPlayer} U币快速购买窗口
-- 关闭最后一次打开的U币快速购买窗口，结合打开U币快速购买窗口使用。
function ____exports.DzAPI_Map_CancelQuickBuy(whichPlayer)
    return RequestExtraBooleanData(
        73,
        whichPlayer,
        nil,
        nil,
        false,
        0,
        0,
        0
    )
end
--- 本局游戏是否处于平台自测服
-- 本局游戏是否处于平台自测服
-- 获取当前游戏局所处的平台环境。
function ____exports.DzAPI_Map_IsMapTest()
    return RequestExtraBooleanData(
        74,
        nil,
        nil,
        nil,
        false,
        0,
        0,
        0
    )
end
--- 玩家地图商城道具是否读取成功
--  ${whichPlayer} 地图商城道具是否读取成功
-- 判断本局游戏中玩家的商城道具是否正确加载。
function ____exports.DzAPI_Map_PlayerLoadedItems(whichPlayer)
    return RequestExtraBooleanData(
        77,
        whichPlayer,
        nil,
        nil,
        false,
        0,
        0,
        0
    )
end
--- 自定义排行榜上榜人数
-- 获取自定义排行榜 ${key} 的上榜人数
-- key为开发者平台所配置的自定义排行榜key值,值为1~9
function ____exports.DzAPI_Map_CustomRankCount(id)
    return RequestExtraIntegerData(
        78,
        nil,
        nil,
        nil,
        false,
        id,
        0,
        0
    )
end
--- 自定义排行榜上的玩家昵称
-- 获取自定义排行榜 ${key} 的排名第 ${ranking} 的玩家昵称
-- key为开发者平台所配置的自定义排行榜key值,值为1~9
function ____exports.DzAPI_Map_CustomRankPlayerName(id, ranking)
    return RequestExtraStringData(
        79,
        nil,
        nil,
        nil,
        false,
        id,
        ranking,
        0
    )
end
--- 自定义排行榜上的玩家数值
-- 获取自定义排行榜 ${key} 排名第 ${ranking} 的数值
-- key为开发者平台所配置的自定义排行榜key值,值为1~9
function ____exports.DzAPI_Map_CustomRankValue(id, ranking)
    return RequestExtraIntegerData(
        80,
        nil,
        nil,
        nil,
        false,
        id,
        ranking,
        0
    )
end
--- 玩家在KK对战平台的完整昵称
--  ${whichPlayer} 在KK对战平台的完整昵称
-- 获取玩家的KK平台完整昵称“基础昵称#编号”
function ____exports.DzAPI_Map_GetPlayerUserName(whichPlayer)
    return RequestExtraStringData(
        81,
        whichPlayer,
        nil,
        nil,
        false,
        0,
        0,
        0
    )
end
--- 获取服务器存档限制余额
-- 获取 ${whichPlayer} 存档 ${key} 上限余额
-- 获取服务器存档当天上限余额，需要在开发者平台对指定KEY设置每天上限，获取的值为余额。如存档A上限为100，当天使用了80，返回20
function ____exports.KKApiGetServerValueLimitLeft(whichPlayer, key)
    return RequestExtraIntegerData(
        82,
        whichPlayer,
        key,
        nil,
        false,
        0,
        0,
        0
    )
end
--- 【随机只读存档】生成随机数
-- 设置 ${whichPlayer} 对随机只读存档 ${key} 的组 ${groupkey} 生成随机数
-- 生成一个服务器随机数并关联组ID，可以在开发者平台对组ID进行防刷分管理，同组ID下各个Key共享CD和次数。
function ____exports.KKApiRequestBackendLogic(whichPlayer, key, groupkey)
    return RequestExtraBooleanData(
        83,
        whichPlayer,
        key,
        groupkey,
        false,
        0,
        0,
        0
    )
end
--- 【随机只读存档】判断随机数是否存在
--  ${whichPlayer} 随机只读存档 ${key} 是否存在
-- 判断指定KEY生成的随机数是否存在，存在返回true
function ____exports.KKApiCheckBackendLogicExists(whichPlayer, key)
    return RequestExtraBooleanData(
        84,
        whichPlayer,
        key,
        nil,
        false,
        0,
        0,
        0
    )
end
--- 【随机只读存档】读取随机数的值
-- 获取 ${whichPlayer} 随机只读存档 ${key} 的值
-- 读取指定KEY生成的服务器随机数的值，返回整数。
function ____exports.KKApiGetBackendLogicIntResult(whichPlayer, key)
    return RequestExtraIntegerData(
        85,
        whichPlayer,
        key,
        nil,
        false,
        0,
        0,
        0
    )
end
--- 【随机只读存档】读取随机数的值
-- 获取 ${whichPlayer} 随机只读存档 ${key} 的值
-- 读取指定KEY生成的服务器随机数的值
function ____exports.KKApiGetBackendLogicStrResult(whichPlayer, key)
    return RequestExtraStringData(
        86,
        whichPlayer,
        key,
        nil,
        false,
        0,
        0,
        0
    )
end
--- 【随机只读存档】读取随机数的生成时间
-- 获取 ${whichPlayer} 随机只读存档 ${key} 的生成时间
-- 读取指定KEY生成的服务器随机数生成的时间戳，返回整数。
function ____exports.KKApiGetBackendLogicUpdateTime(whichPlayer, key)
    return RequestExtraIntegerData(
        87,
        whichPlayer,
        key,
        nil,
        false,
        0,
        0,
        0
    )
end
--- 【随机只读存档】读取随机数的组ID
-- 获取 ${whichPlayer} 随机只读存档 ${key} 的组ID
-- 读取指定KEY生成的服务器随机数生成的组ID，返回整数
function ____exports.KKApiGetBackendLogicGroup(whichPlayer, key)
    return RequestExtraStringData(
        88,
        whichPlayer,
        key,
        nil,
        false,
        0,
        0,
        0
    )
end
--- 【随机只读存档】删除随机数
-- 删除 ${whichPlayer} 随机只读存档 ${key} 的随机数
-- 删除指定KEY生成的服务器生成的随机数
function ____exports.KKApiRemoveBackendLogicResult(whichPlayer, key)
    return RequestExtraBooleanData(
        89,
        whichPlayer,
        key,
        nil,
        false,
        0,
        0,
        0
    )
end
--- 【随机只读存档】剩余次数
--  ${whichPlayer} 随机只读存档的组 ${groupkey} 今日的剩余次数
function ____exports.KKApiRandomSaveGameCount(whichPlayer, groupkey)
    return RequestExtraIntegerData(
        101,
        whichPlayer,
        groupkey,
        nil,
        false,
        0,
        0,
        0
    )
end
--- KKApiTriggerRegisterBackendLogicUpdata
function ____exports.KKApiTriggerRegisterBackendLogicUpdata(trig)
    DzTriggerRegisterSyncData(trig, "DZBLU", true)
end
--- KKApiTriggerRegisterBackendLogicDelete
function ____exports.KKApiTriggerRegisterBackendLogicDelete(trig)
    DzTriggerRegisterSyncData(trig, "DZBLD", true)
end
--- 获取变动的随机存档
-- 获取变动的随机存档
-- 用在注册随机存档更新和删除事件之后
function ____exports.KKApiGetSyncBackendLogic()
    return DzGetTriggerSyncData()
end
--- 是否在平台正常游戏中
-- 是否在平台正常游戏中
-- 主要试用于平台运行中区分正常游戏和观战模式，返回true代表是正常游戏模式，反之为观战模式
function ____exports.KKApiIsGameMode()
    return RequestExtraBooleanData(
        90,
        nil,
        nil,
        nil,
        false,
        0,
        0,
        0
    )
end
--- 初始化平台键位显示设置
-- 设置 ${whichPlayer} 的第 ${n} 套方案的键位： ${key} 设置描述： ${描述}
-- 初始化键位设置会显示在平台改键界面上，最多2套方案。
function ____exports.KKApiInitializeGameKey(whichPlayer, setIndex, k, data)
    return RequestExtraBooleanData(
        91,
        whichPlayer,
        ((("[{\"name\":\"" .. data) .. "\",\"key\":\"") .. k) .. "\"}]",
        nil,
        false,
        setIndex,
        0,
        0
    )
end
--- 获取玩家的平台ID
--  ${whichPlayer} 平台ID
-- 返回的是一个32位的字符串
function ____exports.KKApiPlayerGUID(whichPlayer)
    return RequestExtraStringData(
        93,
        whichPlayer,
        nil,
        nil,
        false,
        0,
        0,
        0
    )
end
--- 玩家地图任务状态
--  ${whichPlayer} 地图任务： ${setIndex} 在 ${taskstat} 状态
function ____exports.KKApiIsTaskInProgress(whichPlayer, setIndex, taskstat)
    return RequestExtraIntegerData(
        94,
        whichPlayer,
        nil,
        nil,
        false,
        setIndex,
        0,
        0
    ) == taskstat
end
--- 玩家地图任务当前进度
--  ${whichPlayer} 地图任务： ${setIndex} 的当前进度
function ____exports.KKApiQueryTaskCurrentProgress(whichPlayer, setIndex)
    return RequestExtraIntegerData(
        95,
        whichPlayer,
        nil,
        nil,
        false,
        setIndex,
        0,
        0
    )
end
--- 玩家地图任务总进度
--  ${whichPlayer} 地图任务： ${setIndex} 总进度
function ____exports.KKApiQueryTaskTotalProgress(whichPlayer, setIndex)
    return RequestExtraIntegerData(
        96,
        whichPlayer,
        nil,
        nil,
        false,
        setIndex,
        0,
        0
    )
end
--- 玩家平台该地图成就是否完成
--  ${whichPlayer} 平台该地图成就： ${key} 已经完成
-- 完成返回true
function ____exports.KKApiIsAchievementCompleted(whichPlayer, id)
    return RequestExtraBooleanData(
        98,
        whichPlayer,
        id,
        nil,
        false,
        0,
        0,
        0
    )
end
--- 玩家平台该地图成就点数
--  ${whichPlayer} 平台该地图成就点数
function ____exports.KKApiAchievementPoints(whichPlayer)
    return RequestExtraIntegerData(
        99,
        whichPlayer,
        nil,
        nil,
        false,
        0,
        0,
        0
    )
end
--- 判定测试大厅游戏时长区间
--  ${whichPlayer} 在测试大厅的游戏时长是否在区间（ ${minHours} 到 ${maxHours} ）小时
-- 判断测试大厅游戏时长是否满足该区间 ，0表示不限制，单位为小时
function ____exports.KKApiPlayedTime(whichPlayer, minHours, maxHours)
    return RequestExtraBooleanData(
        100,
        whichPlayer,
        nil,
        nil,
        false,
        minHours,
        maxHours,
        0
    )
end
--- 【批量存档】开始保存
--  ${whichPlayer} 开始批量保存存档
-- 对添加批量保存存档条目进行保存。
function ____exports.KKApiBeginBatchSaveArchive(whichPlayer)
    return RequestExtraBooleanData(
        102,
        whichPlayer,
        nil,
        nil,
        false,
        0,
        0,
        0
    )
end
--- 【批量存档】添加条目
-- 设置 ${whichPlayer} 批量存档添加条目 ${key} ，数据： ${value} ， ${caseInsensitive} 区分大小写
-- 对添加批量保存存档条目进行保存。
function ____exports.KKApiAddBatchSaveArchive(whichPlayer, key, value, caseInsensitive)
    return RequestExtraBooleanData(
        103,
        whichPlayer,
        key,
        value,
        caseInsensitive,
        0,
        0,
        0
    )
end
--- 【批量存档】结束保存
-- 设置 ${whichPlayer}  ${abandon} 结束批量保存存档
-- 结束批量保存存档。
function ____exports.KKApiEndBatchSaveArchive(whichPlayer, abandon)
    return RequestExtraBooleanData(
        104,
        whichPlayer,
        nil,
        nil,
        abandon,
        0,
        0,
        0
    )
end
--- 【批量存档】添加条目-整数
-- 设置 ${whichPlayer} 批量存档添加条目 ${key} ，数据： ${value}
-- 对添加批量保存存档条目进行保存。KEY不区分大小写
function ____exports.KKApiAddBatchSaveArchiveInteger(whichPlayer, key, value)
    key = "I" .. key
    ____exports.KKApiAddBatchSaveArchive(
        whichPlayer,
        key,
        I2S(value),
        false
    )
end
--- 【批量存档】添加条目-实数
-- 设置 ${whichPlayer} 批量存档添加条目 ${key} ，数据： ${value}
-- 对添加批量保存存档条目进行保存。KEY不区分大小写
function ____exports.KKApiAddBatchSaveArchiveReal(whichPlayer, key, value)
    key = "R" .. key
    ____exports.KKApiAddBatchSaveArchive(
        whichPlayer,
        key,
        R2S(value),
        false
    )
end
--- 【批量存档】添加条目-布尔值
-- 设置 ${whichPlayer} 批量存档添加条目 ${key} ，数据： ${value}
-- 对添加批量保存存档条目进行保存。KEY不区分大小写
function ____exports.KKApiAddBatchSaveArchiveBoolean(whichPlayer, key, value)
    key = "B" .. key
    if value then
        ____exports.KKApiAddBatchSaveArchive(whichPlayer, key, "1", false)
    else
        ____exports.KKApiAddBatchSaveArchive(whichPlayer, key, "0", false)
    end
end
--- 【批量存档】添加条目-字符串
-- 设置 ${whichPlayer} 批量存档添加条目 ${key} ，数据： ${value}
-- 对添加批量保存存档条目进行保存。KEY不区分大小写
function ____exports.KKApiAddBatchSaveArchiveString(whichPlayer, key, value)
    key = "S" .. key
    ____exports.KKApiAddBatchSaveArchive(whichPlayer, key, value, false)
end
--- KKApiTriggerRegisterLadderSurrender
function ____exports.KKApiTriggerRegisterLadderSurrender(trig)
    DzTriggerRegisterSyncData(trig, "DZSR", true)
end
--- 获取天梯投降的队伍ID
-- 获取天梯投降的队伍ID
-- 用于天梯投降事件动作里
function ____exports.KKApiGetLadderSurrenderTeamId()
    return S2I(DzGetTriggerSyncData())
end
--- 玩家在公会的等级
-- 获取 ${whichPlayer} 公会等级
-- 获取玩家公会等级
function ____exports.KKApiGetGuildLevel(whichPlayer)
    return RequestExtraIntegerData(
        106,
        whichPlayer,
        nil,
        nil,
        false,
        0,
        0,
        0
    )
end
--- 宠物探险次数
--  ${whichPlayer} 宠物探险次数
-- 获取平台宠物探险次数
function ____exports.KKApiMapExplorationNum(whichPlayer)
    return RequestExtraIntegerData(
        107,
        whichPlayer,
        nil,
        nil,
        false,
        0,
        0,
        0
    )
end
--- 宠物探险时间
--  ${whichPlayer} 宠物探险时间
-- 获取平台宠物探险时间
function ____exports.KKApiMapExplorationTime(whichPlayer)
    return RequestExtraIntegerData(
        108,
        whichPlayer,
        nil,
        nil,
        false,
        0,
        0,
        0
    )
end
--- 测试大厅预约人数
-- 测试大厅预约人数
function ____exports.KKApiMapOrderNum()
    return RequestExtraIntegerData(
        109,
        nil,
        nil,
        nil,
        false,
        0,
        0,
        0
    )
end
--- 发送云脚本数据
-- 发送云脚本数据 ${玩家}  ${事件}  ${数据}
-- 发送云脚本数据
function ____exports.KKApiMlScriptEvent(whichPlayer, eventName, payload)
    return RequestExtraBooleanData(
        1009,
        whichPlayer,
        eventName,
        payload,
        false,
        0,
        0,
        0
    )
end
--- 事件响应 - 商城道具最后变动的数量
--  ${whichPlayer} 商城道具： ${key} 最后更新的数量
-- 获取的是当次玩家商城背包新增或消耗的数量，如果是时效型道具获取的是剩余时间，可以用于【玩家获取商城道具事件】、【玩家消耗使用商城道具事件】和【玩家删除商城道具事件】后。
function ____exports.KKApiGetMallItemUpdateCount(whichPlayer, key)
    return RequestExtraIntegerData(
        110,
        whichPlayer,
        key,
        nil,
        false,
        0,
        0,
        0
    )
end
--- 获取地图版本号[new]
-- 获取地图版本号
function ____exports.KKApiGetMapVersion()
    return RequestExtraStringData(
        111,
        nil,
        nil,
        nil,
        false,
        0,
        0,
        0
    )
end
--- 获取赛事模式[new]
-- 获取赛事模式
function ____exports.KKApiGetCompetitionGameMode()
    return RequestExtraStringData(
        112,
        nil,
        nil,
        nil,
        false,
        0,
        0,
        0
    )
end
--- 获取玩家当天总游戏局数[new]
-- 获取 ${whichPlayer} 当天总游戏局数
-- 为当天玩家玩该地图的有效局数，10分钟算一局，每天05:00刷新
function ____exports.KKApiDayRounds(whichPlayer)
    return RequestExtraIntegerData(
        113,
        whichPlayer,
        nil,
        nil,
        false,
        0,
        0,
        0
    )
end
--- 获取玩家在指定地图会员等级[new]
-- 获取 ${whichPlayer} 在地图 ${mapId} 的会员等级
function ____exports.KKApiConsumeLevel(whichPlayer, mapId)
    return RequestExtraIntegerData(
        115,
        whichPlayer,
        nil,
        nil,
        false,
        mapId,
        0,
        0
    )
end
--- 判断玩家当前地图在游戏大厅置顶状态[new]
--  ${whichPlayer} 当前地图在游戏大厅置顶状态
-- 玩家在游戏大厅首页置顶该地图后返回true
function ____exports.KKApiIsPinned(whichPlayer)
    return RequestExtraBooleanData(
        117,
        whichPlayer,
        nil,
        nil,
        false,
        0,
        0,
        0
    )
end
--- 仅只读存档[new]
-- 只读存档: 读取玩家 ${player} 名称 ${key} 的数据
-- 只能读取只读存档，不可读取可写存档
function ____exports.DzAPI_Map_SystemArchive(whichPlayer, key)
    return RequestExtraStringData(
        35,
        whichPlayer,
        key,
        nil,
        false,
        0,
        0,
        0
    )
end
--- 获取玩家赏金助力榜排名
-- 获取 ${whichPlayer} 赏金助力榜排名
-- 0=未上榜，1=第一名，依此类推
function ____exports.KKApiBountyRank(whichPlayer)
    return RequestExtraIntegerData(
        120,
        whichPlayer,
        nil,
        nil,
        false,
        0,
        0,
        0
    )
end
--- 获取玩家赏金助力值
-- 获取 ${whichPlayer} 赏金助力值
-- 获取玩家赏金助力值
function ____exports.KKApiBountyValue(whichPlayer)
    return RequestExtraIntegerData(
        121,
        whichPlayer,
        nil,
        nil,
        false,
        0,
        0,
        0
    )
end
--- DzK2I
function ____exports.DzK2I(i)
    return i
end
--- DzI2K
function ____exports.DzI2K(i)
    return i
end
--- DzTriggerRegisterMallItemSyncData
function ____exports.DzTriggerRegisterMallItemSyncData(trig)
    DzTriggerRegisterSyncData(trig, "DZMIA", true)
end
--- DzTriggerRegisterMallItemConsumeEvent
function ____exports.DzTriggerRegisterMallItemConsumeEvent(trig)
    DzTriggerRegisterSyncData(trig, "DZMIC", true)
end
--- DzTriggerRegisterMallItemRemoveEvent
function ____exports.DzTriggerRegisterMallItemRemoveEvent(trig)
    DzTriggerRegisterSyncData(trig, "DZMID", true)
end
--- 事件响应 - 触发的商城道具事件的玩家
-- 触发的商城道具事件的玩家
-- 可以用于【玩家获取商城道具事件】、【玩家消耗使用商城道具事件】和【玩家删除商城道具事件】后。
function ____exports.DzGetTriggerMallItemPlayer()
    return DzGetTriggerSyncPlayer()
end
--- 事件响应 - 触发的商城道具（实时）
-- 触发的商城道具
-- 可以用于【玩家获取商城道具事件】、【玩家消耗使用商城道具事件】和【玩家删除商城道具事件】后。
function ____exports.DzGetTriggerMallItem()
    return DzGetTriggerSyncData()
end
return ____exports

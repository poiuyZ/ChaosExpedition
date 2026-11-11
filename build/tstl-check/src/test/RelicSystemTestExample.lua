local ____exports = {}
local _____2A = require("lua_modules.@eiriksgata.wc3ts.src.index")
local Players = _____2A.Players
local ____helper = require("src.utils.helper")
local FourCC = ____helper.FourCC
local ____actor = require("src.system.actor")
local Actor = ____actor.Actor
local ____relic = require("src.system.relic.index")
local RelicSystem = ____relic.RelicSystem
local ____RelicBarUI = require("src.system.ui.component.RelicBarUI")
local RelicBarUI = ____RelicBarUI.RelicBarUI
local ____logger = require("src.utils.logger")
local createLogger = ____logger.createLogger
local log = createLogger("RelicSystemTestExample")
--- 遗物系统测试说明
-- 
-- - **数据**：遗物挂在 **单位** 上（`RelicSystem.addRelic(actor, id)`），每个单位一套库存。
-- - **UI**：`RelicBarUI` 只展示「当前关注」的那一个单位的遗物。
-- - **与选中的关系**：默认不会自动跟选中；调用 `RelicBarUI.getInstance().bindFollowLocalSelection()` 后，
--   本地玩家选中自己的单位时，栏会切到该单位；点空白取消选中时栏会清空。
-- 
-- 在 `main()` 里延迟一帧调用 `relicSystemTestExample()` 即可（需已执行 `initialize()` 内的遗物与 UI 初始化）。
function ____exports.relicSystemTestExample()
    local owner = Players[1]
    local rs = RelicSystem:getInstance()
    local bar = RelicBarUI:getInstance()
    local heroA = Actor:create(
        owner,
        FourCC("Hpal"),
        -200,
        0
    )
    local heroB = Actor:create(
        owner,
        FourCC("Hamg"),
        200,
        0
    )
    if not heroA or not heroB then
        log:error("创建英雄失败")
        return
    end
    local relicIds = {"burning_blood", "war_fang", "iron_plate", "arcane_grimoire_water"}
    for ____, id in ipairs(relicIds) do
        local ok = rs:addRelic(heroA, id)
        if ok then
            log:info("已为英雄 A 添加遗物: " .. id)
        else
            log:warn("添加遗物失败（未注册或已达上限）: " .. id)
        end
    end
    bar:bindFollowLocalSelection()
    log:info("请点击选中两名英雄对比遗物栏；点地面取消选中会清空栏。")
end
return ____exports

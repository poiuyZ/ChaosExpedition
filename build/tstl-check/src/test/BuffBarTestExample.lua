local ____exports = {}
local _____2A = require("lua_modules.@eiriksgata.wc3ts.src.index")
local Players = _____2A.Players
local ____helper = require("src.utils.helper")
local FourCC = ____helper.FourCC
local ____actor = require("src.system.actor")
local Actor = ____actor.Actor
local ____BuffBarUI = require("src.system.ui.component.BuffBarUI")
local BuffBarUI = ____BuffBarUI.BuffBarUI
local ____logger = require("src.utils.logger")
local createLogger = ____logger.createLogger
local log = createLogger("BuffBarTestExample")
--- Buff 栏测试：本地英雄加护盾 Buff，选中单位后屏幕中央显示 Buff 图标与剩余时间。
-- 在 `main()` 里延迟调用 `buffBarTestExample()`（需已执行 `initialize()` 内的 TOC 与 BuffBarUI.create）。
function ____exports.buffBarTestExample()
    local owner = Players[1]
    local bar = BuffBarUI:getInstance()
    local hero = Actor:create(
        owner,
        FourCC("Hpal"),
        0,
        0
    )
    if not hero then
        log:error("创建英雄失败")
        return
    end
    hero:addShield(500, 30)
    bar:bindFollowLocalSelection()
    log:info("请选中该英雄查看屏幕中央的 Buff 栏；30s 后护盾 Buff 将按持续时间移除。")
end
return ____exports

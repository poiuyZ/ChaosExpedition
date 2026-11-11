local ____exports = {}
local ____event = require("src.system.event.index")
local gameEvents = ____event.gameEvents
local ____GachaPanel = require("src.system.ui.component.GachaPanel")
local GachaPanel = ____GachaPanel.GachaPanel
local ____logger = require("src.utils.logger")
local createLogger = ____logger.createLogger
local log = createLogger("GachaExample")
function ____exports.gachaTest()
    local gacha = GachaPanel:createCentered("抽卡天赋", 1100, 500):setCardSize(300, 350):setDraggable(true)
    gacha:addCard({
        icon = "ReplaceableTextures\\CommandButtons\\BTNHeroPaladin.blp",
        title = "圣光信仰",
        description = "提高你的治疗效果 20%，\n并在释放技能时有几率恢复生命。",
        onClick = function()
            log:info("选择了天赋：圣光信仰")
        end
    })
    gacha:addCard({
        icon = "ReplaceableTextures\\CommandButtons\\BTNStormBolt.blp",
        title = "雷霆一击",
        description = "获得一个可以对敌方单位造成伤害并眩晕的主动技能。",
        onClick = function()
            log:info("选择了天赋：雷霆一击")
        end
    })
    gacha:addCard({
        icon = "ReplaceableTextures\\CommandButtons\\BTNStormBolt.blp",
        title = "雷霆一击",
        description = "获得一个可以对敌方单位造成伤害并眩晕的主动技能。",
        onClick = function()
            log:info("选择了天赋：雷霆一击")
        end
    })
    gacha:show()
    gameEvents:onSpellEffect(function(data)
        local ____DisplayTextToPlayer_3 = DisplayTextToPlayer
        local ____Player_result_2 = Player(0)
        local ____opt_0 = data.Actor
        ____DisplayTextToPlayer_3(
            ____Player_result_2,
            0,
            0,
            ((tostring(____opt_0 and ____opt_0.name) .. " 释放了 ") .. tostring(data.abilityId)) .. " 效果"
        )
    end)
end
return ____exports

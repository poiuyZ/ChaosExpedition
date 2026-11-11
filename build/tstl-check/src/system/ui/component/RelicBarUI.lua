local ____lualib = require("lualib_bundle")
local __TS__Class = ____lualib.__TS__Class
local __TS__ObjectAssign = ____lualib.__TS__ObjectAssign
local __TS__New = ____lualib.__TS__New
local ____exports = {}
local _____2A = require("lua_modules.@eiriksgata.wc3ts.src.index")
local Frame = _____2A.Frame
local FRAME_ALIGN_LEFT_TOP = _____2A.FRAME_ALIGN_LEFT_TOP
local FRAME_ALIGN_RIGHT_BOTTOM = _____2A.FRAME_ALIGN_RIGHT_BOTTOM
local MapPlayer = _____2A.MapPlayer
local ____utils = require("src.constants.frame.utils")
local FrameEventUtils = ____utils.FrameEventUtils
local ____preset = require("src.constants.ui.preset")
local UIBackgrounds = ____preset.UIBackgrounds
local ____relic = require("src.system.relic.index")
local RelicSystem = ____relic.RelicSystem
local RELIC_EVENT_INVENTORY_CHANGED = ____relic.RELIC_EVENT_INVENTORY_CHANGED
local ____EventBus = require("src.system.event.EventBus")
local eventBus = ____EventBus.eventBus
local ____event = require("src.system.event.index")
local gameEvents = ____event.gameEvents
local ____ScreenCoordinates = require("src.system.ui.ScreenCoordinates")
local ScreenCoordinates = ____ScreenCoordinates.ScreenCoordinates
local ____Tips = require("src.system.ui.component.Tips")
local Tips = ____Tips.Tips
local TipsAnimation = ____Tips.TipsAnimation
local TipsPosition = ____Tips.TipsPosition
local ____logger = require("src.utils.logger")
local createLogger = ____logger.createLogger
local log = createLogger("RelicBarUI")
local nextRelicSlotNameId = 1
____exports.DEFAULT_RELIC_BAR_LAYOUT = {
    anchorX = 120,
    anchorY = 30,
    iconSizePx = 48,
    borderPadPx = 3,
    spacingPx = 6,
    rowPaddingPx = 4,
    maxIcons = 24
}
--- 与 TipsExample / 物品品质色接近，便于区分稀有度
local function relicTipsTextColor(def)
    repeat
        local ____switch3 = def.rarity
        local ____cond3 = ____switch3 == "uncommon"
        if ____cond3 then
            return "1EFF00"
        end
        ____cond3 = ____cond3 or ____switch3 == "rare"
        if ____cond3 then
            return "0070DD"
        end
        ____cond3 = ____cond3 or ____switch3 == "boss"
        if ____cond3 then
            return "FFD700"
        end
        do
            return "FFFFFF"
        end
    until true
end
--- 左上角横向遗物栏（杀戮尖塔式：小方块从左到右，悬停 Tips）
____exports.RelicBarUI = __TS__Class()
local RelicBarUI = ____exports.RelicBarUI
RelicBarUI.name = "RelicBarUI"
function RelicBarUI.prototype.____constructor(self)
    self.layout = __TS__ObjectAssign({}, ____exports.DEFAULT_RELIC_BAR_LAYOUT)
    self.gameUI = nil
    self.slots = {}
    self.subscriptionId = -1
    self.created = false
end
function RelicBarUI.getInstance(self)
    if not ____exports.RelicBarUI.instance then
        ____exports.RelicBarUI.instance = __TS__New(____exports.RelicBarUI)
    end
    return ____exports.RelicBarUI.instance
end
function RelicBarUI.prototype.setLayout(self, config)
    self.layout = __TS__ObjectAssign({}, self.layout, config)
    if self.created and self.watchTarget then
        self:rebuildSlots()
    end
    return self
end
function RelicBarUI.prototype.getLayout(self)
    return __TS__ObjectAssign({}, self.layout)
end
function RelicBarUI.prototype.create(self)
    if self.created then
        return
    end
    local gui = Frame:fromHandle(DzGetGameUI())
    self.gameUI = gui or nil
    if not self.gameUI then
        log:error("DzGetGameUI failed")
        return
    end
    self.subscriptionId = eventBus:on(
        RELIC_EVENT_INVENTORY_CHANGED,
        function(payload)
            if self.watchTarget and payload.actor.id == self.watchTarget.id then
                self:rebuildSlots()
            end
        end
    )
    self.created = true
end
function RelicBarUI.prototype.bindFollowLocalSelection(self)
    if ____exports.RelicBarUI.followSelectionBound then
        return
    end
    ____exports.RelicBarUI.followSelectionBound = true
    gameEvents:onUnitSelected(function(data)
        if GetTriggerPlayer() ~= GetLocalPlayer() then
            return
        end
        ____exports.RelicBarUI:getInstance():setWatchTarget(data.Actor)
    end)
    gameEvents:onUnitDeselected(function()
        if GetTriggerPlayer() ~= GetLocalPlayer() then
            return
        end
        ____exports.RelicBarUI:getInstance():setWatchTarget(nil)
    end)
end
function RelicBarUI.prototype.setWatchTarget(self, actor)
    self.watchTarget = actor
    if not actor or actor.owner ~= MapPlayer:fromLocal() then
        self:clearSlots()
        return
    end
    self:rebuildSlots()
end
function RelicBarUI.prototype.getWatchTarget(self)
    return self.watchTarget
end
function RelicBarUI.prototype.destroy(self)
    if self.subscriptionId >= 0 then
        eventBus:off(self.subscriptionId)
        self.subscriptionId = -1
    end
    self:clearSlots()
    self.watchTarget = nil
    self.created = false
    self.gameUI = nil
    ____exports.RelicBarUI.instance = nil
end
function RelicBarUI.prototype.clearSlots(self)
    for ____, s in ipairs(self.slots) do
        s.hit:destroy()
        s.icon:destroy()
        s.border:destroy()
    end
    self.slots = {}
end
function RelicBarUI.prototype.rebuildSlots(self)
    self:clearSlots()
    if not self.gameUI or not self.watchTarget then
        return
    end
    if self.watchTarget.owner ~= MapPlayer:fromLocal() then
        return
    end
    local rs = RelicSystem:getInstance()
    local items = rs:getRelics(self.watchTarget)
    local n = math.min(#items, self.layout.maxIcons)
    local ____self_layout_0 = self.layout
    local anchorX = ____self_layout_0.anchorX
    local anchorY = ____self_layout_0.anchorY
    local iconSizePx = ____self_layout_0.iconSizePx
    local borderPadPx = ____self_layout_0.borderPadPx
    local spacingPx = ____self_layout_0.spacingPx
    local rowPaddingPx = ____self_layout_0.rowPaddingPx
    local slotOuter = iconSizePx + borderPadPx * 2
    local slotIndex = 0
    do
        local i = 0
        while i < n do
            do
                local item = items[i + 1]
                local def = rs:getDefinition(item.id)
                if not def then
                    goto __continue33
                end
                local slotLeft = anchorX + rowPaddingPx + slotIndex * (slotOuter + spacingPx)
                local nameIdx = slotIndex
                slotIndex = slotIndex + 1
                local slotTop = anchorY + rowPaddingPx
                local wc3Outer = ScreenCoordinates:pixelSizeToWC3(slotOuter, slotOuter)
                local wc3Pos = ScreenCoordinates:pixelToWC3(slotLeft, slotTop, ScreenCoordinates.ORIGIN_TOP_LEFT)
                local rightX = wc3Pos.x + wc3Outer.width
                local bottomY = wc3Pos.y - wc3Outer.height
                local ____nextRelicSlotNameId_1 = nextRelicSlotNameId
                nextRelicSlotNameId = ____nextRelicSlotNameId_1 + 1
                local nameId = ____nextRelicSlotNameId_1
                local border = Frame:createType(
                    (((("RelicSlotBorder_" .. tostring(nameId)) .. "_") .. tostring(nameIdx)) .. "_") .. tostring(i),
                    self.gameUI,
                    0,
                    "BACKDROP",
                    ""
                )
                border:setAbsPoint(FRAME_ALIGN_LEFT_TOP, wc3Pos.x, wc3Pos.y):setAbsPoint(FRAME_ALIGN_RIGHT_BOTTOM, rightX, bottomY):setTexture(UIBackgrounds.BLACK_TRANSPARENT, 0, true):setAlpha(200)
                DzFrameSetPriority(border.handle, 900)
                local padX = borderPadPx / ScreenCoordinates.STANDARD_WIDTH * ScreenCoordinates.WC3_SCREEN_WIDTH
                local padY = borderPadPx / ScreenCoordinates.STANDARD_HEIGHT * ScreenCoordinates.WC3_SCREEN_HEIGHT
                local wc3Icon = ScreenCoordinates:pixelSizeToWC3(iconSizePx, iconSizePx)
                local icon = Frame:createType(
                    (("RelicSlotIcon_" .. tostring(nameId)) .. "_") .. tostring(i),
                    border,
                    0,
                    "BACKDROP",
                    ""
                )
                icon:setPoint(
                    FRAME_ALIGN_LEFT_TOP,
                    border,
                    FRAME_ALIGN_LEFT_TOP,
                    padX,
                    -padY
                ):setSize(wc3Icon.width, wc3Icon.height):setTexture(def.icon, 0, true):setAlpha(255)
                local hit = Frame:createType(
                    (("RelicSlotHit_" .. tostring(nameId)) .. "_") .. tostring(i),
                    border,
                    0,
                    "BUTTON",
                    ""
                )
                hit:setAllPoints(border)
                DzFrameSetPriority(hit.handle, 901)
                local tips = Tips:getInstance()
                local componentInfo = {
                    frame = hit,
                    x = slotLeft,
                    y = slotTop,
                    width = slotOuter,
                    height = slotOuter
                }
                FrameEventUtils:bindEvents(
                    hit,
                    {
                        onMouseEnter = function()
                            tips:showFromComponentInfo(
                                {
                                    text = self:buildTipsText(def.name, def.description, item.stacks),
                                    textColor = relicTipsTextColor(def),
                                    icon = def.icon,
                                    width = 320,
                                    maxHeight = 360,
                                    position = TipsPosition.AUTO,
                                    animation = TipsAnimation.NONE,
                                    delayShow = 0
                                },
                                componentInfo
                            )
                        end,
                        onMouseLeave = function()
                            tips:hide()
                        end
                    }
                )
                local ____self_slots_2 = self.slots
                ____self_slots_2[#____self_slots_2 + 1] = {border = border, icon = icon, hit = hit}
            end
            ::__continue33::
            i = i + 1
        end
    end
end
function RelicBarUI.prototype.buildTipsText(self, name, description, stacks)
    local t = (name .. "\n\n") .. description
    if stacks > 1 then
        t = t .. "\n\n层数：" .. tostring(stacks)
    end
    return t
end
RelicBarUI.followSelectionBound = false
return ____exports

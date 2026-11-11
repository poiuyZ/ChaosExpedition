local ____lualib = require("lualib_bundle")
local __TS__Class = ____lualib.__TS__Class
local __TS__ObjectAssign = ____lualib.__TS__ObjectAssign
local __TS__New = ____lualib.__TS__New
local ____exports = {}
local _____2A = require("lua_modules.@eiriksgata.wc3ts.src.index")
local Frame = _____2A.Frame
local FRAME_ALIGN_BOTTOM = _____2A.FRAME_ALIGN_BOTTOM
local FRAME_ALIGN_LEFT_TOP = _____2A.FRAME_ALIGN_LEFT_TOP
local FRAME_ALIGN_RIGHT_BOTTOM = _____2A.FRAME_ALIGN_RIGHT_BOTTOM
local MapPlayer = _____2A.MapPlayer
local Timer = _____2A.Timer
local ____utils = require("src.constants.frame.utils")
local FrameEventUtils = ____utils.FrameEventUtils
local ____preset = require("src.constants.ui.preset")
local UIBackgrounds = ____preset.UIBackgrounds
local ____buff = require("src.system.buff.index")
local BUFF_EVENT_BUFFS_CHANGED = ____buff.BUFF_EVENT_BUFFS_CHANGED
local buildBuffTooltipText = ____buff.buildBuffTooltipText
local formatSlotTimeShort = ____buff.formatSlotTimeShort
local registerDefaultBuffDisplays = ____buff.registerDefaultBuffDisplays
local resolveBuffDisplay = ____buff.resolveBuffDisplay
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
local log = createLogger("BuffBarUI")
local REFRESH_INTERVAL = 0.1
local nextBuffSlotNameId = 1
--- 槽位时间角标用字体（与 UnitBlood 一致，地图内已有资源）
local SLOT_TIME_FONT = "resource\\Texture\\ui\\hpbar\\ZiTi.TTf"
____exports.DEFAULT_BUFF_BAR_LAYOUT = {
    slotsPerRow = 10,
    maxRows = 3,
    iconSizePx = 36,
    borderPadPx = 2,
    spacingPx = 4,
    rowSpacingPx = 4,
    rowPaddingPx = 4,
    centerOffsetXPx = 0,
    centerOffsetYPx = 0
}
local function buffTipsTextColor(buff)
    repeat
        local ____switch3 = buff.polarity
        local ____cond3 = ____switch3 == 1
        if ____cond3 then
            return "A8FFA8"
        end
        ____cond3 = ____cond3 or ____switch3 == -1
        if ____cond3 then
            return "FF8888"
        end
        ____cond3 = ____cond3 or ____switch3 == 0
        if ____cond3 then
            return "CCCCCC"
        end
        do
            return "FFFFFF"
        end
    until true
end
--- 屏幕居中 Buff 图标网格（紧凑、悬停 Tips、槽位显示剩余时间）
____exports.BuffBarUI = __TS__Class()
local BuffBarUI = ____exports.BuffBarUI
BuffBarUI.name = "BuffBarUI"
function BuffBarUI.prototype.____constructor(self)
    self.layout = __TS__ObjectAssign({}, ____exports.DEFAULT_BUFF_BAR_LAYOUT)
    self.gameUI = nil
    self.slots = {}
    self.subscriptionId = -1
    self.refreshTimer = nil
    self.created = false
end
function BuffBarUI.getInstance(self)
    if not ____exports.BuffBarUI.instance then
        ____exports.BuffBarUI.instance = __TS__New(____exports.BuffBarUI)
    end
    return ____exports.BuffBarUI.instance
end
function BuffBarUI.prototype.getMaxSlots(self)
    local cap = self.layout.slotsPerRow * self.layout.maxRows
    if self.layout.maxSlots ~= nil then
        return math.min(self.layout.maxSlots, cap)
    end
    return cap
end
function BuffBarUI.prototype.setLayout(self, config)
    self.layout = __TS__ObjectAssign({}, self.layout, config)
    if self.created and self.watchTarget then
        self:rebuildSlots()
    end
    return self
end
function BuffBarUI.prototype.getLayout(self)
    return __TS__ObjectAssign({}, self.layout)
end
function BuffBarUI.prototype.create(self)
    if self.created then
        return
    end
    registerDefaultBuffDisplays()
    local gui = Frame:fromHandle(DzGetGameUI())
    self.gameUI = gui or nil
    if not self.gameUI then
        log:error("DzGetGameUI failed")
        return
    end
    self.subscriptionId = eventBus:on(
        BUFF_EVENT_BUFFS_CHANGED,
        function(payload)
            if self.watchTarget and payload.actor.id == self.watchTarget.id then
                self:rebuildSlots()
            end
        end
    )
    self.refreshTimer = Timer:create()
    self.refreshTimer:start(
        REFRESH_INTERVAL,
        true,
        function()
            self:refreshTimeLabels()
        end
    )
    self.created = true
end
function BuffBarUI.prototype.bindFollowLocalSelection(self)
    if ____exports.BuffBarUI.followSelectionBound then
        return
    end
    ____exports.BuffBarUI.followSelectionBound = true
    gameEvents:onUnitSelected(function(data)
        if GetTriggerPlayer() ~= GetLocalPlayer() then
            return
        end
        ____exports.BuffBarUI:getInstance():setWatchTarget(data.Actor)
    end)
    gameEvents:onUnitDeselected(function()
        if GetTriggerPlayer() ~= GetLocalPlayer() then
            return
        end
        ____exports.BuffBarUI:getInstance():setWatchTarget(nil)
    end)
end
function BuffBarUI.prototype.setWatchTarget(self, actor)
    self.watchTarget = actor
    if not actor or actor.owner ~= MapPlayer:fromLocal() then
        self:clearSlots()
        return
    end
    self:rebuildSlots()
end
function BuffBarUI.prototype.getWatchTarget(self)
    return self.watchTarget
end
function BuffBarUI.prototype.destroy(self)
    if self.subscriptionId >= 0 then
        eventBus:off(self.subscriptionId)
        self.subscriptionId = -1
    end
    if self.refreshTimer then
        self.refreshTimer:destroy()
        self.refreshTimer = nil
    end
    self:clearSlots()
    self.watchTarget = nil
    self.created = false
    self.gameUI = nil
    ____exports.BuffBarUI.instance = nil
end
function BuffBarUI.prototype.clearSlots(self)
    for ____, s in ipairs(self.slots) do
        s.hit:destroy()
        s.timeText:destroy()
        s.icon:destroy()
        s.border:destroy()
    end
    self.slots = {}
end
function BuffBarUI.prototype.refreshTimeLabels(self)
    if not self.created or not self.gameUI or not self.watchTarget then
        return
    end
    if self.watchTarget.owner ~= MapPlayer:fromLocal() then
        return
    end
    local buffs = self.watchTarget.buffManager:getBuffs()
    local n = math.min(
        #buffs,
        self:getMaxSlots()
    )
    if #self.slots ~= n then
        self:rebuildSlots()
        return
    end
    do
        local i = 0
        while i < n do
            local slot = self.slots[i + 1]
            local b = buffs[i + 1]
            if not slot or b.id ~= slot.buffId then
                self:rebuildSlots()
                return
            end
            slot.timeText:setText(formatSlotTimeShort(b))
            i = i + 1
        end
    end
end
function BuffBarUI.prototype.rebuildSlots(self)
    self:clearSlots()
    if not self.gameUI or not self.watchTarget then
        return
    end
    if self.watchTarget.owner ~= MapPlayer:fromLocal() then
        return
    end
    local buffs = self.watchTarget.buffManager:getBuffs()
    local n = math.min(
        #buffs,
        self:getMaxSlots()
    )
    local ____self_layout_0 = self.layout
    local slotsPerRow = ____self_layout_0.slotsPerRow
    local iconSizePx = ____self_layout_0.iconSizePx
    local borderPadPx = ____self_layout_0.borderPadPx
    local spacingPx = ____self_layout_0.spacingPx
    local rowSpacingPx = ____self_layout_0.rowSpacingPx
    local rowPaddingPx = ____self_layout_0.rowPaddingPx
    local centerOffsetXPx = ____self_layout_0.centerOffsetXPx
    local centerOffsetYPx = ____self_layout_0.centerOffsetYPx
    local slotOuter = iconSizePx + borderPadPx * 2
    local cols = slotsPerRow
    local rows = self.layout.maxRows
    local gridWidthPx = cols * slotOuter + (cols - 1) * spacingPx + 2 * rowPaddingPx
    local gridHeightPx = rows * slotOuter + (rows - 1) * rowSpacingPx + 2 * rowPaddingPx
    local anchorLeft = (ScreenCoordinates.STANDARD_WIDTH - gridWidthPx) / 2 + centerOffsetXPx
    local anchorTop = (ScreenCoordinates.STANDARD_HEIGHT - gridHeightPx) / 2 + centerOffsetYPx
    local padX = borderPadPx / ScreenCoordinates.STANDARD_WIDTH * ScreenCoordinates.WC3_SCREEN_WIDTH
    local padY = borderPadPx / ScreenCoordinates.STANDARD_HEIGHT * ScreenCoordinates.WC3_SCREEN_HEIGHT
    local wc3Icon = ScreenCoordinates:pixelSizeToWC3(iconSizePx, iconSizePx)
    local timeH = 14
    local wc3Time = ScreenCoordinates:pixelSizeToWC3(slotOuter, timeH)
    do
        local i = 0
        while i < n do
            local buff = buffs[i + 1]
            local def = resolveBuffDisplay(buff)
            local row = math.floor(i / slotsPerRow)
            local col = i % slotsPerRow
            local slotLeft = anchorLeft + rowPaddingPx + col * (slotOuter + spacingPx)
            local slotTop = anchorTop + rowPaddingPx + row * (slotOuter + rowSpacingPx)
            local wc3Outer = ScreenCoordinates:pixelSizeToWC3(slotOuter, slotOuter)
            local wc3Pos = ScreenCoordinates:pixelToWC3(slotLeft, slotTop, ScreenCoordinates.ORIGIN_TOP_LEFT)
            local rightX = wc3Pos.x + wc3Outer.width
            local bottomY = wc3Pos.y - wc3Outer.height
            local ____nextBuffSlotNameId_1 = nextBuffSlotNameId
            nextBuffSlotNameId = ____nextBuffSlotNameId_1 + 1
            local nameId = ____nextBuffSlotNameId_1
            local border = Frame:createType(
                (("BuffSlotBorder_" .. tostring(nameId)) .. "_") .. tostring(i),
                self.gameUI,
                0,
                "BACKDROP",
                ""
            )
            border:setAbsPoint(FRAME_ALIGN_LEFT_TOP, wc3Pos.x, wc3Pos.y):setAbsPoint(FRAME_ALIGN_RIGHT_BOTTOM, rightX, bottomY):setTexture(UIBackgrounds.BLACK_TRANSPARENT, 0, true):setAlpha(200)
            DzFrameSetPriority(border.handle, 898)
            local icon = Frame:createType(
                (("BuffSlotIcon_" .. tostring(nameId)) .. "_") .. tostring(i),
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
            local timeText = Frame:createType(
                (("BuffSlotTime_" .. tostring(nameId)) .. "_") .. tostring(i),
                border,
                0,
                "TEXT",
                ""
            )
            timeText:setPoint(
                FRAME_ALIGN_BOTTOM,
                border,
                FRAME_ALIGN_BOTTOM,
                0,
                0.003
            ):setSize(wc3Time.width, wc3Time.height):setText(formatSlotTimeShort(buff))
            timeText:setTextAlignment(4, 0)
            timeText:setFont(SLOT_TIME_FONT, 0.008, 0)
            local hit = Frame:createType(
                (("BuffSlotHit_" .. tostring(nameId)) .. "_") .. tostring(i),
                border,
                0,
                "BUTTON",
                ""
            )
            hit:setAllPoints(border)
            DzFrameSetPriority(hit.handle, 899)
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
                                text = buildBuffTooltipText(buff),
                                textColor = buffTipsTextColor(buff),
                                icon = def.icon,
                                width = 300,
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
            ____self_slots_2[#____self_slots_2 + 1] = {
                border = border,
                icon = icon,
                timeText = timeText,
                hit = hit,
                buffId = buff.id
            }
            i = i + 1
        end
    end
end
BuffBarUI.followSelectionBound = false
return ____exports

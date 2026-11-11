local ____lualib = require("lualib_bundle")
local __TS__Class = ____lualib.__TS__Class
local __TS__Delete = ____lualib.__TS__Delete
local __TS__New = ____lualib.__TS__New
local ____exports = {}
local ____units = require("src.constants.game.units")
local UNIT_TYPE_HERO = ____units.UNIT_TYPE_HERO
local UNIT_TYPE_DEAD = ____units.UNIT_TYPE_DEAD
local UNIT_STATE_LIFE = ____units.UNIT_STATE_LIFE
local UNIT_STATE_MAX_LIFE = ____units.UNIT_STATE_MAX_LIFE
local UNIT_STATE_MANA = ____units.UNIT_STATE_MANA
local UNIT_STATE_MAX_MANA = ____units.UNIT_STATE_MAX_MANA
local ____actor = require("src.system.actor")
local Actor = ____actor.Actor
--- 底框宽度（130 / 2400）
local BASE_WIDTH = 130 / 2400
--- 底框高度（28 / 1800）
local BASE_HEIGHT = 28 / 1800
--- 条形区域宽度（100 / 2400）
local BAR_WIDTH = 100 / 2400
--- 生命条高度（12 / 1800）
local LIFE_HEIGHT = 12 / 1800
--- 蓝条高度（8 / 1800）
local MANA_HEIGHT = 8 / 1800
--- 条形区域相对底框的 X 偏移（26 / 2400）
local BAR_OFFSET_X = 26 / 2400
--- 生命/护盾条相对底框的 Y 偏移（-4 / 1800）
local LIFE_OFFSET_Y = -4 / 1800
--- 蓝条相对底框的 Y 偏移（-18 / 1800）
local MANA_OFFSET_Y = -18 / 1800
--- 定时器间隔（与 JASS 0.03 一致）
local TIMER_INTERVAL = 0.03
--- 与 {@link UnitBlood } 相同血条/蓝条填充贴图（仅换皮，不改布局）
local TEX_LIFE_SELF = "Texture\\ui\\hpbar\\02.tga"
local TEX_LIFE_ENEMY = "Texture\\ui\\hpbar\\05.tga"
local TEX_LIFE_ALLY = "Texture\\ui\\hpbar\\06.tga"
local TEX_MANA = "Texture\\ui\\hpbar\\03.tga"
local TEX_SHIELD = "Texture\\ui\\hpbar\\huduntiao.tga"
local TEX_BASE = "Texture\\ui\\hpbar\\01.tga"
--- 获取英雄单位头像贴图路径（可改为从配置/物编读取）
local function getHeroArtPath(unitTypeId)
    return "ReplaceableTextures\\CommandButtons\\BTNHeroPaladin.blp"
end
____exports.KKWEHeroBloodBar = __TS__Class()
local KKWEHeroBloodBar = ____exports.KKWEHeroBloodBar
KKWEHeroBloodBar.name = "KKWEHeroBloodBar"
function KKWEHeroBloodBar.prototype.____constructor(self, u)
    self.unit = u
    self.unitId = GetHandleId(u)
    self.barWidth = BAR_WIDTH
    self.lifeHeight = LIFE_HEIGHT
    self.manaHeight = MANA_HEIGHT
    self.baseWidth = BASE_WIDTH
    self.baseHeight = BASE_HEIGHT
    local base = ____exports.KKWEHeroBloodBar:getLifeBaseFrame()
    local idStr = tostring(self.unitId)
    local nameBackdrop = "血条" .. idStr
    local nameLife = "血条图片" .. idStr
    local nameShield = "护盾条图片" .. idStr
    local nameMana = "蓝条图片" .. idStr
    local nameIcon = "血条英雄图标" .. idStr
    local nameText = "血条英雄名字" .. idStr
    local nameIconText = "血条英雄图标文字" .. idStr
    local backdrop = DzCreateFrameByTagName(
        "BACKDROP",
        nameBackdrop,
        base,
        "",
        0
    )
    DzFrameBindWidget(
        backdrop,
        u,
        0,
        0,
        0,
        0,
        0,
        false,
        true,
        false
    )
    DzFrameSetTexture(backdrop, TEX_BASE, 0)
    DzFrameSetSize(backdrop, self.baseWidth, self.baseHeight)
    local lifeBar = DzCreateFrameByTagName(
        "BACKDROP",
        nameLife,
        backdrop,
        "",
        0
    )
    DzFrameSetPoint(
        lifeBar,
        0,
        backdrop,
        0,
        BAR_OFFSET_X,
        LIFE_OFFSET_Y
    )
    local lp = GetLocalPlayer()
    local owner = GetOwningPlayer(u)
    if owner == lp then
        DzFrameSetTexture(lifeBar, TEX_LIFE_SELF, 0)
    elseif IsPlayerAlly(owner, lp) then
        DzFrameSetTexture(lifeBar, TEX_LIFE_ALLY, 0)
    else
        DzFrameSetTexture(lifeBar, TEX_LIFE_ENEMY, 0)
    end
    DzFrameSetSize(lifeBar, self.barWidth, self.lifeHeight)
    local shieldBar = DzCreateFrameByTagName(
        "BACKDROP",
        nameShield,
        backdrop,
        "",
        0
    )
    DzFrameSetPoint(
        shieldBar,
        0,
        backdrop,
        0,
        BAR_OFFSET_X,
        LIFE_OFFSET_Y
    )
    DzFrameSetTexture(shieldBar, TEX_SHIELD, 0)
    DzFrameSetSize(shieldBar, self.barWidth, self.lifeHeight)
    DzFrameShow(shieldBar, false)
    local manaBar = DzCreateFrameByTagName(
        "BACKDROP",
        nameMana,
        backdrop,
        "",
        0
    )
    DzFrameSetPoint(
        manaBar,
        0,
        backdrop,
        0,
        BAR_OFFSET_X,
        MANA_OFFSET_Y
    )
    DzFrameSetTexture(manaBar, TEX_MANA, 0)
    DzFrameSetSize(manaBar, self.barWidth, self.manaHeight)
    local heroIcon = DzCreateFrameByTagName(
        "BACKDROP",
        nameIcon,
        backdrop,
        "",
        0
    )
    local heroIconText = DzCreateFrameByTagName(
        "TEXT",
        nameIconText,
        backdrop,
        "",
        0
    )
    DzFrameSetPoint(
        heroIconText,
        4,
        backdrop,
        0,
        14 / 2400,
        -14 / 1800
    )
    DzFrameSetSize(heroIconText, 0.01, 0.01)
    DzFrameSetText(heroIconText, "1")
    DzFrameSetTextAlignment(heroIconText, 4)
    DzFrameSetIgnoreTrackEvents(heroIconText, true)
    DzFrameSetFont(heroIconText, "resource\\Texture\\ui\\hpbar\\ZiTi.TTf", 0.009, 0)
    local heroName = DzCreateFrameByTagName(
        "TEXT",
        nameText,
        backdrop,
        "",
        0
    )
    DzFrameSetPoint(
        heroName,
        7,
        backdrop,
        1,
        0,
        0.002
    )
    DzFrameSetSize(heroName, 0, 0.01)
    DzFrameSetText(
        heroName,
        GetUnitName(u)
    )
    DzFrameSetTextAlignment(heroName, 4)
    DzFrameSetIgnoreTrackEvents(heroName, true)
    DzFrameSetFont(heroName, "resource\\Texture\\ui\\hpbar\\ZiTi.TTf", 0.009, 0)
    self.backdrop = backdrop
    self.lifeBar = lifeBar
    self.shieldBar = shieldBar
    self.manaBar = manaBar
    self.heroIcon = heroIcon
    self.heroName = heroName
    self.heroIconTextFrame = heroIconText
    self.timer = CreateTimer()
    ____exports.KKWEHeroBloodBar.instanceMap[self.unitId] = self
    TimerStart(
        self.timer,
        TIMER_INTERVAL,
        true,
        function() return self:onTimerTick() end
    )
end
function KKWEHeroBloodBar.prototype.onTimerTick(self)
    local u = self.unit
    if u == nil or IsUnitType(u, UNIT_TYPE_DEAD) or self.backdrop == 0 then
        self:destroy()
        return
    end
    local maxLife = GetUnitState(u, UNIT_STATE_MAX_LIFE)
    local lifePercent = maxLife <= 0 and 0 or GetUnitState(u, UNIT_STATE_LIFE) / maxLife * 100
    local maxMana = GetUnitState(u, UNIT_STATE_MAX_MANA)
    local manaPercent = maxMana <= 0 and 0 or GetUnitState(u, UNIT_STATE_MANA) / maxMana * 100
    local heroLevel = GetUnitLevel(u)
    DzFrameSetText(
        self.heroIconTextFrame,
        tostring(heroLevel) .. ""
    )
    DzFrameSetSize(self.lifeBar, self.barWidth * lifePercent / 100, self.lifeHeight)
    DzFrameSetSize(self.manaBar, self.barWidth * manaPercent / 100, self.manaHeight)
    local actor = Actor:fromHandle(u)
    local shieldPercent = actor and actor.shieldPercent or 0
    if shieldPercent <= 0 then
        if DzFrameIsVisible(self.shieldBar) then
            DzFrameShow(self.shieldBar, false)
        end
    else
        if not DzFrameIsVisible(self.shieldBar) then
            DzFrameShow(self.shieldBar, true)
        end
        local clamped = math.max(
            0,
            math.min(shieldPercent, 1)
        )
        DzFrameSetSize(self.shieldBar, self.barWidth * clamped, self.lifeHeight)
    end
end
function KKWEHeroBloodBar.prototype.destroy(self)
    if self.backdrop ~= 0 then
        DzFrameUnBind(self.backdrop)
        DzDestroyFrame(self.backdrop)
    end
    if self.lifeBar ~= 0 then
        DzDestroyFrame(self.lifeBar)
    end
    if self.shieldBar ~= 0 then
        DzDestroyFrame(self.shieldBar)
    end
    if self.manaBar ~= 0 then
        DzDestroyFrame(self.manaBar)
    end
    if self.heroIcon ~= 0 then
        DzDestroyFrame(self.heroIcon)
    end
    if self.heroIconTextFrame ~= 0 then
        DzDestroyFrame(self.heroIconTextFrame)
    end
    if self.heroName ~= 0 then
        DzDestroyFrame(self.heroName)
    end
    if self.timer ~= nil then
        DestroyTimer(self.timer)
    end
    self.unit = nil
    self.backdrop = 0
    self.lifeBar = 0
    self.shieldBar = 0
    self.manaBar = 0
    self.heroIcon = 0
    self.heroIconTextFrame = 0
    self.heroName = 0
    __TS__Delete(____exports.KKWEHeroBloodBar.instanceMap, self.unitId)
end
function KKWEHeroBloodBar.prototype.getUnit(self)
    return self.unit
end
function KKWEHeroBloodBar.prototype.getUnitId(self)
    return self.unitId
end
function KKWEHeroBloodBar.getLifeBaseFrame(self)
    if ____exports.KKWEHeroBloodBar.lifeBaseFrame ~= 0 then
        return ____exports.KKWEHeroBloodBar.lifeBaseFrame
    end
    local lower = DzFrameGetLowerLevelFrame()
    ____exports.KKWEHeroBloodBar.lifeBaseFrame = DzCreateFrameByTagName(
        "FRAME",
        "血条底层",
        lower,
        "",
        0
    )
    return ____exports.KKWEHeroBloodBar.lifeBaseFrame
end
function KKWEHeroBloodBar.create(self, u)
    if u == nil then
        return nil
    end
    if IsUnitType(u, UNIT_TYPE_HERO) ~= true then
        return nil
    end
    DzSetUnitPreselectUIVisible(u, false)
    local unitId = GetHandleId(u)
    local existing = ____exports.KKWEHeroBloodBar.instanceMap[unitId]
    if existing ~= nil then
        return existing
    end
    return __TS__New(____exports.KKWEHeroBloodBar, u)
end
function KKWEHeroBloodBar.get(self, u)
    if u == nil then
        return nil
    end
    return ____exports.KKWEHeroBloodBar.instanceMap[GetHandleId(u)] or nil
end
function KKWEHeroBloodBar.removeByUnit(self, u)
    local bar = ____exports.KKWEHeroBloodBar:get(u)
    if bar ~= nil then
        bar:destroy()
    end
end
function KKWEHeroBloodBar.setLifeBaseFrame(self, frameHandle)
    ____exports.KKWEHeroBloodBar.lifeBaseFrame = frameHandle
end
KKWEHeroBloodBar.lifeBaseFrame = 0
KKWEHeroBloodBar.instanceMap = {}
return ____exports

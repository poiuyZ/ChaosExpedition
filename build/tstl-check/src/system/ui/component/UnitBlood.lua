local ____lualib = require("lualib_bundle")
local __TS__Class = ____lualib.__TS__Class
local __TS__New = ____lualib.__TS__New
local __TS__Iterator = ____lualib.__TS__Iterator
local Map = ____lualib.Map
local ____exports = {}
local _____2A = require("lua_modules.@eiriksgata.wc3ts.src.index")
local Frame = _____2A.Frame
local FRAME_ALIGN_BOTTOM = _____2A.FRAME_ALIGN_BOTTOM
local FRAME_ALIGN_CENTER = _____2A.FRAME_ALIGN_CENTER
local FRAME_ALIGN_LEFT_TOP = _____2A.FRAME_ALIGN_LEFT_TOP
local FRAME_ALIGN_RIGHT_BOTTOM = _____2A.FRAME_ALIGN_RIGHT_BOTTOM
local FRAME_ALIGN_TOP = _____2A.FRAME_ALIGN_TOP
local MapPlayer = _____2A.MapPlayer
local UNIT_TYPE_DEAD = _____2A.UNIT_TYPE_DEAD
local ____CameraControl = require("src.utils.CameraControl")
local CameraControl = ____CameraControl.CameraControl
local ____helper = require("src.utils.helper")
local worldToScreen = ____helper.worldToScreen
local ____logger = require("src.utils.logger")
local createLogger = ____logger.createLogger
local log = createLogger("UnitBlood")
____exports.UnitBlood = __TS__Class()
local UnitBlood = ____exports.UnitBlood
UnitBlood.name = "UnitBlood"
function UnitBlood.prototype.____constructor(self, actor)
    self.actor = actor
    self.frame = Frame:createType(
        "UnitBloodFrame_" .. tostring(actor.id),
        Frame:fromHandle(DzGetGameUI()),
        0,
        "BACKDROP",
        ""
    )
    self.frame:setSize(130 / 2400, 28 / 1800)
    self.frame:setTexture("Texture\\ui\\hpbar\\01.tga", 0, false)
    self.frame:setVisible(true)
    self.lifeFrame = Frame:createType(
        "LifeFrame_" .. tostring(actor.id),
        self.frame,
        0,
        "BACKDROP",
        ""
    )
    self.lifeFrame:setSize(100 / 2400, 12 / 1800)
    self.lifeFrame:setTexture("Texture\\ui\\hpbar\\02.tga", 0, false)
    self.lifeFrame:setPoint(
        FRAME_ALIGN_LEFT_TOP,
        self.frame,
        FRAME_ALIGN_LEFT_TOP,
        26 / 2400,
        -4 / 1800
    )
    self.shieldFrame = Frame:createType(
        "ShieldFrame_" .. tostring(actor.id),
        self.frame,
        0,
        "BACKDROP",
        ""
    )
    self.shieldFrame:setSize(100 / 2400, 12 / 1800)
    self.shieldFrame:setTexture("Texture\\ui\\hpbar\\huduntiao.tga", 0, false)
    self.shieldFrame:setPoint(
        FRAME_ALIGN_LEFT_TOP,
        self.frame,
        FRAME_ALIGN_LEFT_TOP,
        26 / 2400,
        -4 / 1800
    )
    self.shieldFrame:setVisible(false)
    self.manaFrame = Frame:createType(
        "ManaFrame_" .. tostring(actor.id),
        self.frame,
        0,
        "BACKDROP",
        ""
    )
    self.manaFrame:setSize(100 / 2400, 8 / 1800)
    self.manaFrame:setTexture("Texture\\ui\\hpbar\\03.tga", 0, false)
    self.manaFrame:setPoint(
        FRAME_ALIGN_LEFT_TOP,
        self.frame,
        FRAME_ALIGN_LEFT_TOP,
        26 / 2400,
        -18 / 1800
    )
    self.levelFrame = Frame:createType(
        "LevelFrame_" .. tostring(actor.id),
        self.frame,
        0,
        "TEXT",
        ""
    )
    self.levelFrame:setTextAlignment(50, 0)
    self.levelFrame:setText(tostring(actor.level))
    self.levelFrame:setFont("resource\\Texture\\ui\\hpbar\\ZiTi.TTf", 1, 0)
    self.levelFrame:setPoint(
        FRAME_ALIGN_CENTER,
        self.frame,
        FRAME_ALIGN_LEFT_TOP,
        14 / 2400,
        -14 / 1800
    )
    self.nameBoxFrame = Frame:createType(
        "NameBoxFrame_" .. tostring(actor.id),
        self.frame,
        0,
        "BACKDROP",
        ""
    )
    self.nameBoxFrame:setTexture("Texture\\ui\\hpbar\\07.tga", 0, false)
    self.nameBoxFrame.alpha = 75
    self.nameFrame = Frame:createType(
        "NameFrame_" .. tostring(actor.id),
        self.nameBoxFrame,
        0,
        "TEXT",
        ""
    )
    self.nameFrame:setText(actor:getLabel())
    self.nameFrame:setTextAlignment(18, 0)
    self.nameFrame:setFont("resource\\Texture\\ui\\hpbar\\ZiTi.TTf", 1, 0)
    self.nameFrame.alpha = 255
    self.nameFrame:setPoint(
        FRAME_ALIGN_BOTTOM,
        self.frame,
        FRAME_ALIGN_TOP,
        0.003,
        10 / 1800
    )
    self.nameBoxFrame:setPoint(
        FRAME_ALIGN_LEFT_TOP,
        self.nameFrame,
        FRAME_ALIGN_LEFT_TOP,
        -0.003,
        0.004
    )
    self.nameBoxFrame:setPoint(
        FRAME_ALIGN_RIGHT_BOTTOM,
        self.nameFrame,
        FRAME_ALIGN_RIGHT_BOTTOM,
        0.004,
        -0.004
    )
    if actor.owner == MapPlayer:fromLocal() then
        self.lifeFrame:setTexture("Texture\\ui\\hpbar\\02.tga", 0, false)
    else
        if actor:isAlly(MapPlayer:fromLocal()) then
            self.lifeFrame:setTexture("Texture\\ui\\hpbar\\06.tga", 0, false)
        else
            self.lifeFrame:setTexture("Texture\\ui\\hpbar\\05.tga", 0, false)
        end
    end
    ____exports.UnitBlood.allUnitBlood:set(actor.id, self)
end
function UnitBlood.create(self, actor)
    local existing = ____exports.UnitBlood.allUnitBlood:get(actor.id)
    if existing ~= nil then
        return existing
    end
    return __TS__New(____exports.UnitBlood, actor)
end
function UnitBlood.get(self, unit)
    return ____exports.UnitBlood.allUnitBlood:get(unit.id)
end
function UnitBlood.remove(self, unit)
    local unitBlood = ____exports.UnitBlood.allUnitBlood:get(unit.id)
    if unitBlood ~= nil then
        unitBlood:destroy()
        ____exports.UnitBlood.allUnitBlood:delete(unit.id)
    end
end
function UnitBlood.prototype.destroy(self)
    self.frame:destroy()
    ____exports.UnitBlood.allUnitBlood:delete(self.actor.id)
end
function UnitBlood.registerLocalDrawEvent(self)
    if ____exports.UnitBlood.isDrawEventRegistered then
        log:warn("绘制事件已经注册过，重复调用被忽略")
        return false
    end
    ____exports.UnitBlood.isDrawEventRegistered = true
    DzFrameSetUpdateCallbackByCode(function()
        CameraControl:update()
        ____exports.UnitBlood:updateAllUnitBloods()
    end)
    log:info("绘制事件注册成功")
    return true
end
function UnitBlood.isRegistered(self)
    return ____exports.UnitBlood.isDrawEventRegistered
end
function UnitBlood.updateAllUnitBloods(self)
    for ____, unitBlood in __TS__Iterator(____exports.UnitBlood.allUnitBlood:values()) do
        unitBlood:updateUI()
    end
end
function UnitBlood.prototype.updateUI(self)
    if not self.actor or self.actor.handle == nil or self.actor.id == 0 then
        self:destroy()
        return
    end
    if self.actor.life <= 0 then
        self.frame:setVisible(false)
        return
    end
    self:updateLifeBar()
    self:updateManaBar()
    self:updateShieldBar()
    self:updatePosition()
    self.levelFrame:setText(tostring(self.actor.level))
    local scale = 1 - (CameraControl:getViewLevel() - 8) * 0.1
    self:setScale(scale)
end
function UnitBlood.prototype.updateLifeBar(self)
    local maxLife = self.actor.maxLife
    local lifePercent = maxLife > 0 and self.actor.life / maxLife or 0
    self.lifeFrame:setSize(100 / 2400 * lifePercent, 12 / 1800)
end
function UnitBlood.prototype.updateManaBar(self)
    local maxMana = self.actor.maxMana
    local manaPercent = maxMana > 0 and self.actor.mana / maxMana or 0
    self.manaFrame:setSize(100 / 2400 * manaPercent, 8 / 1800)
end
function UnitBlood.prototype.updateShieldBar(self)
    local shieldPercent = self.actor.shieldPercent
    if shieldPercent <= 0 then
        if DzFrameIsVisible(self.shieldFrame.handle) then
            self.shieldFrame:setVisible(false)
        end
        return
    end
    if not DzFrameIsVisible(self.shieldFrame.handle) then
        self.shieldFrame:setVisible(true)
    end
    local clamped = math.max(
        0,
        math.min(shieldPercent, 1)
    )
    self.shieldFrame:setSize(100 / 2400 * clamped, 12 / 1800)
end
function UnitBlood.prototype.updatePosition(self)
    local unitX = self.actor.x
    local unitY = self.actor.y
    local unitHeightOffset = self.actor.hpBarUIHeight * self.actor.size
    local screenPos = worldToScreen(unitX - 30, unitY + unitHeightOffset, 0)
    if screenPos.screenY >= 1000 / 1800 or screenPos.screenY <= 300 / 1800 or self.actor.life < 0.05 or self.actor:isUnitType(UNIT_TYPE_DEAD()) or screenPos.screenX >= 1850 / 2400 or screenPos.screenX <= 70 / 2400 then
        self.frame:setVisible(false)
        return
    end
    if self.actor == nil or self.actor.id == 0 then
        self:destroy()
        return
    end
    if DzFrameIsVisible(self.frame.handle) == false then
        self.frame:setVisible(true)
    end
    self.frame:setAbsPoint(FRAME_ALIGN_BOTTOM, screenPos.screenX, screenPos.screenY)
end
function UnitBlood.prototype.setScale(self, scale)
    self.frame:setScale(scale)
    self.lifeFrame:setScale(scale)
    self.manaFrame:setScale(scale)
    self.shieldFrame:setScale(scale)
    self.nameBoxFrame:setScale(scale)
    self.levelFrame:setFont("resource\\Texture\\ui\\hpbar\\ZiTi.TTf", 0.01 * scale, 0)
    self.nameFrame:setFont("resource\\Texture\\ui\\hpbar\\ZiTi.TTf", 0.01 * scale, 0)
end
UnitBlood.allUnitBlood = __TS__New(Map)
UnitBlood.isDrawEventRegistered = false
return ____exports

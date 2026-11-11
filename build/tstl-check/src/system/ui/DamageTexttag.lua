local ____lualib = require("lualib_bundle")
local __TS__Class = ____lualib.__TS__Class
local __TS__StringAccess = ____lualib.__TS__StringAccess
local __TS__ParseInt = ____lualib.__TS__ParseInt
local __TS__New = ____lualib.__TS__New
local ____exports = {}
local _____2A = require("lua_modules.@eiriksgata.wc3ts.src.index")
local Frame = _____2A.Frame
local FRAME_ALIGN_BOTTOM = _____2A.FRAME_ALIGN_BOTTOM
local Timer = _____2A.Timer
local ____helper = require("src.utils.helper")
local worldToScreen = ____helper.worldToScreen
local ____ScreenCoordinates = require("src.system.ui.ScreenCoordinates")
local ScreenCoordinates = ____ScreenCoordinates.ScreenCoordinates
local ____logger = require("src.utils.logger")
local createLogger = ____logger.createLogger
local poolLog = createLogger("DamageTextPool")
local managerLog = createLogger("DamageTextManager")
--- 漂浮方向
____exports.FloatDirection = ____exports.FloatDirection or ({})
____exports.FloatDirection.UP = "UP"
____exports.FloatDirection.DOWN = "DOWN"
____exports.FloatDirection.LEFT = "LEFT"
____exports.FloatDirection.RIGHT = "RIGHT"
____exports.FloatDirection.NONE = "NONE"
--- 单个伤害文字实例
local DamageText = __TS__Class()
DamageText.name = "DamageText"
function DamageText.prototype.____constructor(self, maxDigits)
    if maxDigits == nil then
        maxDigits = 8
    end
    self.containerFrame = nil
    self.digitFrames = {}
    self.isActive = false
    self.damage = 0
    self.worldX = 0
    self.worldY = 0
    self.height = 0
    self.direction = ____exports.FloatDirection.UP
    self.speed = 100
    self.duration = 1.5
    self.scale = 0.8
    self.fadeOut = true
    self.elapsedTime = 0
    self.offsetX = 0
    self.offsetY = 0
    self.currentAlpha = 255
    self.color = "gray"
    self.containerFrame = Frame:createType(
        "DamageTextContainer_" .. tostring(GetRandomInt(0, 999999)),
        Frame:fromHandle(DzGetGameUI()),
        0,
        "BACKDROP",
        ""
    )
    self.containerFrame:setTexture("Texture\\ui\\dmg\\transparent.tga", 0, true)
    local containerWidth = DamageText.DIGIT_WIDTH * maxDigits / DamageText.STANDARD_WIDTH
    local containerHeight = DamageText.DIGIT_HEIGHT / DamageText.STANDARD_HEIGHT
    self.containerFrame:setSize(containerWidth * ScreenCoordinates.WC3_SCREEN_WIDTH, containerHeight * ScreenCoordinates.WC3_SCREEN_HEIGHT)
    do
        local i = 0
        while i < maxDigits do
            local digitFrame = Frame:createType(
                (("DamageDigit_" .. tostring(GetRandomInt(0, 999999))) .. "_") .. tostring(i),
                self.containerFrame,
                0,
                "BACKDROP",
                ""
            )
            digitFrame:setVisible(false)
            local ____self_digitFrames_0 = self.digitFrames
            ____self_digitFrames_0[#____self_digitFrames_0 + 1] = digitFrame
            i = i + 1
        end
    end
    self.containerFrame:setVisible(false)
end
function DamageText.prototype.show(self, config)
    self.damage = config.damage
    self.worldX = config.worldX
    self.worldY = config.worldY
    self.height = config.height or 0
    self.direction = config.direction or ____exports.FloatDirection.UP
    self.speed = config.speed or 100
    self.duration = config.duration or 1.5
    self.scale = config.scale or 0.8
    local ____temp_1
    if config.fadeOut ~= nil then
        ____temp_1 = config.fadeOut
    else
        ____temp_1 = true
    end
    self.fadeOut = ____temp_1
    self.color = config.color or "gray"
    self.elapsedTime = 0
    self.offsetX = 0
    self.offsetY = 0
    self.currentAlpha = 255
    self.isActive = true
    self:setupDigits()
    self.containerFrame:setVisible(true)
    self:updatePosition()
end
function DamageText.prototype.setupDigits(self)
    local damageStr = tostring(math.floor(math.abs(self.damage)))
    local digitCount = #damageStr
    local scaledWidth = DamageText.DIGIT_WIDTH * self.scale / DamageText.STANDARD_WIDTH * ScreenCoordinates.WC3_SCREEN_WIDTH
    local scaledHeight = DamageText.DIGIT_HEIGHT * self.scale / DamageText.STANDARD_HEIGHT * ScreenCoordinates.WC3_SCREEN_HEIGHT
    local scaledSpacing = DamageText.DIGIT_SPACING * self.scale / DamageText.STANDARD_WIDTH * ScreenCoordinates.WC3_SCREEN_WIDTH
    local stepWidth = scaledWidth + scaledSpacing
    local totalWidth = stepWidth * digitCount
    do
        local i = 0
        while i < #self.digitFrames do
            if i < digitCount then
                local digit = __TS__ParseInt(__TS__StringAccess(damageStr, i))
                local digitFrame = self.digitFrames[i + 1]
                digitFrame:setTexture(
                    ((("Texture\\ui\\dmg\\" .. self.color) .. "\\") .. tostring(digit)) .. ".tga",
                    0,
                    true
                )
                digitFrame:setSize(scaledWidth, scaledHeight)
                local xOffset = i * stepWidth - totalWidth / 2
                digitFrame:clearPoints()
                digitFrame:setPoint(
                    FRAME_ALIGN_BOTTOM,
                    self.containerFrame,
                    FRAME_ALIGN_BOTTOM,
                    xOffset,
                    0
                )
                digitFrame:setAlpha(255)
                digitFrame:setVisible(true)
            else
                self.digitFrames[i + 1]:setVisible(false)
            end
            i = i + 1
        end
    end
end
function DamageText.prototype.update(self, deltaTime)
    if not self.isActive then
        return
    end
    self.elapsedTime = self.elapsedTime + deltaTime
    if self.elapsedTime >= self.duration then
        self:hide()
        return
    end
    self:updateOffset(deltaTime)
    if self.fadeOut then
        local progress = self.elapsedTime / self.duration
        if progress > 0.7 then
            local fadeProgress = (progress - 0.7) / 0.3
            self.currentAlpha = 255 * (1 - fadeProgress)
            for ____, digitFrame in ipairs(self.digitFrames) do
                if digitFrame.visible then
                    digitFrame:setAlpha(math.floor(self.currentAlpha))
                end
            end
        end
    end
    self:updatePosition()
end
function DamageText.prototype.updateOffset(self, deltaTime)
    local moveDistance = self.speed * deltaTime
    repeat
        local ____switch20 = self.direction
        local ____cond20 = ____switch20 == ____exports.FloatDirection.UP
        if ____cond20 then
            self.offsetY = self.offsetY + moveDistance
            break
        end
        ____cond20 = ____cond20 or ____switch20 == ____exports.FloatDirection.DOWN
        if ____cond20 then
            self.offsetY = self.offsetY - moveDistance
            break
        end
        ____cond20 = ____cond20 or ____switch20 == ____exports.FloatDirection.LEFT
        if ____cond20 then
            self.offsetX = self.offsetX - moveDistance
            break
        end
        ____cond20 = ____cond20 or ____switch20 == ____exports.FloatDirection.RIGHT
        if ____cond20 then
            self.offsetX = self.offsetX + moveDistance
            break
        end
        ____cond20 = ____cond20 or ____switch20 == ____exports.FloatDirection.NONE
        if ____cond20 then
            break
        end
    until true
end
function DamageText.prototype.updatePosition(self)
    local screenPos = worldToScreen(self.worldX, self.worldY, self.height)
    local offsetXScreen = self.offsetX / DamageText.STANDARD_WIDTH * ScreenCoordinates.WC3_SCREEN_WIDTH
    local offsetYScreen = self.offsetY / DamageText.STANDARD_HEIGHT * ScreenCoordinates.WC3_SCREEN_HEIGHT
    local finalX = screenPos.screenX + offsetXScreen
    local finalY = screenPos.screenY + offsetYScreen
    if self:isOffScreen(finalX, finalY) then
        self.containerFrame:setVisible(false)
        return
    end
    if not self.containerFrame.visible then
        self.containerFrame:setVisible(true)
    end
    self.containerFrame:clearPoints()
    self.containerFrame:setAbsPoint(FRAME_ALIGN_BOTTOM, finalX, finalY)
end
function DamageText.prototype.isOffScreen(self, screenX, screenY)
    return screenY >= 1000 / 1800 or screenY <= 300 / 1800 or screenX >= 1850 / 2400 or screenX <= 70 / 2400
end
function DamageText.prototype.hide(self)
    self.isActive = false
    self.containerFrame:setVisible(false)
    for ____, digitFrame in ipairs(self.digitFrames) do
        digitFrame:setVisible(false)
    end
end
function DamageText.prototype.active(self)
    return self.isActive
end
function DamageText.prototype.destroy(self)
    if self.containerFrame then
        self.containerFrame:destroy()
        self.containerFrame = nil
    end
    self.digitFrames = {}
end
DamageText.DIGIT_WIDTH = 40
DamageText.DIGIT_HEIGHT = 64
DamageText.DIGIT_SPACING = -12
DamageText.STANDARD_WIDTH = 1920
DamageText.STANDARD_HEIGHT = 1080
--- 伤害文字对象池
____exports.DamageTextPool = __TS__Class()
local DamageTextPool = ____exports.DamageTextPool
DamageTextPool.name = "DamageTextPool"
function DamageTextPool.prototype.____constructor(self, poolSize)
    if poolSize == nil then
        poolSize = 30
    end
    self.pool = {}
    self.updateTimer = nil
    self.lastUpdateTime = 0
    self.poolSize = poolSize
    self:initializePool()
    self:startUpdateTimer()
end
function DamageTextPool.prototype.initializePool(self)
    do
        local i = 0
        while i < self.poolSize do
            local ____self_pool_2 = self.pool
            ____self_pool_2[#____self_pool_2 + 1] = __TS__New(DamageText, 8)
            i = i + 1
        end
    end
    poolLog:info(("初始化了 " .. tostring(self.poolSize)) .. " 个伤害文字对象")
end
function DamageTextPool.prototype.startUpdateTimer(self)
    self.updateTimer = Timer:create()
    self.updateTimer:start(
        0.02,
        true,
        function()
            local deltaTime = 0.02
            self:updateAll(deltaTime)
        end
    )
end
function DamageTextPool.prototype.updateAll(self, deltaTime)
    for ____, damageText in ipairs(self.pool) do
        if damageText:active() then
            damageText:update(deltaTime)
        end
    end
end
function DamageTextPool.prototype.acquire(self)
    for ____, damageText in ipairs(self.pool) do
        if not damageText:active() then
            return damageText
        end
    end
    return nil
end
function DamageTextPool.prototype.show(self, config)
    local damageText = self:acquire()
    if not damageText then
        return false
    end
    damageText:show(config)
    return true
end
function DamageTextPool.prototype.clear(self)
    for ____, damageText in ipairs(self.pool) do
        if damageText:active() then
            damageText:hide()
        end
    end
end
function DamageTextPool.prototype.destroy(self)
    if self.updateTimer then
        self.updateTimer:destroy()
        self.updateTimer = nil
    end
    for ____, damageText in ipairs(self.pool) do
        damageText:destroy()
    end
    self.pool = {}
end
--- 全局伤害文字管理器（单例）
____exports.DamageTextManager = __TS__Class()
local DamageTextManager = ____exports.DamageTextManager
DamageTextManager.name = "DamageTextManager"
function DamageTextManager.prototype.____constructor(self, poolSize)
    if poolSize == nil then
        poolSize = 30
    end
    self.pool = __TS__New(____exports.DamageTextPool, poolSize)
end
function DamageTextManager.getInstance(self, poolSize)
    if poolSize == nil then
        poolSize = 30
    end
    if not ____exports.DamageTextManager.instance then
        ____exports.DamageTextManager.instance = __TS__New(____exports.DamageTextManager, poolSize)
        managerLog:info("单例已创建")
    end
    return ____exports.DamageTextManager.instance
end
function DamageTextManager.show(self, config)
    return ____exports.DamageTextManager:getInstance().pool:show(config)
end
function DamageTextManager.showDamage(self, damage, worldX, worldY, height)
    if height == nil then
        height = 100
    end
    return ____exports.DamageTextManager:show({
        damage = damage,
        worldX = worldX,
        worldY = worldY,
        height = height,
        direction = ____exports.FloatDirection.UP,
        speed = 80,
        duration = 1.5,
        scale = 0.8,
        fadeOut = true
    })
end
function DamageTextManager.prototype.clear(self)
    self.pool:clear()
end
function DamageTextManager.prototype.destroy(self)
    self.pool:destroy()
    ____exports.DamageTextManager.instance = nil
end
DamageTextManager.instance = nil
return ____exports

local ____lualib = require("lualib_bundle")
local __TS__Class = ____lualib.__TS__Class
local __TS__New = ____lualib.__TS__New
local __TS__ArrayFilter = ____lualib.__TS__ArrayFilter
local __TS__ArrayIndexOf = ____lualib.__TS__ArrayIndexOf
local __TS__ArraySplice = ____lualib.__TS__ArraySplice
local ____exports = {}
local _____2A = require("lua_modules.@eiriksgata.wc3ts.src.index")
local MapPlayer = _____2A.MapPlayer
local ____ScreenCoordinates = require("src.system.ui.ScreenCoordinates")
local ScreenCoordinates = ____ScreenCoordinates.ScreenCoordinates
local ____Panel = require("src.system.ui.component.Panel")
local Panel = ____Panel.Panel
local ____Text = require("src.system.ui.component.Text")
local Text = ____Text.Text
local ____logger = require("src.utils.logger")
local createLogger = ____logger.createLogger
local log = createLogger("MessageList")
--- 消息项类 - 封装单条消息
local MessageItem = __TS__Class()
MessageItem.name = "MessageItem"
function MessageItem.prototype.____constructor(self, text, x, y, width, height, duration, color, origin, parent, targetPlayer)
    if color == nil then
        color = "FFFFFF"
    end
    self.elapsedTime = 0
    self.fadeTimer = nil
    self.isRemoving = false
    self.fadeStartTime = 0
    self.fadeAnimationDuration = 0.3
    self.currentAlpha = 255
    self.duration = duration
    self.targetY = y
    self.currentY = y
    self.currentAlpha = 255
    self.targetPlayer = targetPlayer
    self.textComponent = __TS__New(
        Text,
        text,
        x,
        y,
        width,
        height,
        origin
    )
    self.textComponent:setColor(color)
    self.textComponent:create(parent)
    self:updateVisibility()
end
function MessageItem.prototype.updateVisibility(self)
    if self.targetPlayer then
        local localPlayer = MapPlayer:fromLocal()
        if self.targetPlayer == localPlayer then
            self.textComponent:setVisible(true)
        else
            self.textComponent:setVisible(false)
        end
    else
        self.textComponent:setVisible(true)
    end
end
function MessageItem.prototype.update(self, deltaTime)
    if self.isRemoving then
        return
    end
    self.elapsedTime = self.elapsedTime + deltaTime
    if self.elapsedTime >= self.duration then
        self:startFadeOut()
        return
    end
    local fadeStartRatio = 0.7
    if self.elapsedTime >= self.duration * fadeStartRatio then
        if self.fadeStartTime == 0 then
            self.fadeStartTime = self.elapsedTime
        end
        self:updateFadeOut()
    end
end
function MessageItem.prototype.updateFadeOut(self)
    if self.isRemoving then
        return
    end
    local fadeProgress = (self.elapsedTime - self.fadeStartTime) / (self.duration * 0.3)
    if fadeProgress >= 1 then
        self.isRemoving = true
        self.currentAlpha = 0
        self.textComponent:setAlpha(0)
    else
        local alpha = math.floor(255 * (1 - fadeProgress))
        self.currentAlpha = alpha
        self.textComponent:setAlpha(alpha)
    end
end
function MessageItem.prototype.startFadeOut(self)
    if self.isRemoving then
        return
    end
    self.isRemoving = true
    local startAlpha = self.currentAlpha
    local targetAlpha = 0
    local interval = 0.01
    local totalSteps = math.ceil(self.fadeAnimationDuration / interval)
    local step = 0
    if self.fadeTimer then
        PauseTimer(self.fadeTimer)
        DestroyTimer(self.fadeTimer)
    end
    self.fadeTimer = CreateTimer()
    TimerStart(
        self.fadeTimer,
        interval,
        true,
        function()
            step = step + 1
            local progress = step / totalSteps
            if progress >= 1 then
                self.currentAlpha = 0
                self.textComponent:setAlpha(0)
                if self.fadeTimer then
                    PauseTimer(self.fadeTimer)
                    DestroyTimer(self.fadeTimer)
                    self.fadeTimer = nil
                end
                return
            end
            local eased = 1 - (1 - progress) ^ 3
            local alpha = math.floor(startAlpha + (targetAlpha - startAlpha) * eased)
            self.currentAlpha = alpha
            self.textComponent:setAlpha(alpha)
        end
    )
end
function MessageItem.prototype.setTargetY(self, y)
    self.targetY = y
end
function MessageItem.prototype.updatePosition(self, progress)
    local eased = 1 - (1 - progress) ^ 3
    local newY = self.currentY + (self.targetY - self.currentY) * eased
    self.textComponent:setPosition(
        self.textComponent:getPixelX(),
        newY
    )
end
function MessageItem.prototype.finishPositionAnimation(self)
    self.currentY = self.targetY
    self.textComponent:setPosition(
        self.textComponent:getPixelX(),
        self.targetY
    )
end
function MessageItem.prototype.destroy(self)
    if self.fadeTimer then
        PauseTimer(self.fadeTimer)
        DestroyTimer(self.fadeTimer)
        self.fadeTimer = nil
    end
    if self.textComponent ~= nil then
        self.textComponent:destroy()
    end
end
--- 消息列表组件
-- 用于显示类似游戏聊天/日志控制台的消息列表
-- 
-- 坐标说明：
-- - 默认使用 TOP_LEFT 坐标系（左上角为原点）
-- - x, y 参数表示 Panel 的左上角位置（像素坐标）
-- - 消息从底部向上排列，新消息添加在底部
-- 
-- @example ```typescript
-- // 在屏幕左下角创建消息列表（从底部300像素，高度300）
-- const messageList = new MessageList(100, 780, 400, 300); // y = 1080 - 300 = 780
-- messageList.create();
-- messageList.addMessage("玩家加入了游戏", 5, "00FF00");
-- 
-- // 或者使用 BOTTOM_LEFT 坐标系
-- const messageList2 = new MessageList(100, 300, 400, 300, { origin: ScreenCoordinates.ORIGIN_BOTTOM_LEFT });
-- messageList2.create();
-- ```
____exports.MessageList = __TS__Class()
local MessageList = ____exports.MessageList
MessageList.name = "MessageList"
function MessageList.prototype.____constructor(self, x, y, width, height, config)
    self.messages = {}
    self.animationTimer = nil
    self.isAnimating = false
    self.animationProgress = 0
    self.updateTimer = nil
    self.isCreated = false
    self.pixelX = x
    self.pixelY = y
    self.pixelWidth = width
    self.pixelHeight = height
    self.origin = config and config.origin or ScreenCoordinates.ORIGIN_TOP_LEFT
    self.messageHeight = config and config.messageHeight or 30
    self.messageSpacing = config and config.messageSpacing or 5
    self.maxMessages = config and config.maxMessages or 10
    self.defaultDuration = config and config.defaultDuration or 5
    self.slideAnimationDuration = config and config.slideAnimationDuration or 0.2
    self.fadeAnimationDuration = config and config.fadeAnimationDuration or 0.3
    self.panel = __TS__New(
        Panel,
        x,
        y,
        width,
        height,
        self.origin
    )
    if config and config.backgroundColor then
        self.panel:setBackground(config.backgroundColor)
    end
end
function MessageList.getInstance(self, x, y, width, height, config)
    if not ____exports.MessageList.instance then
        local defaultX = x or 300
        local defaultY = y or 200
        local defaultWidth = width or 400
        local defaultHeight = height or 300
        ____exports.MessageList.instance = __TS__New(
            ____exports.MessageList,
            defaultX,
            defaultY,
            defaultWidth,
            defaultHeight,
            config
        )
    end
    return ____exports.MessageList.instance
end
function MessageList.createInstance(self, x, y, width, height, config, parent)
    local instance = ____exports.MessageList:getInstance(
        x,
        y,
        width,
        height,
        config
    )
    if not instance.isCreated then
        instance:create(parent)
    end
    return instance
end
function MessageList.prototype.create(self, parent)
    if self.isCreated then
        log:info("already created")
        return
    end
    self.panel:create(parent)
    self.updateTimer = CreateTimer()
    TimerStart(
        self.updateTimer,
        0.1,
        true,
        function()
            self:update(0.1)
        end
    )
    self.isCreated = true
end
function MessageList.prototype.addMessage(self, text, duration, color, player)
    local messageDuration = duration ~= nil and duration or self.defaultDuration
    local messageColor = color or "FFFFFF"
    if #self.messages >= self.maxMessages then
        local oldestMessage = self.messages[1]
        self:removeMessage(oldestMessage)
    end
    local contentFrame = self.panel:getContentFrame()
    if not contentFrame then
        return
    end
    local contentPos = self.panel:getContentPosition()
    local contentSize = self.panel:getContentSize()
    local contentPosX = contentPos.x
    local contentPosY = contentPos.y
    local contentSizeWidth = contentSize.width
    local contentSizeHeight = contentSize.height
    local baseY = contentPosY + contentSizeHeight - self.messageHeight
    local newMessageX = contentPosX
    local newMessageY = baseY
    local messageWidth = contentSizeWidth
    local newMessage = __TS__New(
        MessageItem,
        text,
        newMessageX,
        newMessageY,
        messageWidth,
        self.messageHeight,
        messageDuration,
        messageColor,
        self.origin,
        contentFrame,
        player
    )
    local ____self_messages_16 = self.messages
    ____self_messages_16[#____self_messages_16 + 1] = newMessage
    self:updateAllMessageTargetPositions()
    self:startPositionAnimation()
end
function MessageList.prototype.updateAllMessageTargetPositions(self)
    local contentPos = self.panel:getContentPosition()
    local contentSize = self.panel:getContentSize()
    local baseY = contentPos.y + contentSize.height - self.messageHeight
    local messageX = contentPos.x
    local visibleMessages = __TS__ArrayFilter(
        self.messages,
        function(____, msg) return msg.textComponent:getVisible() end
    )
    local visibleIndex = 0
    do
        local i = 0
        while i < #self.messages do
            local message = self.messages[i + 1]
            local isVisible = message.textComponent:getVisible()
            if isVisible then
                local targetY = baseY - (#visibleMessages - 1 - visibleIndex) * (self.messageHeight + self.messageSpacing)
                message:setTargetY(targetY)
                message.textComponent:setPosition(
                    messageX,
                    message.textComponent:getPixelY()
                )
                message.textComponent:setSize(contentSize.width, self.messageHeight)
                visibleIndex = visibleIndex + 1
            else
            end
            i = i + 1
        end
    end
end
function MessageList.prototype.startPositionAnimation(self)
    if self.isAnimating then
        return
    end
    self.isAnimating = true
    self.animationProgress = 0
    local interval = 0.01
    local totalSteps = math.ceil(self.slideAnimationDuration / interval)
    if self.animationTimer then
        PauseTimer(self.animationTimer)
        DestroyTimer(self.animationTimer)
    end
    self.animationTimer = CreateTimer()
    TimerStart(
        self.animationTimer,
        interval,
        true,
        function()
            self.animationProgress = self.animationProgress + 1 / totalSteps
            if self.animationProgress >= 1 then
                self.animationProgress = 1
                self:finishPositionAnimation()
                self.isAnimating = false
                if self.animationTimer then
                    PauseTimer(self.animationTimer)
                    DestroyTimer(self.animationTimer)
                    self.animationTimer = nil
                end
                return
            end
            for ____, message in ipairs(self.messages) do
                message:updatePosition(self.animationProgress)
            end
        end
    )
end
function MessageList.prototype.finishPositionAnimation(self)
    for ____, message in ipairs(self.messages) do
        if message.textComponent:getVisible() then
            message:finishPositionAnimation()
        end
    end
end
function MessageList.prototype.removeMessage(self, message)
    local index = __TS__ArrayIndexOf(self.messages, message)
    if index == -1 then
        return
    end
    message:destroy()
    __TS__ArraySplice(self.messages, index, 1)
    self:updateAllMessageTargetPositions()
    self:startPositionAnimation()
end
function MessageList.prototype.update(self, deltaTime)
    local messagesToRemove = {}
    for ____, message in ipairs(self.messages) do
        message:update(deltaTime)
        if message.isRemoving and message.fadeTimer == nil then
            messagesToRemove[#messagesToRemove + 1] = message
        end
    end
    for ____, message in ipairs(messagesToRemove) do
        self:removeMessage(message)
    end
end
function MessageList.prototype.clear(self)
    for ____, message in ipairs(self.messages) do
        message:destroy()
    end
    self.messages = {}
end
function MessageList.prototype.setPosition(self, x, y)
    self.pixelX = x
    self.pixelY = y
    self.panel:setPosition(x, y)
    self:updateAllMessageTargetPositions()
    self:startPositionAnimation()
    return self
end
function MessageList.prototype.getPosition(self)
    return {x = self.pixelX, y = self.pixelY}
end
function MessageList.prototype.setSize(self, width, height)
    self.pixelWidth = width
    self.pixelHeight = height
    self.panel:setSize(width, height)
    self:updateAllMessageTargetPositions()
    self:startPositionAnimation()
    return self
end
function MessageList.prototype.getSize(self)
    return {width = self.pixelWidth, height = self.pixelHeight}
end
function MessageList.prototype.setVisible(self, visible)
    self.panel:setVisible(visible)
    return self
end
function MessageList.prototype.getVisible(self)
    return self.panel:getVisible()
end
function MessageList.prototype.show(self)
    return self:setVisible(true)
end
function MessageList.prototype.hide(self)
    return self:setVisible(false)
end
function MessageList.prototype.getMessageCount(self)
    return #self.messages
end
function MessageList.prototype.destroy(self)
    if self.updateTimer then
        PauseTimer(self.updateTimer)
        DestroyTimer(self.updateTimer)
        self.updateTimer = nil
    end
    if self.animationTimer then
        PauseTimer(self.animationTimer)
        DestroyTimer(self.animationTimer)
        self.animationTimer = nil
    end
    self:clear()
    if self.panel ~= nil then
        self.panel:destroy()
    end
    self.isCreated = false
end
function MessageList.resetInstance(self)
    if ____exports.MessageList.instance then
        ____exports.MessageList.instance:destroy()
        ____exports.MessageList.instance = nil
    end
end
MessageList.instance = nil
return ____exports

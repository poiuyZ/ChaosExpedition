local ____lualib = require("lualib_bundle")
local __TS__Class = ____lualib.__TS__Class
local ____exports = {}
local ____ScreenCoordinates = require("src.system.ui.ScreenCoordinates")
local ScreenCoordinates = ____ScreenCoordinates.ScreenCoordinates
local ____MouseEvent = require("src.system.event.MouseEvent")
local MouseEventManager = ____MouseEvent.MouseEventManager
local ____logger = require("src.utils.logger")
local createLogger = ____logger.createLogger
local mixinLog = createLogger("DraggableMixin")
local log = createLogger("UIComponentBase")
--- 拖拽功能混入类
-- 可以被任何UI组件使用，无需继承
-- 
-- @example ```typescript
-- class MyComponent implements IDraggableComponent {
--   private draggable = new DraggableMixin(this);
--   
--   public setDraggable(enabled: boolean) {
--     this.draggable.setEnabled(enabled);
--   }
--   
--   public destroy() {
--     this.draggable.cleanup();
--   }
-- }
-- ```
____exports.DraggableMixin = __TS__Class()
local DraggableMixin = ____exports.DraggableMixin
DraggableMixin.name = "DraggableMixin"
function DraggableMixin.prototype.____constructor(self, component)
    self.isDraggableEnabled = false
    self.isDragging = false
    self.isMouseOver = false
    self.dragTimer = nil
    self.dragOffsetX = 0
    self.dragOffsetY = 0
    self.dragMouseDownId = -1
    self.dragMouseUpId = -1
    self.onDragStartCallback = nil
    self.onDragEndCallback = nil
    self.onDraggingCallback = nil
    self.component = component
end
function DraggableMixin.prototype.setEnabled(self, enabled)
    if self.isDraggableEnabled == enabled then
        return
    end
    self.isDraggableEnabled = enabled
    if enabled then
        self:setupDragEventListeners()
    else
        self:cleanupDragEventListeners()
    end
end
function DraggableMixin.prototype.getEnabled(self)
    return self.isDraggableEnabled
end
function DraggableMixin.prototype.getIsDragging(self)
    return self.isDragging
end
function DraggableMixin.prototype.setMouseOver(self, isOver)
    self.isMouseOver = isOver
end
function DraggableMixin.prototype.getIsMouseOver(self)
    return self.isMouseOver
end
function DraggableMixin.prototype.setOnDragStart(self, callback)
    self.onDragStartCallback = callback
end
function DraggableMixin.prototype.setOnDragEnd(self, callback)
    self.onDragEndCallback = callback
end
function DraggableMixin.prototype.setOnDragging(self, callback)
    self.onDraggingCallback = callback
end
function DraggableMixin.prototype.configure(self, config)
    if config.onDragStart then
        self.onDragStartCallback = config.onDragStart
    end
    if config.onDragEnd then
        self.onDragEndCallback = config.onDragEnd
    end
    if config.onDragging then
        self.onDraggingCallback = config.onDragging
    end
end
function DraggableMixin.prototype.cleanup(self)
    if self.isDragging then
        self:endDrag()
    end
    self:cleanupDragEventListeners()
    self.onDragStartCallback = nil
    self.onDragEndCallback = nil
    self.onDraggingCallback = nil
end
function DraggableMixin.prototype.getMousePixelX(self)
    local windowWidth = DzGetWindowWidth()
    local mouseRelativeX = DzGetMouseXRelative()
    return mouseRelativeX / windowWidth * ScreenCoordinates.STANDARD_WIDTH
end
function DraggableMixin.prototype.getMousePixelY(self)
    local windowHeight = DzGetWindowHeight()
    local mouseRelativeY = DzGetMouseYRelative()
    return mouseRelativeY / windowHeight * ScreenCoordinates.STANDARD_HEIGHT
end
function DraggableMixin.prototype.startDrag(self)
    if not self.isDraggableEnabled or self.isDragging then
        return
    end
    self.isDragging = true
    local currentMouseX = self:getMousePixelX()
    local currentMouseY = self:getMousePixelY()
    self.dragOffsetX = currentMouseX - self.component:getPixelX()
    self.dragOffsetY = currentMouseY - self.component:getPixelY()
    mixinLog:info("Drag started")
    if self.onDragStartCallback then
        self.onDragStartCallback()
    end
    self.dragTimer = CreateTimer()
    TimerStart(
        self.dragTimer,
        0.01,
        true,
        function()
            self:updateDragPosition()
        end
    )
    local mouseEvents = MouseEventManager:getInstance()
    self.dragMouseUpId = mouseEvents:onMouseUp(
        function()
            self:endDrag()
        end,
        1,
        {once = true}
    )
end
function DraggableMixin.prototype.updateDragPosition(self)
    if not self.isDragging then
        return
    end
    local currentMouseX = self:getMousePixelX()
    local currentMouseY = self:getMousePixelY()
    local newX = currentMouseX - self.dragOffsetX
    local newY = currentMouseY - self.dragOffsetY
    self.component:setPosition(newX, newY)
    if self.onDraggingCallback then
        self.onDraggingCallback(newX, newY)
    end
end
function DraggableMixin.prototype.endDrag(self)
    if not self.isDragging then
        return
    end
    self.isDragging = false
    if self.dragTimer then
        PauseTimer(self.dragTimer)
        DestroyTimer(self.dragTimer)
        self.dragTimer = nil
    end
    if self.dragMouseUpId >= 0 then
        local mouseEvents = MouseEventManager:getInstance()
        mouseEvents:off(self.dragMouseUpId)
        self.dragMouseUpId = -1
    end
    mixinLog:info("Drag ended")
    if self.onDragEndCallback then
        self.onDragEndCallback(
            self.component:getPixelX(),
            self.component:getPixelY()
        )
    end
end
function DraggableMixin.prototype.setupDragEventListeners(self)
    if self.dragMouseDownId >= 0 then
        return
    end
    local mouseEvents = MouseEventManager:getInstance()
    self.dragMouseDownId = mouseEvents:onMouseDown(
        function()
            if self.isMouseOver and self.isDraggableEnabled and not self.isDragging and self.component:getEnabled() then
                self:startDrag()
            end
        end,
        1
    )
end
function DraggableMixin.prototype.cleanupDragEventListeners(self)
    local mouseEvents = MouseEventManager:getInstance()
    if self.dragMouseDownId >= 0 then
        mouseEvents:off(self.dragMouseDownId)
        self.dragMouseDownId = -1
    end
    if self.dragMouseUpId >= 0 then
        mouseEvents:off(self.dragMouseUpId)
        self.dragMouseUpId = -1
    end
    if self.isDragging then
        self:endDrag()
    end
end
--- UI组件基类
-- 提供通用的位置、大小、可见性、拖拽等功能
-- 所有UI组件都应该继承此基类
-- 
-- @example ```typescript
-- class MyComponent extends UIComponentBase {
--   create(parent?: Frame): void { ... }
--   destroy(): void { ... }
--   protected getInteractiveFrame(): Frame | null { ... }
--   protected updateFramePositions(): void { ... }
-- }
-- 
-- const comp = new MyComponent(100, 100, 200, 50);
-- comp.create();
-- comp.setDraggable(true);  // 自动获得拖拽功能
-- ```
____exports.UIComponentBase = __TS__Class()
local UIComponentBase = ____exports.UIComponentBase
UIComponentBase.name = "UIComponentBase"
function UIComponentBase.prototype.____constructor(self, x, y, width, height, origin)
    if origin == nil then
        origin = ScreenCoordinates.ORIGIN_TOP_LEFT
    end
    self.isVisible = true
    self.isEnabled = true
    self.isDraggable = false
    self.isDragging = false
    self.dragTimer = nil
    self.dragOffsetX = 0
    self.dragOffsetY = 0
    self.dragMouseDownId = -1
    self.dragMouseUpId = -1
    self.isMouseOver = false
    self.onDragStartCallback = nil
    self.onDragEndCallback = nil
    self.onDraggingCallback = nil
    self.pixelX = x
    self.pixelY = y
    self.pixelWidth = width
    self.pixelHeight = height
    self.origin = origin
end
function UIComponentBase.prototype.setPosition(self, x, y)
    self.pixelX = x
    self.pixelY = y
    self:updateFramePositions()
    return self
end
function UIComponentBase.prototype.getPosition(self)
    return {x = self.pixelX, y = self.pixelY}
end
function UIComponentBase.prototype.getPixelX(self)
    return self.pixelX
end
function UIComponentBase.prototype.getPixelY(self)
    return self.pixelY
end
function UIComponentBase.prototype.setSize(self, width, height)
    self.pixelWidth = width
    self.pixelHeight = height
    self:updateFramePositions()
    return self
end
function UIComponentBase.prototype.getSize(self)
    return {width = self.pixelWidth, height = self.pixelHeight}
end
function UIComponentBase.prototype.getBounds(self)
    return {x = self.pixelX, y = self.pixelY, width = self.pixelWidth, height = self.pixelHeight}
end
function UIComponentBase.prototype.setVisible(self, visible)
    self.isVisible = visible
    return self
end
function UIComponentBase.prototype.getVisible(self)
    return self.isVisible
end
function UIComponentBase.prototype.show(self)
    return self:setVisible(true)
end
function UIComponentBase.prototype.hide(self)
    return self:setVisible(false)
end
function UIComponentBase.prototype.toggle(self)
    return self:setVisible(not self.isVisible)
end
function UIComponentBase.prototype.setEnabled(self, enabled)
    self.isEnabled = enabled
    return self
end
function UIComponentBase.prototype.getEnabled(self)
    return self.isEnabled
end
function UIComponentBase.prototype.pixelToWC3(self)
    return ScreenCoordinates:pixelToWC3(self.pixelX, self.pixelY, self.origin)
end
function UIComponentBase.prototype.getWC3Width(self)
    return self.pixelWidth / ScreenCoordinates.STANDARD_WIDTH * ScreenCoordinates.WC3_SCREEN_WIDTH
end
function UIComponentBase.prototype.getWC3Height(self)
    return self.pixelHeight / ScreenCoordinates.STANDARD_HEIGHT * ScreenCoordinates.WC3_SCREEN_HEIGHT
end
function UIComponentBase.prototype.getMousePixelX(self)
    local windowWidth = DzGetWindowWidth()
    local mouseRelativeX = DzGetMouseXRelative()
    return mouseRelativeX / windowWidth * ScreenCoordinates.STANDARD_WIDTH
end
function UIComponentBase.prototype.getMousePixelY(self)
    local windowHeight = DzGetWindowHeight()
    local mouseRelativeY = DzGetMouseYRelative()
    return mouseRelativeY / windowHeight * ScreenCoordinates.STANDARD_HEIGHT
end
function UIComponentBase.prototype.setDraggable(self, draggable)
    if self.isDraggable == draggable then
        return self
    end
    self.isDraggable = draggable
    if draggable then
        self:setupDragEventListeners()
    else
        self:cleanupDragEventListeners()
    end
    return self
end
function UIComponentBase.prototype.getDraggable(self)
    return self.isDraggable
end
function UIComponentBase.prototype.getIsDragging(self)
    return self.isDragging
end
function UIComponentBase.prototype.setOnDragStart(self, callback)
    self.onDragStartCallback = callback
    return self
end
function UIComponentBase.prototype.setOnDragEnd(self, callback)
    self.onDragEndCallback = callback
    return self
end
function UIComponentBase.prototype.setOnDragging(self, callback)
    self.onDraggingCallback = callback
    return self
end
function UIComponentBase.prototype.enableDrag(self, config)
    self:setDraggable(true)
    if config then
        if config.onDragStart then
            self:setOnDragStart(config.onDragStart)
        end
        if config.onDragEnd then
            self:setOnDragEnd(config.onDragEnd)
        end
        if config.onDragging then
            self:setOnDragging(config.onDragging)
        end
    end
    return self
end
function UIComponentBase.prototype.disableDrag(self)
    self:setDraggable(false)
    if self.isDragging then
        self:endDrag()
    end
    return self
end
function UIComponentBase.prototype.startDrag(self)
    if not self.isDraggable or self.isDragging then
        return
    end
    self.isDragging = true
    local currentMouseX = self:getMousePixelX()
    local currentMouseY = self:getMousePixelY()
    self.dragOffsetX = currentMouseX - self.pixelX
    self.dragOffsetY = currentMouseY - self.pixelY
    log:info(((("Drag started at mouse(" .. tostring(currentMouseX)) .. ", ") .. tostring(currentMouseY)) .. ")")
    if self.onDragStartCallback then
        self.onDragStartCallback()
    end
    self.dragTimer = CreateTimer()
    TimerStart(
        self.dragTimer,
        0.01,
        true,
        function()
            self:updateDragPosition()
        end
    )
    local mouseEvents = MouseEventManager:getInstance()
    self.dragMouseUpId = mouseEvents:onMouseUp(
        function()
            self:endDrag()
        end,
        1,
        {once = true}
    )
end
function UIComponentBase.prototype.updateDragPosition(self)
    if not self.isDragging then
        return
    end
    local currentMouseX = self:getMousePixelX()
    local currentMouseY = self:getMousePixelY()
    local newX = currentMouseX - self.dragOffsetX
    local newY = currentMouseY - self.dragOffsetY
    self:setPosition(newX, newY)
    if self.onDraggingCallback then
        self.onDraggingCallback(newX, newY)
    end
end
function UIComponentBase.prototype.endDrag(self)
    if not self.isDragging then
        return
    end
    self.isDragging = false
    if self.dragTimer then
        PauseTimer(self.dragTimer)
        DestroyTimer(self.dragTimer)
        self.dragTimer = nil
    end
    if self.dragMouseUpId >= 0 then
        local mouseEvents = MouseEventManager:getInstance()
        mouseEvents:off(self.dragMouseUpId)
        self.dragMouseUpId = -1
    end
    log:info(((("Drag ended at position(" .. tostring(self.pixelX)) .. ", ") .. tostring(self.pixelY)) .. ")")
    if self.onDragEndCallback then
        self.onDragEndCallback(self.pixelX, self.pixelY)
    end
end
function UIComponentBase.prototype.setupDragEventListeners(self)
    if self.dragMouseDownId >= 0 then
        return
    end
    local mouseEvents = MouseEventManager:getInstance()
    self.dragMouseDownId = mouseEvents:onMouseDown(
        function()
            if self.isMouseOver and self.isDraggable and not self.isDragging and self.isEnabled then
                self:startDrag()
            end
        end,
        1
    )
end
function UIComponentBase.prototype.cleanupDragEventListeners(self)
    local mouseEvents = MouseEventManager:getInstance()
    if self.dragMouseDownId >= 0 then
        mouseEvents:off(self.dragMouseDownId)
        self.dragMouseDownId = -1
    end
    if self.dragMouseUpId >= 0 then
        mouseEvents:off(self.dragMouseUpId)
        self.dragMouseUpId = -1
    end
    if self.isDragging then
        self:endDrag()
    end
end
function UIComponentBase.prototype.setMouseOver(self, isOver)
    self.isMouseOver = isOver
end
function UIComponentBase.prototype.getIsMouseOver(self)
    return self.isMouseOver
end
function UIComponentBase.prototype.setTag(self, tag)
    self.componentTag = tag
    return self
end
function UIComponentBase.prototype.getTag(self)
    return self.componentTag
end
function UIComponentBase.prototype.cleanupDrag(self)
    if self.isDragging then
        self:endDrag()
    end
    self:cleanupDragEventListeners()
    self.onDragStartCallback = nil
    self.onDragEndCallback = nil
    self.onDraggingCallback = nil
end
return ____exports

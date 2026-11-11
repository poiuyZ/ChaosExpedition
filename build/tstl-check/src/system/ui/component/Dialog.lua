local ____lualib = require("lualib_bundle")
local __TS__Class = ____lualib.__TS__Class
local __TS__New = ____lualib.__TS__New
local __TS__ArrayForEach = ____lualib.__TS__ArrayForEach
local Error = ____lualib.Error
local RangeError = ____lualib.RangeError
local ReferenceError = ____lualib.ReferenceError
local SyntaxError = ____lualib.SyntaxError
local TypeError = ____lualib.TypeError
local URIError = ____lualib.URIError
local __TS__ArraySplice = ____lualib.__TS__ArraySplice
local ____exports = {}
local ____Panel = require("src.system.ui.component.Panel")
local Panel = ____Panel.Panel
local ____Button = require("src.system.ui.component.Button")
local Button = ____Button.Button
local ____Text = require("src.system.ui.component.Text")
local Text = ____Text.Text
local TextColors = ____Text.TextColors
local ____preset = require("src.constants.ui.preset")
local UIBackgrounds = ____preset.UIBackgrounds
local ____logger = require("src.utils.logger")
local createLogger = ____logger.createLogger
local log = createLogger("Dialog")
--- Dialog 类 - 对话框组件
-- 继承自 Panel，提供标题和可动态添加按钮的对话框
-- 
-- @example ```typescript
-- // 创建对话框
-- const dialog = new Dialog("选择难度", 400, 300);
-- dialog.create();
-- 
-- // 添加按钮
-- dialog.addButton({
--   text: "简单",
--   onClick: () => {
--     print("选择了简单难度");
--     dialog.hide();
--   }
-- });
-- 
-- dialog.addButton({
--   text: "困难",
--   onClick: () => {
--     print("选择了困难难度");
--     dialog.hide();
--   }
-- });
-- 
-- // 显示对话框
-- dialog.show();
-- ```
____exports.Dialog = __TS__Class()
local Dialog = ____exports.Dialog
Dialog.name = "Dialog"
function Dialog.prototype.____constructor(self, title, width, height)
    if width == nil then
        width = 500
    end
    if height == nil then
        height = 300
    end
    self.titleText = nil
    self.buttons = {}
    self.buttonStartY = 70
    self.buttonSpacing = 65
    self.buttonHeight = 50
    self.buttonWidthRatio = 0.8
    self.isCreated = false
    self.userOnDragStart = nil
    self.userOnDragEnd = nil
    self.userOnDragging = nil
    self.title = title
    self.dialogWidth = width
    self.dialogHeight = height
    local centerX = (1920 - width) / 2
    local centerY = (1080 - height) / 2
    self.panel = __TS__New(
        Panel,
        centerX,
        centerY,
        width,
        height
    )
end
function Dialog.createCentered(self, title, width, height, parent)
    if width == nil then
        width = 500
    end
    if height == nil then
        height = 300
    end
    local dialog = __TS__New(____exports.Dialog, title, width, height)
    dialog:create(parent)
    return dialog
end
function Dialog.createConfirm(self, title, message, onYes, onNo, parent)
    local dialog = __TS__New(____exports.Dialog, title, 400, 250)
    dialog:create(parent)
    local contentPos = dialog:getContentPosition()
    local contentSize = dialog:getContentSize()
    local messageText = __TS__New(
        Text,
        message,
        contentPos.x + 30,
        contentPos.y + 20,
        contentSize.width - 60,
        60
    )
    messageText:create(dialog:getContentFrame())
    messageText:setColor(TextColors.WHITE):setAlignment(50, 50):setFontSizePixels(14)
    dialog:addButton({
        text = "是",
        onClick = function()
            onYes()
            dialog:hide()
        end,
        color = TextColors.GREEN
    })
    dialog:addButton({
        text = "否",
        onClick = function()
            if onNo then
                onNo()
            end
            dialog:hide()
        end,
        color = TextColors.RED
    })
    return dialog
end
function Dialog.createChoice(self, title, options, onSelect, parent)
    local height = math.min(300 + #options * 50, 700)
    local dialog = __TS__New(____exports.Dialog, title, 450, height)
    dialog:create(parent)
    __TS__ArrayForEach(
        options,
        function(____, option, index)
            dialog:addButton({
                text = option,
                onClick = function()
                    onSelect(index)
                    dialog:hide()
                end
            })
        end
    )
    return dialog
end
function Dialog.prototype.create(self, parent)
    if self.isCreated then
        return
    end
    self.panel:setTitle(self.title):setTitleColor(TextColors.BLACK):setShowTitleBar(true):setShowCloseButton(true):setBackground(UIBackgrounds.SHUIMO_STYLE_PANEL_BACKGROUND):setAlpha(240):setOnClose(function()
        self:hide()
    end)
    self.panel:create(parent)
    self.isCreated = true
end
function Dialog.prototype.addButton(self, config)
    if not self.isCreated then
        log:error("Dialog not created yet. Call create() first.")
        error(
            __TS__New(Error, "Dialog not created"),
            0
        )
    end
    local buttonIndex = #self.buttons
    local contentPos = self.panel:getContentPosition()
    local buttonWidth = self.dialogWidth * self.buttonWidthRatio
    local buttonX = contentPos.x + (self.dialogWidth - buttonWidth) / 2
    local buttonY = contentPos.y + self.buttonStartY + buttonIndex * self.buttonSpacing
    log:info((((("Creating button at absolute position: x=" .. tostring(buttonX)) .. ", y=") .. tostring(buttonY)) .. ", width=") .. tostring(buttonWidth))
    local button = Button:createWithTemplatePreset(
        config.text,
        buttonX,
        buttonY,
        buttonWidth,
        self.buttonHeight,
        "NORMAL_UP"
    )
    button:centerText()
    if config.color then
        button:setTextColor(config.color)
    end
    if config.onClick then
        button:setOnClick(config.onClick)
    end
    if config.onHover then
        button:setOnHover(config.onHover)
    end
    if config.onLeave then
        button:setOnLeave(config.onLeave)
    end
    if config.enabled ~= nil then
        button:setEnabled(config.enabled)
    end
    button:addHoverEffect(200, 255)
    button:setVisible(self:getVisible())
    local ____self_buttons_0 = self.buttons
    ____self_buttons_0[#____self_buttons_0 + 1] = button
    local requiredHeight = self.buttonStartY + (buttonIndex + 1) * self.buttonSpacing + 50
    if requiredHeight > self.dialogHeight then
        local newHeight = requiredHeight + 20
        self:setSize(self.dialogWidth, newHeight)
    end
    return button
end
function Dialog.prototype.getButton(self, index)
    return self.buttons[index + 1] or nil
end
function Dialog.prototype.getButtons(self)
    return self.buttons
end
function Dialog.prototype.removeButton(self, index)
    local button = self.buttons[index + 1]
    if button ~= nil then
        button:destroy()
        __TS__ArraySplice(self.buttons, index, 1)
        self:repositionButtons()
    end
end
function Dialog.prototype.clearButtons(self)
    __TS__ArrayForEach(
        self.buttons,
        function(____, button) return button:destroy() end
    )
    self.buttons = {}
end
function Dialog.prototype.repositionButtons(self)
    local contentPos = self.panel:getContentPosition()
    local buttonWidth = self.dialogWidth * self.buttonWidthRatio
    local buttonX = contentPos.x + (self.dialogWidth - buttonWidth) / 2
    __TS__ArrayForEach(
        self.buttons,
        function(____, button, index)
            local buttonY = contentPos.y + self.buttonStartY + index * self.buttonSpacing
            button:setPosition(buttonX, buttonY)
        end
    )
end
function Dialog.prototype.setButtonStartY(self, y)
    self.buttonStartY = y
    self:repositionButtons()
    return self
end
function Dialog.prototype.setButtonSpacing(self, spacing)
    self.buttonSpacing = spacing
    self:repositionButtons()
    return self
end
function Dialog.prototype.setButtonHeight(self, height)
    self.buttonHeight = height
    return self
end
function Dialog.prototype.setButtonWidthRatio(self, ratio)
    self.buttonWidthRatio = math.max(
        0.1,
        math.min(1, ratio)
    )
    self:repositionButtons()
    return self
end
function Dialog.prototype.setTitle(self, title)
    self.title = title
    self.panel:setTitle(title)
    return self
end
function Dialog.prototype.getTitle(self)
    return self.title
end
function Dialog.prototype.setPosition(self, x, y)
    self.panel:setPosition(x, y)
    self:repositionButtons()
    return self
end
function Dialog.prototype.setSize(self, width, height)
    self.dialogWidth = width
    self.dialogHeight = height
    self.panel:setSize(width, height)
    self:repositionButtons()
    return self
end
function Dialog.prototype.getPosition(self)
    return self.panel:getPosition()
end
function Dialog.prototype.getSize(self)
    return self.panel:getSize()
end
function Dialog.prototype.center(self)
    local centerX = (1920 - self.dialogWidth) / 2
    local centerY = (1080 - self.dialogHeight) / 2
    self.panel:setPosition(centerX, centerY)
    return self
end
function Dialog.prototype.setVisible(self, visible)
    self.panel:setVisible(visible)
    __TS__ArrayForEach(
        self.buttons,
        function(____, button) return button:setVisible(visible) end
    )
    return self
end
function Dialog.prototype.getVisible(self)
    return self.panel:getVisible()
end
function Dialog.prototype.show(self)
    return self:setVisible(true)
end
function Dialog.prototype.hide(self)
    return self:setVisible(false)
end
function Dialog.prototype.toggle(self)
    self.panel:toggle()
    return self
end
function Dialog.prototype.setBackground(self, texture)
    self.panel:setBackground(texture)
    return self
end
function Dialog.prototype.setAlpha(self, alpha)
    self.panel:setAlpha(alpha)
    return self
end
function Dialog.prototype.setTitleColor(self, hexColor)
    self.panel:setTitleColor(hexColor)
    return self
end
function Dialog.prototype.setShowTitleBar(self, show)
    self.panel:setShowTitleBar(show)
    return self
end
function Dialog.prototype.setShowCloseButton(self, show)
    self.panel:setShowCloseButton(show)
    return self
end
function Dialog.prototype.setDraggable(self, draggable)
    if draggable then
        self.panel:setOnDragStart(function()
            if self.userOnDragStart then
                self.userOnDragStart()
            end
        end)
        self.panel:setOnDragging(function(x, y)
            self:repositionButtons()
            if self.userOnDragging then
                self.userOnDragging(x, y)
            end
        end)
        self.panel:setOnDragEnd(function(x, y)
            self:repositionButtons()
            if self.userOnDragEnd then
                self.userOnDragEnd(x, y)
            end
        end)
    end
    self.panel:setDraggable(draggable)
    return self
end
function Dialog.prototype.getDraggable(self)
    return self.panel:getDraggable()
end
function Dialog.prototype.getIsDragging(self)
    return self.panel:getIsDragging()
end
function Dialog.prototype.setOnDragStart(self, callback)
    self.userOnDragStart = callback
    return self
end
function Dialog.prototype.setOnDragEnd(self, callback)
    self.userOnDragEnd = callback
    return self
end
function Dialog.prototype.setOnDragging(self, callback)
    self.userOnDragging = callback
    return self
end
function Dialog.prototype.getPanel(self)
    return self.panel
end
function Dialog.prototype.getContentFrame(self)
    return self.panel:getContentFrame()
end
function Dialog.prototype.getContentPosition(self)
    return self.panel:getContentPosition()
end
function Dialog.prototype.getContentSize(self)
    return self.panel:getContentSize()
end
function Dialog.prototype.configure(self, config)
    if config.title ~= nil then
        self:setTitle(config.title)
    end
    if config.titleColor ~= nil then
        self:setTitleColor(config.titleColor)
    end
    if config.showTitleBar ~= nil then
        self:setShowTitleBar(config.showTitleBar)
    end
    if config.showCloseButton ~= nil then
        self:setShowCloseButton(config.showCloseButton)
    end
    if config.background ~= nil then
        self:setBackground(config.background)
    end
    if config.alpha ~= nil then
        self:setAlpha(config.alpha)
    end
    if config.visible ~= nil then
        self:setVisible(config.visible)
    end
    if config.draggable ~= nil then
        self:setDraggable(config.draggable)
    end
    if config.buttonStartY ~= nil then
        self:setButtonStartY(config.buttonStartY)
    end
    if config.buttonSpacing ~= nil then
        self:setButtonSpacing(config.buttonSpacing)
    end
    if config.buttonHeight ~= nil then
        self:setButtonHeight(config.buttonHeight)
    end
    if config.buttonWidthRatio ~= nil then
        self:setButtonWidthRatio(config.buttonWidthRatio)
    end
    return self
end
function Dialog.prototype.destroy(self)
    log:info("开始销毁对话框: " .. tostring(self.titleText))
    log:info(("销毁 " .. tostring(#self.buttons)) .. " 个按钮")
    self:clearButtons()
    if self.titleText then
        log:info("销毁标题文本")
        self.titleText:destroy()
        self.titleText = nil
    end
    log:info("清理拖拽回调")
    self.userOnDragStart = nil
    self.userOnDragEnd = nil
    self.userOnDragging = nil
    log:info("销毁面板")
    self.panel:destroy()
    self.isCreated = false
    log:info("对话框销毁完成")
end
return ____exports

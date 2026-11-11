local ____lualib = require("lualib_bundle")
local __TS__Class = ____lualib.__TS__Class
local __TS__ClassExtends = ____lualib.__TS__ClassExtends
local Set = ____lualib.Set
local __TS__New = ____lualib.__TS__New
local ____exports = {}
local ____EventEmitter = require("src.system.event.EventEmitter")
local EventEmitter = ____EventEmitter.EventEmitter
local ____logger = require("src.utils.logger")
local createLogger = ____logger.createLogger
local log = createLogger("KeyboardEventManager")
--- 常用按键代码（OSKEYTYPE）
____exports.KeyCode = {
    ESCAPE = 27,
    BACKSPACE = 8,
    TAB = 9,
    ENTER = 13,
    SHIFT = 16,
    CTRL = 17,
    ALT = 18,
    PAUSE = 19,
    CAPSLOCK = 20,
    SPACE = 32,
    LEFT = 37,
    UP = 38,
    RIGHT = 39,
    DOWN = 40,
    KEY_0 = 48,
    KEY_1 = 49,
    KEY_2 = 50,
    KEY_3 = 51,
    KEY_4 = 52,
    KEY_5 = 53,
    KEY_6 = 54,
    KEY_7 = 55,
    KEY_8 = 56,
    KEY_9 = 57,
    A = 65,
    B = 66,
    C = 67,
    D = 68,
    E = 69,
    F = 70,
    G = 71,
    H = 72,
    I = 73,
    J = 74,
    K = 75,
    L = 76,
    M = 77,
    N = 78,
    O = 79,
    P = 80,
    Q = 81,
    R = 82,
    S = 83,
    T = 84,
    U = 85,
    V = 86,
    W = 87,
    X = 88,
    Y = 89,
    Z = 90,
    F1 = 112,
    F2 = 113,
    F3 = 114,
    F4 = 115,
    F5 = 116,
    F6 = 117,
    F7 = 118,
    F8 = 119,
    F9 = 120,
    F10 = 121,
    F11 = 122,
    F12 = 123,
    NUMPAD0 = 96,
    NUMPAD1 = 97,
    NUMPAD2 = 98,
    NUMPAD3 = 99,
    NUMPAD4 = 100,
    NUMPAD5 = 101,
    NUMPAD6 = 102,
    NUMPAD7 = 103,
    NUMPAD8 = 104,
    NUMPAD9 = 105,
    MULTIPLY = 106,
    ADD = 107,
    SUBTRACT = 109,
    DECIMAL = 110,
    DIVIDE = 111
}
--- 键盘事件管理器
____exports.KeyboardEventManager = __TS__Class()
local KeyboardEventManager = ____exports.KeyboardEventManager
KeyboardEventManager.name = "KeyboardEventManager"
__TS__ClassExtends(KeyboardEventManager, EventEmitter)
function KeyboardEventManager.prototype.____constructor(self)
    EventEmitter.prototype.____constructor(self, "KeyboardEventManager")
    self.initialized = false
    self.nativeTriggers = {}
    self.registeredKeys = __TS__New(Set)
end
function KeyboardEventManager.getInstance(self)
    if not ____exports.KeyboardEventManager.instance then
        ____exports.KeyboardEventManager.instance = __TS__New(____exports.KeyboardEventManager)
    end
    return ____exports.KeyboardEventManager.instance
end
function KeyboardEventManager.prototype.initialize(self, registerCommonKeys)
    if registerCommonKeys == nil then
        registerCommonKeys = false
    end
    if self.initialized then
        return
    end
    if registerCommonKeys then
        self:registerKey(____exports.KeyCode.ESCAPE)
        self:registerKey(____exports.KeyCode.SPACE)
        self:registerKey(____exports.KeyCode.ENTER)
        do
            local i = ____exports.KeyCode.A
            while i <= ____exports.KeyCode.Z do
                self:registerKey(i)
                i = i + 1
            end
        end
        do
            local i = ____exports.KeyCode.KEY_0
            while i <= ____exports.KeyCode.KEY_9 do
                self:registerKey(i)
                i = i + 1
            end
        end
        do
            local i = ____exports.KeyCode.F1
            while i <= ____exports.KeyCode.F12 do
                self:registerKey(i)
                i = i + 1
            end
        end
    end
    self.initialized = true
    log:info("初始化完成")
end
function KeyboardEventManager.prototype.registerKey(self, keyCode, isDown)
    if isDown == nil then
        self:registerKey(keyCode, true)
        self:registerKey(keyCode, false)
        return
    end
    local key = (tostring(keyCode) .. ":") .. tostring(isDown and 1 or 0)
    if self.registeredKeys:has(key) then
        return
    end
    local trig = CreateTrigger()
    local ____self_nativeTriggers_0 = self.nativeTriggers
    ____self_nativeTriggers_0[#____self_nativeTriggers_0 + 1] = trig
    local eventType = isDown and "key:down" or "key:up"
    DzTriggerRegisterKeyEventByCode(
        trig,
        keyCode,
        isDown and 1 or 0,
        false,
        function()
            local data = {
                keyCode = keyCode,
                type = eventType,
                metaKey = DzGetTriggerKey()
            }
            self:emit(eventType, data)
            self:emit(
                (eventType .. ":") .. tostring(keyCode),
                data
            )
        end
    )
    self.registeredKeys:add(key)
end
function KeyboardEventManager.prototype.onKeyDown(self, handler, keyCode, options)
    if keyCode ~= nil then
        self:registerKey(keyCode, true)
        return self:on(
            ("key:down" .. ":") .. tostring(keyCode),
            handler,
            options
        )
    end
    return self:on("key:down", handler, options)
end
function KeyboardEventManager.prototype.onKeyUp(self, handler, keyCode, options)
    if keyCode ~= nil then
        self:registerKey(keyCode, false)
        return self:on(
            ("key:up" .. ":") .. tostring(keyCode),
            handler,
            options
        )
    end
    return self:on("key:up", handler, options)
end
function KeyboardEventManager.prototype.onKey(self, handler, keyCode, options)
    self:registerKey(keyCode)
    local downId = self:on(
        ("key:down" .. ":") .. tostring(keyCode),
        handler,
        options
    )
    local upId = self:on(
        ("key:up" .. ":") .. tostring(keyCode),
        handler,
        options
    )
    return {downId, upId}
end
function KeyboardEventManager.prototype.destroy(self)
    EventEmitter.prototype.destroy(self)
    for ____, trig in ipairs(self.nativeTriggers) do
        DestroyTrigger(trig)
    end
    self.nativeTriggers = {}
    self.registeredKeys:clear()
    self.initialized = false
end
--- 快捷访问键盘事件管理器
____exports.keyboardEvents = ____exports.KeyboardEventManager:getInstance()
return ____exports

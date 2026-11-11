local ____exports = {}
--- 功能键 F1-F12
____exports.KEY_F1 = 112
____exports.KEY_F2 = 113
____exports.KEY_F3 = 114
____exports.KEY_F4 = 115
____exports.KEY_F5 = 116
____exports.KEY_F6 = 117
____exports.KEY_F7 = 118
____exports.KEY_F8 = 119
____exports.KEY_F9 = 120
____exports.KEY_F10 = 121
____exports.KEY_F11 = 122
____exports.KEY_F12 = 123
--- 数字键 0-9 (主键盘区)
____exports.KEY_0 = 48
____exports.KEY_1 = 49
____exports.KEY_2 = 50
____exports.KEY_3 = 51
____exports.KEY_4 = 52
____exports.KEY_5 = 53
____exports.KEY_6 = 54
____exports.KEY_7 = 55
____exports.KEY_8 = 56
____exports.KEY_9 = 57
--- 小键盘数字键 0-9
____exports.KEY_NUMPAD0 = 96
____exports.KEY_NUMPAD1 = 97
____exports.KEY_NUMPAD2 = 98
____exports.KEY_NUMPAD3 = 99
____exports.KEY_NUMPAD4 = 100
____exports.KEY_NUMPAD5 = 101
____exports.KEY_NUMPAD6 = 102
____exports.KEY_NUMPAD7 = 103
____exports.KEY_NUMPAD8 = 104
____exports.KEY_NUMPAD9 = 105
--- 字母键 A-Z
____exports.KEY_A = 65
____exports.KEY_B = 66
____exports.KEY_C = 67
____exports.KEY_D = 68
____exports.KEY_E = 69
____exports.KEY_F = 70
____exports.KEY_G = 71
____exports.KEY_H = 72
____exports.KEY_I = 73
____exports.KEY_J = 74
____exports.KEY_K = 75
____exports.KEY_L = 76
____exports.KEY_M = 77
____exports.KEY_N = 78
____exports.KEY_O = 79
____exports.KEY_P = 80
____exports.KEY_Q = 81
____exports.KEY_R = 82
____exports.KEY_S = 83
____exports.KEY_T = 84
____exports.KEY_U = 85
____exports.KEY_V = 86
____exports.KEY_W = 87
____exports.KEY_X = 88
____exports.KEY_Y = 89
____exports.KEY_Z = 90
--- 方向键
____exports.KEY_LEFT = 37
____exports.KEY_UP = 38
____exports.KEY_RIGHT = 39
____exports.KEY_DOWN = 40
--- 控制键
____exports.KEY_ESCAPE = 27
____exports.KEY_ENTER = 13
____exports.KEY_SPACE = 32
____exports.KEY_TAB = 9
____exports.KEY_BACKSPACE = 8
____exports.KEY_DELETE = 46
____exports.KEY_INSERT = 45
____exports.KEY_HOME = 36
____exports.KEY_END = 35
____exports.KEY_PAGEUP = 33
____exports.KEY_PAGEDOWN = 34
--- 修饰键
____exports.KEY_SHIFT = 16
____exports.KEY_CTRL = 17
____exports.KEY_ALT = 18
____exports.KEY_CAPSLOCK = 20
--- 小键盘运算符
____exports.KEY_NUMPAD_MULTIPLY = 106
____exports.KEY_NUMPAD_ADD = 107
____exports.KEY_NUMPAD_SUBTRACT = 109
____exports.KEY_NUMPAD_DECIMAL = 110
____exports.KEY_NUMPAD_DIVIDE = 111
--- 按键元状态 (用于 metaKey 参数)
____exports.META_KEY_NONE = 0
____exports.META_KEY_SHIFT = 1
____exports.META_KEY_CTRL = 2
____exports.META_KEY_ALT = 4
____exports.META_KEY_SHIFT_CTRL = 3
____exports.META_KEY_SHIFT_ALT = 5
____exports.META_KEY_CTRL_ALT = 6
____exports.META_KEY_SHIFT_CTRL_ALT = 7
--- 当控件（如按钮）被点击时触发
____exports.FRAMEEVENT_CONTROL_CLICK = 1
--- 当鼠标光标移入框架区域时触发
____exports.FRAMEEVENT_MOUSE_ENTER = 2
--- 当鼠标光标移出框架区域时触发
____exports.FRAMEEVENT_MOUSE_LEAVE = 3
--- 当鼠标按钮在框架上松开时触发
____exports.FRAMEEVENT_MOUSE_UP = 4
--- 当在框架上滚动鼠标滚轮时触发
____exports.FRAMEEVENT_MOUSE_WHEEL = 5
--- 当复选框被勾选时触发（适用于复选框控件）
____exports.FRAMEEVENT_CHECKBOX_CHECKED = 6
--- 当编辑框内的文本发生变化时触发
____exports.FRAMEEVENT_EDITBOX_TEXT_CHANGED = 7
--- Frame事件类型枚举
____exports.FrameEventType = ____exports.FrameEventType or ({})
____exports.FrameEventType.CONTROL_CLICK = 1
____exports.FrameEventType[____exports.FrameEventType.CONTROL_CLICK] = "CONTROL_CLICK"
____exports.FrameEventType.MOUSE_ENTER = 2
____exports.FrameEventType[____exports.FrameEventType.MOUSE_ENTER] = "MOUSE_ENTER"
____exports.FrameEventType.MOUSE_LEAVE = 3
____exports.FrameEventType[____exports.FrameEventType.MOUSE_LEAVE] = "MOUSE_LEAVE"
____exports.FrameEventType.MOUSE_UP = 4
____exports.FrameEventType[____exports.FrameEventType.MOUSE_UP] = "MOUSE_UP"
____exports.FrameEventType.MOUSE_WHEEL = 5
____exports.FrameEventType[____exports.FrameEventType.MOUSE_WHEEL] = "MOUSE_WHEEL"
____exports.FrameEventType.CHECKBOX_CHECKED = 6
____exports.FrameEventType[____exports.FrameEventType.CHECKBOX_CHECKED] = "CHECKBOX_CHECKED"
____exports.FrameEventType.EDITBOX_TEXT_CHANGED = 7
____exports.FrameEventType[____exports.FrameEventType.EDITBOX_TEXT_CHANGED] = "EDITBOX_TEXT_CHANGED"
return ____exports

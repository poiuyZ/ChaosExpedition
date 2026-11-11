local ____lualib = require("lualib_bundle")
local __TS__New = ____lualib.__TS__New
local ____exports = {}
local testDialogWithTitleToggle
local ____Dialog = require("src.system.ui.component.Dialog")
local Dialog = ____Dialog.Dialog
local ____Text = require("src.system.ui.component.Text")
local TextColors = ____Text.TextColors
function testDialogWithTitleToggle()
    print("\n--- Test: Dialog Title Bar Toggle & Dragging ---")
    local dialogWithTitle = __TS__New(Dialog, "可拖拽对话框", 450, 400)
    dialogWithTitle:setDraggable(true):create()
    dialogWithTitle:setOnDragStart(function()
        print("开始拖拽对话框")
    end):setOnDragEnd(function(x, y)
        print(((("拖拽结束，新位置: (" .. tostring(x)) .. ", ") .. tostring(y)) .. ")")
    end):setOnDragging(function(_x, _y)
    end)
    dialogWithTitle:addButton({
        text = "隐藏标题栏",
        onClick = function()
            dialogWithTitle:setShowTitleBar(false)
            print("标题栏已隐藏")
        end
    })
    dialogWithTitle:addButton({
        text = "显示标题栏",
        onClick = function()
            dialogWithTitle:setShowTitleBar(true)
            print("标题栏已显示")
        end
    })
    dialogWithTitle:addButton({
        text = "禁用拖拽",
        onClick = function()
            dialogWithTitle:setDraggable(false)
            print("拖拽已禁用")
        end
    })
    dialogWithTitle:addButton({
        text = "启用拖拽",
        onClick = function()
            dialogWithTitle:setDraggable(true)
            print("拖拽已启用")
        end
    })
    dialogWithTitle:addButton({
        text = "隐藏关闭按钮",
        onClick = function()
            dialogWithTitle:setShowCloseButton(false)
            print("关闭按钮已隐藏")
        end
    })
    dialogWithTitle:addButton({
        text = "显示关闭按钮",
        onClick = function()
            dialogWithTitle:setShowCloseButton(true)
            print("关闭按钮已显示")
        end
    })
    dialogWithTitle:addButton({
        text = "关闭",
        onClick = function()
            dialogWithTitle:hide()
        end,
        color = TextColors.RED
    })
    dialogWithTitle:show()
    local dialogNoTitle = __TS__New(Dialog, "这个标题不会显示", 400, 300)
    dialogNoTitle:setShowTitleBar(false):create()
    dialogNoTitle:setPosition(100, 100)
    dialogNoTitle:addButton({
        text = "无标题栏对话框",
        onClick = function()
            print("这是一个没有标题栏的对话框")
        end
    })
    dialogNoTitle:addButton({
        text = "显示标题栏",
        onClick = function()
            dialogNoTitle:setShowTitleBar(true)
            print("标题栏已启用")
        end
    })
    dialogNoTitle:addButton({
        text = "启用拖拽",
        onClick = function()
            dialogNoTitle:setDraggable(true)
            print("拖拽已启用（需要标题栏才能拖拽）")
        end
    })
    dialogNoTitle:addButton({
        text = "关闭",
        onClick = function()
            dialogNoTitle:hide()
        end,
        color = TextColors.RED
    })
    dialogNoTitle:show()
    print("✓ 标题栏切换和拖拽测试对话框创建完成")
    print("  - 中间对话框: 可拖拽，可切换标题栏")
    print("  - 左上角对话框: 初始无标题栏，不可拖拽")
    print("  - 提示: 拖拽对话框需要鼠标在标题栏上按住拖动")
end
--- Dialog 组件使用示例
function ____exports.runDialogExamples()
    print("=== Dialog Component Examples ===")
    testDialogWithTitleToggle()
    print("=== Dialog Examples Complete ===")
end
--- 完整示例：游戏菜单
function ____exports.createGameMenuDialog()
    print("\n=== Creating Game Menu Dialog ===")
    local menuDialog = Dialog:createCentered("游戏菜单", 450, 450)
    menuDialog:configure({titleColor = TextColors.GOLD, alpha = 240, buttonSpacing = 65})
    menuDialog:addButton({
        text = "继续游戏",
        onClick = function()
            print("继续游戏")
            menuDialog:hide()
        end,
        color = TextColors.GREEN
    })
    menuDialog:addButton({
        text = "保存游戏",
        onClick = function()
            print("保存游戏")
        end,
        color = TextColors.CYAN
    })
    menuDialog:addButton({
        text = "读取存档",
        onClick = function()
            print("读取存档")
        end,
        color = TextColors.CYAN
    })
    menuDialog:addButton({
        text = "设置",
        onClick = function()
            print("打开设置")
        end,
        color = TextColors.WHITE
    })
    menuDialog:addButton({
        text = "退出游戏",
        onClick = function()
            print("退出游戏")
            local exitConfirm = Dialog:createConfirm(
                "退出确认",
                "确定要退出游戏吗？",
                function()
                    print("退出游戏确认")
                end
            )
            exitConfirm:show()
        end,
        color = TextColors.RED
    })
    menuDialog:hide()
    print("✓ 游戏菜单对话框创建完成")
    return menuDialog
end
--- 快速开始 - 最简单的用法
function ____exports.quickStartDialog()
    print("\n=== Quick Start: Dialog ===")
    local dialog1 = __TS__New(Dialog, "标题", 500, 300)
    dialog1:create()
    dialog1:addButton({
        text = "确定",
        onClick = function() return dialog1:hide() end
    })
    Dialog:createConfirm(
        "确认",
        "确定要执行此操作吗？",
        function() return print("确认") end
    )
    Dialog:createChoice(
        "选择",
        {"选项1", "选项2", "选项3"},
        function(index) return print("选择了选项" .. tostring(index + 1)) end
    )
    print("✓ 快速开始示例完成")
end
return ____exports

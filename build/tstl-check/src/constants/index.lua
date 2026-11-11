local ____exports = {}
do
    local ____export = require("src.constants.frame.index")
    for ____exportKey, ____exportValue in pairs(____export) do
        if ____exportKey ~= "default" then
            ____exports[____exportKey] = ____exportValue
        end
    end
end
do
    local ____export = require("src.constants.game.units")
    for ____exportKey, ____exportValue in pairs(____export) do
        if ____exportKey ~= "default" then
            ____exports[____exportKey] = ____exportValue
        end
    end
end
do
    local ____export = require("src.constants.ui.colors")
    for ____exportKey, ____exportValue in pairs(____export) do
        if ____exportKey ~= "default" then
            ____exports[____exportKey] = ____exportValue
        end
    end
end
____exports.FrameConstants = require("src.constants.frame.index")
____exports.GameConstants = require("src.constants.game.units")
____exports.UIConstants = require("src.constants.ui.colors")
return ____exports

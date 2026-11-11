local ____lualib = require("lualib_bundle")
local __TS__Class = ____lualib.__TS__Class
local ____exports = {}
local ____CameraControl = require("src.utils.CameraControl")
local CameraControl = ____CameraControl.CameraControl
____exports.PlayersConfig = __TS__Class()
local PlayersConfig = ____exports.PlayersConfig
PlayersConfig.name = "PlayersConfig"
function PlayersConfig.prototype.____constructor(self)
end
function PlayersConfig.CameraControl(self)
    CameraControl:initMouseControl()
end
return ____exports

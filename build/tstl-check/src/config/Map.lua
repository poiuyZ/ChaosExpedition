local ____lualib = require("lualib_bundle")
local __TS__Class = ____lualib.__TS__Class
local ____exports = {}
____exports.MapGeneral = __TS__Class()
local MapGeneral = ____exports.MapGeneral
MapGeneral.name = "MapGeneral"
function MapGeneral.prototype.____constructor(self)
end
function MapGeneral.sceneVisionInit(self)
    FogMaskEnable(false)
    FogEnable(false)
end
return ____exports

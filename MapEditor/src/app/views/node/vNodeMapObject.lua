local ViewBaseEx = require("app.views.ViewBaseEx")
local WindowMgr = require("app.components.WindowMgr")
local vNodeMapObject = class("vNodeMapObject", ViewBaseEx)

function vNodeMapObject:onCreate()
	self:loadFromDB()
end

function vNodeMapObject:loadFromDB()

end


return vNodeMapObject
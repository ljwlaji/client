local ViewBaseEx 			= require("app.views.ViewBaseEx")
local DataBase 				= require("app.components.DataBase")
local WindowMgr 			= require("app.components.WindowMgr")
local Utils 				= require("app.components.Utils")
local vLayerInputCheckBox 	= class("vLayerInputCheckBox", ViewBaseEx)

function vLayerInputCheckBox:onCreate(context)
	self:createLayout({
		size = cc.size(500, 300)
	}):addTo(self)
	self:onRefresh(context)
end

function vLayerInputCheckBox:onRefresh(context)
	self.context = context
end

return vLayerInputCheckBox
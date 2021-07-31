local WindowMgr = require("app.components.WindowMgr")
local ViewBaseEx = require("app.views.ViewBaseEx")
local TableViewEx = require("app.components.TableViewEx")
local vLayerChooseBrush = class("vLayerChooseBrush", ViewBaseEx)

local WINDOW_SIZE = {
	width = 400,
	height = 600
}
function vLayerChooseBrush:onCreate(context)
	self:setAnchorPoint(0.5, 0.5)
	self:setContentSize(WINDOW_SIZE)
	local bg = self:createLayout({
		size = WINDOW_SIZE,
		ap = cc.p(0, 0),
		cb = function() end,
		st = true,
	}):addTo(self)

	self:createLayout({
		size = cc.size(350, 30),
		ap = cc.p(0.5, 1),
		op = 30,
		fs = 16,
		str = "选择地形刷",
	}):addTo(self):move(WINDOW_SIZE.width * 0.5, WINDOW_SIZE.height - 10)

	self:createLayout({
		size = cc.size(350, 30),
		ap = cc.p(0.5, 0),
		op = 30,
		fs = 16,
		str = "返回",
		cb = function(e) if e.name ~= "ended" then return end WindowMgr:removeWindow(self) end
	}):addTo(self):move(WINDOW_SIZE.width * 0.5, 10)
end




return vLayerChooseBrush
local ViewBaseEx = require("app.views.ViewBaseEx")
local WindowMgr = require("app.components.WindowMgr")
local vLayerModeChoose = class("vLayerModeChoose", ViewBaseEx)

-- function vLayerModeChoose:

function vLayerModeChoose:onCreate()
    self:autoAlgin()
	local bg = self:createLayout({
		size = cc.size(250, 300),
		color = cc.c3b(255, 255, 255),
		op = 30,
		cb = function(e)
			if e.name ~= "ended" then return end
		end
	}):addTo(self):move(display.center)
	self:createLayout({
		size = cc.size(220, 40),
		cb = handler(self, self.onTouchBtnNew),
		str = "新建地图"
	}):addTo(bg):alignCenter():setPositionY(300 * 0.7)
	self:createLayout({
		size = cc.size(220, 40),
		cb = handler(self, self.onTouchBtnLoad),
		str = "读取已有地图"
	}):addTo(bg):alignCenter():setPositionY(300 * 0.3)
end

function vLayerModeChoose:onTouchBtnNew(e)
	if e.name ~= "ended" then return true end
	WindowMgr:createWindow("app.views.layer.vLayerCreateNewMap")
end

function vLayerModeChoose:onTouchBtnLoad(e)
	if e.name ~= "ended" then return end
	WindowMgr:createWindow("app.views.layer.vLayerLoadOldMap")

end


return vLayerModeChoose
local ViewBaseEx = require("app.views.ViewBaseEx")
local vNodeGroundGrid = class("vNodeGroundGrid", ViewBaseEx)

function vNodeGroundGrid:ctor(context)
	self.context = context or {}
	self:setContentSize(20, 20)
	self:createLayout({
		size = cc.size(20, 20),
		color = cc.c3b(255, 0, 0),
		op = 30,
		cb = handler(self, self.onTouch),
		st = false,
		ap = cc.p(0, 0)
	}):addTo(self)
end

function vNodeGroundGrid:onTouch(e)
	
end

return vNodeGroundGrid
local ViewBaseEx = require("app.views.ViewBaseEx")
local vNodeMainScene = class("vNodeMainScene", ViewBaseEx)

function vNodeMainScene:onCreate(size)
	self:setContentSize(size.width - 4, size.height - 4)
		:setAnchorPoint(0.5, 0.5)
		:move(0, 0)
	local bg = self:createLayout({
		size = cc.size(size.width - 4, size.height - 4),
		ap = cc.p(0, 0),
		dad = true,
		cb = function() release_print("OnTouch") end
	}):addTo(self)
end




return vNodeMainScene
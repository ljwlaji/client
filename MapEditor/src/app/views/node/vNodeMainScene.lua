local ViewBaseEx = require("app.views.ViewBaseEx")
local vNodeMainScene = class("vNodeMainScene", ViewBaseEx)

--[[
cc.Handler.EVENT_MOUSE_DOWN       = 48
cc.Handler.EVENT_MOUSE_UP         = 49
cc.Handler.EVENT_MOUSE_MOVE       = 50
cc.Handler.EVENT_MOUSE_SCROLL     = 51
]]


function vNodeMainScene:genGroundGrids()

end

function vNodeMainScene:onCreate(size)
	self:setContentSize(size.width - 4, size.height - 4)
		:setAnchorPoint(0.5, 0.5)
		:move(0, 0)
	local bg = self:createLayout({
		size = cc.size(size.width - 4, size.height - 4),
		ap = cc.p(0, 0),
		dad = true,
	}):addTo(self)
end

return vNodeMainScene
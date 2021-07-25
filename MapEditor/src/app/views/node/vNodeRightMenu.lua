local ViewBaseEx = require("app.views.ViewBaseEx")
local vNodeRightMenu = class("vNodeRightMenu", ViewBaseEx)

local BG_WIDTH = 180
local SINGLE_BTN_HEIGHT = 50
local SINGLE_BTN_WIDTH 	= BG_WIDTH * 0.5 - 4

function vNodeRightMenu:addNewLine()
	self.btnOffsetX = 2
	self.btnOffsetY = self.btnOffsetY - SINGLE_BTN_HEIGHT - 2
end

function vNodeRightMenu:addBtn(btn)
	if self.btnOffsetX + SINGLE_BTN_HEIGHT + 2 > BG_WIDTH then
		self:addNewLine()
	end
	btn:addTo(self):move(self.btnOffsetX, self.btnOffsetY)
	self.btnOffsetX = self.btnOffsetX + SINGLE_BTN_WIDTH + 2
end

function vNodeRightMenu:onCreate()
	self.btnOffsetX = 2
	self.btnOffsetY = display.height - 30 - 30 - 4 - 32 - 2
	self:setContentSize(BG_WIDTH, display.height - 30 - 30 - 4)
		:setAnchorPoint(1, 1)
		:move(0, - 32)
	local bg = self:createLayout({
		size = cc.size(BG_WIDTH, display.height - 30 - 30 - 4),
		ap = cc.p(0, 0)
	}):addTo(self)

	self:createLayout({
		size = cc.size(BG_WIDTH - 4, 30),
		ap = cc.p(0.5, 1),
		op = 30,
		fs = 16,
		str = "单位属性",
		cb = handler(self, self.onTouchMapInfo),
	}):addTo(self):move(BG_WIDTH * 0.5, self:getContentSize().height - 2)
end

return vNodeRightMenu
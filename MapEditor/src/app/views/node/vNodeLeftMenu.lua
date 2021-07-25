local ViewBaseEx = require("app.views.ViewBaseEx")
local vNodeLeftMenu = class("vNodeLeftMenu", ViewBaseEx)

local BG_WIDTH = 180
local SINGLE_BTN_HEIGHT = 50
local SINGLE_BTN_WIDTH 	= BG_WIDTH * 0.5 - 4

function vNodeLeftMenu:addNewLine()
	self.btnOffsetX = 2
	self.btnOffsetY = self.btnOffsetY - SINGLE_BTN_HEIGHT - 2
end

function vNodeLeftMenu:addBtn(btn)
	if self.btnOffsetX + SINGLE_BTN_HEIGHT + 2 > BG_WIDTH then
		self:addNewLine()
	end
	btn:addTo(self):move(self.btnOffsetX, self.btnOffsetY)
	self.btnOffsetX = self.btnOffsetX + SINGLE_BTN_WIDTH + 2
end

function vNodeLeftMenu:onCreate()
	self.btnOffsetX = 2
	self.btnOffsetY = display.height - 30 - 30 - 4 - 32 - 2
	self:setContentSize(BG_WIDTH, display.height - 30 - 30 - 4)
		:setAnchorPoint(0, 1)
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
		str = "可添加物体",
		cb = handler(self, self.onTouchMapInfo),
	}):addTo(self):move(BG_WIDTH * 0.5, self:getContentSize().height - 2)

	self:addBtn(self:createLayout({
		size = cc.size(SINGLE_BTN_WIDTH, SINGLE_BTN_HEIGHT),
		ap = cc.p(0, 1),
		fs = 16,
		str = "生物",
		cb = handler(self, self.onTouchMapInfo),
	}))
	self:addBtn(self:createLayout({
		size = cc.size(SINGLE_BTN_WIDTH, SINGLE_BTN_HEIGHT),
		ap = cc.p(0, 1),
		fs = 16,
		str = "传送门",
		cb = handler(self, self.onTouchMapInfo),
	}))
	self:addBtn(self:createLayout({
		size = cc.size(SINGLE_BTN_WIDTH, SINGLE_BTN_HEIGHT),
		ap = cc.p(0, 1),
		fs = 16,
		str = "采集物",
		cb = handler(self, self.onTouchMapInfo),
	}))
	self:addBtn(self:createLayout({
		size = cc.size(SINGLE_BTN_WIDTH, SINGLE_BTN_HEIGHT),
		ap = cc.p(0, 1),
		fs = 16,
		str = "建筑",
		cb = handler(self, self.onTouchMapInfo),
	}))
	self:addBtn(self:createLayout({
		size = cc.size(SINGLE_BTN_WIDTH, SINGLE_BTN_HEIGHT),
		ap = cc.p(0, 1),
		fs = 16,
		str = "游戏物体",
		cb = handler(self, self.onTouchMapInfo),
	}))
	self:addBtn(self:createLayout({
		size = cc.size(SINGLE_BTN_WIDTH, SINGLE_BTN_HEIGHT),
		ap = cc.p(0, 1),
		fs = 16,
		str = "区域框",
		cb = handler(self, self.onTouchMapInfo),
	}))
	self:addBtn(self:createLayout({
		size = cc.size(SINGLE_BTN_WIDTH, SINGLE_BTN_HEIGHT),
		ap = cc.p(0, 1),
		fs = 16,
		str = "地形刷",
		cb = handler(self, self.onTouchMapInfo),
	}))
end


return vNodeLeftMenu
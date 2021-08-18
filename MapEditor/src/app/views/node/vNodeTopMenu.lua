local ViewBaseEx = require("app.views.ViewBaseEx")
local vNodeTopMenu = class("vNodeTopMenu", ViewBaseEx)

function vNodeTopMenu:addBtn(btn)
	btn:addTo(self):move(self.btnOffset, 0)
	self.btnOffset = self.btnOffset + btn:getContentSize().width + 2
end

function vNodeTopMenu:onCreate(context)
	self.btnOffset = 0
	self:setContentSize(display.width, 30)
		:setAnchorPoint(0.5, 1)
	local bg = self:createLayout({
		size = cc.size(display.width, 30),
		ap = cc.p(0, 0)
	}):addTo(self)
	self:addBtn(self:createLayout({
		size = cc.size(150, 30),
		ap = cc.p(0, 0),
		op = 30,
		fs = 18,
		str = string.format("地图名称:[%s]", context),
		cb = handler(self, self.onTouchMapInfo),
	}))
	self:addBtn(self:createLayout({
		size = cc.size(100, 30),
		ap = cc.p(0, 0),
		op = 30,
		fs = 18,
		str = "新建地图",
		cb = handler(self, self.onTouchBtnNew),
	}))
	self:addBtn(self:createLayout({
		size = cc.size(100, 30),
		ap = cc.p(0, 0),
		op = 30,
		fs = 18,
		str = "保存",
		cb = handler(self, self.onTouchBtnSave),
	}))
	self:addBtn(self:createLayout({
		size = cc.size(100, 30),
		ap = cc.p(0, 0),
		op = 30,
		fs = 18,
		str = "全部保存",
		cb = handler(self, self.onTouchBtnSaveAll),
	}))
	self:addBtn(self:createLayout({
		size = cc.size(100, 30),
		ap = cc.p(0, 0),
		op = 30,
		fs = 18,
		str = "发布",
		cb = handler(self, self.onTouchBtnPublish),
	}))
end


----------------	Events	 ----------------
function vNodeTopMenu:onTouchBtnNew(e)
	if e.name ~= "ended" then return end
end

function vNodeTopMenu:onTouchBtnPublish(e)
	if e.name ~= "ended" then return end
end

function vNodeTopMenu:onTouchBtnSave(e)
	print("onTouchBtnSave")
	if e.name ~= "ended" then return end
	self:sendAppMsg("MSG_ON_SAVE_BTN_CLICKED")
end

function vNodeTopMenu:onTouchBtnSaveAll(e)
	if e.name ~= "ended" then return end
end

function vNodeTopMenu:onTouchMapInfo(e)
	if e.name ~= "ended" then return end
end

return vNodeTopMenu
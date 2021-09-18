local ViewBaseEx 			= require("app.views.ViewBaseEx")
local DataBase 				= require("app.components.DataBase")
local WindowMgr 			= require("app.components.WindowMgr")
local NativeHelper 			= require("app.components.NativeHelper")
local vLayerPasswordDetail 	= class("vLayerPasswordDetail", ViewBaseEx)

local WIDTH = display.width - 100
function vLayerPasswordDetail:onCreate(context)
	self:regiestCustomEventListenter("MSG_APP_WILL_ENTER_FOREGROUND", function()
		if NativeHelper:canVerify() then NativeHelper:verify(function(sec)
			if not sec then self:removeSelf() return end
		end) end
	end)
	self:createLayout({
		size = cc.size(display.width, display.height),
		op = 127,
		color = cc.c3b(0, 0, 0),
		cb = function(e)
			if e.name ~= "ended" then return end
			self:removeSelf()
		end
	}):addTo(self)
	self.bg = self:createLayout({
		size = cc.size(WIDTH, 370),
		op = 127,

		cb = function() end
	}):addTo(self)

	self:createLayout({
		size = cc.size(WIDTH, 35),
		str = "密码详情",
		op = 0,
		fc = cc.c3b(255, 255, 0),
		ap = cc.p(0.5, 1),
	}):addTo(self.bg):move(WIDTH * 0.5, self.bg:getContentSize().height)

	local offset = 40
	self:createLayout({
		size = cc.size(WIDTH, 35),
		str = "密码为: "..context.value,
		op = 0,
		fc = cc.c3b(255, 255, 0),
		ap = cc.p(0.5, 1),
	}):addTo(self.bg):move(WIDTH * 0.5, self.bg:getContentSize().height - offset)
	offset = offset + 40
	self:createLayout({
		size = cc.size(WIDTH, 35),
		str = "密码描述: "..context.desc,
		op = 0,
		fc = cc.c3b(255, 255, 0),
		ap = cc.p(0.5, 1),
	}):addTo(self.bg):move(WIDTH * 0.5, self.bg:getContentSize().height - offset)
	offset = offset + 40

	self.newPass = self:cEditBox({
		size = cc.size(display.width * 0.8, 35),
		ap = cc.p(0.5, 1),
		op = 127,
		ph = "修改记录的密码",
	}):addTo(self.bg):move(WIDTH * 0.5, self.bg:getContentSize().height - offset)
	offset = offset + 40

	self.newDesc = self:cEditBox({
		size = cc.size(display.width * 0.8, 35),
		ap = cc.p(0.5, 1),
		op = 127,
		ph = "修改记录的描述",
	}):addTo(self.bg):move(WIDTH * 0.5, self.bg:getContentSize().height - offset)
	offset = offset + 40

	self:createLayout({
		size = cc.size(WIDTH, 35),
		str = "提交修改",
		op = 0,
		fc = cc.c3b(255, 255, 0),
		ap = cc.p(0.5, 1),
		cb = handler(self, self.onConfirmEdit)
	}):addTo(self.bg):move(WIDTH * 0.5, self.bg:getContentSize().height - offset)
	offset = offset + 40

	self:createLayout({
		size = cc.size(WIDTH, 35),
		str = "删除本条记录",
		op = 0,
		fc = cc.c3b(255, 0, 0),
		ap = cc.p(0.5, 1),
		cb = handler(self, self.onDelete)
	}):addTo(self.bg):move(WIDTH * 0.5, self.bg:getContentSize().height - offset)

	offset = offset + 40
	self:createLayout({
		size = cc.size(WIDTH, 35),
		str = "复制密码到剪切板",
		op = 0,
		fc = cc.c3b(0, 255, 127),
		ap = cc.p(0.5, 1),
		cb = handler(self, self.onPasteToClipBoard)
	}):addTo(self.bg):move(WIDTH * 0.5, self.bg:getContentSize().height - offset)


	offset = offset + 40
	self:createLayout({
		size = cc.size(WIDTH, 35),
		str = "返回",
		op = 0,
		fc = cc.c3b(127, 127, 127),
		ap = cc.p(0.5, 1),
		cb = function(e) if e.name ~= "ended" then return end self:removeSelf() end
	}):addTo(self.bg):move(WIDTH * 0.5, self.bg:getContentSize().height - offset)

	self.context = context
end

function vLayerPasswordDetail:onConfirmEdit(e)
	if e.name ~= "ended" then return end
	if self.newPass:getText() == "" or self.newDesc:getText() == "" then 
        	WindowMgr:popCheckWindow({
        		title = 990002,
        		desc = 990001,
        	})
		return end

	local sql = "REPLACE INTO pass(entry, desc, value) VALUES(%d, '%s', '%s')"
	DataBase:query(string.format("REPLACE INTO pass(entry, desc, value) VALUES(%d, '%s', '%s')", self.context.entry, self.newDesc:getText(), self.newPass:getText()))
	self:removeSelf()
end

function vLayerPasswordDetail:onDelete(e)
	if e.name ~= "ended" then return end
	WindowMgr:popCheckWindow({
		title = 990002,
		desc = 990003,
    onConfirm = function()
    	print("onConfirm")
    	local sql = "DELETE FROM pass WHERE entry = %d"
    	DataBase:query(string.format(sql, self.context.entry))
    	self:removeSelf()
    end
	})
end

function vLayerPasswordDetail:onPasteToClipBoard(e)
	if e.name ~= "ended" then return end 
	NativeHelper:pasteToClipBoard(self.context.value)
	self:removeSelf() 
end


return vLayerPasswordDetail

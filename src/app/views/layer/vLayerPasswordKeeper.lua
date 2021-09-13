local ViewBaseEx 			= require("app.views.ViewBaseEx")
local DataBase 				= require("app.components.DataBase")
local WindowMgr 			= require("app.components.WindowMgr")
local Utils 				= require("app.components.Utils")
local vLayerPasswordKeeper 	= class("vLayerPasswordKeeper", ViewBaseEx)

local HEIGHT = 800
local offset = 0
function vLayerPasswordKeeper:onCreate()
        	WindowMgr:popCheckWindow({
        		title = 990002,
        		desc = 990001,
        	})
	self:onRefresh()
end

function vLayerPasswordKeeper:onPushToTop()
	print("vLayerPasswordKeeper:onPushToTop()")
	self:onRefresh()
end

function vLayerPasswordKeeper:onRefresh()
	self:removeAllChildren()
	offset = 30
	local result = DataBase:query(string.format("SELECT entry, desc, value FROM pass"))
	if #result == 0 then
		self:onNewEnter()
	else
		self:onNormalEnter()
		self:refreshSearch()
	end
	local bg = cc.Sprite:create("res/bg.jpg"):addTo(self):setLocalZOrder(-1)
end

function vLayerPasswordKeeper:onNormalEnter()
	self:cEditBox({
		size = cc.size(display.width * 0.8, 35),
		ap = cc.p(0.5, 1),
		op = 127,
		cb = handler(self, self.onTextChange),
		ph = "输入描述以提供模糊查询"
	}):addTo(self):move(0, display.cy - 30)
	offset = offset + 37
	self.layout = self:createLayout({
        size = cc.size(500, HEIGHT),
        ap = cc.p(0.5, 1)
	}):addTo(self):move(0, display.cy - offset)
	offset = offset + HEIGHT + 2

	self.catagoryView = require("app.components.TableViewEx"):create({
        size = cc.size(500, HEIGHT),
        direction = cc.SCROLLVIEW_DIRECTION_VERTICAL,
        fillOrder = cc.TABLEVIEW_FILL_TOPDOWN,
        cellSize = cc.size(500, 35),
    }):addTo(self.layout)
    self.catagoryView:onCellAtIndex(
        function(cell, index)
        	index = index + 1
        	cell.item = cell.item or self:createLayout({
        		size = cc.size(500, 35),
        		str = "",
        		fc = cc.c3b(0, 0, 0),
        		ap = cc.p(0, 0),
        		cb = function(e)
        			if e.name ~= "ended" then return end
        			WindowMgr:createWindow("app.views.layer.vLayerPasswordDetail", self.datas[index])
        		end
        	}):addTo(cell)
        	cell.item:setTitleStr(self.datas[index].desc)
            return cell
        end)


	self:createLayout({
        size = cc.size(500, 35),
        str = "添加新的密码",
        ap = cc.p(0.5, 1)
	}):addTo(self):move(0, display.cy - offset)
	offset = offset + 37
	self.newPass = self:cEditBox({
		size = cc.size(display.width * 0.8, 35),
		ap = cc.p(0.5, 1),
		op = 127,
		ph = "输入新的密码",
	}):addTo(self):move(0, display.cy - offset)
	offset = offset + 37

	self.newDesc = self:cEditBox({
		size = cc.size(display.width * 0.8, 35),
		ap = cc.p(0.5, 1),
		op = 127,
		ph = "新密码的描述",
	}):addTo(self):move(0, display.cy - offset)
	offset = offset + 37

	self:createLayout({
        size = cc.size(500, 35),
        str = "提交",
        ap = cc.p(0.5, 1),
        cb = handler(self, self.submitNewPass),
	}):addTo(self):move(0, display.cy - offset)
end

function vLayerPasswordKeeper:onNewEnter()
	self:createLayout({
        size = cc.size(500, 35),
        str = "第一次进入，请创建备忘录密码",
        ap = cc.p(0.5, 1),
	}):addTo(self):move(0, display.cy - offset)
	offset = offset + 37

	self.pw1 = self:cEditBox({
		size = cc.size(display.width * 0.8, 35),
		ap = cc.p(0.5, 1),
		op = 127,
	}):addTo(self):move(0, display.cy - offset)
	offset = offset + 37
	self.pw2 = self:cEditBox({
		size = cc.size(display.width * 0.8, 35),
		ap = cc.p(0.5, 1),
		op = 127,
	}):addTo(self):move(0, display.cy - offset)
	offset = offset + 37
	self:createLayout({
        size = cc.size(500, 35),
        str = "确认输入",
        ap = cc.p(0.5, 1),
        cb = function(e) 
        if e.name ~= "ended" and self.pw1:getText() == "" then return end 
        if self.pw1:getText() ~= self.pw2:getText() then
        	WindowMgr:popCheckWindow({
        		title = 990002,
        		desc = 990001,
        	})
        return end
		local sql = string.format("INSERT INTO pass(desc, value) VALUES('%s', '%s')", "此备忘录密码", self.pw2:getText())
		DataBase:query(sql)
        self:onRefresh()
    end
	}):addTo(self):move(0, display.cy - offset)
end

function vLayerPasswordKeeper:onTextChange(e, box)
	if e ~= "changed" then return end
	self:refreshSearch(box:getText() == "" and nil or box:getText())
end

function vLayerPasswordKeeper:refreshSearch(str)
	str = str or ".*"
	local result = DataBase:query(string.format("SELECT entry, desc, value FROM pass WHERE entry != 0"))
	local ret = {}
	for _, v in pairs(result) do
		if v.desc:find(str) then
			table.insert(ret, v)
		end
	end
	self.datas = ret
	self.catagoryView:setNumbers(#self.datas):reloadData()
end

function vLayerPasswordKeeper:submitNewPass(e)
	if e.name ~= "ended" or self.newPass:getText() == "" or self.newDesc:getText() == "" then return end
	DataBase:query(string.format("INSERT INTO pass(desc, value) VALUES('%s', '%s')", self.newDesc:getText(), self.newPass:getText()))
	-- DataBase:query(stirng.format("SELECT entry FROM pass WHERE desc = '%s'", self.newDesc:getText()))
	self.newPass:setText("")
	self.newDesc:setText("")
	self:refreshSearch()
end

return vLayerPasswordKeeper
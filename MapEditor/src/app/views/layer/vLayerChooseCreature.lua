local WindowMgr = require("app.components.WindowMgr")
local ViewBaseEx = require("app.views.ViewBaseEx")
local TableViewEx = require("app.components.TableViewEx")
local vLayerChooseCreature = class("vLayerChooseCreature", ViewBaseEx)


local WINDOW_SIZE = {
	width = 500,
	height = 600
}

function vLayerChooseCreature:onCreate()
	self:setAnchorPoint(0.5, 0.5)
	self:setContentSize(WINDOW_SIZE)
	local bg = self:createLayout({
		size = WINDOW_SIZE,
		ap = cc.p(0, 0),
		st = true,
	}):addTo(self)

	self:createLayout({
		size = cc.size(40, 40),
		ap = cc.p(1, 1),
		cb = function() WindowMgr:removeWindow(self) end,
		st = true,
	}):addTo(self):move(WINDOW_SIZE.width, WINDOW_SIZE.height)

	self:createLayout({
		size = cc.size(300, 40),
		ap = cc.p(0.5, 1),
		str = "選擇生物",
	}):addTo(self):move(WINDOW_SIZE.width * 0.5, WINDOW_SIZE.height)

	self:cEditBox({
		size = cc.size(400, 30),
		cb = function(state, box)
			if state == "changed" then
			    -- self:reloadData(box:getText())
			end
		end,
		ph = "输入需要查询的生物名称或id",
	}):addTo(self):move(WINDOW_SIZE.width * 0.5, WINDOW_SIZE.height - 100)


	self.tableView = import("app.components.TableViewEx"):create({
        cellSize = cc.size(300, 30),
        direction = cc.SCROLLVIEW_DIRECTION_VERTICAL,
        fillOrder = cc.TABLEVIEW_FILL_TOPDOWN,
        size = cc.size(300, 300),
    }):addTo(self):move(WINDOW_SIZE.width * 0.5, WINDOW_SIZE.height * 0.5):setAnchorPoint(0.5, 0.5)
    self.tableView:onCellAtIndex(handler(self, self.onCellAtIndex))
    self:loadAllCreatureInfoFromDB()
end

function vLayerChooseCreature:onCellAtIndex(cell, index)
	cell.item = cell.item or self:createLayout({
		size = cc.size(300, 30),
		str = "1",
		ap = cc.p(0, 0)
	}):addTo(cell)

	cell.item:setTitleStr("creatureInfo"..index)
end


function vLayerChooseCreature:loadAllCreatureInfoFromDB()
    self.tableView:setNumbers(100)
    self.tableView:reloadData()
end


return vLayerChooseCreature
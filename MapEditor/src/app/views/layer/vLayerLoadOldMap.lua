local WindowMgr = require("app.components.WindowMgr")
local ViewBaseEx = require("app.views.ViewBaseEx")
local TableViewEx = require("app.components.TableViewEx")
local vLayerCreateNewMap = class("vLayerCreateNewMap", ViewBaseEx)

local rootPath = lfs.currentdir().."/../../../../../maps/"
function vLayerCreateNewMap:onCreate( ... )
    self:autoAlgin()
	local bg = self:createLayout({
		size = display.size,
		color = cc.c3b(0, 0, 0),
		op = 255,
		cb = function() end
	}):addTo(self):move(display.center)

	self:createLayout({
		size = cc.size(300, 40),
		color = cc.c3b(255, 255, 255),
		op = 30,
		str = "创建新的地图"
	}):addTo(bg):move(display.cx, display.height - 50)

	self:createLayout({
		size = cc.size(300, 40),
		color = cc.c3b(255, 255, 255),
		op = 30,
		str = "返回",
		cb = function(e) if e.name ~= "ended" then return end WindowMgr:removeWindow(self) end
	}):addTo(bg):move(display.cx, 80)


	self:createLayout({
		size = cc.size(300, 40),
		color = cc.c3b(255, 255, 255),
		op = 30,
		str = "确认",
		cb = function(e) if e.name ~= "ended" then return end WindowMgr:removeWindow(self) end
	}):addTo(bg):move(display.cx, 140)

	self:cEditBox({
		size = cc.size(400, 30),
		cb = function(state, box)
			if state == "changed" then
			    self:reloadData(box:getText())
			end
		end
	}):addTo(self):move(display.cx, display.height - 100)

	local tableViewLayouter = self:createLayout({
		size = cc.size(300, 400),
		color = cc.c3b(255, 255, 255),
	}):addTo(self):move(display.cx, display.cy)

	self.tableView = import("app.components.TableViewEx"):create({
        cellSize = cc.size(300, 30),
        direction = cc.SCROLLVIEW_DIRECTION_VERTICAL,
        fillOrder = cc.TABLEVIEW_FILL_TOPDOWN,
        size = tableViewLayouter:getContentSize(),
    }):addTo(tableViewLayouter)

    self.tableView:onCellAtIndex(handler(self, self.onCellAtIndex))
    self:reloadData()
end

function vLayerCreateNewMap:reloadData(str)
    self._mapDatas = self:searchDirFor(str)
    self.tableView:setNumbers(#self._mapDatas)
    self.tableView:reloadData()
end

function vLayerCreateNewMap:onCellAtIndex(cell, index)
	index = index + 1
	cell.item = cell.item or self:createLayout({
		size = cc.size(300, 30),
		str = "123123",
		st = false,
		cb = handler(self, self.onTouchedCell)
	}):addTo(cell):setAnchorPoint(0, 0)

	cell.item:setTitleStr(self._mapDatas[index])
	cell.item.index = index
end

function vLayerCreateNewMap:onTouchedCell(e)
	if e.name ~= "ended" then return end
	WindowMgr:createWindow("app.views.layer.vLayerEditor", rootPath..e.target:getTitleStr())
	WindowMgr:removeWindow(self)
end



function vLayerCreateNewMap:searchDirFor(str)
	if not str or str == "" then str = ".*" end
	local ret = {}
    for dir in lfs.dir(rootPath) do
    	if string.sub(dir, 1, 1) ~= "." then
    		if string.find(dir, str) then table.insert(ret, dir) end
    	end
    end
    return ret
end


return vLayerCreateNewMap
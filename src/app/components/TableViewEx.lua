local TableViewEx = class("TableViewEx", cc.Node)

function TableViewEx:ctor(context)
	self.context = context
	self:setContentSize(context.size)
	self.tableView = cc.TableView:create(context.size):addTo(self)
	self.tableView:setDirection(context.direction or cc.SCROLLVIEW_DIRECTION_VERTICAL)
	self.tableView:setVerticalFillOrder(context.fillOrder or cc.TABLEVIEW_FILL_TOPDOWN)
	self.tableView:setDelegate()
	self.tableView:registerScriptHandler(handler(self, self.onNativeCellAtIndex), cc.TABLECELL_SIZE_AT_INDEX)
    self.tableView:registerScriptHandler(handler(self, self.onNativeCellSizeAtIndex), cc.TABLECELL_SIZE_FOR_INDEX)
	self.tableView:registerScriptHandler(handler(self, self.onNativeNumberInTableView), cc.NUMBER_OF_CELLS_IN_TABLEVIEW)
end

function TableViewEx:setNumbers(number)
	self.m_Length = number
	return self
end

function TableViewEx:onCellAtIndex(foo)
	self.__onCellAtIndex = foo
	return self
end

function TableViewEx:onNativeCellSizeAtIndex(...)
	local size = self.context.cellSize
	size = type(size) == "table" and size or size(...)
	return size.width, size.height
end

function TableViewEx:onNativeCellAtIndex(table, index)
    local cell = self.tableView:dequeueCell() or cc.TableViewCell:new()
    xpcall(function() self.__onCellAtIndex(cell, index) end, function(msg) __G__TRACKBACK__(msg) end)
	return cell
end

function TableViewEx:onNativeNumberInTableView(foo)
	return self.m_Length and self.m_Length or 0
end

function TableViewEx:reloadData()
	self.tableView:reloadData()
	return self
end


return TableViewEx
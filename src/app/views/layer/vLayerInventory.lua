local ViewBaseEx 		= require("app.views.ViewBaseEx")
local Player 			= require("app.components.Object.Player")
local GridView			= require("app.components.GridView")
local ShareDefine		= require("app.ShareDefine")
local DataBase 			= require("app.components.DataBase")
local WindowMgr			= require("app.components.WindowMgr")
local vLayerInventory 	= class("vLayerInventory", ViewBaseEx)

vLayerInventory.DisableDuplicateCreation = true
vLayerInventory.RESOURCE_FILENAME = "res/csb/layer/CSB_Layer_Inventory.csb"
vLayerInventory.RESOURCE_BINDING = {
	ButtonExit = "Exit"
}

local CATAGORYS = {
	ALL 		= 0,
	EQUIPMENTS 	= 1,
	MISC 		= 2
}

function vLayerInventory:onCreate()
	self.m_Catagory = CATAGORYS.ALL
	self.m_Children["Text_Title"]:setString(DataBase:getStringByID(100001))
	self:onReset()
	self:regiestCustomEventListenter("MSG_INVENTORY_DATA_CHANGED", handler(self, self.onReset))
	self:regiestCustomEventListenter("MSG_ON_INSTANCE_DATA_DIRTY", handler(self, self.updateMoney))
end

function vLayerInventory:onReset()
	self:initViews()
	self.inventoryDatas = self:fetchInventoryDatas()
	self:fetchCatagorys()
	self:sortInventory()
	self.gridView:setDatas(self.inventoryDatas)
	self:updateMoney()
end

function vLayerInventory:updateMoney()
	local plr = Player:getInstance()
	self.m_Children["Text_Money"]:setString(plr:getMoney())
end

function vLayerInventory:initViews()
	if self.gridView == nil then
		-- local itemCount = 100
		local parent = self.m_Children["Panel_Slots"]
		self.gridView = GridView:create({
	        viewSize    = parent:getContentSize(),
	        cellSize    = { width = 80, height = 80 },
	        rowCount    = 5,
	        fieldCount  = 10,
	        VGAP        = 3,
	        HGAP        = 3,
	    }):addTo(parent):move(0, 0):setAnchorPoint(0, 0)
	    self.gridView.onCellAtIndex = handler(self, self.onCellAtIndex)
	end

	if self.catagoryView == nil then
		self.catagoryView = import("app.components.TableViewEx"):create({
	        cellSize = cc.size(180, 40),
	        direction = cc.SCROLLVIEW_DIRECTION_VERTICAL,
	        fillOrder = cc.TABLEVIEW_FILL_TOPDOWN,
	        size = self.m_Children["Panel_Catagory"]:getContentSize(),
	    }):addTo(self.m_Children["Panel_Catagory"])
	    self.catagoryView:onCellAtIndex(
	        function(cell, data)
	        	cell.item = cell.item or import("app.views.node.vNodeInventoryCatagory"):create():addTo(cell)
	        	cell.item:onReset(data)
	            return cell
	        end)
	end
end

function vLayerInventory:getPlayerInventorySlotCount(inventoryDatas)
	local count = ShareDefine.inventoryBaseSlotCount()
	for i = ShareDefine.containerSlotBegin(), ShareDefine.containerSlotEnd() do
		local container = inventoryDatas[i]
		if container then
			local extraCount = container.template.container_slot_count
			count = count + extraCount
		end
	end
	return count - 1
end

function vLayerInventory:fetchCatagorys()
    self.catagoryView:setNumbers(3):reloadData()
end

function vLayerInventory:canFetchByCatagory(itemData)
	return true
end

function vLayerInventory:sortInventory()

end

function vLayerInventory:fetchInventoryDatas()
	local currPlr = Player:getInstance()
	local datas = currPlr:getInventoryData() or {}
	local retDatas = {}

	local fetchSlotBegin 	= ShareDefine.inventorySlotBegin()
	local fetchSlotEnd 		= fetchSlotBegin + currPlr:getInventorySlotCount()

	for slot_id = fetchSlotBegin, fetchSlotEnd do
		local currData = datas[slot_id] or "null"
		table.insert(retDatas, currData)
	end
	return retDatas
end

function vLayerInventory:onCellAtIndex(cell, data)
	cell.item = cell.item or require("app.views.node.vNodeInventorySlot"):create():addTo(cell)
	cell.item:onReset(data)
end

function vLayerInventory:Exit(e)
	if e.name ~= "ended" then return end
	self:removeSelf()
end


return vLayerInventory
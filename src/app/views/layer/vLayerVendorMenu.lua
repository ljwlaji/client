local ViewBaseEx 			= import("app.views.ViewBaseEx")
local TableViewEx      		= import("app.components.TableViewEx")
local DataBase 				= import("app.components.DataBase")
local vLayerVendorMenu 		= class("vLayerVendorMenu", ViewBaseEx)

vLayerVendorMenu.RESOURCE_FILENAME = "res/csb/layer/CSB_Layer_VendorMenu.csb"
vLayerVendorMenu.RESOURCE_BINDING = {
	Panel_Exit = "onTouchPanelExit"
}

function vLayerVendorMenu:onCreate(creatureEntry)
	self.VendorTable = import("app.components.TableViewEx"):create({
        cellSize = cc.size(400, 80),
        direction = cc.SCROLLVIEW_DIRECTION_VERTICAL,
        fillOrder = cc.TABLEVIEW_FILL_TOPDOWN,
        size = self.m_Children["Panel_VendorList"]:getContentSize(),
    }):addTo(self.m_Children["Panel_VendorList"])
    self.VendorTable:onCellAtIndex(handler(self, self.onCellAtIndex))
	self:onReset(creatureEntry)
end

function vLayerVendorMenu:onReset(creatureEntry)
	local sql = string.format("SELECT * FROM vendor_template AS VT WHERE VT.creature_entry = '%d'", creatureEntry)
	self.datas = DataBase:query(sql)
	for k, v in pairs(self.datas) do
		v.template = DataBase:getItemTemplateByEntry(v.item_entry)
	end
    self.VendorTable:setNumbers(#self.datas):reloadData()
end

function vLayerVendorMenu:onCellAtIndex(cell, index)
	cell.item = cell.item or import("app.views.node.vNodeVendorMenuCell"):create():addTo(cell)
	cell.item:onReset(self.datas[index + 1])
end

function vLayerVendorMenu:onTouchPanelExit(e)
	if e.name ~= "ended" then return end
	self:removeFromParent()
end

return vLayerVendorMenu
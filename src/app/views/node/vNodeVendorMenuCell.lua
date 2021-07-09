local ViewBaseEx      		= import("app.views.ViewBaseEx")
local InventorySlot 		= import("app.views.node.vNodeInventorySlot")
local ShareDefine 			= import("app.ShareDefine")
local Utils             	= import("app.components.Utils")
local DataBase 				= import("app.components.DataBase")
local vNodeVendorMenuCell 	= class("vNodeVendorMenuCell", ViewBaseEx)

vNodeVendorMenuCell.RESOURCE_FILENAME = "res/csb/node/CSB_Node_VendorMenuCell.csb"
vNodeVendorMenuCell.RESOURCE_BINDING = {
}

function vNodeVendorMenuCell:onCreate()
	self.slot = InventorySlot:create():addTo(self.m_Children["Panel_Icon"])
end

function vNodeVendorMenuCell:onReset(context)
	self.slot:onReset(context, true)
	local template = context.template
	local gold 		= math.floor(template.buy_price * 0.0001)
	local silver 	= math.floor(template.buy_price % 10000 * 0.01)
	local copper 	= template.buy_price % 100
	self.m_Children["Text_Name"]:setColor(ShareDefine.getQualityColor(template.quality))
	self.m_Children["Text_Name"]:setString(DataBase:getStringByID(template.name_string))
	self.m_Children["Text_Gold"]:setString(gold):setVisible(gold > 0)
	self.m_Children["Text_Silver"]:setString(silver):setVisible(silver > 0)
	self.m_Children["Text_Copper"]:setString(copper):setVisible(copper > 0)
	self.m_Children["Sprite_Gold"]:setVisible(gold > 0)
	self.m_Children["Sprite_Silver"]:setVisible(silver > 0)
	self.m_Children["Sprite_Copper"]:setVisible(copper > 0)
	Utils.autoAlginChildrenH(self.m_Children["Panel_Price"], 1)
end

return vNodeVendorMenuCell
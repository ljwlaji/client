local ViewBaseEx 				= import("app.views.ViewBaseEx")
local ShareDefine 				= import("app.ShareDefine")
local DataBase 					= import("app.components.DataBase")
local vNodeItemDetailUpper 		= class("vNodeItemDetailUpper", ViewBaseEx)

vNodeItemDetailUpper.RESOURCE_FILENAME = "res/csb/node/CSB_Node_ItemDetail_Upper.csb"
vNodeItemDetailUpper.RESOURCE_BINDING = {
}

function vNodeItemDetailUpper:onCreate()
end

function vNodeItemDetailUpper:onReset(context)
	local isWeapon = not ShareDefine.isAmmorType(context.type)
	if isWeapon then self.m_Children["Text_Speed"]:setString(string.format("%.02f", context.attack_speed * 0.01)) end
	self.m_Children["Text_Speed"]:setVisible(isWeapon)
	self.m_Children["Text_ItemName"]:setColor(ShareDefine.getQualityColor(context.quailty))
	self.m_Children["Text_ItemName"]:setString(DataBase:getStringByID(context.name_string))
	self.m_Children["Text_ItemLevel"]:setString(string.format(DataBase:getStringByID(297), context.item_level))
	self.m_Children["Text_Slot"]:setString(DataBase:getStringByID(context.equip_slot + 300))
	self.m_Children["Text_Type"]:setString(DataBase:getStringByID(context.type + 200))
	self.m_Children["Text_AttackOrAmmor"]:setString(isWeapon and string.format(DataBase:getStringByID(299), context.min_attack, context.max_attack)
															 or string.format(DataBase:getStringByID(298), context.ammor))
end

return vNodeItemDetailUpper
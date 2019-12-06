local ViewBaseEx 				= import("app.views.ViewBaseEx")
local ShareDefine 				= import("app.ShareDefine")
local DataBase 					= import("app.components.DataBase")
local Player 					= import("app.components.Object.Player")
local vLayerItemDetail 			= class("vLayerItemDetail", ViewBaseEx)

vLayerItemDetail.DisableDuplicateCreation = true
vLayerItemDetail.RESOURCE_FILENAME = "res/csb/layer/CSB_Layer_ItemDetail.csb"
vLayerItemDetail.RESOURCE_BINDING = {
	Panel_Exit 		= "onTouchPanelExit",
	Button_Equip 	= "onTouchButtonEquip",
	Button_Enchant 	= "onTouchButtonEnchant"
}

local SINGLE_LINE_HEIGHT = 30

local SLOT_TYPE_EQUIPMENT = 1
local SLOT_TYPE_INVENTORY = 2

function vLayerItemDetail:onCreate(...)
	self:onReset(...)
	self:regiestCustomEventListenter("MSG_INVENTORY_DATA_CHANGED", handler(self, self.onRecvInventoryDataChanged))
end

function vLayerItemDetail:onReset(itemData, slotType)
	self.slotType = slotType
	self.itemData = itemData
	self.m_Children["Text_Equip"]:setString(DataBase:getStringByID(slotType + 280))
	self.m_OffsetY = 0
	self.m_Children["Panel_Detail"]:removeAllChildren()
	local itemTemplate = itemData.template
	import("app.views.node.vNodeItemDetailUpper"):create()
												 :addTo(self.m_Children["Panel_Detail"])
												 :onReset(itemTemplate)

	-- 动态文本

	-- 攻击速度
	if not ShareDefine.isAmmorType(itemData.template.type) then
		local dps = (itemTemplate.min_attack_power + itemTemplate.max_attack_power) * 0.5 / itemTemplate.attack_speed * 0.01
		self:newLine(string.format(DataBase:getStringByID(296), dps)) 
	end

	-- 基础属性
	for attrName, attrValue in pairs(itemTemplate.attrs) do
		self:newLine(string.format("+%d %s", attrValue, ShareDefine.getStateStringByStateName(attrName)))
	end

	-- 耐久度
	if itemTemplate.max_durable > 0 then
		self:newLine(string.format( DataBase:getStringByID(295), itemData.durable, itemTemplate.max_durable ))
	end

	if itemTemplate.require_class > 0 then
		self:newLine(string.format( DataBase:getStringByID(294), DataBase:getStringByID(itemTemplate.require_class + 100) ))
	end

	if itemTemplate.require_level > 0 then
		self:newLine(string.format( DataBase:getStringByID(293), itemTemplate.require_level))
	end

	self.m_Children["Panel_Detail"]:setPositionY(-self.m_OffsetY + 130)
	self.m_Children["Panel_Frame"]:setContentSize(400, -self.m_OffsetY + 130 + 130)

end

function vLayerItemDetail:newLine(str)
	import("app.views.node.vNodeItemDetailLine"):create()
												:addTo(self.m_Children["Panel_Detail"])
												:setPositionY(self.m_OffsetY)
												:onReset(str)
	self.m_OffsetY = self.m_OffsetY - SINGLE_LINE_HEIGHT
end

function vLayerItemDetail:onTouchPanelExit(e)
	if e.name ~= "ended" then return end
	self:removeFromParent()
end

function vLayerItemDetail:onTouchButtonEquip(e)
	if e.name ~= "ended" then return end
	local plr = Player:getInstance()
	assert(plr, "No Player Result!")
	if self.slotType == SLOT_TYPE_EQUIPMENT then
		plr:tryUnEquipItem(self.itemData.slot_id)
	else
		plr:tryEquipItem(self.itemData.slot_id)
	end
end

function vLayerItemDetail:onTouchButtonEnchant(e)
	if e.name ~= "ended" then return end

end

function vLayerItemDetail:onRecvInventoryDataChanged()
	self:removeFromParent()
end

return vLayerItemDetail
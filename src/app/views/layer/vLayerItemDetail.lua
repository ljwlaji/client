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

-- 0 for preview
local SLOT_TYPE_PREVIEW 	= 0
local SLOT_TYPE_EQUIPMENT 	= 1
local SLOT_TYPE_INVENTORY 	= 2

function vLayerItemDetail:onCreate(...)
	self:onReset(...)
	self:regiestCustomEventListenter("MSG_INVENTORY_DATA_CHANGED", handler(self, self.onRecvInventoryDataChanged))
end

function vLayerItemDetail:onReset(itemData, slotType)
	local plr = Player:getInstance()
	self.slotType = slotType
	self.itemData = itemData
	self.m_OffsetY = 0
	self.m_Children["Panel_Detail"]:removeAllChildren()
	local itemTemplate = itemData.template
	import("app.views.node.vNodeItemDetailUpper"):create()
												 :addTo(self.m_Children["Panel_Detail"])
												 :onReset(itemTemplate)

	-- 动态文本

	-- 攻击速度
	if not ShareDefine.isAmmorType(itemData.template.type) then
		local dps = (itemTemplate.minAttack + itemTemplate.maxAttack) * 0.5 / itemTemplate.attack_speed * 0.01
		self:newLine(string.format(DataBase:getStringByID(296), dps)) 
	end

	-- 基础属性
	for attrName, attrValue in pairs(itemTemplate.attrs) do
		self:newLine(string.format("+%d %s", attrValue, ShareDefine.getStateStringByStateIndex(attrName)))
	end

	-- 耐久度
	if itemData.durable > 0 then
		self:newLine(string.format( DataBase:getStringByID(295), itemData.durable or itemTemplate.max_durable, itemTemplate.max_durable ))
	end

	if itemTemplate.require_class > 0 then
		self:newLine(string.format(DataBase:getStringByID(294), DataBase:getStringByID(itemTemplate.require_class + 100)), itemTemplate.require_class == plr:getClass() and cc.c3b(255,255,255) or cc.c3b(255,50,50))
	end

	if itemTemplate.require_level > 0 then
		self:newLine(string.format( DataBase:getStringByID(293), itemTemplate.require_level))
	end

	local offset = self.slotType ~= 0 and 130 or 0
	self.m_Children["Panel_Detail"]:setPositionY(-self.m_OffsetY + offset)
	self.m_Children["Panel_Frame"]:setContentSize(400, -self.m_OffsetY + 130 + offset)

	if self.slotType then
		self.m_Children["Text_Equip"]:setString(DataBase:getStringByID(slotType + 280))
	end
	self.m_Children["Panel_Buttom"]:setVisible(self.slotType ~= 0)

end

function vLayerItemDetail:newLine(str, color)
	import("app.views.node.vNodeItemDetailLine"):create()
												:addTo(self.m_Children["Panel_Detail"])
												:setPositionY(self.m_OffsetY)
												:onReset(str, color)

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
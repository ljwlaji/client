local ViewBaseEx 		= import("app.views.ViewBaseEx")
local ShareDefine 		= import("app.ShareDefine")
local DataBase 			= import("app.components.DataBase")
local Player 			= import("app.components.Object.Player")
local ShareDefine		= import("app.ShareDefine")
local WindowMgr			= import("app.components.WindowMgr")
local vLayerEquipments 	= class("vLayerEquipments", ViewBaseEx)

vLayerEquipments.DisableDuplicateCreation = true
vLayerEquipments.RESOURCE_FILENAME = "res/csb/layer/CSB_Layer_Equipment.csb"
vLayerEquipments.RESOURCE_BINDING = {
	ButtonExit = "Exit"
}

function vLayerEquipments:onCreate()
	for slotID = ShareDefine.equipSlotBegin(), ShareDefine.equipSlotEnd() do
		self.m_Children["Slot_"..slotID]:onTouch(handler(self, self.onTouchEquiptmentSlot))
	end
end

function vLayerEquipments:onReset()
	self.datas = {}
	local currPlr = Player:getInstance()
	local playerData = currPlr and currPlr:getInventoryData() or {}
	for slot_id, itemData in pairs(playerData) do
		if ShareDefine.isEquipSlot(slot_id) then
			self.datas[slot_id] = itemData
		end
	end
	for slotID = ShareDefine.equipSlotBegin(), ShareDefine.equipSlotEnd() do
		self.m_Children["Slot_"..slotID]:removeAllChildren()
	end
	self:refreshAllSlots()
	self:refreshStrings()
end

function vLayerEquipments:refreshAllSlots()
	for slotID, v in pairs(self.datas) do
		local slot = self.m_Children["Slot_"..slotID]
		cc.Sprite:create(ShareDefine.getItemIconPath(v.template))
				 :addTo(slot)
				 :move(slot:getContentSize().width * 0.5, slot:getContentSize().height * 0.5)
	end
end

function vLayerEquipments:refreshStrings()
	local currPlr = Player:getInstance()
	self.m_Children["Text_Misc"]:setString(string.format(DataBase:getStringByID(10007), currPlr:getLevel(), currPlr:getClassString()))
	self.m_Children["Text_Name"]:setString(currPlr:getName())
end

function vLayerEquipments:onTouchEquiptmentSlot(e)
	if e.name ~= "ended" then return end
	local slotData = self.datas[e.target:getTag()]
	if not slotData then return end
	WindowMgr:createWindow("app.views.layer.vLayerItemDetail", slotData)
	
	do return end
	local window = WindowMgr:findWindowIndexByClassName("vLayerItemDetail")
	if e.name == "ended" or e.name == "cancelled" then
		if window then window:removeFromParent() end
		return 
	end
	if window then return end
	WindowMgr:createWindow("app.views.layer.vLayerItemDetail"):onReset(slotData)
end

function vLayerEquipments:onEnterTransitionFinish()
	self:onReset()
end

function vLayerEquipments:Exit()
	self:removeFromParent()
end

return vLayerEquipments
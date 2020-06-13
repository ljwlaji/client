local ViewBaseEx 			= import("app.views.ViewBaseEx")
local TalentIcon 			= import("app.views.node.vNodeTalentIcon")
local DataBase 				= import("app.components.DataBase")
local Player 				= import("app.components.Object.Player")
local vLayerTalent 			= class("vLayerTalent", ViewBaseEx)

vLayerTalent.DisableDuplicateCreation = true
vLayerTalent.RESOURCE_FILENAME = "res/csb/layer/CSB_Layer_Talent.csb"
vLayerTalent.RESOURCE_BINDING = {
	Panel_Exit		  = "onTouchPanelExit",
	Button_Catagory_1 = "onTouchButtonCatagory",
	Button_Catagory_2 = "onTouchButtonCatagory",
	Button_Catagory_3 = "onTouchButtonCatagory",
}

local GAP = 74				--列间距
local POS_START	= 42		--起点

function vLayerTalent:onCreate()
	self.m_Class = nil
	self.m_DisplayCatagory = nil
	self:onReset()
end

function vLayerTalent:onReset()
	local plr = Player:getInstance()
	self.m_Class = plr:getClass()
	for i=1, 3 do
		self.m_Children["Text_Catagory_"..i]:setString(DataBase:getStringByID(500 + plr:getClass() * 10 + i))
		-- cc.Label.getLetter(self.m_Children["Text_Catagory_"..i]:getVirtualRenderer(), 1):setVisible(false) -- for hide testting
	end
	self:switchToCatagory(1)
end

function vLayerTalent:switchToCatagory(catagory)
	if self.m_DisplayCatagory == catagory then return end

	self.m_Children["Panel_Slot"]:removeAllChildren()
	local templateResult = DataBase:query(string.format("SELECT * FROM talent_template WHERE catagory = %d and class = %d", catagory, self.m_Class))
	for k, info in pairs(templateResult) do
		local ico = TalentIcon:create()
							  :addTo(self.m_Children["Panel_Slot"])
							  :onReset(info)
							  :move((info.position_index % 4) * GAP + POS_START,
							  		528 - (math.floor(info.position_index * 0.25) * GAP + POS_START))
	end
	self.m_DisplayCatagory = catagory
end

function vLayerTalent:onTouchButtonCatagory(e)
	if e.name ~= "ended" then return end
	local catagory = e.target:getTag()
	self:switchToCatagory(catagory)
end

function vLayerTalent:onTouchPanelExit(e)
	if e.name ~= "ended" then return end
	self:removeFromParent()
end

return vLayerTalent
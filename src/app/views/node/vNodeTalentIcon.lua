local ViewBaseEx 			= import("app.views.ViewBaseEx")
local vNodeTalentIcon 		= class("vNodeTalentIcon", ViewBaseEx)

vNodeInventorySlot.RESOURCE_FILENAME = "res/csb/node/CSB_Node_TalentIcon.csb"
vNodeInventorySlot.RESOURCE_BINDING = {
	Icon_Talent = "onTouchTalentSpell"
}

function vNodeTalentIcon:onCreate(TalentInfo)
	self.m_Progress = 0
	self.m_CurrentSpellInfo = nil
end

function vNodeTalentIcon:onReset()

end

function vNodeTalentIcon:onTouchTalentSpell(e)
	if e.name ~= "ended" then return end

end

return vNodeTalentIcon
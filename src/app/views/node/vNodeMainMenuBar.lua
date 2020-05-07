local ViewBaseEx 			= import("app.views.ViewBaseEx")
local DataBase 				= import("app.components.DataBase")
local WindowMgr				= import("app.components.WindowMgr")
local vNodeMainMenuBar 		= class("vNodeMainMenuBar", ViewBaseEx)

vNodeMainMenuBar.RESOURCE_FILENAME = "res/csb/node/CSB_Node_MainMenuBar.csb"
vNodeMainMenuBar.RESOURCE_BINDING = {
	Button_Character 	= "onTouchButtonCharacter",
	Button_Spell 		= "onTouchButtonSpell",
	Button_Inventory 	= "onTouchButtonInventory",
	Button_Quest 		= "onTouchButtonQuest",
	Button_Talent 		= "onTouchButtonTalent",
	Button_Settings 	= "onTouchButtonSettings",
}

function vNodeMainMenuBar:onCreate()
	self:setStr(self.m_Children["Text_Character"], 	10008)
	self:setStr(self.m_Children["Text_Spell"], 		10009)
	self:setStr(self.m_Children["Text_Talent"], 	10010)
	self:setStr(self.m_Children["Text_Quest"], 		10011)
	self:setStr(self.m_Children["Text_Quest"], 		10011)
	self:setStr(self.m_Children["Text_Inventory"], 	100001)
end

function vNodeMainMenuBar:setStr(obj, id)
	obj:setString(DataBase:getStringByID(id))
end

function vNodeMainMenuBar:onReset()

end

function vNodeMainMenuBar:onTouchButtonCharacter(e)
	if e.name ~= "ended" then return end
	WindowMgr:createWindow("app.views.layer.vLayerEquipments")
end

function vNodeMainMenuBar:onTouchButtonSpell(e)
	if e.name ~= "ended" then return end
	WindowMgr:createWindow("app.views.layer.vLayerSpellBook")
end

function vNodeMainMenuBar:onTouchButtonInventory(e)
	if e.name ~= "ended" then return end
	WindowMgr:createWindow("app.views.layer.vLayerInventory")
end

function vNodeMainMenuBar:onTouchButtonQuest(e)
	if e.name ~= "ended" then return end
end

function vNodeMainMenuBar:onTouchButtonTalent(e)
	if e.name ~= "ended" then return end
end

function vNodeMainMenuBar:onTouchButtonSettings(e)
	if e.name ~= "ended" then return end
	
end





return vNodeMainMenuBar
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
	self:setStr(self.m_Children["Text_Inventory"], 	100001)
	self:setStr(self.m_Children["Text_Talent"], 	10010)
	self:setStr(self.m_Children["Text_Quest"], 		10011)
	self:setStr(self.m_Children["Text_Settings"], 	10012)
	-- self:setStr(self.m_Children["Text_Quest"], 		10011)
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
	WindowMgr:createWindow("app.views.layer.vLayerQuestBook")
end

function vNodeMainMenuBar:onTouchButtonTalent(e)
	if e.name ~= "ended" then return end
	WindowMgr:createWindow("app.views.layer.vLayerTalent")
end

function vNodeMainMenuBar:onTouchButtonSettings(e)
	if e.name ~= "ended" then return end
	-- import("app.components.Object.Player"):getInstance():getMap():removeFromParent()
	-- -- import("app.components.Object.Player"):getInstance():addItem(1, 111)

	-- local entry = 3
	-- local amount = 81
	-- -- if import("app.components.Object.Player"):getInstance():hasSpaceFor(entry, amount) then
	-- -- 	import("app.components.Object.Player"):getInstance():addItem(entry, amount)
	-- -- end
	-- dump(import("app.components.Object.Player"):getInstance():getItemCount(entry))
	-- if import("app.components.Object.Player"):getInstance():getItemCount(entry) > 55 then
	-- 	import("app.components.Object.Player"):getInstance():destoryItem(entry, 55)
	-- else
	-- 	release_print("Item Count Less Than 55!")
	-- end
end





return vNodeMainMenuBar
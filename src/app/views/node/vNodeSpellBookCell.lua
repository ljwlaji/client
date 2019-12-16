local ViewBaseEx 			= import("app.views.ViewBaseEx")
local DataBase 				= import("app.components.DataBase")
local WindowMgr				= import("app.components.WindowMgr")
local vNodeSpellBookCell 	= class("vNodeSpellBookCell", ViewBaseEx)

vNodeSpellBookCell.RESOURCE_FILENAME = "res/csb/node/CSB_Node_SpellBookCell.csb"
vNodeSpellBookCell.RESOURCE_BINDING = {
	Panel_BackGround = "onTouchCell"
}



function vNodeSpellBookCell:onCreate()
	self.m_Children["Panel_BackGround"]:setSwallowTouches(false)
	self.m_Children["Panel_Icon"]:setSwallowTouches(false)
end

function vNodeSpellBookCell:onReset(context)
	self.context = context
	self.m_Children["Sprite_Icon"]:setTexture(string.format("res/ui/icon/%s", context.icon_name))
	self.m_Children["Text_SpellName"]:setString(DataBase:getStringByID(context.name_string))
end


function vNodeSpellBookCell:onTouchCell(e)
	if e.name ~= "ended" then return end
	if cc.pGetDistance(e.target:getTouchBeganPosition(), e.target:getTouchEndPosition()) > 20 then return end
	WindowMgr:createWindow("app.views.layer.vLayerSpellInfo", self.context)
end


return vNodeSpellBookCell
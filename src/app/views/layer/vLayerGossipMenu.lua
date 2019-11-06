local ViewBaseEx 		= import("app.views.ViewBaseEx")
local vNodeGossipMenu 	= class("vNodeGossipMenu", ViewBaseEx)

vNodeGossipMenu.RESOURCE_FILENAME = "res/csb/layer/CSB_Layer_Gossip_Menu.csb"
vNodeGossipMenu.RESOURCE_BINDING = {
	Panel_2 = "Exit"
}

function vNodeGossipMenu:onCreate(...)
	release_print("vNodeGossipMenu:onCreate(GossipItems, player, creature)")
	dump({...})
end

function vNodeGossipMenu:Exit()
	self:removeFromParent()
end

return vNodeGossipMenu
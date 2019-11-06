local ViewBaseEx 		= import("app.views.ViewBaseEx")
local vNodeGossipMenu 	= class("vNodeGossipMenu", ViewBaseEx)

vNodeGossipMenu.RESOURCE_FILENAME = "res/csb/layer/CSB_Layer_Gossip_Menu.csb"
vNodeGossipMenu.RESOURCE_BINDING = {
}

function vNodeGossipMenu:onCreate(...)
	release_print("vNodeGossipMenu:onCreate(GossipItems, player, creature)")
	dump({...})
end

return vNodeGossipMenu
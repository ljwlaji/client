local ViewBaseEx 		= import("app.views.ViewBaseEx")
local vNodeGossipMenu 	= class("vNodeGossipMenu", ViewBaseEx)

vNodeGossipMenu.RESOURCE_FILENAME = "res/csb/node/CSB_Node_Gossip_Menu.csb"
vNodeGossipMenu.RESOURCE_BINDING = {
}

function vNodeGossipMenu:onCreate(GossipItems, player, creature)
	
end

return vNodeGossipMenu
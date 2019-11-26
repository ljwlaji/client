local ViewBaseEx 		= import("app.views.ViewBaseEx")
local vNodeGossipItem 	= class("vNodeGossipItem", ViewBaseEx)

vNodeGossipItem.RESOURCE_FILENAME = "res/csb/node/CSB_Node_GossipItem.csb"
vNodeGossipItem.RESOURCE_BINDING = {
	Panel_Touch = "onTouchCell"
}

local MenuIcons = {
	[1] = "icon_Compose.png",
	[2] = "icon_Disenchant.png",
	[3] = "Icon_Enchant.png",
	[4] = "Icon_Pet.png",
}

function vNodeGossipItem:onCreate()
	self.m_Children["Panel_Touch"]:setSwallowTouches(false)
end

function vNodeGossipItem:refresh(context)
	self.m_Children["Image_Icon"]:setTexture("ui/common/"..MenuIcons[context.IconIndex])
	self.context = context
end

function vNodeGossipItem:onEnterTransitionFinish()

end

function vNodeGossipItem:onTouchCell(e)
	if e.name ~= "ended" then return end
	if cc.pGetDistance(e.target:getTouchBeganPosition(), e.target:getTouchEndPosition()) > 20 then return end
	if self.onTouch then self.onTouch(self.context) end
end

return vNodeGossipItem
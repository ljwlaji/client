local ViewBaseEx 		= import("app.views.ViewBaseEx")
local DataBase 			= import("app.components.DataBase")
local GossipItem 		= import("app.views.node.vNodeGossipItem")
local TableViewEx      	= import("app.components.TableViewEx")
local vNodeGossipMenu 	= class("vNodeGossipMenu", ViewBaseEx)

vNodeGossipMenu.RESOURCE_FILENAME = "res/csb/layer/CSB_Layer_Gossip_Menu.csb"
vNodeGossipMenu.RESOURCE_BINDING = {
	ButtonBack = "Exit"
}

function vNodeGossipMenu:onCreate(GossipItems, player, sender, titleStringID)
	self.titleStringID = titleStringID
	self.GossipItems = GossipItems
	self.player = player
	self.sender = sender
	self:autoAlgin()
end

function vNodeGossipMenu:onEnterTransitionFinish()
    self.m_Children["Text_Title"]:setString(DataBase:getStringByID(self.titleStringID))
    self.sender:createModelByID(self.sender.context.model_id):addTo(self.m_Children["Node_Npc"]):setAnchorPoint(0.5, 0)
    self.m_Children["Text_Npc_Name"]:setString(self.sender:getName())

    self.GossipItemTable = import("app.components.TableViewEx"):create({
        cellSize = cc.size(700, 60),
        direction = cc.SCROLLVIEW_DIRECTION_VERTICAL,
        fillOrder = cc.TABLEVIEW_FILL_TOPDOWN,
        size = self.m_Children["GossipPanel"]:getContentSize(),
    }):addTo(self.m_Children["GossipPanel"])

    self.GossipItemTable:onCellAtIndex(handler(self, self.onCellAtIndex))
    self.GossipItemTable:setNumbers(#self.GossipItems):reloadData()
end

function vNodeGossipMenu:createGossipItem()
	local item = GossipItem:create()
	item.onTouch = handler(self, self.onTouchedGossipItem)
	return item
end

function vNodeGossipMenu:onCellAtIndex(cell, index)
	index = index + 1
	cell.item = cell.item or self:createGossipItem():addTo(cell)
	cell.item:refresh(self.GossipItems[index])
    return cell
end

function vNodeGossipMenu:onTouchedGossipItem(context)
	local ai = self.sender:getAI()
	if ai and ai.onGossipSelect then
		ai:onGossipSelect(self.player, self.sender, context.GossipSender, context.GossipIndex)
	end
end

function vNodeGossipMenu:Exit(e)
	if e.name ~= "ended" then return end
	self:removeFromParent()
end

return vNodeGossipMenu
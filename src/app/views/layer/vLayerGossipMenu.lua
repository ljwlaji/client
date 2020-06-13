local ViewBaseEx 		= import("app.views.ViewBaseEx")
local DataBase 			= import("app.components.DataBase")
local GossipItem 		= import("app.views.node.vNodeGossipItem")
local TableViewEx      	= import("app.components.TableViewEx")
local vLayerGossipMenu 	= class("vLayerGossipMenu", ViewBaseEx)

vLayerGossipMenu.RESOURCE_FILENAME = "res/csb/layer/CSB_Layer_Gossip_Menu.csb"
vLayerGossipMenu.RESOURCE_BINDING = {
	ButtonBack = "Exit"
}

function vLayerGossipMenu:onCreate(GossipItems, player, sender, titleStringID)
	self.titleStringID = titleStringID
	self.GossipItems = GossipItems
	self.player = player
	self.sender = sender
	-- self:autoAlgin()
end

function vLayerGossipMenu:onEnterTransitionFinish()
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

function vLayerGossipMenu:createGossipItem()
	local item = GossipItem:create()
	item.onTouch = handler(self, self.onTouchedGossipItem)
	return item
end

function vLayerGossipMenu:onCellAtIndex(cell, index)
	index = index + 1
	cell.item = cell.item or self:createGossipItem():addTo(cell)
	cell.item:refresh(self.GossipItems[index])
    return cell
end

function vLayerGossipMenu:onTouchedGossipItem(context)
	local ai = self.sender:getAI()
	if ai then
		-- 如果创建了额外窗口则移除自身
		if ai:onNativeGossipSelect(self.player, self.sender, context.GossipSender, context.GossipIndex) then self:removeFromParent() end
	end
end

function vLayerGossipMenu:Exit(e)
	if e.name ~= "ended" then return end
	self:removeFromParent()
end

return vLayerGossipMenu
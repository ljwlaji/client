local Unit 				= import("app.components.Object.Unit")
local DataBase 			= import("app.components.DataBase")
local ShareDefine 		= import("app.ShareDefine")
local WindowMgr			= import("app.components.WindowMgr")
local Player 			= class("Player", Unit)

Player.instance = nil

function Player.getInstance()
	return Player.instance
end

function Player:onCreate()
	Unit.onCreate(self, ShareDefine:playerType())
	self:setAlive(true)
	self:initAvatar()
	self:setControlByPlayer(true)
	self:resetGossipList()
	Player.instance = self
end

function Player:initAvatar()
	local sp = cc.Sprite:create("res/player.png"):addTo(self:getPawn().m_Children["Node_Character"]):setAnchorPoint(0.5, 0)
    local CharacterData = DataBase:query(string.format("SELECT * FROM character WHERE character_id = %d", self.context))[1]
    self:move(CharacterData.x, CharacterData.y)
    	:setLocalZOrder(1)
    	:setContentSize(sp:getContentSize())
end

function Player:onUpdate(diff)
	Unit.onUpdate(self, diff)
end

function Player:saveToDB()

end

function Player:resetGossipList()
	self.m_GossipItemList = {}
end

function Player:sendGossipMenu(pObject, pTitleStringID)
	local window = WindowMgr:findWindowIndexByClassName("vLayerGossipMenu")
	if window then window:removeFromParent() end
	WindowMgr:createWindow("app.views.layer.vLayerGossipMenu", self.m_GossipItemList, self, pObject, pTitleStringID)
	self:resetGossipList()
end

function Player:addGossipItem(iconIndex, StringID, GossipSender, GossipIndex)
	self.m_GossipItemList[#self.m_GossipItemList + 1] = {
		IconIndex 		= iconIndex,
		StringID 		= StringID,
		GossipSender 	= GossipSender,
		GossipIndex 	= GossipIndex
	}
end

function Player:cleanUpBeforeDelete()
	release_print("Player : cleanUpBeforeDelete()")
	self:saveToDB()
	Unit.cleanUpBeforeDelete(self)
	Player.instance = nil
end

return Player
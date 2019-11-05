local Unit 				= import("app.components.Object.Unit")
local DataBase 			= import("app.components.DataBase")
local Player 			= class("Player", Unit)
local ShareDefine 		= import("app.ShareDefine")

Player.instance = nil


function Player.getInstance()
	return Player.instance
end

function Player:onCreate()
	Unit.onCreate(self, ShareDefine:playerType())
	self:setAlive(true)
	local sp = cc.Sprite:create("res/player.png"):addTo(self:getPawn().m_Children["Node_Character"]):setAnchorPoint(0.5, 0)
    local CharacterData = DataBase:query(string.format("SELECT * FROM character WHERE character_id = %d", self.context))[1]
    self:move(CharacterData.x, CharacterData.y)
    	:setLocalZOrder(1)
    	:setContentSize(sp:getContentSize())
	Player.instance = self
	self:setControlByPlayer(true)
	self.m_GossipItemList = {}
end

function Player:initAvatar()
	
end

function Player:onUpdate(diff)
	Unit.onUpdate(self, diff)
end

function Player:saveToDB()

end

function Player:sendGossipMenu(pGossipItemList, pObject)
	display.getWorld():createView("app.views.node.vNodeGossipMenu", pGossipItemList, self, pObject)
	self.m_GossipItemList = nil
end

function Player:addGossipItem(iconIndex, textOrStringID, GossipSender, GossipIndex)

end

function Player:cleanUpBeforeDelete()
	release_print("Player : cleanUpBeforeDelete()")
	self:saveToDB()
	Player.instance = nil
	Unit.cleanUpBeforeDelete(self)
end

return Player
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
	cc.Sprite:create("res/player.png"):addTo(self:getPawn().m_Children["Node_Character"]):setAnchorPoint(0.5, 0)
    local CharacterData = DataBase:query(string.format("SELECT * FROM character WHERE character_id = %d", self.context))[1]
    self:move(CharacterData.x, CharacterData.y + 50)
    	:setLocalZOrder(1)
	self.movementOffset = { x = 0, y = 0 }
	Player.instance = self
	self:setControlByPlayer(true)
end

function Player:initAvatar()
	
end

function Player:onUpdate(diff)
	Unit.onUpdate(self, diff)
end

function Player:saveToDB()

end

function Player:cleanUpBeforeDelete()
	self:saveToDB()
	Player.instance = nil
	Unit.cleanUpBeforeDelete(self)
end

return Player
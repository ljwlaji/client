local Unit 				= import("app.components.Object.Unit")
local DataBase 			= import("app.components.DataBase")
local Player 			= class("Player", Unit)

Player.instance = nil


function Player.getInstance()
	return Player.instance
end

function Player:onCreate()
    local CharacterData = DataBase:query(string.format("SELECT * FROM character WHERE character_id = %d", self.context))[1]
    self:move(CharacterData.x, CharacterData.y)
    	:setLocalZOrder(1)
	cc.Sprite:create("res/character.jpg"):addTo(self):setAnchorPoint(0, 0)
	self:setupStateMechine()

	self.movementOffset = { x = 0, y = 0 }
	Player.instance = self
end

function Player:onUpdate(diff)
	Unit.onUpdate(self, diff)
	self:move( cc.pAdd( { 
				x = self.movementOffset.x == 0 and 0 or ( self.movementOffset.x > 0 and 10 or -10 ),
				y = self.movementOffset.y == 0 and 0 or ( self.movementOffset.y > 0 and 10 or -10 )
			 }, cc.p(self:getPosition()) ) )
end

function Player:cleanUpBeforeDelete()
	Player.instance = nil
	Unit.cleanUpBeforeDelete(self)
end

function Player:onControllerUpdate(offset)
	self.movementOffset = offset
end


return Player
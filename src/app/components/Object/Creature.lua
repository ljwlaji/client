local Unit = import("app.components.Object.Unit")
local ShareDefine = import("app.ShareDefine")
local Creature = class("Creature", Unit)

function Creature:onCreate()
	Unit.onCreate(self, ShareDefine:creatureType())
	self.m_Faction = self.context.faction
	self:setAlive(self.context.alive)
	self.m_Entry = self.context.entry
	self:resetAttr()
	if self.context.script_name then
		self:initAI(self.context.script_name)
	end
	self:move(self.context.x, self.context.y)

	local sp = cc.Sprite:create("res/player.png"):addTo(self:getPawn().m_Children["Node_Character"]):setAnchorPoint(0.5, 0)

    self:setContentSize(sp:getContentSize())
end

function Creature:initAvatar()

end

function Creature:resetAttr()
	self:setBaseAttr("maxHealth", 			self.context.max_health)
	self:setBaseAttr("maxMana", 			self.context.max_mana)
	self:setBaseAttr("attackPower", 		self.context.attack)
	self:setBaseAttr("magicAttackPower",	self.context.magic_attack)
	self:setBaseAttr("defence", 			self.context.defence)
	self:setBaseAttr("magicDefence", 		self.context.magic_defence)
	self:setBaseAttr("moveSpeed", 			self.context.move_speed)
	self:setBaseAttr("jumpForce", 			self.context.jump_force)
	self:setBaseAttr("attackSpeed", 		self.context.attack_speed)
	self:setAttrToBase()
end

function Creature:onUpdate(diff)
	Unit.onUpdate(self, diff)
end

function Creature:cleanUpBeforeDelete()
	release_print("Creature : cleanUpBeforeDelete()")
	Unit.cleanUpBeforeDelete(self)
end



return Creature

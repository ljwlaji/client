local DataBase 			= import("app.components.DataBase")
local Object 			= import("app.components.Object.Object")
local Pawn 				= import("app.views.node.vNodePawn")
local MovementMonitor 	= import("app.components.Object.UnitMovementMonitor")
local Unit 				= class("Unit", Object)

--[[
	Unit Base Attrs

	1. maxHeath
	2. maxMana
	3. baseAttack
	4. baseMagicAttack
	5. baseDefence
	6. baseMagicDefence
	7. baseMoveSpeed
	8. baseJumpForce
]]

-- 关于攀爬 其实就是左右移动偏移值变成了上下移动偏移值
function Unit:onCreate(objType)
	Object.onCreate(self, objType)
	self.m_ActivatedSpells = {} --Activated Spells 当身上有相同法术存留的时候只覆盖
	self.m_ControlByPlayer = false
	self.m_Alive = false
	self.m_Pawn = Pawn:create():addTo(self)
	self.m_BaseAttrs = {
		maxHealth 				= 100,
		maxMana 				= 100,
		maxRage					= 100,
		maxEnergy				= 100,

		attackPower 			= 1,
		magicAttackPower 		= 1,
		defence 				= 1,
		magicDefence 			= 1,

		moveSpeed				= 7.0,
		jumpForce				= 8,

		attackSpeed 			= 1000,

		strength				= 0,
		agility					= 0,
		intelligence 			= 0,
		spirit 					= 0,
		stamina					= 0,
	}
	self.m_Attrs = {}
	self.m_MovementMonitor = MovementMonitor:create(self)
	self:regiestCustomEventListenter("onTouchButtonX", function() end)
	self:regiestCustomEventListenter("onTouchButtonY", function() end)
	self:regiestCustomEventListenter("onTouchButtonA", function() end)
	self:regiestCustomEventListenter("onControllerJump", function() if self:isControlByPlayer() then self.m_MovementMonitor:jump() end end)
end

function Unit:onUpdate(diff)
	-- module for testting --
	-- end of testting --
	Object.onUpdate(self, diff)
	self.m_MovementMonitor:update(diff)
end

function Unit:setFaction(faction)
	self.m_Faction = faction
end

function Unit:getFaction()
	return self.m_Faction
end

function Unit:setClass(class)
	self.m_Class = class
end

function Unit:getClass()
	return self.m_Class
end

function Unit:getLevel()
	return self.m_Level
end

function Unit:setLevel(lvl)
	self.m_Level = lvl
end

function Unit:getClassString()
	return DataBase:getStringByID(self:getClass() + 100)
end

function Unit:initAI(AIName)
	local currAITemplate = import(string.format("app.scripts.%s", AIName))
	assert(currAITemplate, "Cannot Find Current AI By Path Named: ["..AIName.."]")
	self:setAI(currAITemplate:create(self))
end
			--------------------
			-- For Attr Issus --
			--------------------

function Unit:setAttrToBase()
	for k, v in pairs(self.m_BaseAttrs) do
		self.m_Attrs[k] = v
	end
	if self:isPlayer() then
		self.m_Attrs["health"]	= self.context.current_health
		self.m_Attrs["mana"]	= self.context.current_mana
	else
		self.m_Attrs["health"] 	= self.m_BaseAttrs["maxHealth"]
		self.m_Attrs["mana"] 	= self.m_BaseAttrs["maxMana"]
	end
end

function Unit:setAlive(alive)
	if alive == self.m_Alive then return end
	self.m_Alive = alive
end

function Unit:isAlive()
	return self.m_Alive
end

function Unit:updateAttrs()
	for k, v in pairs(self.m_BaseAttrs) do
		if self.context[k] then
			self:setBaseAttr(k, self.context[k])
		end
	end
	if self:isPlayer() then
		local lvl = self.context.level - 1
		for _, attrName in pairs({"maxHealth", "maxMana", "strength", "intelligence", "agility", "spirit", "stamina"}) do
			local extraValue = self.context[string.format("%s_per_lvl", attrName)] * lvl
			self:setBaseAttr(attrName, self:getBaseAttr(attrName) + extraValue)
		end
		self:updateEquipmentAttrs()
	end
	self:setAttrToBase()
	self:getPawn():modifyHealth(self:getAttr("health"), self:getAttr("maxHealth"))
end

function Unit:setBaseAttr(attrName, value)
	self.m_BaseAttrs[attrName] = value
end

function Unit:getBaseAttr(attrName, value)
	return self.m_BaseAttrs[attrName]
end

function Unit:setAttr(attrName, value)
	self.m_Attrs[attrName] = value
end

function Unit:getAttr(attrName)
	return self.m_Attrs[attrName]
end

function Unit:modifyHealth(value)
	if value == 0 then return end
	local currHealth = self:getAttr("health")
	local maxHealth = self:getAttr("maxHealth")
	if value > 0 then
		value = currHealth + value > maxHealth and maxHealth - currHealth or value
	else
		value = currHealth - value < 0 and currHealth or value
	end
	local final = currHealth + value
	if final == 0 then self:justDie() end
	self:getPawn():modifyHealth(final, self:getAttr("maxHealth"))
	self:setAttr("health", final)
end

function Unit:getDeathTime()
	return self.m_DeathTime
end

function Unit:setDeathTime(time)
	self.m_DeathTime = time
end

function Unit:justDie()
	self:setAlive(false)
	-- TODO
	-- CleanUp All Areas
	-- Play Animation
	-- CleanUp All Threats And Targets
	self:setDeathTime(os.time())
	if self:getAI() then self:getAI():onDead() end
end
			-----------------------
			-- End Of Attr Issus --
			-----------------------

function Unit:castSpell(target, spellID)
	if self.m_CasttingSpell then release_print("Already Castting a Spell !") return end
	local spellTemplate = SpellMgr:getSpellTemplate(spellID)
	if not spellTemplate then release_print("Cannot Find SpellTemplate By SpellID : "..spellID) return end

	self.m_CasttingSpell = Spell:create(self, target, spellTemplate)
	self.m_CasttingSpell:prepare()
end

function Unit:onSpellCancel()
	release_print("onSpellCancel")
end

			--------------------
			-- For Pawn Issus --
			--------------------
function Unit:getPawn()
	return self.m_Pawn
end
			-----------------------
			-- End Of Pawn Issus --
			-----------------------

function Unit:getMovementMonitor()
	return self.m_MovementMonitor
end
function Unit:getMaxMoveSpeed()
	return self:getBaseAttr("moveSpeed")
end

function Unit:setControlByPlayer(enabled)
	self.m_ControlByPlayer = enabled
end

function Unit:isControlByPlayer()
	return self.m_ControlByPlayer
end

function Unit:cleanUpBeforeDelete()
	release_print("Unit : cleanUpBeforeDelete()")
	self.m_MovementMonitor:cleanUpBeforeDelete()
	self.m_MovementMonitor = nil
    Object.cleanUpBeforeDelete(self)
end

return Unit

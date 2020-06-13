local DataBase 			= import("app.components.DataBase")
local Object 			= import("app.components.Object.Object")
local MovementMonitor 	= import("app.components.Object.UnitMovementMonitor")
local SpellMgr 			= import("app.components.SpellMgr")
local Spell 			= import("app.components.Object.Spell")
local ShareDefine 		= import("app.ShareDefine")
local Unit 				= class("Unit", Object)

--[[
	Unit Base Attrs

	1. maxHealth
	2. maxMana
	3. baseAttack
	4. baseMagicAttack
	5. baseDefence
	7. baseMoveSpeed
	8. baseJumpForce
]]

-- 关于攀爬 其实就是左右移动偏移值变成了上下移动偏移值
function Unit:onCreate(objType)
	Object.onCreate(self, objType)
	self.m_Buffs = {} --Activated Spells 当身上有相同法术存留的时候只覆盖
	self.m_SpellCoolDowns = {}
	self.m_ControlByPlayer = false
	self.m_Alive = false
	self.m_BaseAttrs = {
		maxHealth 				= 100,
		maxMana 				= 100,
		maxRage					= 100,
		maxEnergy				= 100,

		attackPower 			= 0,
		magicAttackPower 		= 0,
		armor 					= 0,

		moveSpeed				= 7.0,
		jumpForce				= 8,

		attackSpeed 			= 1000,

		strength				= 0,
		agility					= 0,
		intelligence 			= 0,
		spirit 					= 0,
		stamina					= 0,

		blockChance 			= 0,
		dodgeChance				= 0,
		hitChance				= 0,
		meleeCritChance			= 0,
		magicCritChance 		= 0,

		minAttack				= 0,
		maxAttack				= 0,

		critMutiply				= 1.5

	}
	self.m_Attrs = {
		rage 					= 100,
		health 					= 100,
		energy 					= 100,
		mana 					= 100,
	}
	self.m_MovementMonitor = MovementMonitor:create(self)
	self:regiestCustomEventListenter("onTouchButtonX", function() end)
	self:regiestCustomEventListenter("onTouchButtonY", function() end)
	self:regiestCustomEventListenter("onTouchButtonA", function() end)
	self:regiestCustomEventListenter("onControllerJump", function() if self:isControlByPlayer() then self.m_MovementMonitor:jump() end end)
	self:setAttrDataDirty(true)
end

function Unit:onUpdate(diff)
	-- module for testting --
	-- end of testting --
	Object.onUpdate(self, diff)
	if self:isAttrDataDirty() then 
		self:sendAppMsg("MSG_ON_ATTR_CHANGED")
		self:setAttrDataDirty(false)
	end

	if not self:isAlive() then return end
	self.m_MovementMonitor:update(diff)
	if self.m_CasttingSpell then self.m_CasttingSpell:onUpdate(diff) end
	self:updateSpellCoolDown(diff)
end

function Unit:reborn()
	local seed = self:isPlayer() and 0.2 or 1
	self:setAttr("health", 	self:getAttr("maxHealth") * seed)
	self:setAttr("mana", 	self:getAttr("maxMana") * seed)
	self:updateAttrs()
	self:getMovementMonitor():onReset()
	self:setAlive(true)
end

function Unit:updateSpellCoolDown(diff)
	local new_t = {}
	for k, v in pairs(self.m_SpellCoolDowns) do
		v = v - diff
		if v > 0 then new_t[k] = v end
	end
	self.m_SpellCoolDowns = new_t
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

function Unit:getGender()
	return self.m_Gender
end

function Unit:setGender(gender)
	self.m_Gender = gender
end

function Unit:getRace()
	return self.m_Race
end

function Unit:setRace(race)
	self.m_Race = race
end

function Unit:setLevel(lvl)
	local oldLevel = self.m_Level
	self.m_Level = lvl
	if self:isPlayer() and oldLevel and lvl > oldLevel then
		self:onLevelUp(oldLevel, self.m_Level)
	end
end

function Unit:getClassString()
	return DataBase:getStringByID(self:getClass() + 100)
end

			--------------------
			-- For Attr Issus --
			--------------------
function Unit:setAlive(alive)
	if alive == self.m_Alive then return end
	self.m_Alive = alive
end

function Unit:isAlive()
	return self.m_Alive
end

function Unit:updateBaseAttrs(init)
	-- calc base Attrs 
	-- include base attrs, level granted, equipment attrs
	-- base attrs will change while equipment changed, level changed
	-- base attrs include helth, maxHealth, mana, maxMana, rage, maxRage, energy, maxEnegry, strengh, agility, intelliange, sprirt, stamina 
	-- for Creature Issus we just create constant value for it
	for k, v in pairs(self.m_BaseAttrs) do
		if self.context[k] then
			self:setBaseAttr(k, self.context[k])
		end
	end

	-- for Player Issus we need calc level-based values and equipment granted values
	if self:isPlayer() then
		-- level-based values
		local lvl = self.context.level - 1
		for _, attrName in pairs({"maxHealth", "maxMana", "strength", "intelligence", "agility", "spirit", "stamina"}) do
			local extraValue = self.context[string.format("%s_per_lvl", attrName)] * lvl
			self:setBaseAttr(attrName, self:getBaseAttr(attrName) + extraValue)
		end
		-- equipment values
		self:updateEquipmentAttrs()
	end

	-- 计算高级属性加成
	self:updateAttrs()

	local recalc = {
		["health"] 	= "maxHealth",
		["mana"] 	= "maxMana",
		["rage"] 	= "maxRage",
		["energy"] 	= "maxEnergy",
	}
	if init then
		if self:isPlayer() then
			self:setAttr("health", self.context.current_health)
			self:setAttr("mana", self.context.current_mana)
		else
			self:setAttr("health", self.context.maxHealth)
			self:setAttr("mana", self.context.maxMana)
		end
	end
	for k, v in pairs(recalc) do
		local now = self:getAttr(k)
		local max = self:getAttr(v)
		if now > max then self:setAttr(k, max) end
	end

end

function Unit:updateAttrsForBuffs()
	for spell_id, spell_template in pairs(self.m_Buffs) do

	end
end

function Unit:updateAttrs()
	-- sync base attrs to modifible attrs
	for valueName, value in pairs(self.m_BaseAttrs) do
		self:setAttr(valueName, value)
	end


	-- for dynaic Attrs, there has more value to calc
	-- include max Attack, min Attack, magic Attack, block Chance, dodge Chance, miss Chance
	-- their are depends on Activated spells

	-- to calc changed by Activated spells
	-- need to fill

	local extraValue = {
			maxHealth 				= 0,
			maxMana 				= 0,
			maxRage					= 0,
			maxEnergy				= 0,
			attackPower 			= 0,
			magicAttackPower 		= 0,
			armor 					= 0,
			attackSpeed 			= 0,

			strength				= 0,
			agility					= 0,
			intelligence 			= 0,
			spirit 					= 0,
			stamina					= 0,

			minAttack 				= 0,
			maxAttack 				= 0,

			blockChance 			= 0,
			dodgeChance				= 0,
			meleeCritChance			= 0,
			magicCritChance 		= 0,

			plus = function(this, k, v)
				this[k] = this[k] + v
			end
	}
	-- for player Multiply
	if self:isPlayer() then
		
		extraValue:plus("maxHealth", 		self:getAttr("stamina") 		* 10)
		extraValue:plus("maxMana", 			self:getAttr("intelligence") 	* 10)
		extraValue:plus("dodgeChance", 		self:getAttr("agility") 		* 0.05)
		extraValue:plus("meleeCritChance", 	self:getAttr("agility") 		* 0.05)
		extraValue:plus("magicCritChance", 	self:getAttr("intelligence")	* 0.05)
		-- extraValue:plus("maxMeleeDamage", )
		-- For Class Issus
		local class = self:getClass()
		if class == ShareDefine.classWarrior() 		then
			extraValue:plus("attackPower", self:getAttr("strength") * 2)
		elseif class == ShareDefine.classMage() 	then
		elseif class == ShareDefine.classPriest() 	then
		elseif class == ShareDefine.classKnight() 	then
			extraValue:plus("attackPower", self:getAttr("strength") * 2)
		elseif class == ShareDefine.classHunter() 	then
			extraValue:plus("attackPower", self:getAttr("agility") * 2)
		elseif class == ShareDefine.classWarlock() 	then
 		elseif class == ShareDefine.classThief() 	then
			extraValue:plus("attackPower", self:getAttr("agility") 	* 2)
			extraValue:plus("attackPower", self:getAttr("strength") * 1)
 		elseif class == ShareDefine.classDruid() 	then
			extraValue:plus("attackPower", self:getAttr("strength") * 1)
			extraValue:plus("attackPower", self:getAttr("agility") 	* 1)
		elseif class == ShareDefine.classShaman() 	then
			extraValue:plus("attackPower", self:getAttr("strength") * 1)
			extraValue:plus("attackPower", self:getAttr("agility") 	* 1)
		end
	end
	-- finally we calc and applied all attrs, 
	-- then we need to send a notify to some window whitch has oppenned to change displaying values
	-- attr update msg will automatic send when update func notice the attr data was dirty Unit:isAttrDataDirty()
	extraValue.plus = nil
	for k, v in pairs(extraValue) do
		self:setAttr(k, self:getAttr(k) + v)
	end
end

function Unit:setBaseAttr(attrName, value)
	self.m_BaseAttrs[attrName] = value
	self:setAttrDataDirty(true)
end

function Unit:getBaseAttr(attrName, value)
	return self.m_BaseAttrs[attrName]
end

function Unit:modifyAttr(attrName, value)
	assert(self.m_Attrs[attrName], "Cannot Find Attr Named : "..attrName)
	self:setAttr(attrName, self:getAttr(attrName) + value)
end

function Unit:setAttr(attrName, value)
	self.m_Attrs[attrName] = value
	self:setAttrDataDirty(true)
end

function Unit:getAttr(attrName)
	local ret = self.m_Attrs[attrName]
	assert(ret, "No Such Attr : "..attrName)
	return ret
end

function Unit:setAttrDataDirty(ditry)
	self.m_IsAttrDataDirty = ditry
end

function Unit:isAttrDataDirty()
	return self.m_IsAttrDataDirty
end

function Unit:modifyHealth(value)
	if value == 0 then return end
	local currHealth = self:getAttr("health")
	local maxHealth = self:getAttr("maxHealth")
	if value > 0 then
		value = currHealth + value > maxHealth and maxHealth - currHealth or value
	else
		value = currHealth + value <= 0 and -currHealth or value
	end
	local final = currHealth + value
	self:setAttr("health", final)
end

function Unit:getDeathTime()
	return self.m_DeathTime
end

function Unit:setDeathTime(time)
	self.m_DeathTime = time
end

function Unit:justDie(killer)
	self:setAlive(false)
	-- TODO
	-- CleanUp All Areas
	self.m_Buffs = {}
	-- Play Animation
	-- CleanUp All Threats And Targets
	self:updateAttrs()
	self:setDeathTime(os.time())
	self:getAI():onDead()
	if killer then
		if self:isCreature() and killer:isPlayer() and killer:isAlive() then killer:awardExp(self.context.award_exp) end
		if killer:isCreature() and killer:getAI() then killer:onKill(self) end
	end
end
			-----------------------
			-- End Of Attr Issus --
			-----------------------

--[[ For Combat Issus ]]
function Unit:startCombat()
	
end

function Unit:leaveCombat()
	-- return to home pos
end

function Unit:isFacingTo(otherUnit)
	local offset = self:getPositionX() - otherUnit:getPositionX()
	local direction = self:getMovementMonitor():getDirection()
	return (offset >= 0 and direction == "left") or (offset < 0 and direction == "right")
end

function Unit:getDistance(otherUnit)
	return cc.pGetDistance(cc.p(self:getPosition()), cc.p(otherUnit:getPosition()))
end

function Unit:dealDamage(damage, victim)
	local finalDamage = 0
	-- 等级差
	local lvl_diff = (self:getLevel() - victim:getLevel()) * 5
	-- 计算命中
	local hitChance = ShareDefine.hitChance() + lvl_diff
	if self:isPlayer() then hitChance = hitChance + self:getAttr("hitChance") end
	if math.random(1, 100) > hitChance then return end

	if math.random(1, 100) <= self:getAttr("dodgeChance") then return end

	if math.random(1, 100) <= self:getAttr("blockChance") then return end


	for damageType, damageInfo in pairs(damage) do
		--计算招架格
		local cleanMinDamage = damageInfo.minDamage
		local cleanMaxDamage = damageInfo.maxDamage

		local cleanDamage = math.random(cleanMinDamage, cleanMaxDamage)
		if damageType == ShareDefine.meleeDamage() then
			finalDamage = cleanDamage - victim:getAttr("armor")
		end
	end 

	victim:modifyHealth(-finalDamage)
	if victim:getAttr("health") == 0 then victim:justDie(self) end
end

function Unit:addBuff(spell_id)

end

function Unit:castSpell(spellID)
	if self.m_CasttingSpell then release_print("Already Castting a Spell !") return end
	if self:isInSpellCoolDown(spellID) then release_print("This Spell Is In CoolDown!") return end
	local spellTemplate = SpellMgr:getSpellTemplate(spellID)
	if not spellTemplate then release_print("Cannot Find SpellTemplate By SpellID : "..spellID) return end
	local casttingSpell = Spell:create(self, spellTemplate):addTo(self:getMap())
	if casttingSpell:checkCast() == Spell.CastResult.CAST_OK then self.m_CasttingSpell = casttingSpell end
end

function Unit:isInSpellCoolDown(spellID)
	return self.m_SpellCoolDowns[spellID] ~= nil
end

function Unit:onSpellCancel()
	self.m_CasttingSpell = nil
end

function Unit:onSpellLaunched(spellInfo)
	-- 减去相关技能消耗所需
	if spellInfo.cost_type ~= 0 then
		local costType = ShareDefine.stateIndexToString(spellInfo.cost_type)
		self:modifyAttr(costType, -spellInfo.cost_amount)
	end
	-- 增加spellCoolDown
	self:insertSpellCoolDown(spellInfo.entry, spellInfo.cool_down)
	self.m_CasttingSpell = nil
end

function Unit:insertSpellCoolDown(spellID, timeleft)
	if timeleft == 0 then return end
	if self.m_SpellCoolDowns[spellID] and self.m_SpellCoolDowns[spellID] > timeleft then return end
	self.m_SpellCoolDowns[spellID] = timeleft
end

function Unit:getSpellCoolDownList()
	return self.m_SpellCoolDowns
end
--[[ End Combat Issus ]]

			--------------------
			-- For Pawn Issus --
			--------------------
function Unit:getPawn()
	return self.m_Pawn
end

function Unit:setPawn(pawn)
	assert(not self.m_Pawn)
	self.m_Pawn = pawn
end
			-----------------------
			-- End Of Pawn Issus --
			-----------------------

function Unit:getMovementMonitor()
	return self.m_MovementMonitor
end
function Unit:getMaxMoveSpeed()
	return self:getAttr("moveSpeed")
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

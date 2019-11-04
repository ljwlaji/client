local StateMachine = import("app.components.StateMachine")
local Spell = class("Spell", cc.Node)


--[[
	技能释放顺序
		1. 读取技能Template
		2. 检查释放条件
		3. 释放读条/瞬发
		4. 读条完成触发效果
]]
-- 技能释放状态

Spell.CastResult = {
	CAST_OK 						= 0,
	CAST_CANCELED 					= 1,
	CAST_ERROR_COOL_DOWN 			= 2,
	CAST_ERROR_WRONG_TARGET 		= 3,

	CAST_ERROR_NOT_ENOUGH_BEGIN		= 3,
	CAST_ERROR_NOT_ENOUGH_MANA 		= 4, --魔法
	CAST_ERROR_NOT_ENOUGH_RAGE 		= 5, --怒气
	CAST_ERROR_NOT_ENOUGH_ENERGY 	= 6, --能量
	CAST_ERROR_NOT_ENOUGH_HEALTH 	= 7, --体力

	CAST_ERROR_NOT_ENOUGH_RANGE		= 8,

	CAST_PREPARE 					= 100,
}
local CastResult = Spell.CastResult

Spell.SpellTargetType = {
	TARGET_ALL 					= 0,
	TARGET_ENEMY 				= 1,
	TARGET_NOT_ENEMY 			= 2,
	TARGET_SELF 				= 3,
	TARGET_SPECIFIC_CREATURE	= 4,
	TARGET_SPECIFIC_GAMEOBJECT	= 5,
}
local SpellTargetType = Spell.SpellTargetType

Spell.SpellRequirementType = {
	[1] = "mana",
	[2] = "rage",
	[3] = "enegry",
	[4] = "health"
}
local SpellRequirementType = Spell.SpellRequirementType

function Spell:ctor(caster, target, spellInfo)
	self.m_Caster = caster
	self.m_Target = target
	self.m_SpellInfo = spellInfo
	self.m_CastResult = CastResult.CAST_PREPARE
	self:onNodeEvent("cleanup", handler(self, self.cleanUpBeforeDelete))
end

function Spell:getCaster()
	return self.m_Caster
end

function Spell:getTarget()
	return self.m_Target
end

function Spell:getSpellInfo()
	return self.m_SpellInfo
end

function Spell:prepare()
	if CastResult.CAST_OK ~= self:checkCast() then self:cancel() end
	--Init CastTime
end

function Spell:cancel()
	self:getCaster():onSpellCancel()
	self:removeFromParent()
end

function Spell:checkCast()
	local spellInfo = self:getSpellInfo()
	--Check Requirements
	for requireType, requireValue in pairs(spellInfo.requirements) do
		if self:getCaster():getAttr(SpellRequirementType[requireType]) < requireValue then
			return CastResult.CAST_ERROR_NOT_ENOUGH_BEGIN + requireType
		end
	end
	--Check ColdDown


	--Check Target
	if 	(spellInfo.SpellTargetType == SpellTargetType.TARGET_ENEMY 					and not FactionMgr:isHostile(self:getCaster(), self:getTarget())) or
		(spellInfo.SpellTargetType == SpellTargetType.TARGET_NOT_ENEMY 				and FactionMgr:isHostile(self:getCaster(), self:getTarget())) or
		(spellInfo.SpellTargetType == SpellTargetType.TARGET_SELF 					and self:getCaster() ~= self:getTarget()) or
		(spellInfo.SpellTargetType == SpellTargetType.TARGET_SPECIFIC_GAMEOBJECT 	and (not self:getTarget():isGameObject() 	or self:getTarget():getEntry() ~= spellInfo.SpellTargetValue)) or
		(spellInfo.SpellTargetType == SpellTargetType.TARGET_SPECIFIC_CREATURE 		and (not self:getTarget():isCreature() 		or self:getTarget():getEntry() ~= spellInfo.SpellTargetValue)) then
		return CastResult.CAST_ERROR_WRONG_TARGET
	end


	--Check Range
	if cc.pGetDistance(cc.p(self:getCaster():getPosition()), self:getTarget()) then
		return CastResult.CAST_ERROR_NOT_ENOUGH_RANGE
	end
	return CastResult.CAST_OK
end

function Spell:fetchTargets()

end

function Spell:onUpdate(diff)
	if self.m_CastResult == CastResult.CAST_PREPARE or self.m_CastResult == CastResult.CAST_CANCELED then 
		return 
	end

end

function Spell:cleanUpBeforeDelete()

end

return Spell
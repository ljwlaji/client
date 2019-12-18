local StateMachine 		= import("app.components.StateMachine")
local ShareDefine       = import("app.ShareDefine")
local WindowMgr			= import("app.components.WindowMgr")
local Spell 			= class("Spell", cc.Node)


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

	CAST_ERROR_NOT_ENOUGH_BEGIN		= 400,
	CAST_ERROR_NOT_ENOUGH_MANA 		= 417, --魔法
	CAST_ERROR_NOT_ENOUGH_RAGE 		= 418, --怒气
	CAST_ERROR_NOT_ENOUGH_ENERGY 	= 419, --能量
	CAST_ERROR_NOT_ENOUGH_HEALTH 	= 420, --体力
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
	TARGET_BODY					= 6,
}

local SpellTargetType = Spell.SpellTargetType

local SPELL_CAST_STATES = {
	STATE_CASTTING 		= 1,
	-- STATE_LAUNCHING 	= 2,
}

local SPELL_DAMAGE_TYPES = {
	MELEE_DAMAGE = 1,
	MAGIC_DAMAGE = 2,
}

function Spell:ctor(caster, spellInfo)
	self.m_Caster = caster
	self.m_Targets = {}
	self.m_CastTimer = 0
	self.m_SpellInfo = spellInfo
	self.m_CastResult = CastResult.CAST_PREPARE
	self:onNodeEvent("cleanup", handler(self, self.cleanUpBeforeDelete))

	self.m_StateMachine = StateMachine:create()
									  :addState(SPELL_CAST_STATES.STATE_CASTTING, 	handler(self, self.onEnterCastting), handler(self, self.onExecuteCastting), nil, nil)
									  -- :addState(SPELL_CAST_STATES.STATE_LAUNCHING, handler(self, self.onEnterLaunch), handler(self, self.onExecuteLaunch), handler(self, self.onExitLaunch), nil)

	self:tryCast()
end

function Spell:getCaster()
	return self.m_Caster
end

function Spell:getTarget()
	return self.m_Targets
end

function Spell:getSpellInfo()
	return self.m_SpellInfo
end

function Spell:cancel()
	self.m_StateMachine:stop()
	self.m_StateMachine = nil
	self:getCaster():onSpellCancel()
	self:removeFromParent()
end

function Spell:checkCast()
	local spellInfo = self:getSpellInfo()
	if spellInfo.cost_type > 0 and spellInfo.cost_amount > 0 and self:getCaster():getAttr(ShareDefine.stateIndexToString(spellInfo.cost_type)) < spellInfo.cost_amount then
		return CastResult.CAST_ERROR_NOT_ENOUGH_BEGIN + spellInfo.cost_type
	end
	return CastResult.CAST_OK
end

function Spell:tryCast()
	self.m_StateMachine:setState(SPELL_CAST_STATES.STATE_CASTTING)
				   	   :run()
	self:onExecuteCastting(0) --先检查一次
end

function Spell:onEnterCastting()
	-- 通知WindowMgr呼出倒计时栏
	WindowMgr:createWindow("app.views.layer.vLayerCasttingBar", self.m_SpellInfo, 0)
	-- play Cast Effect
end

function Spell:onExecuteCastting(diff)
	if CastResult.CAST_OK ~= self:checkCast() then self:cancel() end

	if self.m_CastTimer >= self.m_SpellInfo.cast_time then
		self.m_StateMachine:stop()
		self:launchSpell()
		return
	end
	self.m_CastTimer = self.m_CastTimer + diff
	WindowMgr:createWindow("app.views.layer.vLayerCasttingBar", self.m_SpellInfo, self.m_CastTimer / self.m_SpellInfo.cast_time * 100)
end

function Spell:launchSpell()
	-- TODO
	-- modify spell cast_cost

	-- fetch targets
	self:fetchTargets()
	-- just launch


	self:getCaster():onSpellLaunched()

	-- launch spell effect
end

--[[
Spell.SpellTargetType = {
	TARGET_ALL 					= 0,
	TARGET_ENEMY 				= 1,
	TARGET_NOT_ENEMY 			= 2,
	TARGET_SELF 				= 3,
	TARGET_SPECIFIC_CREATURE	= 4,
	TARGET_SPECIFIC_GAMEOBJECT	= 5,
	TARGET_BODY					= 6,
}

local SpellTargetType = Spell.SpellTargetType
]]

function Spell:fetchTargets()
	-- fetch vailed targets in range
	local spellInfo = self:getSpellInfo()
	local range = spellInfo.cast_range
	local spellTarget = spellInfo.target_type
	local ingnoreSelf = spellTarget == SpellTargetType.TARGET_ENEMY or 
						spellTarget == SpellTargetType.TARGET_SPECIFIC_CREATURE or 
						spellTarget == SpellTargetType.TARGET_SPECIFIC_GAMEOBJECT

	local aliveOnly 	= spellTarget ~= SpellTargetType.TARGET_BODY
	local hostileOnly 	= spellTarget == SpellTargetType.TARGET_ENEMY
	local maxNumber 	= spellInfo.max_target_count
	local checkFacingTo = spellInfo.check_facing_to == 1

	local fetchResult 	= self:getCaster():getMap():fetchUnitInRange(self:getCaster(), range, ingnoreSelf, aliveOnly, hostileOnly, maxNumber, checkFacingTo)

	-- fetch damage

end

function Spell:calcDamage()
	local minDamage = 0
	local maxDamage = 0
	local spellInfo = self:getSpellInfo()
	local caster = self:getCaster()
	if caster:isPlayer() then
		if spellInfo.damage_type == SPELL_DAMAGE_TYPES.MELEE_DAMAGE then
			local weapon = caster:getInventoryData()[ShareDefine.inventoryMainHandSlot()]
			
		else

		end
	else

	end
end

function Spell:onUpdate(diff)
	self.m_StateMachine:executeStateProgress(diff)
end

function Spell:cleanUpBeforeDelete()

end

return Spell
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
									  :setState(SPELL_CAST_STATES.STATE_CASTTING)
				   	   				  :run()

end

function Spell:getCaster()
	return self.m_Caster
end

function Spell:getTargets()
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
		release_print("Spell:checkCast() Failed With Code : "..result)
		-- SendNotify
		return CastResult.CAST_ERROR_NOT_ENOUGH_BEGIN + spellInfo.cost_type
	end
	return CastResult.CAST_OK
end

function Spell:onEnterCastting()
	-- 通知WindowMgr呼出倒计时栏
	if self.m_SpellInfo.cast_time > 0 then
		WindowMgr:createWindow("app.views.layer.vLayerCasttingBar", self.m_SpellInfo, 0)
	end
	-- play Cast Effect
end

function Spell:onExecuteCastting(diff)
	if CastResult.CAST_OK ~= self:checkCast() then self:cancel() return end

	if self.m_CastTimer >= self.m_SpellInfo.cast_time then
		self.m_StateMachine:stop()
		self:launchSpell()
		return
	end
	self.m_CastTimer = self.m_CastTimer + diff
	WindowMgr:createWindow("app.views.layer.vLayerCasttingBar", self.m_SpellInfo, self.m_CastTimer / self.m_SpellInfo.cast_time * 100)
	return result
end

function Spell:launchSpell()
	-- TODO
	-- fetch targets
	self:fetchTargets()
	-- just launch
	local damages = self:calcSpellDamage()
	-- 这边分为即时伤害和子弹时间伤害

	-- 如果是即时伤害则直接 owner:dealDamage(victim, damage, ...)

	-- 如果是子弹时间伤害则让子弹实例携带damage数值 碰撞后 dealDamage

	-- 思考 如果owner在碰撞时状态是死亡或者被移除了怎么办?

	-- 直接造成伤害
	for k, victim in pairs(self.m_Targets) do
		self:getCaster():dealDamage(damages, victim)
	end
	-- launch spell effect
	self.m_StateMachine:stop()
	self.m_StateMachine = nil
	self:getCaster():onSpellLaunched(self.m_SpellInfo)
	self:removeFromParent()
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
	local range = spellInfo.target_range
	local spellTarget = spellInfo.target_type
	local ingnoreSelf = spellTarget == SpellTargetType.TARGET_ENEMY or 
						spellTarget == SpellTargetType.TARGET_SPECIFIC_CREATURE or 
						spellTarget == SpellTargetType.TARGET_SPECIFIC_GAMEOBJECT

	local aliveOnly 	= spellTarget ~= SpellTargetType.TARGET_BODY
	local hostileOnly 	= spellTarget == SpellTargetType.TARGET_ENEMY
	local maxNumber 	= spellInfo.max_target_count
	local checkFacingTo = spellInfo.check_facing_to == 1

	local fetchResult 	= self:getCaster():getMap():fetchUnitInRange(self:getCaster(), range, ingnoreSelf, aliveOnly, hostileOnly, maxNumber, checkFacingTo)
	local results = {}
	for k, v in pairs(fetchResult) do table.insert(results, v.obj) end
	
	self.m_Targets = results
end

function Spell:calcSpellDamage()
	local damages = {}
	local spellInfo = self:getSpellInfo()
	local caster = self:getCaster()
	if spellInfo.damage_type == ShareDefine.meleeDamage() then
		local isCrit 	= math.random(1, 100) <= caster:getAttr("meleeCritChance")
		local minDamage = spellInfo.damage_multiply_base * caster:getAttr("minAttack") + spellInfo.extra_damage
		local maxDamage = spellInfo.damage_multiply_base * caster:getAttr("maxAttack") + spellInfo.extra_damage * spellInfo.extra_damage_seed
		if isCrit then
			minDamage = minDamage * caster:getAttr("critMutiply")
			maxDamage = maxDamage * caster:getAttr("critMutiply")
		end
		damages[spellInfo.damage_type] = { minDamage = minDamage, maxDamage = maxDamage }
	else

	end
	return damages
end

function Spell:onUpdate(diff)
	self.m_StateMachine:executeStateProgress(diff)
end

function Spell:cleanUpBeforeDelete()
	local window = WindowMgr:findWindowIndexByClassName("vLayerCasttingBar")
	if window then window:hide() end
end

return Spell
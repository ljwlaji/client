local ShareDefine 	= import("app.ShareDefine")
local WindowMgr		= import("app.components.WindowMgr")
local FactionMgr	= import("app.components.FactionMgr")
local DataBase 		= import("app.components.DataBase")
local ScriptAI 		= class("ScriptAI")

local GOSSIP_SENDER_TYPES = ShareDefine.gossipSenderTypes()
--[[
	TYPE_QUEST 		= -1,
	TYPE_TRAINER 	= -2,
	TYPE_VENDOR 	= -3,
]]

local SIGHT_RANGE = ShareDefine.sightRange()

local MOVE_IN_LINE_OF_SIGHT_TIMER = 1000

local SPELL_ID_MELEE_ATTACK = 200000

function ScriptAI:ctor(me)
	self.getOwner = function() return me end
	self.m_IsInCombat 	= false
	self.m_TracedUnit 	= nil
	self.m_Victim 		= nil
	self.m_ThreadList 	= {}
	self.m_AttackTimer 	= 0
end

function ScriptAI:onNativeGossipHello(pPlayer, pObject)
	if self.onGossipHello then return self:onGossipHello(pPlayer, pObject) end

	if not pObject:isQuestProvider() and not pObject:isVendor() and not pObject:isTrainer() then return false end
	for _, v in pairs(pObject:getQuestList()) do
		local template = DataBase:getQuestTemplateByEntry(v.entry)
		if (pPlayer:canAcceptQuest(v.entry) and template.accept_npc == pObject:getEntry()) or (pPlayer:canSubmitQuest(v.entry) and template.submit_npc == pObject:getEntry() ) then
			pPlayer:addGossipItem(GOSSIP_SENDER_TYPES.TYPE_QUEST, v.title_string, GOSSIP_SENDER_TYPES.TYPE_QUEST, v.entry)
		end
	end
	if pObject:isTrainer() then
		pPlayer:addGossipItem(GOSSIP_SENDER_TYPES.TYPE_TRAINER, 1, GOSSIP_SENDER_TYPES.TYPE_TRAINER, 0)
	end
	if pObject:isVendor() then
		pPlayer:addGossipItem(GOSSIP_SENDER_TYPES.TYPE_VENDOR, 1, GOSSIP_SENDER_TYPES.TYPE_VENDOR, 0)
	end
	pPlayer:sendGossipMenu(pObject, 1)
	return true
end

--	@ return bool
--	true 销毁窗口 false 保留
function ScriptAI:onNativeGossipSelect(pPlayer, pObject, pSender, pIndex)
	if self.onGossipSelect then return self:onGossipSelect(pPlayer, pObject, pSender, pIndex) end
	local ret = nil
	if pSender == GOSSIP_SENDER_TYPES.TYPE_QUEST then
		ret = WindowMgr:createWindow("app.views.layer.vLayerQuestMenu", pIndex)
	elseif pSender == GOSSIP_SENDER_TYPES.TYPE_TRAINER then
		ret = WindowMgr:createWindow("app.views.layer.vLayerTrainerMenu", pObject:getEntry())
	elseif pSender == GOSSIP_SENDER_TYPES.TYPE_VENDOR then
		ret = WindowMgr:createWindow("app.views.layer.vLayerVendorMenu", pObject:getEntry())
	end
	return ret ~= nil
end

function ScriptAI:onReset()
	self.m_MoveInLineOfSightTimer = 0
	self:setVictim(nil)
	self:setInCombat(false)
	self:setTraceOn(nil)
	self:clearThreatList()
	return self
end

function ScriptAI:onTranceMove(victim)
	local offsetX = victim:getPositionX() > self:getOwner():getPositionX() and 1 or -1
	local distance = self:getOwner():getDistance(victim)
	if distance < 100 then offsetX = 0 end
	return offsetX
end

function ScriptAI:onAIMove(diff)
	local offsetX = 0
	local TracedUnit = self:isInCombat() and self:getVictim() or self:getTracedUnit()
	if TracedUnit then 
		offsetX = self:onTranceMove(TracedUnit) 
	end
	return offsetX
end

--[[ For Combat Issus]]

	--[[ For Threat Issus]]
function ScriptAI:addThreat(who, val)
	local currThreat = self.m_ThreadList[who] or 0
	currThreat = math.min(1, currThreat + val)
	self.m_ThreadList[who] = currThreat
end

function ScriptAI:clearThreatList()
	-- mind to exit Combat
	for unit, threat in pairs(self.m_ThreadList) do
		if unit:isPlayer() then
			unit:getScript():minusThreatRef()
		end
	end
	self.m_ThreadList = {}
end

	--[[ End Threat Issus]]
function ScriptAI:moveInLineOfSight(who)
	if not self:isInCombat() and FactionMgr:isHostile(self:getOwner():getFaction(), who:getFaction()) then
		self:setInCombatWith(who)
	end
end

function ScriptAI:setInCombatWith(who)
	-- body
	if self:isCreature() then
		local script = self:getScript()
		script:setInCombat(true)
		script:addThreat(who, 1) --[[ 添加一点基础的威胁值 ]]
	else -- Player
		local script = self:getScript()
		script:setInCombat(true)
	end
end

function ScriptAI:isInCombatWith(who)
	return self.m_ThreadList[who] ~= nil
end

function ScriptAI:setInCombat(enabled)
	if self.m_IsInCombat == enabled then return end
	self.m_IsInCombat = enabled
	if self.m_IsInCombat == true then
		self:onStartCombat()
	else
		self:onExitCombat()
	end
end

function ScriptAI:onStartCombat() end --override

function ScriptAI:onExitCombat() end --override

function ScriptAI:isInCombat()
	return self.m_IsInCombat
end

function ScriptAI:setVictim(victim)
	self.m_Victim = victim
end

function ScriptAI:getVictim()
	return self.m_Victim
end

function ScriptAI:getThreadList()
	return self.m_ThreadList
end

function ScriptAI:onNativeDead()
	if self.onDead then self:onDead() end
	self:setInCombat(false)
end

function ScriptAI:isInMeleeAttackRange(target)
	return cc.pDistance(self:getOwner():getPosition(), target:getPosition()) < 50
end

function ScriptAI:doMeleeAttackIfReady()
	local victim = self:getVictim()
	if not self:isInMeleeAttackRange(victim) then return end
	self:getOwner():castSpell(SPELL_ID_MELEE_ATTACK)
end

function ScriptAI:getTracedUnit()
	return self.m_TracedUnit
end

function ScriptAI:setTraceOn(unit)
	self.m_TracedUnit = unit
end

function ScriptAI:onExecuteCombat(diff)
end
--[[ End Combat Issus]]

function ScriptAI:onUpdate(diff)
	if self.m_MoveInLineOfSightTimer >= MOVE_IN_LINE_OF_SIGHT_TIMER then
		--															(who, 			range, 	ingnoreSelf, aliveOnly, hostileOnly, maxNumber, checkFacing)
		local units = self:getOwner():getMap():fetchUnitInRange(self:getOwner(), SIGHT_RANGE, true, 		true, 	true, 			999, 		true)
		for k, v in pairs(units) do
			self:moveInLineOfSight(v.obj)
		end
		self.m_MoveInLineOfSightTimer = 0
	else
		self.m_MoveInLineOfSightTimer = self.m_MoveInLineOfSightTimer + diff
	end
end

return ScriptAI
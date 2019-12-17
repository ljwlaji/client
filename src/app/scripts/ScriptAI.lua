local ShareDefine 	= import("app.ShareDefine")
local WindowMgr		= import("app.components.WindowMgr")
local ScriptAI 		= class("ScriptAI")

local GOSSIP_SENDER_TYPES = ShareDefine.gossipSenderTypes()
--[[
	TYPE_QUEST 		= -1,
	TYPE_TRAINER 	= -2,
	TYPE_VENDOR 	= -3,
]]

local SIGHT_RANGE = ShareDefine.sightRange()

function ScriptAI:ctor(me)
	self.getOwner = function() return me end
	self:onReset()
end

function ScriptAI:onGossipHello(pPlayer, pObject)
	if not pObject:isQuestGiver() and not pObject:isVendor() and not pObject:isTrainer() then return false end
	for quest_entry, v in pairs(pObject:getQuestList()) do
		pPlayer:addGossipItem(GOSSIP_SENDER_TYPES.TYPE_QUEST, 1, GOSSIP_SENDER_TYPES.TYPE_QUEST, quest_entry)
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

function ScriptAI:onGossipSelect(pPlayer, pObject, pSender, pIndex)
	if pSender == GOSSIP_SENDER_TYPES.TYPE_QUEST then
		WindowMgr:createWindow("app.views.layer.vLayerQuestMenu", pObject:getQuestList()[pIndex])
	elseif pSender == GOSSIP_SENDER_TYPES.TYPE_TRAINER then
		WindowMgr:createWindow("app.views.layer.vLayerTrainerMenu", pObject:getEntry())
	elseif pSender == GOSSIP_SENDER_TYPES.TYPE_VENDOR then
		WindowMgr:createWindow("app.views.layer.vLayerVendorMenu", pObject:getEntry())
	end
end

function ScriptAI:onReset()
	self.m_Victim = nil
	self.m_ThreadList = {}
	self.m_MoveInLineOfSightTimer = 1000
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

function ScriptAI:moveInLineOfSight(who)
	if not self:isInCombat() then self:startCombat(who) end
end

function ScriptAI:startCombat(victim)
	self:setVictim(victim)
	self:setInCombat(true)
end

function ScriptAI:setInCombat(enabled)
	if self.m_Combat == enabled then return end
	self.m_Combat = enabled
	if self.m_Combat == true then
		self:getOwner():onCombatStart()
	else
		self:getOwner():onCombatEnded()
	end
end

function ScriptAI:isInCombat()
	return self.m_Combat
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

function ScriptAI:onDead()
	self:setInCombat(false)
end

function ScriptAI:doMeleeAttack()
	if cc.pGetDistance(self:getOwner(), self:getVictim()) <= 50 then
		self:getOwner():attack(self:getVictim())
	end
end

function ScriptAI:getTracedUnit()
	return self.m_TracedUnit
end

function ScriptAI:setTraceOn(unit)
	self.m_TracedUnit = unit
end

function ScriptAI:onExecuteCombat(diff)
	if not self:getVictim() and self:getVictim():isAlive() then return end
end
--[[ End Combat Issus]]

function ScriptAI:onUpdate(diff)
	if self.m_MoveInLineOfSightTimer <= diff then
		local units = self:getOwner():getMap():fetchUnitInRange(self:getOwner(), SIGHT_RANGE, true, true, true)
		for k, v in pairs(units) do
			self:moveInLineOfSight(v.obj)
		end
		self.m_MoveInLineOfSightTimer = 1000
	else
		self.m_MoveInLineOfSightTimer = self.m_MoveInLineOfSightTimer - diff
	end
end

return ScriptAI
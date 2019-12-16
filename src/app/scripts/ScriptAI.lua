local ShareDefine 	= import("app.ShareDefine")
local WindowMgr		= import("app.components.WindowMgr")
local ScriptAI 		= class("ScriptAI")

local GOSSIP_SENDER_TYPES = ShareDefine.gossipSenderTypes()
--[[
	TYPE_QUEST 		= -1,
	TYPE_TRAINER 	= -2,
	TYPE_VENDOR 	= -3,
]]

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

function ScriptAI:moveInLineOfSight(who)
	
end

function ScriptAI:onReset()
	self.m_Victim = nil
	self.m_ThreadList = {}
end

function ScriptAI:onAIMove(diff)

end

--[[ For Combat Issus]]
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

end

function ScriptAI:doMeleeAttack()
	if cc.pGetDistance(self:getOwner(), self:getVictim()) <= 50 then
		self:getOwner():attack(self:getVictim())
	end
end

function ScriptAI:isInAttackRange(who)

end

function ScriptAI:tryTraceVictim()

end

function ScriptAI:onExecuteCombat(diff)
	if not self:getVictim() and self:getVictim():isAlive() then return end
end

function ScriptAI:onEnterCombat(victim)
	self:setVictim(victim)
end

function ScriptAI:onExitCombat()

end
--[[ End Combat Issus]]

function ScriptAI:onUpdate(diff)

end

return ScriptAI
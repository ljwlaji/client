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
	self.m_PathGenerateTimer = 2000
	self.m_TargetMoementPos = nil
end

function ScriptAI:onDead()

end

function ScriptAI:tryGenrateNextMovePos()
	local nextPos = 0
	local owner = self:getOwner()
	if owner:isCreature() then
		if false then
		-- if owner:getVictim() then
		else
			nextPos = owner.context.x + math.random(-200, 200)
		end
	end
	return nextPos
end

function ScriptAI:onAIMove(diff)
	do return end
	if self.m_TargetMoementPos then
		local dis = self:getOwner():getPositionX() - self.m_TargetMoementPos
		if math.abs(dis) < 5 then
			self.m_TargetMoementPos = nil
			return 0
		else
			return self:getOwner():getPositionX() > self.m_TargetMoementPos and -1 or 1
		end
	end

	if self.m_PathGenerateTimer <= diff then
		self.m_TargetMoementPos = self:tryGenrateNextMovePos()
		self.m_PathGenerateTimer = 2000
	else
		self.m_PathGenerateTimer = self.m_PathGenerateTimer - diff
	end

	return 0
end

function ScriptAI:onUpdate(diff)

end

return ScriptAI
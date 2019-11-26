local ShareDefine 	= import("app.ShareDefine")
local ScriptAI 		= class("ScriptAI")

function ScriptAI:ctor(me)
	self.getOwner = function() return me end
	self:onReset()
end

function ScriptAI:onGossipHello(pPlayer, pObject)
	return false
end

function ScriptAI:onGossipSelect(pPlayer, pObject, pSender, pIndex)

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
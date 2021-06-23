local PlayerScript 	= class("PlayerScript", ScriptAI)

function PlayerScript:ctor(me)
	self.getOwner = function() return me end
end

function PlayerScript:onReset()
	self:setVictim(nil)
	self:setInCombat(false)
	return self
end

--[[ For Combat Issus]]
function PlayerScript:setInCombat(enabled)
	if self.m_Combat == enabled then return end
	self.m_Combat = enabled
	if self.m_Combat == true then
		self:getOwner():startCombat()
		self:onNativeStartCombat()
	else
		self:getOwner():leaveCombat()
		self:onNativeExitCombat()
	end
end

function PlayerScript:addThreatRef()
	self.m_ThreadRef = self.m_ThreadRef + 1
	return self
end

function PlayerScript:minusThreatRef()
	self.m_ThreadRef = self.m_ThreadRef - 1
	if self.m_ThreadRef == 0 then self:setInCombat(false) end
	return self
end

function PlayerScript:onNativeStartCombat() 
	if self.onStartCombat then self:onStartCombat() end
end --override

function PlayerScript:onNativeExitCombat() 
	if self.onExitCombat then self:onExitCombat() end
end --override

function PlayerScript:onNativeLevelUp(oldLvl, newLvl)
	if self.onLevelUp then self:onLevelUp(oldLvl, newLvl) end
end

function PlayerScript:isInCombat()
	return self.m_Combat
end

function PlayerScript:setVictim(victim)
	self.m_Victim = victim
	return self
end

function PlayerScript:getVictim()
	return self.m_Victim
end

function PlayerScript:onNativeDead()
	if self.onDead then self:onDead() end
end

function PlayerScript:isInMeleeAttackRange(target)
	return cc.pDistance(self:getOwner():getPosition(), target:getPosition()) < 50
end

function PlayerScript:doMeleeAttackIfReady()
end

function PlayerScript:getTracedUnit()
end

function PlayerScript:setTraceOn(unit)
end

function PlayerScript:onExecuteCombat(diff)
end
--[[ End Combat Issus]]

function PlayerScript:onUpdate(diff)

end

return PlayerScript
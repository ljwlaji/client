local ScriptAI = class("ScriptAI")

function ScriptAI:ctor(me)
	self.me = me
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

end

function ScriptAI:onDead()

end

function ScriptAI:onUpdate(diff)

end

return ScriptAI
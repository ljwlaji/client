local ScriptAI = import("app.scripts.ScriptAI")
local script_test = class("script_test", ScriptAI)

function script_test:onGossipHello(pPlayer, pObject)
	release_print("onGossipHello")
	local GossipItems = {}
	pPlayer:addGossipItem(1, 2, 1, 1);
	pPlayer:addGossipItem(2, 2, 1, 2);
	pPlayer:addGossipItem(3, 2, 1, 3);
	pPlayer:sendGossipMenu(pObject, 1)
	return true
end

function script_test:onGossipSelect(pPlayer, pObject, pSender, pIndex)
	local maxindex = math.random(1, 3)

	for i=1, maxindex do
		pPlayer:addGossipItem(math.random(1, 3), 2, 1, math.random(1, 3))
	end
	pPlayer:sendGossipMenu(pObject, 1)
end


return script_test
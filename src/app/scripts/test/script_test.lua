local ScriptAI = import("app.scripts.ScriptAI")
local script_test = class("script_test", ScriptAI)

function script_test:onGossipHello(pPlayer, pObject)
	release_print("onGossipHello")

	local GossipItems = {}
	pPlayer:addGossipItem(1, 1, 1, 1);
	pPlayer:sendGossipMenu(GossipItems)
	return true
end

function script_test:onGossipSelect(pPlayer, pObject, pSender, pIndex)

end


return script_test
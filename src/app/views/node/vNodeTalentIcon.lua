local ViewBaseEx 			= import("app.views.ViewBaseEx")
local Player 				= import("app.components.Object.Player")
local SpellMgr 				= import("app.components.SpellMgr")
local vNodeTalentIcon 		= class("vNodeTalentIcon", ViewBaseEx)

vNodeTalentIcon.RESOURCE_FILENAME = "res/csb/node/CSB_Node_TalentIcon.csb"
vNodeTalentIcon.RESOURCE_BINDING = {
	Panel_Icon = "onTouchTalentSpell"
}

local function split( str,reps )
    local resultStrList = {}
    string.gsub(str,'[^'..reps..']+', function ( w )
    	resultStrList[#resultStrList + 1] = tonumber(w)
    end)
    return resultStrList
end

function vNodeTalentIcon:onCreate()

end

function vNodeTalentIcon:onReset(TalentInfo)
	local plr = Player:getInstance()
	local spells = split(TalentInfo.spells, ",")
	local currentProgress = 1
	for k, v in pairs(spells) do
		if not plr:hasSpell(v) then break end
		currentProgress = currentProgress + 1
	end

	--for testting
	currentProgress = 1
	-- release_print("index : "..TalentInfo.index.." || ".."progress : "..currentProgress)

	assert(spells[currentProgress], TalentInfo.index)
	local spellInfo = SpellMgr:getSpellTemplate(spells[currentProgress])
	local iconPath = string.format("res/ui/icon/%s", spellInfo.icon_name)
	self.m_Children["Sprite_Icon"]:setTexture(iconPath)
	self.m_Children["Text_Progress"]:setString(string.format("%d/%d", currentProgress, #spells))
									:setColor(currentProgress == #spells and cc.c3b(253, 202, 109) or cc.c3b(0, 255, 0))
	return self
end


function vNodeTalentIcon:onTouchTalentSpell(e)
	if e.name ~= "ended" then return end
	local plr = Player:getInstance()
end

return vNodeTalentIcon
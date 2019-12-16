local ViewBaseEx 		= import("app.views.ViewBaseEx")
local WindowMgr			= import("app.components.WindowMgr")
local Player			= import("app.components.Object.Player")
local SpellMgr 			= import("app.components.SpellMgr")
local SkillButtons 		= class("SkillButtons", ViewBaseEx)

SkillButtons.RESOURCE_FILENAME = "res/csb/node/CSB_Node_SkillButtons.csb"
SkillButtons.RESOURCE_BINDING = {
	Panel_Icon_1 = "onTouchSkillButton",
	Panel_Icon_2 = "onTouchSkillButton",
	Panel_Icon_3 = "onTouchSkillButton",
	Panel_Icon_4 = "onTouchSkillButton",
	Panel_Icon_5 = "onTouchSkillButton",
	Panel_Icon_6 = "onTouchSkillButton",
	Panel_Icon_7 = "onTouchSkillButton",
	Panel_Icon_8 = "onTouchSkillButton",
	ButtonJump 	 = "ouTouchButtonJump"
}

local SKILL_BTNS = {}

function SkillButtons:onCreate()
	for i=1, 8 do
		SKILL_BTNS[i] = { panel = self.m_Children["Panel_Icon_"..i], icon = self.m_Children["Sprite_Icon_"..i] }
	end
	self:regiestCustomEventListenter("MSG_ON_SPELL_SLOT_CHANGED", handler(self, self.onReset))
end

function SkillButtons:resetSpellButtons()
	local plr = Player:getInstance()
	if not plr then return end
	local spellSlots = plr:getSpellSlotInfo()
	for k, v in pairs(SKILL_BTNS) do
		v.icon:setVisible(spellSlots[k] ~= nil)
		if spellSlots[k] then
			local SpellTemplate = SpellMgr:getSpellTemplate(spellSlots[k])
			v.icon:setTexture(string.format("res/ui/icon/%s", SpellTemplate.icon_name))
		end
	end
end


function SkillButtons:onReset()
	self:resetSpellButtons()
end

function SkillButtons:onTouchSkillButton(e)
	if e.name ~= "ended" then return end
	local plr = Player:getInstance()
	if not plr then return end
	local spellEntry = plr:getSpellSlotInfo()[e.target:getTag()]
	if not spellEntry then return end
	plr:castSpell(spellEntry)
end

function SkillButtons:ouTouchButtonJump(e)
	if e.name ~= "ended" then return end
	self:sendAppMsg("onControllerJump")
end

return SkillButtons
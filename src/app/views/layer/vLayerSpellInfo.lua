local ViewBaseEx 		= require("app.views.ViewBaseEx")
local Utils             = require("app.components.Utils")
local WindowMgr			= require("app.components.WindowMgr")
local Player			= require("app.components.Object.Player")
local DataBase 			= require("app.components.DataBase")
local SpellMgr 			= require("app.components.SpellMgr")
local ShareDefine       = require("app.ShareDefine")
local vLayerSpellInfo 	= class("vLayerSpellInfo", ViewBaseEx)

vLayerSpellInfo.RESOURCE_FILENAME = "res/csb/layer/CSB_Layer_SpellInfo.csb"
vLayerSpellInfo.RESOURCE_BINDING = {
	Panel_Icon_1 	= "onTouchSpellSlot",
	Panel_Icon_2 	= "onTouchSpellSlot",
	Panel_Icon_3 	= "onTouchSpellSlot",
	Panel_Icon_4 	= "onTouchSpellSlot",
	Panel_Icon_5 	= "onTouchSpellSlot",
	Panel_Icon_6 	= "onTouchSpellSlot",
	Panel_Icon_7 	= "onTouchSpellSlot",
	Panel_Icon_8 	= "onTouchSpellSlot",
	ButtonExit 		= "onTouchButtonExit",
}

local SKILL_BTNS = {}

function vLayerSpellInfo:onCreate(context)
	for i=1, 8 do
		SKILL_BTNS[i] = { panel = self.m_Children["Panel_Icon_"..i], icon = self.m_Children["Sprite_Icon_"..i] }
	end
	self.context = context
	self.m_Children["Text_SpellSlotTitle"]:setString(DataBase:getStringByID(10021))
	self:regiestCustomEventListenter("MSG_ON_SPELL_SLOT_CHANGED", handler(self, self.onReset))
	self:onReset()
end

function vLayerSpellInfo:resetSpellButtons()
	local plr = Player:getInstance()
	local spellSlots = plr:getSpellSlotInfo()
	for k, v in pairs(SKILL_BTNS) do
		v.icon:setVisible(spellSlots[k] ~= nil)
		if spellSlots[k] then
			local SpellTemplate = SpellMgr:getSpellTemplate(spellSlots[k])
			v.icon:setTexture(string.format("res/ui/icon/%s", SpellTemplate.icon_name))
		end
	end
end

function vLayerSpellInfo:onReset()
	local plr = Player:getInstance()
	if not plr or not plr:hasSpell(self.context.entry) then self:removeSelf() return end

	self:resetSpellButtons()
	local desc = SpellMgr:getSpellDescString(self.context)
	desc = table.concat(Utils.splitStrByLetterCount(desc, 30), "\n")
	self.m_Children["Text_SpellDesc"]:setString(desc)
	self.m_Children["Text_SpellName"]:setString(DataBase:getStringByID(self.context.name_string))
	local hideCost = self.context.cost_amount == 0 or self.context.cost_type == 0
	self.m_Children["Text_SpellCost"]:setVisible(not hideCost)
	if not hideCost then
		self.m_Children["Text_SpellCost"]:setString(string.format("%d %s", self.context.cost_amount, ShareDefine.getStateStringByStateIndex(self.context.cost_type)))
	end
	self.m_Children["Text_SpellRange"]:setString(string.format(DataBase:getStringByID(10022), self.context.target_range))
end

function vLayerSpellInfo:onTouchSpellSlot(e)
	if e.name ~= "ended" then return end
	local tag = e.target:getTag()
	local spellid = self.context.entry
	WindowMgr:popCheckWindow({
		onConfirm = function()
			local plr = Player:getInstance()
			if not plr:hasSpell(spellid) then return end
			plr:changeSlotSpell(tag, spellid)
		end,
		block = true
	})
end

function vLayerSpellInfo:onTouchButtonExit(e)
	if e.name ~= "ended" then return end
	self:removeSelf()
end

return vLayerSpellInfo
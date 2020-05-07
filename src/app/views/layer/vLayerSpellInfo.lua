local ViewBaseEx 		= import("app.views.ViewBaseEx")
local Utils             = import("app.components.Utils")
local WindowMgr			= import("app.components.WindowMgr")
local Player			= import("app.components.Object.Player")
local DataBase 			= import("app.components.DataBase")
local SpellMgr 			= import("app.components.SpellMgr")
local ShareDefine       = import("app.ShareDefine")
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
	self:resetSpellButtons()
	local desc = "1231231236516dsafdsafkjhqweoirhuqwouiefhnuilsadhfiulewhrhbnflsadkajhfeiworyqioqwer51ds9af84w9e7rsadf21w6er74we798rqwe"
	desc = table.concat(Utils.splitStrToTable(desc, 28), "\n")
	self.m_Children["Text_SpellDesc"]:setString(desc)
	self.m_Children["Text_SpellName"]:setString(DataBase:getStringByID(self.context.name_string))
	local hideCost = self.context.cost_amount == 0 or self.context.cost_type == 0
	self.m_Children["Text_SpellCost"]:setVisible(not hideCost)
	if not hideCost then
		self.m_Children["Text_SpellCost"]:setString(string.format("%d %s", self.context.cost_amount, ShareDefine.getStateStringByStateIndex(self.context.cost_type)))
	end
	self.m_Children["Text_SpellRange"]:setString(string.format(DataBase:getStringByID(10022), self.context.cast_range))
end

function vLayerSpellInfo:onTouchSpellSlot(e)
	if e.name ~= "ended" then return end
	local plr = Player:getInstance()
	local spellSlots = plr:getSpellSlotInfo()
	WindowMgr:popCheckWindow({
		onConfirm = function() 
			plr:changeSlotSpell(e.target:getTag(), self.context.entry)
		end,
		block = true
	})
end

function vLayerSpellInfo:onTouchButtonExit(e)
	if e.name ~= "ended" then return end
	self:removeFromParent()
end

return vLayerSpellInfo
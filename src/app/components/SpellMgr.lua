local DataBase = import("app.components.DataBase")
local SpellMgr = class("SpellMgr")

SpellMgr.instance = nil

function SpellMgr:getInstance()
	if not SpellMgr.instance then
		SpellMgr.instance = SpellMgr:create()
	end
	return SpellMgr.instance
end

function SpellMgr:ctor()
	self.m_SpellTemplates = {}
end

function SpellMgr:resetDescFitter()
	self.m_DamageFitter = {
		[1] = DataBase:getStringByID(300000),
		[2] = DataBase:getStringByID(300001)
	}
	self.m_CheckFacingToFitter = {
		[1] = DataBase:getStringByID(300002),
		[0] = DataBase:getStringByID(300003)
	}

	self.m_ExtraDamageFitter = DataBase:getStringByID(300004)
end

function SpellMgr:loadFromDB()
	local queryResult = DataBase:query("SELECT * FROM spell_template")
	for k, v in pairs(queryResult) do
		self.m_SpellTemplates[v.entry] = v
	end
	self:resetDescFitter()
end

function SpellMgr:getSpellDescString(spellInfo)
	local str = DataBase:getStringByID(spellInfo.description_string)
	str = string.gsub(str, "{target_range}", 			spellInfo.target_range)
	str = string.gsub(str, "{max_target_count}", 		spellInfo.max_target_count)
	str = string.gsub(str, "{damage_multiply_base}", 	(spellInfo.damage_multiply_base * 100) .. "%")
	
	if spellInfo.extra_damage_seed == 1 then
		str = string.gsub(str, "{extra_damage}", 		spellInfo.extra_damage)
	else
		str = string.gsub(str, "{extra_damage}", 		string.format(self.m_ExtraDamageFitter, spellInfo.extra_damage, spellInfo.extra_damage * spellInfo.extra_damage_seed))
	end
	str = string.gsub(str, "{damage_type}", self.m_DamageFitter[spellInfo.damage_type])
	str = string.gsub(str, "{check_facing_to}", self.m_CheckFacingToFitter[spellInfo.check_facing_to])
	return str
end

function SpellMgr:getSpellTemplate(spellID)
	return self.m_SpellTemplates[spellID]
end


return SpellMgr:getInstance()
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

function SpellMgr:loadFromDB()
	local queryResult = DataBase:query("SELECT * FROM spell_template")
	for k, v in pairs(queryResult) do
		self.m_SpellTemplates[v.entry] = v
	end
end

function SpellMgr:getSpellTemplate(spellID)
	return self.m_SpellTemplates[spellID]
end


return SpellMgr:getInstance()
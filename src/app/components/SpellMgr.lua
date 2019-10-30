local SpellMgr = class("SpellMgr")

SpellMgr.instance = nil

function SpellMgr:getInstance()
	if not SpellMgr.instance then
		SpellMgr.instance = SpellMgr:create()
	end
	return SpellMgr.instance
end

function SpellMgr:loadFromDB()

end

function SpellMgr:getSpellTemplate(spellID)
	return self.m_SpellTemplates[spellID]
end


return SpellMgr:getInstance()
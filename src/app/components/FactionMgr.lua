local DataBase = import("app.components.DataBase")
local FactionMgr = class("FactionMgr")

FactionMgr.instance = nil

function split( str,reps )
    local resultStrList = {}
    string.gsub(str,'[^'..reps..']+',function ( w )
    	resultStrList[w] = true
    end)
    return resultStrList
end

function FactionMgr:getInstance()
	if FactionMgr.instance == nil then
		FactionMgr.instance = FactionMgr:create()
	end
	return FactionMgr
end

function FactionMgr:loadFromDB()
	self.m_FactionTemplate = {}
	sql = "SELECT * FROM faction_template AS T JOIN faction_hostile_template AS H ON T.entry = H.entry"
	local queryResult = DataBase:query(sql)
	for k, v in pairs(queryResult) do 
		if v.hostile_list ~= "*" then v.hostile_list = split(",") end
		self.m_FactionTemplate[v.entry] = v
	end
end

function FactionMgr:isHostile(FactionA, FactionB)
	local template = self.m_FactionTemplate[FactionA]
	assert(template, "Cannot Find Faction Template By Faction Entry : ".. FactionA)
	return type(template.hostile_list) == "string" or template.hostile_list[FactionB] ~= nil
end

return FactionMgr:getInstance()
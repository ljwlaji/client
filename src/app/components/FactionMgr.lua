local DataBase = import("app.components.DataBase")
local FactionMgr = class("FactionMgr")

FactionMgr.instance = nil

--[[
	Faction 初始值

		14 天然敌对
		35 天然友好

		1 	人类
		2 	矮人
		3 	精灵
		4 	侏儒
		5 	狼人

		8 	兽人
		9 	牛头人
		10 	血精灵
		11  巨魔
		12	血精灵

		faction_hostile_template 中 彼此友好的阵营不做记录 对所有敌对的阵营记做*
		敌对阵营的阵营id用半角逗号分开
	
]]
local function split( str,reps )
    local resultStrList = {}
    string.gsub(str,'[^'..reps..']+', function ( w )
    	resultStrList[tonumber(w)] = true
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
	local sql = "SELECT * FROM faction_template AS T JOIN faction_hostile_template AS H ON T.entry = H.entry"
	local queryResult = DataBase:query(sql)
	for k, v in pairs(queryResult) do
		if v.hostile_list ~= "*" then v.hostile_list = split(v.hostile_list, ",") end
		self.m_FactionTemplate[v.entry] = v
	end
end

-- 还需要考虑有声望的情况 需要重写
function FactionMgr:isHostile(FactionA, FactionB)
	local template = self.m_FactionTemplate[FactionA]
	assert(template, "Cannot Find Faction Template By Faction Entry : ".. FactionA)
	if type(template.hostile_list) == "string" then return true end
	if template.hostile_list[FactionB] then return true end
	return false
end

return FactionMgr:getInstance()
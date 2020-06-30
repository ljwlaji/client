local AchievementMgr = class("AchievementMgr", cc.Node)

AchievementMgr.__instance = nil

function AchievementMgr:ctor()
	assert(not AchievementMgr.__instance, "Instance Of AchievementMgr Already Existed!")
	self.m_Datas = {}
	self.m_PlayerDatas = {}
	self:retain()
	self:loadFromDB()
	self:perpareMsgHooks()
end

function AchievementMgr:getInstance()
	if AchievementMgr.__instance == nil then AchievementMgr.__instance = AchievementMgr:create() end
	return AchievementMgr.__instance
end

function AchievementMgr:loadPlayerDatas(characterID)
	local DataBase = import("app.components.DataBase")
	local sql = "SELECT * FROM achievement_template WHERE character_id = %d"
	local queryResult = DataBase:query(string.format(sql, characterID))
	for _, data in pairs(queryResult) do
		self.m_PlayerDatas[data.entry] = data
	end
end

function AchievementMgr:loadFromDB()
	local DataBase = import("app.components.DataBase")
	local sql = "SELECT * FROM achievement_template"
	local queryResult = DataBase:query(sql)
	for _, v in pairs(queryResult) do
		self.m_Datas[v.entry] = v
	end
end

function AchievementMgr:getAchDataByEntry(entry)
	local data = self.m_Datas[entry]
	assert(data, "Cannot Find Such Achievement Data With Entry : "..entry)
	return data
end

function AchievementMgr:perpareMsgHooks()
	for k, v in pairs(self.m_Datas) do
		self:regiestCustomEventListenter(, function(...)  end)
	end
end

function AchievementMgr:onHookUpdate(id, context)

end

return AchievementMgr:getInstance()
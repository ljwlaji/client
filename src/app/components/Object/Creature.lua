local Unit 			= import("app.components.Object.Unit")
local Player        = import("app.components.Object.Player")
local ShareDefine 	= import("app.ShareDefine")
local DataBase 		= import("app.components.DataBase")
local Pawn 			= import("app.views.node.vNodePawn")
local FactionMgr	= import("app.components.FactionMgr")
local Creature 		= class("Creature", Unit)

function Creature:onCreate(pawn)
	Unit.onCreate(self, ShareDefine:creatureType())
	self:setPawn(pawn:addTo(self):init(self))

	self.m_QuestList = {}
	self:setGuid(self.context.guid)
	self:setFaction(self.context.faction)
	self:setAlive(self.context.alive)
	self:setDeathTime(self.context.dead_time)
	self:setLevel(self.context.level)
	self:fetchQuest()
	self:fetchMovePaths()
	self:move(self.context.x, self.context.y)
	self:setName(DataBase:getStringByID(self.context.name_id))
	self:updateBaseAttrs()
    self:setContentSize(50, 90)

    if self.context.script_name and self.context.script_name ~= "" then
		self:initAI(self.context.script_name)
	else
		self:initAI("ScriptAI")
	end
	self.m_RebornCheckTimer = 1000
end

function Creature:getEntry()
	return self.context.entry
end

function Creature:isVendor()
	return self.context.isVendor > 0
end

function Creature:isTrainer()
	return self.context.isTrainer > 0
end

function Creature:getQuestList()
	return self.m_QuestList
end

function Creature:isQuestProvider()
	return #self.m_QuestList > 0
end

function Creature:initAI(AIName)
	local currAITemplate = import(string.format("app.scripts.%s", AIName))
	assert(currAITemplate, "Cannot Find Current AI By Path Named: ["..AIName.."]")
	self:setAI(currAITemplate:create(self):onReset())
end

function Creature:setAI(AIInstance)
	if AIInstance == self.m_AI then return end
	self.m_AI = AIInstance
end

function Creature:getAI()
	return self.m_AI
end

function Creature:onTouched(pPlayer)
	-- 判断阵营
	-- 判断声望
	-- 判断生死情况

	-- if not self:isAlive() then release_print(" Creature:onTouched(pPlayer) 目标已死亡！") return end
	-- if FactionMgr:isHostile(self:getFaction(), pPlayer:getFaction()) then release_print("Creature:onTouched(pPlayer) 敌对状态 无法响应") return end
	return self:getAI():onNativeGossipHello(pPlayer, self)
end

function Creature:fetchMovePaths()
    local sql = string.format("SELECT * FROM path_movement_template WHERE path_id = '%d'", self.context.path_id)
    local queryResult = DataBase:query(sql)[1]
    queryResult = queryResult and loadstring(string.format("return %s" ,queryResult["path_info"]))() or {}
    self:getMovementMonitor():setMovementPath(queryResult)
end

function Creature:fetchQuest()
	local sql = "SELECT entry, title_string FROM quest_template WHERE accept_npc == '%d' or submit_npc == '%d'"
	local queryResult = DataBase:query(string.format(sql, self:getGuid(), self:getGuid()))
	for k, v in pairs(queryResult) do table.insert(self.m_QuestList, v) end
end

function Creature:justDie(victim)
	Unit.justDie(self, victim)
	self:saveToDB()
end

function Creature:saveToDB()
	local sql = string.format("UPDATE creature_instance SET alive = '%d', dead_time = '%d' WHERE guid = '%d'", 
								self:isAlive() and 1 or 0, self:getDeathTime(), self:getGuid())
	DataBase:query(sql)
end

function Creature:reborn()
	Unit.reborn(self)
	self:getAI():onReset()
	self:move(self.context.x, self.context.y)
end

function Creature:onUpdate(diff)
	Unit.onUpdate(self, diff)
	if self:isAlive() then
		if self.m_AI then self.m_AI:onUpdate(diff) end
	else
		if self.m_RebornCheckTimer <= diff then
			self.m_RebornCheckTimer = 1000
			if os.time() - self:getDeathTime() >= self.context.reborn_time then
				self:reborn()
			end
		else
			self.m_RebornCheckTimer = self.m_RebornCheckTimer - diff
		end
	end
end

function Creature:cleanUpBeforeDelete()
	self:saveToDB()
	Unit.cleanUpBeforeDelete(self)
end



return Creature

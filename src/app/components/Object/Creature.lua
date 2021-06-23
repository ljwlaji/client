local Unit 			= import("app.components.Object.Unit")
local Player        = import("app.components.Object.Player")
local ShareDefine 	= import("app.ShareDefine")
local DataBase 		= import("app.components.DataBase")
local Pawn 			= import("app.views.node.vNodePawn")
local FactionMgr	= import("app.components.FactionMgr")
local Creature 		= class("Creature", Unit)

function Creature:onCreate()
	Unit.onCreate(self, ShareDefine:creatureType())
	self:setContentSize(self.context.width, self.context.height)
	self:setPawn(Pawn:create(self):addTo(self):init(self))

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

    if self.context.script_name and self.context.script_name ~= "" then
		self:initScript(self.context.script_name)
	else
		self:initScript("ScriptAI")
	end
	self.m_RebornCheckTimer = 1000
end

function Creature:getTouchBox()
	local box = self:getBoundingBox()
	box.x = box.x - self:getContentSize().width * .5
	return box
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

function Creature:initScript(ScriptName)
	local currAITemplate = import(string.format("app.scripts.%s", ScriptName))
	assert(currAITemplate, "Cannot Find Current AI By Path Named: ["..ScriptName.."]")
	self:setAI(currAITemplate:create(self):onReset())
end

function Creature:setAI(ScriptInstance)
	if ScriptInstance == self.m_Script then return end
	self.m_Script = ScriptInstance
end

function Creature:getScript()
	return self.m_Script
end

function Creature:onTouched(pPlayer)
	-- 判断生死情况
	if not self:isAlive() then return false end
	-- 判断阵营
	if FactionMgr:isHostile(pPlayer:getFaction(), self:getFaction()) then
		return false 
	end
	-- 判断声望
	-- Code Here
	return self:getScript():onNativeGossipHello(pPlayer, self)
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
	self:getScript():onReset()
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

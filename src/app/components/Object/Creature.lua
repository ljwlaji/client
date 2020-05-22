local Unit 			= import("app.components.Object.Unit")
local Player        = import("app.components.Object.Player")
local ShareDefine 	= import("app.ShareDefine")
local DataBase 		= import("app.components.DataBase")
local Pawn 			= import("app.views.node.vNodePawn")
local Creature 		= class("Creature", Unit)

function Creature:onCreate()
	Unit.onCreate(self, ShareDefine:creatureType())
	self:setPawn(Pawn:create():addTo(self):init(self))

	self.m_QuestList = {}

	self:setGuid(self.context.guid)
	self:setFaction(self.context.faction)
	self:setAlive(self.context.alive)
	self:setDeathTime(self.context.dead_time)
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

function Creature:isQuestGiver()
	return #self.m_QuestList > 0
end

function Creature:onTouched(pPlayer)
	-- 判断阵营
	-- 判断声望
	-- 判断生死情况
	return self:getAI():onGossipHello(pPlayer, self)
end

function Creature:fetchMovePaths()
    local sql = string.format("SELECT * FROM path_movement_template WHERE path_id = '%d'", self.context.path_id)
    local queryResult = DataBase:query(sql)[1]
    queryResult = queryResult and loadstring(string.format("return %s" ,queryResult["path_info"]))() or {}
    self:getMovementMonitor():setMovementPath(queryResult)
end

function Creature:fetchQuest()
	local sql = "SELECT * FROM quest_template WHERE accept_npc == '%d' or submit_npc == '%d'"
	local queryResult = DataBase:query(string.format(sql, self:getGuid(), self:getGuid()))
	for k, v in pairs(queryResult) do
		self.m_QuestList[v.entry] = v
	end
end

function Creature:justDie()
	Unit.justDie(self)
	self:saveToDB()
end

function Creature:saveToDB()
	local sql = string.format("UPDATE creature_instance SET alive = '%d', dead_time = '%d' WHERE guid = '%d'", 
								self:isAlive() and 1 or 0, self:getDeathTime(), self:getGuid())
	DataBase:query(sql)
end

function Creature:onUpdate(diff)
	Unit.onUpdate(self, diff)
end

function Creature:cleanUpBeforeDelete()
	release_print("Creature : cleanUpBeforeDelete()")
	self:saveToDB()
	Unit.cleanUpBeforeDelete(self)
end



return Creature

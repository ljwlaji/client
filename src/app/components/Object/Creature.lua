local Unit 			= import("app.components.Object.Unit")
local Player        = import("app.components.Object.Player")
local ShareDefine 	= import("app.ShareDefine")
local DataBase 		= import("app.components.DataBase")
local Creature 		= class("Creature", Unit)

function Creature:onCreate()
	Unit.onCreate(self, ShareDefine:creatureType())

	self.m_QuestList = {}

	self:setGuid(self.context.guid)
	self:setFaction(self.context.faction)
	self:setAlive(self.context.alive)
	self:setDeathTime(self.context.dead_time)
	self:fetchQuest()

	if self.context.script_name and self.context.script_name ~= "" then
		self:initAI(self.context.script_name)
	else
		self:initAI("ScriptAI")
	end

	self:move(self.context.x, self.context.y)

	self.m_Model = self:createModelByID(self.context.model_id)
	self.m_Model:addTo(self):setAnchorPoint(0.5, 0)
	self:setName(DataBase:getStringByID(self.context.name_id))

	self:updateAttrs()
	-- For Testting
	local anims = {
		"attack",
		"celebrate",
		"combskill",
		"death",
		"dizzy",
		"dodge",
		"injured",
		"skill",
		"stand",
	}
	xpcall(function() 
		self.m_Model:setAnimation(0, "attack", false)
		self.m_Model:registerSpineEventHandler(function(event) 
			local index = math.random(1, #anims)
			self.m_Model:setAnimation(0, anims[index], false)
		end, sp.EventType.ANIMATION_COMPLETE)  
	end, function(...) dump({...}) end)
	-- End of testting
	
    self:setContentSize(50, 90)
    self:debugDraw()
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

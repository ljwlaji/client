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
	if self.context.script_name and self.context.script_name ~= "" then
		self:initAI(self.context.script_name)
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

function Creature.isTrainer()
	return self.context.isTrainer > 0
end

function Creature:fetchQuest()
	local sql = "SELECT * FROM quest_template WHERE accept_npc == '%d' or submit_npc == '%d'"
	local queryResult = DataBase:query(string.format(sql, self:getGuid()))
	for k, v in pairs(queryResult) do
		self.m_QuestList[v.entry] = v
	end
end

function Creature:tryTriggerFeature(pPlayer)
	local canTrigger = #self.m_QuestList > 0 or self:isVendor()
	if canTrigger then pPlayer:sendGossipMenu(self, 1) end
	return canTrigger
end

function Creature:onUpdate(diff)
	Unit.onUpdate(self, diff)
end

function Creature:cleanUpBeforeDelete()
	release_print("Creature : cleanUpBeforeDelete()")
	Unit.cleanUpBeforeDelete(self)
end



return Creature

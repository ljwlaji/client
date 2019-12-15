local Unit 				= import("app.components.Object.Unit")
local DataBase 			= import("app.components.DataBase")
local ShareDefine 		= import("app.ShareDefine")
local WindowMgr			= import("app.components.WindowMgr")
local Pawn 				= import("app.views.node.vNodePawn")
local Player 			= class("Player", Unit)

Player.instance = nil

local QUEST_COMPLISHED = 1

function Player.getInstance()
	return Player.instance
end

function Player:onCreate()
	Unit.onCreate(self, ShareDefine:playerType())
	self.m_InventoryData = {}
	self.m_LearnedSpells = {}
	self.m_QuestDatas = {}
	self:setAlive(true)
	self:loadFromDB()
	self:setControlByPlayer(true)
	self:resetGossipList()
	self:updateAttrs()
	Player.instance = self
    self:move(self.context.pos_x, self.context.pos_y)
    	:setLocalZOrder(1)
    	-- :setContentSize(sp:getContentSize())
	-- self:regiestCustomEventListenter("MSG_INVENTORY_DATA_CHANGED", function() end)

end

function Player:loadFromDB()
	-- For CHaracter Base Data Issus
	-- template and instance
	-- race class level tanlent etc.
	local queryResult = nil
	local sql = "SELECT * FROM character_instance AS I JOIN character_template AS T ON I.class = T.class AND I.gender = T.gender WHERE I.guid = %d"
	queryResult = DataBase:query(string.format(sql, self.context))[1]
	self.context = queryResult
	self:setPawn(Pawn:create():addTo(self):init(self))
	self:setClass(queryResult.class)
	self:setLevel(queryResult.level)
	self:setName(queryResult.name)
	self:setGuid(queryResult.guid)
	self:loadInventoryFromDB()
	self:loadAllLearnedSpellsFromDB()
	self:loadActivatedSpellFromDB()

	self:loadQuestFromDB()
end

--[[ For Quest Issus ]]

function Player:loadQuestFromDB()
	local sql = "SELECT * FROM character_quest WHERE character_guid = '%d'"
	local queryResult = DataBase:query(string.format(sql, self:getGuid()))
	for k, v in pairs(queryResult) do
		self.m_QuestDatas[v.quest_entry] = v
	end
end

function Player:saveQuestToDB()
	local sql = "DELETE FROM character_quest WHERE character_guid = '%d'"
	DataBase:query(sql)
	sql = "REPLACE INTO character_quest(character_guid, quest_entry, complished, complished_date) VALUES('%d', '%d', '%d', '%d')"
	for k, v in pairs(self.m_QuestDatas) do
		DataBase:query(string.format(sql, self:getGuid(), v.quest_entry, complished, complished_date))
	end
end

function Player:isQuestComplished(questEntry)
	return self.m_QuestDatas[questEntry] and self.m_QuestDatas[questEntry].complished == QUEST_COMPLISHED
end

function Player:canSubmitQuest(questEntry)
	if not self.m_QuestDatas[questEntry] then return false end
	if self.m_QuestDatas[questEntry].complished == QUEST_COMPLISHED then return false end --已完成过相同任务
	local canSubmit = true
	for item_entry, item_amount in pairs(questTemplate.quest_targets) do
		if self:getItemCount(item_entry) < item_amount then
			canSubmit = false
			break
		end
	end
	return canSubmit
end

function Player:canAcceptQuest(questTemplate)
	if self.m_QuestDatas[questTemplate.entry] then return false end
	if self.m_QuestDatas[questTemplate.previous_quest_entry].complished ~= QUEST_COMPLISHED then return false end --未完成前置任务
	if questTemplate.require_level > self:getLevel() then return false end -- 等级不足
	if questTemplate.require_class ~= self:getClass() then return false end

	local nextTime = 0
	if questTemplate.quest_type == ShareDefine.dailyQuest() then
		nextTime = self.m_QuestDatas[questTemplate.entry].complished_date + ShareDefine.DAY()
	elseif questTemplate.quest_type == ShareDefine.weeklyQuest() then
		nextTime = self.m_QuestDatas[questTemplate.entry].complished_date + ShareDefine.WEEK()
	end

	return nextTime <= os.time()
end

--[[ End Quest Issus ]]

function Player:getLearnedSpells()
	return self.m_LearnedSpells
end

function Player:loadAllLearnedSpellsFromDB()
	local sql = "SELECT * FROM character_spells WHERE character_guid = '%d'"
	local queryResult = DataBase:query(string.format(sql, self:getGuid()))
	for _, singleData in pairs(queryResult) do
		table.insert(self.m_LearnedSpells, singleData.spell_id)
	end
end

function Player:saveAllLearnedSpellToDB()
	local sql = "DELETE FROM character_spells WHERE character_guid = %d"
	DataBase:query(sql)
	sql = "REPLACE INTO character_spells(character_guid, spell_id) VALUES('%d', '%d')"
	for _, spell_id in pairs(self.m_LearnedSpells) do
		DataBase:query(string.format(sql, self:getGuid(), spell_id))
	end
end

function Player:loadActivatedSpellFromDB()
	local sql = "SELECT * FROM spell_activated WHERE character_guid = '%d'"
	local queryResult = DataBase:query(string.format(sql, self:getGuid()))
	for k, v in pairs(queryResult) do
		self.m_ActivatedSpells[v.spell_id] = v
	end
end

function Player:saveActivatedSpellFromDB()
	local sql = "DELETE FROM spell_activated WHERE character_guid = %d"
	DataBase:query(string.format(sql, self:getGuid()))
	sql = "REPLACE INTO spell_activated(character_guid, spell_id, time_left) VALUES('%d', '%d', '%d')"
	for k, v in pairs(self.m_ActivatedSpells) do
		DataBase:query(string.format(sql, self:getGuid(), v.spell_id, v.time_left))
	end 
end

function Player:loadInventoryFromDB()
	local sql = "SELECT * FROM character_inventory WHERE character_guid = %d"
	local queryResult = DataBase:query(string.format(sql, self.context.guid)) or {}
	for k, v in pairs(queryResult) do
		v.template = DataBase:getItemTemplateByEntry(v.item_entry)
		self.m_InventoryData[v.slot_id] = v
	end
end

function Player:getInventorySlotCount()
	local count = ShareDefine.inventoryBaseSlotCount()
	for i = ShareDefine.containerSlotBegin(), ShareDefine.containerSlotEnd() do
		local container = self.m_InventoryData[i]
		if container then
			local extraCount = container.template.container_slot_count
			count = count + extraCount
		end
	end
	return count - 1
end

function Player:getEmptyInventorySlot()
	local slotBegin 	= ShareDefine.inventorySlotBegin()
	local slotEnded 	= slotBegin + self:getInventorySlotCount()
	local emptySlotIndex = nil
	for i = slotBegin, slotEnded do
		if not self.m_InventoryData[i] then emptySlotIndex = i break end
	end
	return emptySlotIndex
end

function Player:getItemCount(pItemEntry)
	local count = 0
	for itemEntry, itemData in pairs(self.m_InventoryData) do
		if itemEntry == pItemEntry then
			count = count + itemData.item_amount
		end
	end
	return count
end

function Player:updateEquipmentAttrs()
	local extraValues = {
		["strength"] 		= 0,
		["intelligence"] 	= 0,
		["agility"] 		= 0,
		["spirit"] 			= 0,
		["stamina"] 		= 0,
	}
	for i = ShareDefine.equipSlotBegin(), ShareDefine.equipSlotEnd() do
		local equipment = self.m_InventoryData[i]
		if equipment then
			-- 计算基础的属性增幅
			for attrName, value in pairs(equipment.template.attrs) do
				extraValues[attrName] = extraValues[attrName] + value
			end
		end
	end
	for attrName, value in pairs(extraValues) do
		self:setBaseAttr(attrName, self:getBaseAttr(attrName) + value)
	end
end

function Player:tryUnEquipItem(itemSlot)
	local emptySlotIndex = self:getEmptyInventorySlot()
	if not emptySlotIndex then return end
	local itemData = self.m_InventoryData[itemSlot]
	assert(itemData, "Cannot Find Current ItemData In Slot : "..itemSlot.."!")
	itemData.slot_id = emptySlotIndex
	self.m_InventoryData[emptySlotIndex] = table.remove(self.m_InventoryData, itemSlot)
	self:onInventoryDataChanged()
end

function Player:tryEquipItem(itemSlot)
	local replacement = self.m_InventoryData[itemSlot]
	assert(replacement, "Cannot Find Current ItemData In Slot : "..itemSlot.."!")
	local equipmentSlot = replacement.template.equip_slot
	local temp = nil
	if not self:canEquip(replacement) then return end

	replacement.slot_id = equipmentSlot
	local oldEquiupData = self.m_InventoryData[equipmentSlot]
	if oldEquiupData then oldEquiupData.slot_id = itemSlot end

	temp = self.m_InventoryData[itemSlot]
	self.m_InventoryData[itemSlot] = oldEquiupData
	self.m_InventoryData[equipmentSlot] = temp
	self:onInventoryDataChanged()
end

function Player:onInventoryDataChanged()
	self:saveInventoryToDB()
	self:updateAttrs()
	self:sendAppMsg("MSG_INVENTORY_DATA_CHANGED")
	-- if self:getAI() then self:getAI():onInventoryDataChanged() end
end

function Player:saveToDB()
	-- Save Instance Stuff						  0		1		2		3	   4	5	  6		7	   8
	local sql = [[REPLACE INTO character_instance(guid, class, gender, level, race, name, map, pos_x, pos_y) 
										   VALUES('%d', '%d',  '%d',   '%d',  '%d', '%s', '%d','%d',  '%d') ]]
	--										0				1				2					3				4
	DataBase:query(string.format(sql, self:getGuid(), self:getClass(), self:getGender(), self:getLevel(), self:getRace(), 
	--										5					6						7					8
									  self:getName(), self:getMap():getEntry(), self:getPositionX(), self:getPositionY()))

	self:saveInventoryToDB()
	self:saveActivatedSpellFromDB()
	self:saveAllLearnedSpellToDB()
	self:saveQuestToDB()
end

function Player:saveInventoryToDB()
	local sql = "DELETE FROM character_inventory WHERE character_guid = '%d'"
	DataBase:query(string.format(sql, self:getGuid()))
	--											  
	sql = [[REPLACE INTO character_inventory(character_guid, slot_id, item_entry, item_guid, item_amount, enchant, durable) 
											VALUES('%d', 		   '%d',	'%d',		'%d',	   '%d',		%d,		 %d)]]
	for k, v in pairs(self.m_InventoryData) do
		DataBase:query(string.format( sql, v.character_guid, v.slot_id, v.item_entry, v.item_guid, v.item_amount, v.enchant, v.durable ))
	end
end

function Player:getInventoryData()
	return self.m_InventoryData
end

function Player:canEquip(itemData)
	-- local itemTemplate = itemData.template
	-- 职业检查
	-- if itemTemplate.require_class then return false end
	-- 耐久检查


	return true
end

function Player:onUpdate(diff)
	Unit.onUpdate(self, diff)
end

function Player:resetGossipList()
	self.m_GossipItemList = {}
end

function Player:sendGossipMenu(pObject, pTitleStringID)
	local window = WindowMgr:findWindowIndexByClassName("vLayerGossipMenu")
	if window then window:removeFromParent() end
	WindowMgr:createWindow("app.views.layer.vLayerGossipMenu", self.m_GossipItemList, self, pObject, pTitleStringID)
	self:resetGossipList()
end

function Player:addGossipItem(iconIndex, StringID, GossipSender, GossipIndex)
	self.m_GossipItemList[#self.m_GossipItemList + 1] = {
		IconIndex 		= iconIndex,
		StringID 		= StringID,
		GossipSender 	= GossipSender,
		GossipIndex 	= GossipIndex
	}
end

function Player:cleanUpBeforeDelete()
	release_print("Player : cleanUpBeforeDelete()")
	self:saveToDB()
	Unit.cleanUpBeforeDelete(self)
	Player.instance = nil
end

return Player
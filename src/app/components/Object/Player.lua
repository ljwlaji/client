local Unit 				= import("app.components.Object.Unit")
local DataBase 			= import("app.components.DataBase")
local ShareDefine 		= import("app.ShareDefine")
local WindowMgr			= import("app.components.WindowMgr")
local Pawn 				= import("app.views.node.vNodePawn")
local SpellMgr 			= import("app.components.SpellMgr")
local Utils             = import("app.components.Utils")
local Player 			= class("Player", Unit)

Player.instance = nil

local questStates = ShareDefine.questStates()
--[[
	IN_PROGRESS 	= 1,
	WAIT_FOR_SUBMIT = 2,
	FINISHED 		= 3,
]]

function Player.getInstance()
	return Player.instance
end

function Player:onCreate()
	Unit.onCreate(self, ShareDefine:playerType())
	self.m_InventoryData = {}
	self.m_LearnedSpells = {}
	self.m_QuestDatas = {}
	self.m_SpellSlots = {}
	self.m_FreeTalentPoint = 0
	self:setAlive(true)
	self:loadFromDB()
	self:setControlByPlayer(true)
	self:resetGossipList()
	self:updateBaseAttrs()
	Player.instance = self
    self:move(self.context.pos_x, self.context.pos_y)
    	:setLocalZOrder(1)


    self:setInventoryDataDirty(false)
    self:setQuestDataDirty(false)
	self:loadScript("PlayerScript")
end

function Player:loadFromDB()
	-- For CHaracter Base Data Issus
	-- template and instance
	-- race class level tanlent etc.
	local queryResult = nil
	local sql = "SELECT * FROM character_instance AS I JOIN character_template AS T ON I.class = T.class AND I.gender = T.gender WHERE I.guid = %d"
	queryResult = DataBase:query(string.format(sql, self.context))[1]
	self.context = queryResult
	self:setPawn(Pawn:create(self):addTo(self):init(self))
	self:setClass(queryResult.class)
	self:setLevel(queryResult.level)
	self:setName(queryResult.name)
	self:setGuid(queryResult.guid)
	self:setFaction(queryResult.faction)
	self:setGender(queryResult.gender)
	self:setRace(queryResult.race)
	self:setMoney(queryResult.money)
	self:loadInventoryFromDB()
	self:loadAllLearnedSpellsFromDB()
	self:loadBuffsFromDB()
	self:loadQuestFromDB()
	self:loadSpellSlotFromDB()
	self:loadSpellCoolDownFromDB()
	self:awardExp(0)
end

function Player:loadSpellCoolDownFromDB()
	local sql = "SELECT spell_id, cooldown_time_left FROM spell_cool_down WHERE character_guid = '%d'"
	local queryResult = DataBase:query(string.format(sql, self:getGuid()))
	for k, v in pairs(queryResult) do
		self:insertSpellCoolDown(v.spell_id, cooldown_time_left * 1000)
	end
end

function Player:isAchivementCompleted(AchiveEntry)
	return true
end
--							[[ ================ ]]
--							[[ For Script Issus ]]
--							[[ ================ ]]
function Player:getScript()
	return self.m_PlayerScript
end

function Player:loadScript(scriptPath)
	self.m_PlayerScript = import("app.scripts."..scriptPath)
end

--							[[ =============== ]]
--							[[ For Quest Issus ]]
--							[[ =============== ]]
function Player:setQuestDataDirty(value)
	self.m_QuestDataDirty = value
end

function Player:isQuestDataDirty()
	return self.m_QuestDataDirty
end

function Player:onQuestDataDirty()
	self:sendAppMsg("MSG_ON_QUEST_DATA_CHANGED")
	self:saveQuestToDB()
	self:setQuestDataDirty(false)
end

function Player:loadQuestFromDB()
	local sql = "SELECT * FROM character_quest WHERE character_guid = '%d'"
	local queryResult = DataBase:query(string.format(sql, self:getGuid()))
	for k, v in pairs(queryResult) do
		self.m_QuestDatas[v.quest_entry] = v
	end
end

function Player:saveQuestToDB()
	release_print("Saving Quest Datas...")
	dump(self.m_QuestDatas)
	local sql = "DELETE FROM character_quest WHERE character_guid = '%d'"
	DataBase:query(string.format(sql, self:getGuid()))
	sql = "REPLACE INTO character_quest(character_guid, quest_entry, state, finish_time) VALUES('%d', '%d', '%d', '%d')"
	for k, v in pairs(self.m_QuestDatas) do
		DataBase:query(string.format(sql, self:getGuid(), v.quest_entry, v.state, v.finish_time))
	end
end

function Player:getQuestDatas()
	return self.m_QuestDatas
end

function Player:isQuestFinished(questEntry)
	return self.m_QuestDatas[questEntry] and self.m_QuestDatas[questEntry].state == questStates.FINISHED
end

function Player:canSubmitQuest(questEntry)
	local questData = self.m_QuestDatas[questEntry]
	if not questData or questData.state == questStates.FINISHED then return false end
	local canSubmit = true
	local questTemplate = DataBase:getQuestTemplateByEntry(questEntry)
	for target_type, target_info in pairs(questTemplate.quest_targets) do
		for entry, amount in pairs(target_info) do
			if target_type == "items" then
				if self:getItemCount(entry) < amount then canSubmit = false break end 
			elseif target_type == "achive" then
				if not self:isAchivementCompleted(entry) then canSubmit = false break end
			end
		end
	end
	return canSubmit
end

function Player:trySubmitQuest(questEntry)
	local questTemplate = DataBase:getQuestTemplateByEntry(questEntry)
	for awards_type, awards_info in pairs(questTemplate.awards) do
		for entry, amount in pairs(awards_info) do
			if awards_type == "money" then
				self:addMoney(amount)
			elseif awards_type == "items" then
				self:addItem(entry, amount)
			elseif awards_type == "exp" then
				self:awardExp(amount)
			elseif awards_type == "reputation" then
			end
		end
	end
	self.m_QuestDatas[questEntry].state = questStates.FINISHED
	self.m_QuestDatas[questEntry].finish_time = os.time()
	self:setQuestDataDirty(true)
end

function Player:canAcceptQuest(questEntry)
	local questTemplate = DataBase:getQuestTemplateByEntry(questEntry)
	local questData = self.m_QuestDatas[questEntry]
	if questData and questTemplate.quest_type == ShareDefine.normalQuest() then
		return false 
	end

	if questTemplate.previous_quest_entry ~= 0 and not self:isQuestFinished(questTemplate.previous_quest_entry) then 
		return false 
	end

	if questTemplate.require_level > self:getLevel() then return false end -- 等级不足
	if questTemplate.require_class ~= 0 and questTemplate.require_class ~= self:getClass() then return false end

	local nextTime = 0
	if questTemplate.quest_type == ShareDefine.dailyQuest() then
		nextTime = self.m_QuestDatas[questTemplate.entry].finish_time + ShareDefine.DAY()
	elseif questTemplate.quest_type == ShareDefine.weeklyQuest() then
		nextTime = self.m_QuestDatas[questTemplate.entry].finish_time + ShareDefine.WEEK()
	end
	return nextTime <= os.time()
end

function Player:acceptQuest(questEntry)
	if self.m_QuestDatas[questEntry] ~= nil then return end
	self.m_QuestDatas[questEntry] = {
		character_guid 	= self:getGuid(),
		quest_entry 	= questEntry,
		state 			= questStates.IN_PROGRESS,
		finish_time		= 0,
	}
	self:setQuestDataDirty(true)
end

function Player:removeQuest(questEntry)
	if self.m_QuestDatas[questEntry] == nil then return end
	self.m_QuestDatas[questEntry] = nil
	self:setQuestDataDirty(true)
end

--							[[ =============== ]]
--							[[ End Quest Issus ]]
--							[[ =============== ]]

--							[[ =============== ]]
--							[[ For Spell Issus ]]
--							[[ =============== ]]


function Player:changeSlotSpell(pSlotID, pSpellID)
	if self.m_SpellSlots[pSlotID] == pSpellID then return end

	for slotID, SpellID in pairs(self.m_SpellSlots) do
		if pSpellID == SpellID then self.m_SpellSlots[slotID] = nil break end -- 移除旧的Slot信息
	end
	self.m_SpellSlots[pSlotID] = pSpellID
	self:saveSpellSlotToDB()
	self:sendAppMsg("MSG_ON_SPELL_SLOT_CHANGED")
end

function Player:getSpellSlotInfo()
	return self.m_SpellSlots
end

function Player:loadSpellSlotFromDB()
	-- local changed = false
	local sql = "SELECT * FROM spell_slot_instance WHERE character_guid = '%d'"
	local queryResult = DataBase:query(string.format(sql, self:getGuid()))
	for k, v in pairs(queryResult) do
		self.m_SpellSlots[v.slot_index] = v.spell_id
	end
end

function Player:saveSpellSlotToDB()
	local sql = "DELETE FROM spell_slot_instance WHERE character_guid = '%d'"
	DataBase:query(string.format(sql, self:getGuid()))
	sql = "INSERT INTO spell_slot_instance(character_guid, slot_index, spell_id) VALUES('%d', '%d', '%d')"
	for slot_index, spell_id in pairs(self.m_SpellSlots) do
		DataBase:query(string.format(sql, self:getGuid(), slot_index, spell_id))
	end
end

function Player:hasSpell(spellid)
	local hasSpell = false
	for i=1, #self.m_LearnedSpells do
		if self.m_LearnedSpells[i] == spellid then
			hasSpell = true
			break
		end
	end
	return hasSpell
end

function Player:learnSpell(spellid)
	if self:hasSpell(spellid) then return false end
	local spellInfo = SpellMgr:getSpellTemplate(spellid)
	if self:getClass() ~= spellInfo.require_class then return false end
	if self:getLevel() < spellInfo.require_level then return false end
	if self:getMoney() < spellInfo.learn_cost then return false end
	table.insert(self.m_LearnedSpells, spellid)
	self:saveAllLearnedSpellToDB()
	return true
end

function Player:unLearnSpell(spellid)
	for i=1, #self.m_LearnedSpells do
		if self.m_LearnedSpells[i] == spellid then
			table.remove(self.m_LearnedSpells, i)
			self:saveAllLearnedSpellToDB()
			self:cleanSpellSlots()
			break
		end
	end
end

function Player:getLearnedSpells()
	return self.m_LearnedSpells
end

function Player:cleanSpellSlots()
	local newSlotInfo = {}
	for slotID, spellid in pairs(self.m_SpellSlots) do
		if self:hasSpell(spellid) then
			newSlotInfo[slotID] = spellid
		end
	end
	self.m_SpellSlots = newSlotInfo
	self:saveSpellSlotToDB()
	self:sendAppMsg("MSG_ON_SPELL_SLOT_CHANGED")
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
	DataBase:query(string.format(sql, self:getGuid()))
	sql = "REPLACE INTO character_spells(character_guid, spell_id) VALUES('%d', '%d')"
	for _, spell_id in pairs(self.m_LearnedSpells) do
		DataBase:query(string.format(sql, self:getGuid(), spell_id))
	end
end

--							[[ =============== ]]
--							[[ End Spell Issus ]]
--							[[ =============== ]]

function Player:loadBuffsFromDB()
	local sql = "SELECT * FROM buff_instance WHERE character_guid = '%d'"
	local queryResult = DataBase:query(string.format(sql, self:getGuid()))
	for k, v in pairs(queryResult) do
		self.m_Buffs[v.spell_id] = v
	end
end

function Player:saveBuffsFromDB()
	local sql = "DELETE FROM buff_instance WHERE character_guid = %d"
	DataBase:query(string.format(sql, self:getGuid()))
	sql = "INSERT INTO buff_instance(character_guid, spell_id, time_left) VALUES('%d', '%d', '%d')"
	for k, v in pairs(self.m_Buffs) do
		DataBase:query(string.format(sql, self:getGuid(), v.spell_id, v.time_left))
	end 
end

--							[[ ======================== ]]
--							[[ For Inventory/Item Issus ]]
--							[[ ======================== ]]

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

function Player:getEmptyInventorySlot(compareItem, compareAmount)
	local slotBegin 		= ShareDefine.inventorySlotBegin()
	local slotEnded 		= slotBegin + self:getInventorySlotCount()
	local emptySlotIndex 	= nil
	local freeSpace 		= 0
	-- 先查找有相同物品的情况
	for i = slotBegin, slotEnded do
		if self.m_InventoryData[i] and 
			self.m_InventoryData[i].item_entry == compareItem and
			self.m_InventoryData[i].item_amount < compareAmount then
			emptySlotIndex 	= i
			freeSpace 		= compareAmount - self.m_InventoryData[i].item_amount
			break
		end
	end
	if emptySlotIndex then return emptySlotIndex, freeSpace end
	for i = slotBegin, slotEnded do
		if not self.m_InventoryData[i] then 
			emptySlotIndex 	= i
			freeSpace 		= compareAmount
			break 
		end
	end
	return emptySlotIndex, freeSpace
end

function Player:setInventoryDataDirty(dirty)
	self.m_InventoryDataDirty = dirty
end

function Player:isInventoryDataDirty()
	return self.m_InventoryDataDirty
end

function Player:onInventoryDataChanged()
	self:saveInventoryToDB()
	self:updateBaseAttrs()
	self:sendAppMsg("MSG_INVENTORY_DATA_CHANGED")
	self:setInventoryDataDirty(false)
end

function Player:getItemCount(pItemEntry)
	local count = 0
	for slotIndex, itemData in pairs(self.m_InventoryData) do
		if itemData.item_entry == pItemEntry then
			count = count + itemData.item_amount
		end
	end
	return count
end

function Player:setMoney(m)
	self.m_Money = m
end

function Player:addMoney(m)
	self.m_Money = self.m_Money + m
	if self.m_Money < 0 then self.m_Money = 0 end
	self:setInstanceDataDirty(true)
end

function Player:getMoney()
	return self.m_Money
end

function Player:hasSpaceFor(itemEntry, amount)
	local itemTemplate 		= DataBase:getItemTemplateByEntry(itemEntry)
	local requireSlot	 	= math.floor(amount / itemTemplate.max_amount)
	local requireSpace		= amount % itemTemplate.max_amount

	local slotBegin 		= ShareDefine.inventorySlotBegin()
	local slotEnded 		= slotBegin + self:getInventorySlotCount()
	local freeSlot 			= 0
	local freeSpace			= 0

	for i = slotBegin, slotEnded do
		if not self.m_InventoryData[i] then 
			freeSlot = freeSlot + 1
		elseif self.m_InventoryData[i].item_entry == itemEntry then
			freeSpace = freeSpace + (itemTemplate.max_amount - self.m_InventoryData[i].item_amount)
		end
	end

	if freeSlot >= (requireSlot + (requireSpace > 0 and 1 or 0)) then
		return true
	elseif freeSlot >= requireSlot and freeSpace > requireSpace then
		return true
	end

	release_print(string.format("Not Enough Space! require [%d Slot] And [%d Space] More!", requireSlot - freeSlot, requireSpace - freeSpace))
	return false
end

function Player:addItem(itemEntry, amount)
	amount = amount or 1
	local itemTemplate = DataBase:getItemTemplateByEntry(itemEntry)
	while amount > 0 do
		local slotIndex, freeSpace = self:getEmptyInventorySlot(itemEntry, itemTemplate.max_amount)
		if not slotIndex then release_print("没有足够的包裹空间！ 溢出 : ".. amount) return false end
		local genAmount = amount > freeSpace and freeSpace or amount

		-- newItem
		self.m_InventoryData[slotIndex] = self.m_InventoryData[slotIndex] or {
			character_guid 	= self:getGuid(),
			slot_id 		= slotIndex,
			item_entry 		= itemEntry,
			item_guid 		= DataBase:newItemGuid(),
			item_amount 	= 0,
			enchant 		= 0,
			durable 		= itemTemplate.max_durable,
			template 		= itemTemplate,
		}
		self.m_InventoryData[slotIndex].item_amount = self.m_InventoryData[slotIndex].item_amount + genAmount
		amount = amount - freeSpace
		self:setInventoryDataDirty(true)
	end
	return true
end

function Player:destoryItem(itemEntry, amount)
	local slotBegin 		= ShareDefine.inventorySlotBegin()
	local slotEnded 		= slotBegin + self:getInventorySlotCount()
	local amount_left = amount

	for i = slotBegin, slotEnded do
		local itemInfo = self.m_InventoryData[i]
		if itemInfo and itemInfo.item_entry == itemEntry then
			local destory_amount = itemInfo.item_amount > amount_left and amount_left or itemInfo.item_amount
			itemInfo.item_amount = itemInfo.item_amount - destory_amount
			if itemInfo.item_amount == 0 then self.m_InventoryData[i] = nil end
			amount_left = amount_left - destory_amount
			if destory_amount == 0 then break end
			assert(destory_amount >= 0, "destory_amount Cannot Less Than 0!")
		end
	end
	self:setInventoryDataDirty(true)
end

function Player:updateEquipmentAttrs()
	local extraValues = {
		["strength"] 		= 0,
		["intelligence"] 	= 0,
		["agility"] 		= 0,
		["spirit"] 			= 0,
		["stamina"] 		= 0,
		["armor"]			= 0,
		["maxAttack"]		= 0,
		["minAttack"]		= 0,
	}
	for i = ShareDefine.equipSlotBegin(), ShareDefine.equipSlotEnd() do
		local equipment = self.m_InventoryData[i]
		if equipment then
			-- 计算基础的属性增幅
			for attrIndex, value in pairs(equipment.template.attrs) do
				local indexStr = ShareDefine.stateIndexToString(attrIndex)
				extraValues[indexStr] = extraValues[indexStr] + value
			end
			for _, v in pairs({ "armor", "maxAttack", "minAttack" }) do
				extraValues[v] = extraValues[v] + equipment.template[v]
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
	self.m_InventoryData[itemSlot] = nil
	self.m_InventoryData[emptySlotIndex] = itemData
	self:setInventoryDataDirty(true)
	return true
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
	self:setInventoryDataDirty(true)
	return true
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
	local itemTemplate = itemData.template
	if itemTemplate.require_class ~= self:getClass() then release_print("can Equip : not equal class") return false end
	if itemTemplate.require_level >  self:getLevel() then release_print("can Equip : not enough level") return false end
	if itemTemplate.requie_spell and itemTemplate.requie_spell ~= 0 and not self:hasSpell(itemTemplate.requie_spell) then release_print("can Equip : require Spell : "..itemTemplate.requie_spell) return false end
	if itemData.durable == 0 then return false end
	return true
end

--							[[ ======================== ]]
--							[[ End Inventory/Item Issus ]]
--							[[ ======================== ]]

function Player:setInstanceDataDirty(value)
	self.m_InstanceDataDirty = value
end

function Player:isInstanceDataDirty()
	return self.m_InstanceDataDirty
end

function Player:onInstanceDataDirty()
	self:sendAppMsg("MSG_ON_INSTANCE_DATA_DIRTY")
	self:saveInstanceToDB()
	self:setInstanceDataDirty(false)
end

function Player:saveInstanceToDB()
	-- Save Instance Stuff						  0		1		2		3	   	4		5	  6		7	   8	9			10				11			12
	local sql = [[REPLACE INTO character_instance(guid, class, gender, faction, level, race, name, map, pos_x, pos_y, free_talent_point, current_exp, money) 
										   VALUES('%d', '%d',  '%d',   '%d',  '%d', '%d', '%s','%d',  '%d', '%d', '%d', '%d', '%d') ]]
	--										0				1				2					3				4					5
	DataBase:query(string.format(sql, self:getGuid(), self:getClass(), self:getGender(), self:getFaction(), self:getLevel(), self:getRace(), 
	--										6					7						8					9						10						11
									  self:getName(), self:getMap():getEntry(), self:getPositionX(), self:getPositionY(), self:getFreeTalentPoint(), self:getCurrExp(), self:getMoney() ))

end

function Player:saveToDB()
	self:saveInstanceToDB()
	self:saveInventoryToDB()
	self:saveBuffsFromDB()
	self:saveAllLearnedSpellToDB()
	self:saveQuestToDB()
	self:saveSpellSlotToDB()
	self:saveSpellCoolDownToDB()
end

function Player:saveSpellCoolDownToDB()
	local sql = "DELETE FROM spell_cool_down WHERE character_guid = '%d'"
	DataBase:query(string.format(sql, self:getGuid()))

	sql = "INSERT INTO spell_cool_down(character_guid, spell_id, cooldown_time_left) VALUES(%d, %d, %d)"
	for spelid, timeleft in pairs(self:getSpellCoolDownList()) do
		DataBase:query(string.format(sql, self:getGuid(), spellid, math.floor(timeleft * 0.001)))
	end
end

function Player:saveTalentPointToDB()
	local sql = [[UPDATE character_instance SET free_talent_point = %d WHERE guid = %d]]
	DataBase:query(string.format( sql, self:getFreeTalentPoint(), self:getGuid() ))
end

function Player:getFreeTalentPoint()
	return self.context.free_talent_point
end

function Player:setFreeTalentPoint(point)
	self.context.free_talent_point = point
	self:saveTalentPointToDB()
end

function Player:tryLearnTalentSpell(spellid)
	if not self:learnSpell(spellid) then return end
	self:setFreeTalentPoint(self:getFreeTalentPoint() - 1)
end

function Player:resetTalent()
	local function split( str,reps )
	    local resultStrList = {}
	    string.gsub(str,'[^'..reps..']+', function ( w )
	    	table.insert(resultStrList, tonumber(w))
	    end)
	    return resultStrList
	end

	local sql = "SELECT spells FROM talent_template WHERE class = '%d'"
	local talentInfo = DataBase:query(string.format( sql, self:getClass() ))
	local allTalentSpellIDs = nil
	for _, v in pairs(talentInfo) do
		allTalentSpellIDs = allTalentSpellIDs and string.format("%s,%s", allTalentSpellIDs, v.spells) or v.spells
	end
	allTalentSpellIDs = split(allTalentSpellIDs, ",")

	local freed_point = 0
	for _, talentSpellID in pairs(allTalentSpellIDs) do
		if self:hasSpell(talentSpellID) then
			freed_point = freed_point + 1
			self:unLearnSpell(talentSpellID)
		end
	end
	self:setFreeTalentPoint(self:getFreeTalentPoint() + freed_point)
end

function Player:setExpDataDirty(value)
	if self.m_ExpDataDirty == value then return end
	self.m_ExpDataDirty = value
end

function Player:getCurrExp()
	return self.context.current_exp
end

function Player:awardExp(amount)
	local exp = self.context.current_exp + amount
	local startLevel = self:getLevel()
	local sql = "SELECT * FROM level_exp WHERE currLevel >= '%d'"
	local result = DataBase:query(string.format(sql, startLevel))
	table.sort(result, function(a, b) return a.currLevel < b.currLevel end)

	local targetLevel = startLevel
	for _, info in pairs(result) do
		if exp < info.exp then break end
		exp = exp - info.exp
		targetLevel = targetLevel + 1
	end

	if startLevel < targetLevel then self:setLevel(targetLevel) end
	self.context.current_exp = exp
	self:setExpDataDirty(true)
end

function Player:isExpDataDirty()
	return self.m_ExpDataDirty
end

function Player:onExpDataChanged()
	local sql = "UPDATE character_instance SET current_exp = '%d' WHERE guid = '%d'"
	DataBase:query(string.format(sql, self:getCurrExp(), self:getGuid()))
	self:sendAppMsg("MSG_ON_EXP_DATA_CHANGED", { currExp = self:getCurrExp(), currLevel = self:getLevel() })
	self:setExpDataDirty(false)
end

function Player:onLevelUp(oldLevel, newLevel)
	self:updateBaseAttrs()
	self:tryAwardTalent(oldLevel, newLevel)
	self:saveToDB()
	self:getScript():onNativeLevelUp(oldLevel, newLevel)
end

function Player:tryAwardTalent(oldLevel, newLevel)
	local minLevel =  ShareDefine.talentAwardLevel()
	local oldLevel = minLevel > oldLevel and minLevel or oldLevel
	local awardPoint = newLevel - oldLevel
	self:setFreeTalentPoint( self:getFreeTalentPoint() + awardPoint )
end

function Player:onUpdate(diff)
	Unit.onUpdate(self, diff)
	if self:isInventoryDataDirty() then self:onInventoryDataChanged() end
	if self:isQuestDataDirty() then self:onQuestDataDirty() end
	if self:isExpDataDirty() then self:onExpDataChanged() end
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
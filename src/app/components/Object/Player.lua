local Unit 				= import("app.components.Object.Unit")
local DataBase 			= import("app.components.DataBase")
local ShareDefine 		= import("app.ShareDefine")
local WindowMgr			= import("app.components.WindowMgr")
local Player 			= class("Player", Unit)

Player.instance = nil

function Player.getInstance()
	return Player.instance
end

function Player:onCreate()
	Unit.onCreate(self, ShareDefine:playerType())
	self.m_InventoryData = {}
	self.m_ActivatedSpells = {} --Activated Spells 当身上有相同法术存留的时候只覆盖
	self.m_LearnedSpells = {}
	self:setAlive(true)
	self:loadFromDB()
	self:initAvatar()
	self:setControlByPlayer(true)
	self:resetGossipList()
	self:updateAttrs()
	Player.instance = self

	-- self:regiestCustomEventListenter("MSG_INVENTORY_DATA_CHANGED", function() end)

end

function Player:loadFromDB()
	-- For CHaracter Base Data Issus
	-- template and instance
	-- race class level tanlent etc.
	local queryResult = nil
	local sql = "SELECT * FROM character_instance AS I JOIN character_template AS T ON I.class = T.class AND I.gender = T.gender WHERE I.guid = %d"
	queryResult = DataBase:query(string.format(sql, self.context))[1]
	self:setClass(queryResult.class)
	self:setLevel(queryResult.level)
	self:setName(queryResult.name)
	self:setGuid(queryResult.guid)
	self.context = queryResult
	self:loadInventoryFromDB()
	self:loadAllLearnedSpellsFromDB()
	self:loadActivatedSpellFromDB()
end

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

function Player:initAvatar()
	local sp = cc.Sprite:create("res/player.png"):addTo(self:getPawn().m_Children["Node_Character"]):setAnchorPoint(0.5, 0)
    self:move(self.context.pos_x, self.context.pos_y)
    	:setLocalZOrder(1)
    	:setContentSize(sp:getContentSize())
end

function Player:canEquip(itemData)
	-- local itemTemplate = itemData.template
	-- if itemTemplate.require_class then return false end


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
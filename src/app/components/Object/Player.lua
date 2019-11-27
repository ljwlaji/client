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
	self:setAlive(true)
	self:loadFromDB()
	self:initAvatar()
	self:setControlByPlayer(true)
	self:resetGossipList()
	Player.instance = self
end

function Player:loadFromDB()
	-- For CHaracter Base Data Issus
	-- template and instance
	-- race class level tanlent etc.
	local queryResult = nil
	local sql = "SELECT * FROM character_instance AS I JOIN character_template AS T ON I.class = T.class AND I.gender = T.gender WHERE I.guid = %d"
	queryResult = DataBase:query(string.format(sql, self.context))[1]
	self:setGuid(queryResult.guid)
	self.context = queryResult
	self:loadInventoryFromDB()

	-- Create Current Item Instances

	dump(self.m_InventoryData)
end

function Player:loadInventoryFromDB()
	local sql = "SELECT * FROM character_inventory WHERE character_guid = %d"
	local queryResult = DataBase:query(string.format(sql, self.context.guid)) or {}
	for k, v in pairs(queryResult) do
		self.m_InventoryData[v.slot_id] = v
	end
end

function Player:initAvatar()
	local sp = cc.Sprite:create("res/player.png"):addTo(self:getPawn().m_Children["Node_Character"]):setAnchorPoint(0.5, 0)
    self:move(self.context.pos_x, self.context.pos_y)
    	:setLocalZOrder(1)
    	:setContentSize(sp:getContentSize())
end

function Player:onUpdate(diff)
	Unit.onUpdate(self, diff)
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
end

function Player:saveInventoryToDB()
	--											  
	local sql = [[REPLACE INTO character_inventory(character_guid, slot_id, item_entry, item_guid, item_amount) 
											VALUES('%d', 		   '%d',	'%d',		'%d',	   '%d')]]
	for k, v in pairs(self.m_InventoryData) do
		DataBase:query(string.format( sql, v.character_guid, v.slot_id, v.item_entry, v.item_guid, v.item_amount ))
		-- Need Save Item Instance To DB
		-- alater...
	end
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
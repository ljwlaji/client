local ShareDefine = class("ShareDefine")

ShareDefine.instance = nil

local TYPE_ERROR 				= 0
local TYPE_PLAYER				= 1
local TYPE_GROUND 				= TYPE_PLAYER + 1
local TYPE_CREATURE				= TYPE_PLAYER + 2
local TYPE_GAME_OBJECT			= TYPE_PLAYER + 3
local TYPE_BACK_GROUND 			= TYPE_PLAYER + 4
local TYPE_FRONT_GROUND 		= TYPE_PLAYER + 5
local TYPE_DISTANT_SIGHT		= TYPE_PLAYER + 8


local ZORDER_START = 1

local MAP_Z_ORDERS = {
	ZORDER_DISTANT_SIGHT 	= ZORDER_START,		  --✔
	ZORDER_BACK_GROUND 		= ZORDER_START + 100, --✔
	ZORDER_GROUND			= ZORDER_START + 200, --✔
	ZORDER_CREATURE			= ZORDER_START + 400, --✔
	ZORDER_PLAYER			= ZORDER_START + 500, --✔
	ZORDER_LOOT 			= ZORDER_START + 600, --✔
	ZORDER_FRONT_GROUND		= ZORDER_START + 700, --✔
	ZORDER_HUD_LAYER		= ZORDER_START + 800, --✔
	ZORDER_WINDOW_START		= ZORDER_START + 900, --✔
}

local ITEM_TYPES = {
	-- 布甲 锁甲 匕首 饰品 等
	FABRIC 	= 1, 	--布甲
	LEATHER = 2, 	--皮甲
	MAIL	= 3, 	--锁甲
	PLATE 	= 4,	--板甲

	ONE_HAND_BEGIN 	= 5,
	ONE_HAND_AXE 	= 5,	--单手斧
	ONE_HAND_HAMMER = 6,	--单手锤
	ONE_HAND_HAND	= 7,	--拳套
	ONE_HAND_SWORD	= 8,	--单手剑
	ONE_HAND_BAGGER	= 9,	--匕首
	ONE_HAND_END	= 9,

	STAFF	= 20, --魔杖
	-- HALBERD
}


local INVENTORY_BASE_SLOT_COUNT = 16

local INVENTORY_SLOTS = {
	SLOT_EQUIP_BEGIN 	= 1,
	SLOT_HELMET			= 1,
	SLOT_NECKLACE		= 2,
	SLOT_SHOULDER		= 3,
	SLOT_BACK			= 4,
	SLOT_CHEST			= 5,
	SLOT_BRACER			= 6,
	SLOT_GAUNTLETS		= 7,
	SLOT_BELT			= 8,
	SLOT_PANTS			= 9,
	SLOT_BOOTS			= 10,
	SLOT_RING_A			= 11,
	SLOT_RING_B			= 12,
	SLOT_MAIN_HAND		= 13,
	SLOT_OFF_HAND		= 14,
	SLOT_RANGE			= 15,
	SLOT_EQUIP_END		= 15,

	SLOT_CONTAINER_BEGIN = 16,
	SLOT_CONTAINER_END	 = 23,

	SLOT_INVENTORY_BEGIN = 24,

	SLOT_BAG_BEGIN		= 16,
}

local CHANGE_STATES = {
	UNCHANGED 	= 0,
	CHANGED		= 1,
}

function ShareDefine.getItemIconPath(template)
	return string.format("res/ui/icon/%s", template.icon)
end

function ShareDefine.containerSlotBegin()
	return INVENTORY_SLOTS.SLOT_CONTAINER_BEGIN
end

function ShareDefine.containerSlotEnd()
	return INVENTORY_SLOTS.SLOT_CONTAINER_END
end

function ShareDefine.inventoryBaseSlotCount()
	return INVENTORY_BASE_SLOT_COUNT
end

function ShareDefine.inventorySlotBegin()
	return INVENTORY_SLOTS.SLOT_INVENTORY_BEGIN
end

function ShareDefine.equipSlotBegin()
	return INVENTORY_SLOTS.SLOT_EQUIP_BEGIN
end

function ShareDefine.equipSlotEnd()
	return INVENTORY_SLOTS.SLOT_EQUIP_END
end

function ShareDefine.isOneHandWeapon(itemType)
	return itemType >= ITEM_TYPES.ONE_HAND_BEGIN and itemType <= ITEM_TYPES.ONE_HAND_END
end

function ShareDefine.getItemRequireSpell(itemType)
	return itemType + 100
end

function ShareDefine.isEquipSlot(slot_id)
	return slot_id >= INVENTORY_SLOTS.SLOT_EQUIP_BEGIN and slot_id <= INVENTORY_SLOTS.SLOT_EQUIP_END
end

function ShareDefine.UnChangeState()
	return CHANGE_STATES["UNCHANGED"]
end

function ShareDefine.changedState()
	return CHANGE_STATES["CHANGED"]
end


function ShareDefine.getZOrderByType(t_Type)
	if not MAP_Z_ORDERS[t_Type] then assert(false) end
	return MAP_Z_ORDERS[t_Type]
end

function ShareDefine.playerType()
	return TYPE_PLAYER
end

function ShareDefine.creatureType()
	return TYPE_CREATURE
end

function ShareDefine.gameObjectType()
	return TYPE_GAME_OBJECT
end

function ShareDefine.groundType()
	return TYPE_GROUND
end

function ShareDefine.getObjectZOrderByType(OBType)
	local ret = 0
	if OBType == TYPE_GROUND then
		ret = MAP_Z_ORDERS.ZORDER_GROUND
	elseif OBType == TYPE_BACK_GROUND then  
		ret = MAP_Z_ORDERS.ZORDER_BACK_GROUND
	elseif OBType == TYPE_DISTANT_SIGHT then
		ret = MAP_Z_ORDERS.ZORDER_DISTANT_SIGHT
	elseif OBType == TYPE_NORMAL_OBJECT then
		ret = MAP_Z_ORDERS.ZORDER_NORMAL_OBJECT
	elseif OBType == TYPE_CREATURE then
		ret = MAP_Z_ORDERS.ZORDER_CREATURE
	elseif OBType == TYPE_PLAYER then
		ret = MAP_Z_ORDERS.ZORDER_PLAYER
	elseif OBType == TYPE_LOOT then
		ret = MAP_Z_ORDERS.ZORDER_LOOT
	elseif OBType == TYPE_FRONT_GROUND then
		ret = MAP_Z_ORDERS.ZORDER_FRONT_GROUND
	elseif OBType == TYPE_CLOUD then
		ret = MAP_Z_ORDERS.ZORDER_CLOUD
	else
		assert(false, "Fail To Fit ZOrder By Type : "..GOBType)
	end
	return ret
end

function ShareDefine.getInstance()
	if not ShareDefine.instance then
		ShareDefine.instance = ShareDefine:create()
	end
	return ShareDefine.instance
end

function ShareDefine:isDevMode()
	return true
end


return ShareDefine.getInstance()
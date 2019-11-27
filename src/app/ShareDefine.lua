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

local INVENTORY_SLOTS = {
	SLOT_BEGIN 			= 1,
	SLOT_EQUIP_BEGIN 	= 1,

	SLOT_HEAD			= 1,
	SLOT_NECKLACE		= 2,
	SLOT_SHOULDER		= 3,
	SLOT_BACK			= 4,
	SLOT_CHEST			= 5,
	SLOT_WRIST			= 6,
	SLOT_HAND			= 7,
	SLOT_BELT			= 8,
	SLOT_PANTS			= 9,
	SLOT_SHOES			= 10,
	SLOT_RING			= 11,
	SLOT_MAIN_HAND		= 12,
	SLOT_OFF_HAND		= 13,
	SLOT_RANGE			= 14,
	SLOT_EQUIP_END		= 14,

	SLOT_BAG_BEGIN		= 15,
	SLOT_BAG_END		= 143,
}

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
local ShareDefine = class("ShareDefine")

ShareDefine.instance = nil

local TYPE_ERROR 				= 0
local TYPE_PLAYER				= 1
local TYPE_FLOOR 				= TYPE_PLAYER + 1
local TYPE_CREATURE				= TYPE_PLAYER + 2
local TYPE_GAME_OBJECT			= TYPE_PLAYER + 3
local TYPE_BACK_GROUND 			= TYPE_PLAYER + 4
local TYPE_FRONT_GROUND 		= TYPE_PLAYER + 5
local TYPE_CLOUD				= TYPE_PLAYER + 6
local TYPE_NORMAL_OBJECT		= TYPE_PLAYER + 7
local TYPE_DISTANT_SIGHT		= TYPE_PLAYER + 8


local ZORDER_START = 1

local MAP_Z_ORDERS = {
	ZORDER_DISTANT_SIGHT 	= ZORDER_START,		  --✔
	ZORDER_BACK_GROUND 		= ZORDER_START + 100, --✔
	ZORDER_FLOOR			= ZORDER_START + 200, --✔
	ZORDER_NORMAL_OBJECT	= ZORDER_START + 300, --✔
	ZORDER_CREATURE			= ZORDER_START + 400, --✔
	ZORDER_PLAYER			= ZORDER_START + 500, --✔
	ZORDER_LOOT 			= ZORDER_START + 600, --✔
	ZORDER_FRONT_GROUND		= ZORDER_START + 700, --✔
	ZORDER_CLOUD			= ZORDER_START + 800, --✔
}

function ShareDefine:playerType()
	return TYPE_PLAYER
end

function ShareDefine:creatureType()
	return TYPE_CREATURE
end

function ShareDefine:gameObjectType()
	return TYPE_GAME_OBJECT
end

function ShareDefine:getObjectZOrderByType(OBType)
	local ret = 0
	if OBType == TYPE_FLOOR then
		ret = MAP_Z_ORDERS.ZORDER_FLOOR
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
	return ret, ret+99
end

function ShareDefine.getInstance()
	if not ShareDefine.instance then
		ShareDefine.instance = ShareDefine:create()
	end
	return ShareDefine.instance
end

function ShareDefine:isDevMode()
	return false
end


return ShareDefine.getInstance()
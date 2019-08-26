local Object = class("Object", cc.Node)
local DataBase = import("app.components.DataBase")
--[[
	Virtual Class
	Object分类:
		1. Unit
			Player
			Creature
		2. GameObject
]]

Object.TYPES = {
	TYPE_GAMEOBJECT = 1,
	TYPE_CREATURE 	= 2,
	TYPE_PLAYER 	= 3,
}

Object.OBJECT_FLAGS = {

}

function Object:ctor(context)
	self.context = context
	if self.onCreate then self:onCreate() end
end

--[[
	所有Object都必须添加到地图上
	所有Object都必须在Area和Map内都保有一个指针
]]
function Object:loadFromDB()
	if self.onLoadFromDB then self:onLoadFromDB(DBData) end
end

function Object:loadModelInfo()
	local modelInfo = DataBase:query("SELECT * FROM model_template WHERE id = %d", self.context.model_id)[1]
	assert(self.modelInfo)
end

function Object:isUnit()
	return self:getType() == Object.TYPES.TYPE_PLAYER or self:getType() == Object.TYPES.TYPE_CREATURE 
end

function Object:isGameObject()
	return self:getType() == Object.TYPES.TYPE_GAMEOBJECT 
end

function Object:getMap()
	return self.currMap
end

function Object:onAddToWorld(currMap)
	self.currMap = currMap
end

function Object:onRemoveFromWorld()
	self.currMap = nil
end

function Object:moveInLineOfSight(object_who)

end

function Object:updateMovement()
	-- 碰撞属性
end

function Object:onUpdate(diff)
	self:updateMovement()
	if self.AI then self.AI:update(diff) end
end

function Object:cleanUpBeforeDelete()
	return self
end

return Object
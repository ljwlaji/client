local Object = class("Object", cc.Node)

--[[
	Virtual Class
	Object分类:
		1. Unit
			Player
			Creature
		2. GameObject
]]

function Object:ctor(context)
	if self.onCreate then self:onCreate(context) end
end

--[[
	所有Object都必须添加到地图上
	所有Object都必须在Area和Map内都保有一个指针
]]

function Object:loadFromDB()
	local DBData = nil

	if self.onLoadFromDB then self:onLoadFromDB(DBData) end
end

function Object:addToWorld(currentWorld)

	if self.onAddToWorld then self:onAddToWorld() end

end

function Object:removeFromWorld()
	if self.onRemoveFromWorld then self:onRemoveFromWorld() end
end

return Object
local Area 			= class("Area", cc.Node)
local DataBase 		= import("app.components.DataBase")
local GameOBject 	= import("app.components.Object.GameOBject")
local Creature 		= import("app.components.Object.Creature")

function Area:ctor(context)
	self.context = context
	self.linkedObjects = {}
	self.backGround = cc.Sprite:create("res/"..context.back_ground_image):addTo(self):setAnchorPoint(0, 0)
end

function Area:loadFromDB()
	-- TODO
	-- Load All Linked Objects
	-- Load Game Objects
	local sql = string.format("SELECT * FROM game_object_instance AS I JOIN game_object_template AS T ON I.entry == T.entry WHERE I.map_entry == %d AND I.area_entry == %d", self.context.mapEntry, self.context.entry)
	local gameObjectDatas = DataBase:query(sql)
	for k, v in pairs(gameObjectDatas) do
		local obj = GameOBject:create(v)
		table.insert(self.linkedObjects, obj)
		self:getMap():addObject(obj)
	end

	-- Load All Linked Creatures.
	local sql = string.format("SELECT * FROM creature_instance AS I JOIN creature_template AS T ON I.entry == T.entry WHERE I.map_entry == %d AND I.area_entry == %d", self.context.mapEntry, self.context.entry)
	local creatureDatas = DataBase:query(sql)
	for k, v in pairs(creatureDatas) do
		local currCreature = Creature:create(v)
		table.insert(self.linkedObjects, currCreature)
		self:getMap():addObject(currCreature)
	end
end

function Area:getEntry()
	return self.context.entry
end

function Area:getRect()
	return self.context.rect
end

function Area:getMap()
	return self:getParent()
end

function Area:isAreaLazy()
	return true
end

function Area:cleanUpBeforeDelete()
	for k, v in pairs(self.linkedObjects) do
		self:getMap():removeObject(v)
	end
	self.linkedObjects = {}
	return self
end

return Area
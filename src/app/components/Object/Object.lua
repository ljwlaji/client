local Object = class("Object", cc.Node)
local DataBase = import("app.components.DataBase")
local ShareDefine = import("app.ShareDefine")

function Object:ctor(context, ...)
	self.context = context
	self.m_Type = 0
	self.m_Guid = 0
	self:onNodeEvent("cleanup", handler(self, self.cleanUpBeforeDelete))
	if self.onCreate then self:onCreate(...) end
end

function Object:onCreate(objType)
	self.getType = function() return objType end
end

function Object:setGuid(guid)
	self.m_Guid = guid
end

function Object:getGuid(guid)
	return self.m_Guid
end

function Object:isUnit()
	return self:isPlayer() or self:isCreature()
end

function Object:isPlayer()
	return self:getType() == ShareDefine:playerType()
end

function Object:isCreature()
	return self:getType() == ShareDefine:creatureType()
end

function Object:isGameObject()
	return self:getType() == ShareDefine:gameObjectType()
end

function Object:isGround()
	return self:getType() == ShareDefine:groundType()
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

function Object:onUpdate(diff)

end

function Object:setName(nameString)
	self.m_Name = nameString
	self:getPawn():setName(self.m_Name)
end

function Object:getName()
	return self.m_Name
end

function Object:cleanUpBeforeDelete()
	release_print("Object : cleanUpBeforeDelete")
	return self
end

function Object:getModelDataByModelID(model_id)
	local sql = string.format("SELECT * FROM model_template WHERE entry = %d", model_id)
	local currModelData = DataBase:query(sql)[1]
	if not currModelData then
		dump(model_id)
		assert(false)
	end
	return currModelData
end

function Object:createModelByID()
	local model = nil
	local currModelData = self:getModelDataByModelID(self.context.model_id)
	if currModelData.model_type == "image" then
		model = cc.Sprite:create(string.format("res/model/image/%s", currModelData.file_path))
	elseif currModelData.model_type == "spine" then
		xpcall(function() 
			model = sp.SkeletonAnimation:createWithJsonFile(string.format("res/model/spine/%s", currModelData.json_path), string.format("res/model/spine/%s", currModelData.altas_path))
		end, function(...)	dump({...}) end)
	elseif currModelData.model_type == "animation" then
		
	end

	return model
end

function Object:debugDraw()
	if self.__drawNode then self.__drawNode:removeFromParent() end
	local myDrawNode=cc.DrawNode:create()
    self:addChild(myDrawNode)
    myDrawNode:setPosition(0, 0)
    local size = cc.p(self:getContentSize().width, self:getContentSize().height)
    myDrawNode:drawSolidRect(cc.p(0, 0), size, cc.c4f(1,1,1,1))
    myDrawNode:setLocalZOrder(-10)
    self.__drawNode = myDrawNode
end

return Object
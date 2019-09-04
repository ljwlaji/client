local Object = class("Object", cc.Node)
local DataBase = import("app.components.DataBase")
local ShareDefine = import("app.ShareDefine")

function Object:ctor(context)
	self.context = context
	self.m_Type = 0
	if self.onCreate then self:onCreate() end
end

function Object:onCreate(objType)
	self.getType = function() return objType end
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
	if self.m_AI then self.m_AI:onUpdate(diff) end
end

function Object:setAI(AIInstance)
	self.m_AI = AIInstance
end

function Object:getAI()
	return self.m_AI
end

function Object:cleanUpBeforeDelete()
	return self
end

function Object:createModelByID(model_id)
	local model = nil
	local sql = string.format("SELECT * FROM model_template WHERE entry = %d", model_id)
	local currModelData = DataBase:query(sql)[1]
	if currModelData.model_type == "image" then
		model = cc.Sprite:create(string.format("res/model/%s", currModelData.file_path))
	elseif currModelData.model_type == "spine" then

	elseif currModelData.model_type == "animation" then
		
	end
	-- self.m_Model = 
	return model
end

return Object
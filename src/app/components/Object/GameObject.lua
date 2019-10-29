local Object 		= import("app.components.Object.Object")
local GameObject 	= class("GameObject", Object)
local ShareDefine 	= import("app.ShareDefine")

local testFile = "res/image180.png"
local sPCMgr = cc.PixalCollisionMgr:getInstance()


			-- alive
		-- area_entry
		-- entry
		-- guid
		-- loot_id	(GObject)
		-- map_entry -- none
		-- max_health (GObject)
		-- resPath
		-- name_id
		-- object_type
		-- pixal_collision
		-- scale_x
		-- scale_y
		-- script_name
		-- x
		-- y
		-- zorder


function GameObject:onCreate()
	Object.onCreate(self, ShareDefine:gameObjectType())
	self:reset()
end

function GameObject:reset()
	local context = self.context
	self.m_Health = self.context.max_health
	self:resetView(context)
end

function GameObject:resetView(context)
	if self.m_View then self.m_View:removeFromParent() self.m_View = nil end
	self.m_View = self:createModelByID(context.model_id):addTo(self):setAnchorPoint(0, 0)
	self:setContentSize(self.m_View:getContentSize())
	self:move(context.x, context.y)
	local ZOrder = context.zorder == 0 and ShareDefine:getObjectZOrderByType(context.object_type) or context.zorder
	self:setLocalZOrder(ZOrder)
	self:setScaleX(context.scale_x)
	self:setScaleY(context.scale_y)
	if context.pixal_collision == 1 then cc.PixalCollisionMgr:getInstance():loadPNGData(context.res_path) end
end

function GameObject:getEntry()
	return self.context.entry
end

function GameObject:getHealth()
	return self.m_Health
end

function GameObject:getMaxHealth()
	return self.context.max_health
end

function GameObject:onUpdate(diff)
	Object.onUpdate(self, diff)
end

function GameObject:getStandingSafeHeight()
	if self:hasPixalCollision() then

	else
		return self:getPositionY() + self:getContentSize().height + 1
	end
end

function GameObject:getCollisionSafePosX(offset)
	if offset.x > 0 then
		return self:getPositionX() - 1
	elseif offset.y < 0 then
		return self:getPositionX() + self:getContentSize().width + 1
	end
end

function GameObject:hasPixalCollision()
	return false--self.context.pixal_collision ~= 0
end

function GameObject:cleanUpBeforeDelete()
	sPCMgr:unLink(testFile)
	return Object.cleanUpBeforeDelete(self)
end


return GameObject

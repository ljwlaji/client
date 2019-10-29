local Object 		= import("app.components.Object.Object")
local ShareDefine 	= import("app.ShareDefine")
local Ground 		= class("Ground", Object)

function Ground:onCreate()
	Object.onCreate(self, ShareDefine:groundType())
	self:construct()
end


function Ground:construct()
	local context = self.context
	if self.m_View then self.m_View:removeFromParent() self.m_View = nil end
	self.m_View = self:createModelByID(context.model_id):addTo(self):setAnchorPoint(0, 0)
	self:setContentSize(self.m_View:getContentSize())
	self:move(context.x, context.y)
	self:setLocalZOrder(ShareDefine:getObjectZOrderByType(self:getType()))
	-- if context.pixal_collision == 1 then cc.PixalCollisionMgr:getInstance():loadPNGData(context.res_path) end
end

function Ground:getEntry()
	return self.context.entry
end


function Ground:onUpdate(diff)
	Object.onUpdate(self, diff)
end

function Ground:cleanUpBeforeDelete()

	Object.cleanUpBeforeDelete(self)
end

return Ground
local Object 		= import("app.components.Object.Object")
local ShareDefine 	= import("app.ShareDefine")
local Utils			= import("app.components.Utils")
local Ground 		= class("Ground", Object)

function Ground:onCreate()
	Object.onCreate(self, ShareDefine:groundType())
	self.m_PixalCollisionEnabled = false
	self:construct()
end


function Ground:construct()
	local context = self.context
	if self.m_View then self.m_View:removeFromParent() self.m_View = nil end
	self.m_View = self:createModelByID(context.model_id):addTo(self):setAnchorPoint(0, 0)
	self:setContentSize(self.m_View:getContentSize())
	self:move(context.x, context.y)
	self:setLocalZOrder(ShareDefine:getObjectZOrderByType(self:getType()))
	if context.pixal_collision == 1 then
		local path = string.format("res/model/image/%s", self:getModelDataByModelID(context.model_id).file_path)
		assert(Utils.isFileExisted(path))
		self.m_PixalCollisionPath = path
		cc.PixalCollisionMgr:getInstance():loadPNGData(path)
		self.m_PixalCollisionEnabled = true
	end
end

function Ground:getEntry()
	return self.context.entry
end

function Ground:isPixalCollisionEnabled()
	return self.m_PixalCollisionEnabled
end


function Ground:onUpdate(diff)
	Object.onUpdate(self, diff)
end

function Ground:cleanUpBeforeDelete()
	release_print("Ground : cleanUpBeforeDelete")
	if self:isPixalCollisionEnabled() then cc.PixalCollisionMgr:getInstance():unLink(self.m_PixalCollisionPath) end
	Object.cleanUpBeforeDelete(self)
end

return Ground
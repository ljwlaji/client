local Object 		= import("app.components.Object.Object")
local GameObject 	= class("GameObject", Object)


local testFile = "res/image180.png"
local sPCMgr = cc.PixalCollisionMgr:getInstance()


function GameObject:onCreate(context)
	-- TODO
	-- self:setContentSize(context.width, context.height)
	self:setAnchorPoint(0.5, 0.5)
	self:generatePixalCollisionData()
end

function GameObject:generatePixalCollisionData()
	sPCMgr:loadPNGData(testFile)
end

function GameObject:onUpdate(diff)
	Unit.onUpdate(self, diff)
end

function GameObject:cleanUpBeforeDelete()
	sPCMgr:unLink(testFile)
	return Object.cleanUpBeforeDelete(self)
end


return GameObject

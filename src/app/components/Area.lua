local Area = class("Area", cc.Node)

function Area:ctor(context)
	self.context = context
	self.backGround = cc.Sprite:create("res/"..context.back_ground_image):addTo(self)
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
	return self
end

return Area
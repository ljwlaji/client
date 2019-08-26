local Object = import("app.components.Object.Object")
local GameObject = class("GameObject", Object)


function GameObject:onCreate(context)
	-- TODO
	self:setContentSize(context.width, context.height)
	self:setAnchorPoint(0.5, 0.5)
end

function GameObject:onUpdate(diff)
	Unit.onUpdate(self, diff)
end


return GameObject

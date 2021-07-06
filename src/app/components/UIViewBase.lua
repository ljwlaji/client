local UIViewBase = class("UIViewBase", function() return cc.Node:create() end)

function UIViewBase:ctor(context)
	self.context = context or {}
	if self.onCreate then self.onCreate(self) end
end

function UIViewBase:onCreate()

end

function UIViewBase:debugDraw(parent, color, size)
	if parent.__drawNode then parent.__drawNode:removeFromParent() end
	local myDrawNode=cc.DrawNode:create()
    parent:addChild(myDrawNode)
    myDrawNode:setPosition(0, 0)
    size = size or cc.p(parent:getContentSize().width, parent:getContentSize().height)
    myDrawNode:drawSolidRect(cc.p(0, 0), size, color or cc.c4f(1,1,1,1))
    myDrawNode:setLocalZOrder(-10)
    parent.__drawNode = myDrawNode
end


function UIViewBase:safeCall(func)
	local status, msg = xpcall(func, __G__TRACKBACK__)
	if not status then release_print(msg) end
end

function UIViewBase:copyContext(origin)
	local new = {}
	for k, v in pairs(origin) do
		if type(v) == "table" then
			new[k] = self:copyContext(v)
		else
			new[k] = v
		end
	end
	return new
end

function UIViewBase:isParentVisible()
	local ret = true
	local parent = self:getParent()
	while parent do
		if parent:isVisible() then
			parent = parent:getParent()
		else
			ret = false
			break
		end
	end

	return ret
end


return UIViewBase
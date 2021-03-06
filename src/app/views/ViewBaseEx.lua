local ViewBaseEx 		= class("ViewBaseEx", cc.load("mvc").ViewBase)
local WindowMgr			= require("app.components.WindowMgr")

function ViewBaseEx:autoAlgin()
	self:setContentSize(display.width, display.height)
	self:getResourceNode():setContentSize(display.width, display.height)

	if self.m_Children["node_Left_Up"] 			then self.m_Children["node_Left_Up"]:move(0, display.height):setAnchorPoint(0, 1) 	end
	if self.m_Children["node_Left"] 			then self.m_Children["node_Left"]:move(0, display.cy):setAnchorPoint(0, 0.5) 		end
	if self.m_Children["node_Left_Buttom"] 		then self.m_Children["node_Left_Buttom"]:move(0, 0):setAnchorPoint(0, 0) 			end

	if self.m_Children["node_Center_Up"] 		then self.m_Children["node_Center_Up"]:move(display.cx, display.height):setAnchorPoint(0.5, 1) end
	if self.m_Children["node_Center"] 			then self.m_Children["node_Center"]:move(display.cx, display.cy):setAnchorPoint(0.5, 0.5) end
	if self.m_Children["node_Center_Buttom"] 	then self.m_Children["node_Center_Buttom"]:move(display.cx, 0):setAnchorPoint(0.5, 0) end

	if self.m_Children["node_Right_Up"] 		then self.m_Children["node_Right_Up"]:move(display.width, display.height):setAnchorPoint(1, 1) end
	if self.m_Children["node_Right"] 			then self.m_Children["node_Right"]:move(display.width, display.cy):setAnchorPoint(1, 0.5) end
	if self.m_Children["node_Right_Buttom"] 	then self.m_Children["node_Right_Buttom"]:move(display.width, 0):setAnchorPoint(1, 0) end
end

function ViewBaseEx:debugDraw(parent, color, size)
	if parent.__drawNode then parent.__drawNode:removeFromParent() end
	local myDrawNode=cc.DrawNode:create()
    parent:addChild(myDrawNode)
    myDrawNode:setPosition(0, 0)
    size = size or cc.p(parent:getContentSize().width, parent:getContentSize().height)
    myDrawNode:drawSolidRect(cc.p(0, 0), size, color or cc.c4f(1,1,1,1))
    myDrawNode:setLocalZOrder(-10)
    parent.__drawNode = myDrawNode
end

function ViewBaseEx:runSequence(...)
	self:runAction( cc.Sequence:create( ... ) )
end

function ViewBaseEx:removeSelf()
	WindowMgr:removeWindow(self)
end

return ViewBaseEx
local ViewBaseEx = class("ViewBaseEx", cc.load("mvc").ViewBase)

function ViewBaseEx:autoAlgin()
	self:setContentSize(display.width, display.height)

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

function ViewBaseEx:onEnter_()
	if self.onEnter then self:onEnter() end
end

function ViewBaseEx:onExit_()
	if self.onExit then self:onExit() end
end

function ViewBaseEx:onEnterTransitionFinish_()
	if self.onEnterTransitionFinish then self:onEnterTransitionFinish() end
end

function ViewBaseEx:onExitTransitionStart_()
	if self.onExitTransitionStart then self:onExitTransitionStart() end
end

function ViewBaseEx:onCleanup_()
	if self._isNodeSyncUpdateEnabled == true then display.getWorld():removeNodeFromSyncUpdateList(self) end
	if self.onCleanup then self:onCleanup() end
end

function ViewBaseEx:sendAppMsg(msgID, ...)
    local pEvent = cc.EventCustom:new(msgID)
    pEvent.parameters = {...}
    cc.Director:getInstance():getEventDispatcher():dispatchEvent(pEvent)
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

function ViewBaseEx:enableUpdate(func)
	display.getWorld():addNodeSyncUpdate(self, func)
	self._isNodeSyncUpdateEnabled = true
end

function ViewBaseEx:runSequence(...)
	self:runAction( cc.Sequence:create( ... ) )
end

return ViewBaseEx
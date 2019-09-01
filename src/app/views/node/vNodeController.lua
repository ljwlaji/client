local ViewBaseEx 	= import("app.views.ViewBaseEx")
local Controller 	= class("Controller", ViewBaseEx)

local M_PI 			= 3.1415926535898
local D_PI 			= M_PI * 2
local AnglePerPi 	= 180 / M_PI

Controller.RESOURCE_FILENAME = "res/csb/node/CSB_Node_Controller.csb"
Controller.RESOURCE_BINDING = {}
Controller.instance = nil
-- Controller
-- 大小
-- 	   宽度 1/3个屏幕大小
--	   高度 屏幕高度
-- ZOrder HUD UI控件ZOrder 减 1

function Controller:onCreate()
	self:setVisible(false)
	self:setContentSize(256, 256):setAnchorPoint(0.5, 0.5)
	self.m_Monitor = self.m_Children["CSB_Monitor"]
	self.centerPoint = {x = self:getContentSize().width / 2, y = self:getContentSize().height / 2}
	self.m_Offset = {x = 0, y = 0}
	Controller.instance = self
	self:registTouchEvents()
end

function Controller:onExit()
	Controller.instance = nil
end

function Controller:getInstance()
	return Controller.instance
end

function Controller:getHorizonOffset()
	return self.m_Offset.x / 128
end

function Controller:onOffsetChanged(offset)
	self.m_Offset = offset
end

function Controller:registTouchEvents()
    local listener = cc.EventListenerTouchOneByOne:create()
    listener:registerScriptHandler(handler(self, self.onTouchBegan), cc.Handler.EVENT_TOUCH_BEGAN)
    listener:registerScriptHandler(handler(self, self.onTouchMoved), cc.Handler.EVENT_TOUCH_MOVED)
    listener:registerScriptHandler(handler(self, self.onTouchEnded), cc.Handler.EVENT_TOUCH_ENDED)
    listener:registerScriptHandler(handler(self, self.onTouchEnded), cc.Handler.EVENT_TOUCH_CANCELLED)
    local eventDispatcher = self:getEventDispatcher()
    eventDispatcher:addEventListenerWithSceneGraphPriority(listener, self)
end

function Controller:onTouchBegan(touch, event)
	local TouchPosition = self:getParent():convertToNodeSpace(touch:getLocation())
	if not cc.rectContainsPoint(self:getParent():getBoundingBox(), self:getParent():getParent():convertToNodeSpace(touch:getLocation())) then return false end
	self:setPosition(TouchPosition)
	self:setVisible(true)
	return true
end

function Controller:onTouchMoved(touch, event)
	-- TODO 计算超出部分
	local currPos = self:convertToNodeSpace(touch:getLocation())
	self.m_Monitor:move(currPos.x, currPos.y)
	local disdance = cc.pGetDistance(self.centerPoint, self:convertToNodeSpace(touch:getLocation()))
	if disdance > 128 then self:move(cc.pAdd(cc.p(self:getPosition()), touch:getDelta())) end
	self:onOffsetChanged(cc.pSub( currPos, self.centerPoint ))

end

function Controller:onTouchEnded(touch, event)
	self:setVisible(false)
	self.m_Monitor:move(self:getContentSize().width / 2, self:getContentSize().height / 2)
	self:onOffsetChanged(cc.p(0, 0))
end


return Controller
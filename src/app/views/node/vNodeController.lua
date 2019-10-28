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

local Pressed_Up 	= false
local Pressed_Down 	= false
local Pressed_Left 	= false
local Pressed_Right = false

local Move_Seed = 0

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
	return self.m_Offset.x * 0.0078125
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

    if device.platform == "mac" or device.platform == "windows" then
		local keyListener = cc.EventListenerKeyboard:create()
	    keyListener:registerScriptHandler(handler(self, self.onKeyPressed), 	cc.Handler.EVENT_KEYBOARD_PRESSED)
	    keyListener:registerScriptHandler(handler(self, self.onKeyReleased), 	cc.Handler.EVENT_KEYBOARD_RELEASED)
    	eventDispatcher:addEventListenerWithSceneGraphPriority(keyListener, self)
    end
end

function Controller:onKeyPressed(keyID, event)
	if keyID == 146 then --Up
		Pressed_Up = true
	elseif keyID == 127 then
		Pressed_Right = true
	elseif keyID == 142 then
		Pressed_Down = true
	elseif keyID == 124 then
		Pressed_Left = true
	end

	if keyID == 59 then
		self:sendAppMsg("onTouchButtonB")
	end
	Move_Seed = 0
	if Pressed_Left 	then Move_Seed = Move_Seed - 256 end
	if Pressed_Right 	then Move_Seed = Move_Seed + 256 end
	self.m_Offset.x = Move_Seed
end

function Controller:onKeyReleased(keyID, event)
	if keyID == 146 then --Up
		Pressed_Up = false
	elseif keyID == 127 then
		Pressed_Right = false
	elseif keyID == 142 then
		Pressed_Down = false
	elseif keyID == 124 then
		Pressed_Left = false
	end
	Move_Seed = 0
	if Pressed_Left 	then Move_Seed = Move_Seed - 256 end
	if Pressed_Right 	then Move_Seed = Move_Seed + 256 end
	self.m_Offset.x = Move_Seed
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
	if disdance > 128 then 
		self:move(cc.pAdd(cc.p(self:getPosition()), touch:getDelta())) 
	end
	self:onOffsetChanged(cc.pSub( currPos, self.centerPoint ))

end

function Controller:onTouchEnded(touch, event)
	self:setVisible(false)
	self.m_Monitor:move(self:getContentSize().width / 2, self:getContentSize().height / 2)
	self:onOffsetChanged(cc.p(0, 0))
end


return Controller
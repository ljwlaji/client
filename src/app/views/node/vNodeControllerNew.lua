local ViewBaseEx 	= import("app.views.ViewBaseEx")
local vNodeControllerNew = class("vNodeControllerNew", ViewBaseEx)

vNodeControllerNew.RESOURCE_FILENAME = "res/csb/node/CSB_Node_Controller_New.csb"
vNodeControllerNew.RESOURCE_BINDING = {}

vNodeControllerNew.instance = nil

local Pressed_Up 	= false
local Pressed_Down 	= false
local Pressed_Left 	= false
local Pressed_Right = false

local Move_Seed = 0

function vNodeControllerNew:onCreate(context)
	self.m_Offset = {x = 0, y = 0}
	vNodeControllerNew.instance = self

	local listener = cc.EventListenerTouchOneByOne:create()
    listener:registerScriptHandler(handler(self, self.onTouchBegan), cc.Handler.EVENT_TOUCH_BEGAN)
    listener:registerScriptHandler(handler(self, self.onTouchMoved), cc.Handler.EVENT_TOUCH_MOVED)
    listener:registerScriptHandler(handler(self, self.onTouchEnded), cc.Handler.EVENT_TOUCH_ENDED)
    listener:registerScriptHandler(handler(self, self.onTouchEnded), cc.Handler.EVENT_TOUCH_CANCELLED)
    local eventDispatcher = self:getEventDispatcher()
    eventDispatcher:addEventListenerWithSceneGraphPriority(listener, self)

	self.m_Children["Button_Left"].onTouchInto = handler(self, self.onTouchButtonLeft)
	self.m_Children["Button_Down"].onTouchInto = handler(self, self.onTouchButtonDown)
	self.m_Children["Button_Right"].onTouchInto = handler(self, self.onTouchButtonRight)
	self.m_Children["Button_Up"].onTouchInto = handler(self, self.onTouchButtonUp)


    if device.platform == "mac" or device.platform == "windows" then
		local keyListener = cc.EventListenerKeyboard:create()
	    keyListener:registerScriptHandler(handler(self, self.onKeyPressed), 	cc.Handler.EVENT_KEYBOARD_PRESSED)
	    keyListener:registerScriptHandler(handler(self, self.onKeyReleased), 	cc.Handler.EVENT_KEYBOARD_RELEASED)
    	eventDispatcher:addEventListenerWithSceneGraphPriority(keyListener, self)
    end
end

function vNodeControllerNew:onKeyPressed(keyID, event)
	if keyID == 146 then --Up
		self:sendAppMsg("onControllerJump")
	elseif keyID == 127 then
		Pressed_Right = true
	elseif keyID == 142 then
		Pressed_Down = true
	elseif keyID == 124 then
		Pressed_Left = true
	end
	self:updateMovement()
end

function vNodeControllerNew:onKeyReleased(keyID, event)
	if keyID == 146 then --Up
		Pressed_Up = false
	elseif keyID == 127 then
		Pressed_Right = false
	elseif keyID == 142 then
		Pressed_Down = false
	elseif keyID == 124 then
		Pressed_Left = false
	end
	self:updateMovement()
end

function vNodeControllerNew:getInstance()
	return vNodeControllerNew.instance
end

function vNodeControllerNew:getHorizonOffset()
	return self.m_Offset.x * 0.0078125
end

function vNodeControllerNew:checkTouch(touch)
	local isButtonTouched = false
	for k, v in pairs({self.m_Children["Button_Left"], 
					   self.m_Children["Button_Down"],
					   self.m_Children["Button_Right"],
					   self.m_Children["Button_Up"]}) do
		if cc.rectContainsPoint(v:getBoundingBox(), self:convertToNodeSpace(touch:getLocation())) then
			v.onTouchInto()
			isButtonTouched = true
			break
		end
	end
	return isButtonTouched
end

function vNodeControllerNew:onTouchBegan(touch, event)
	return self:checkTouch(touch)
end

function vNodeControllerNew:onTouchMoved(touch, event)
	-- TODO 计算超出部分
	self:checkTouch(touch)
end

function vNodeControllerNew:onTouchEnded(touch, event)
	Pressed_Left = false
	Pressed_Right = false
	self:updateMovement()
end

function vNodeControllerNew:onTouchButtonUp(e)
	self:sendAppMsg("onControllerJump")
end

function vNodeControllerNew:onTouchButtonDown(e)

end

function vNodeControllerNew:onTouchButtonLeft(e)
	Pressed_Left = true
	Pressed_Right = not Pressed_Left
	self:updateMovement()
end

function vNodeControllerNew:onTouchButtonRight(e)
	Pressed_Right = true
	Pressed_Left = not Pressed_Right
	self:updateMovement()
end

function vNodeControllerNew:updateMovement()
	Move_Seed = 0
	if Pressed_Left 	then Move_Seed = Move_Seed - 128 end
	if Pressed_Right 	then Move_Seed = Move_Seed + 128 end
	self.m_Offset.x = Move_Seed
end

return vNodeControllerNew
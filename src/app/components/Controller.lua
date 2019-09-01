local Controller 	= class("Controller", cc.Node)
local Player 		= import("app.components.Object.Player")

local M_PI 			= 3.1415926535898
local D_PI 			= M_PI * 2
local AnglePerPi 	= 180 / M_PI


-- Controller
-- 大小
-- 	   宽度 1/3个屏幕大小
--	   高度 屏幕高度
-- ZOrder HUD UI控件ZOrder 减 1


function Controller:ctor()
	self:setVisible(false)
	self:setContentSize(256, 256):setAnchorPoint(0.5, 0.5)
	cc.Sprite:create("res/Controller_BG.jpg"):addTo(self):setAnchorPoint(0.5, 0.5):move(self:getContentSize().width / 2, self:getContentSize().height / 2):setOpacity(127)
	self.m_Monitor = cc.Sprite:create("res/Controller.jpg"):addTo(self):move(self:getContentSize().width / 2, self:getContentSize().height / 2):setScale(0.3):setOpacity(127)
	self:onCreate()
	self.centerPoint = {x = self:getContentSize().width / 2, y = self:getContentSize().height / 2}
end

function Controller:onCreate()
	self:registTouchEvents()
end

function Controller:onOffsetChanged(offset)
	local currPlr = Player.getInstance()
	if currPlr then currPlr:onControllerUpdate(offset) end
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
	if disdance > 120 then self:move(cc.pAdd(cc.p(self:getPosition()), touch:getDelta())) end
	self:onOffsetChanged(cc.pSub( currPos, self.centerPoint ))

end

function Controller:onTouchEnded(touch, event)
	self:setVisible(false)
	self.m_Monitor:move(self:getContentSize().width / 2, self:getContentSize().height / 2)
	self:onOffsetChanged(cc.p(0, 0))
end


return Controller
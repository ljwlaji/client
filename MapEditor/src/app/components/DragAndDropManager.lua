local DragAndDropManager = class("DragAndDropManager")

DragAndDropManager.instance = nil

function DragAndDropManager:getInstance()
	if DragAndDropManager.instance == nil then
		DragAndDropManager.instance = DragAndDropManager:create()
	end
	return DragAndDropManager.instance
end

function DragAndDropManager:ctor()
	self._DragNodes = {}
end

function DragAndDropManager:isDragInside(node, touch)
	if not node:getParent() then return false end
    local TouchPosition = node:getParent():convertToNodeSpace(touch:getLocation())
    local box = node:getBoundingBox()
    box.x = box.x - node:getContentSize().width * node:getAnchorPoint().x
    box.y = box.y - node:getContentSize().height * node:getAnchorPoint().y
    return cc.rectContainsPoint(box, TouchPosition)
end

function DragAndDropManager:onDragBegan(this, touch, event)
	return this:isVisible() and self:isDragInside(this, touch)
end

function DragAndDropManager:onDragMoved(this, touch, event)
    this:move(cc.pAdd(cc.p(this:getPosition()), touch:getDelta()))
end

function DragAndDropManager:onDragEnded(this, touch, event)
	local otherNode = nil
	for node, _ in pairs(self._DragNodes) do
		if node ~= this then
		    local TouchPosition = node:getParent():convertToNodeSpace(touch:getLocation())
		    local box = node:getBoundingBox()
		    box.x = box.x - node:getContentSize().width * node:getAnchorPoint().x
		    box.y = box.y - node:getContentSize().height * node:getAnchorPoint().y
		    if cc.rectContainsPoint(box, TouchPosition) then
		    	otherNode = node
		    	break
		    end
		end
	end
    local Delta = cc.pSub(touch:getStartLocation(), touch:getLocation())
	if otherNode and otherNode.__onDrop and otherNode.__onDrop(this) then
		return
	else
		this:move(cc.pAdd(cc.p(this:getPosition()), Delta))
	end

    if math.abs(Delta.x) >= 10 or math.abs(Delta.y) >= 10 then release_print("偏移量过大, 丢弃这个触摸!") return end
	if this.___onNormalTouchCallBack then this.___onNormalTouchCallBack({
		touch = touch,
		target = target,
		name = "began"
	}) end
end


function DragAndDropManager:enableDragAndDrop(node)
    local listener = cc.EventListenerTouchOneByOne:create()
    listener:registerScriptHandler(function(...) return self:onDragBegan(node, ...) end, cc.Handler.EVENT_TOUCH_BEGAN)
    listener:registerScriptHandler(function(...) self:onDragMoved(node, ...) end, cc.Handler.EVENT_TOUCH_MOVED)
    listener:registerScriptHandler(function(...) self:onDragEnded(node, ...) end, cc.Handler.EVENT_TOUCH_ENDED)
    listener:registerScriptHandler(function(...) self:onDragEnded(node, ...) end, cc.Handler.EVENT_TOUCH_CANCELLED)
    local eventDispatcher = node:getEventDispatcher()
    eventDispatcher:addEventListenerWithSceneGraphPriority(listener, node)
    self:insertDragAndDropNode(node)
end

function DragAndDropManager:insertDragAndDropNode(node)
	if self._DragNodes[node] then return end
	self._DragNodes[node] = true
end

function DragAndDropManager:removeDrageAndDropNode(node)
	if not self._DragNodes[node] then return end
	self._DragNodes[node] = nil
end





return DragAndDropManager:getInstance()
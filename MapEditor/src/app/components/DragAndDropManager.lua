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
	self:regiestMouseListener()
end

function DragAndDropManager:isDragInside(node, touch)
	if not node:getParent() then return false end
    local TouchPosition = node:getParent():convertToNodeSpace(touch:getLocation())
    local box = node:getBoundingBox()
    return cc.rectContainsPoint(box, TouchPosition)
end

function DragAndDropManager:onDragBegan(this, touch, event)
	if self.__isTouchDown then return false end
	self.__isTouchDown = this:isVisible() and self:isDragInside(this, touch)
	return self.__isTouchDown
end

function DragAndDropManager:onDragMoved(this, touch, event)
	for _, node in pairs(self._DragNodes) do
    	if node ~= this and self:isDragInside(node, touch) then
    		if not node.__drawNode.drawing then
    			local size = node:getContentSize()
			    node.__drawNode:drawPolygon({cc.p(0, 0), cc.p(size.width, 0), cc.p(size.width, size.height), cc.p(0, size.height)}, 4, cc.c4f(0,0,0,0), 1, cc.c4f(1,1,1,1))
			    node.__drawNode.drawing = true
			end
    	else
    		if node.__drawNode.drawing then
    			node.__drawNode:clear()
    			node.__drawNode.drawing = false
    		end
    	end
    end
    this:move(cc.pAdd(cc.p(this:getPosition()), touch:getDelta()))
end

function DragAndDropManager:onDragEnded(this, touch, event)
	self.__isTouchDown = false
	local otherNode = nil
	for _, node in pairs(self._DragNodes) do
		node.__drawNode:clear()
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
	this:move(cc.pAdd(cc.p(this:getPosition()), Delta))
	if otherNode and otherNode.__onDrop then
		otherNode.__onDrop({
			touch = touch,
			otherNode = otherNode,
		})
		return
	end

	if this.___onNormalTouchCallBack then this.___onNormalTouchCallBack({
		touch = touch,
		target = this,
		name = "ended",
		largeOffset = math.abs(Delta.x) >= 10 or math.abs(Delta.y) >= 10
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
	table.insert(self._DragNodes, 1, node)
    node:onNodeEvent("cleanup", function()
        self:removeDragAndDropNode(btn)
    end)
	node.__drawNode = node.__drawNode or cc.DrawNode:create():addTo(node)
end

function DragAndDropManager:removeDrageAndDropNode(node)
	for k, v in ipairs(self._DragNodes) do
		if v == node then
			table.remove(self._DragNodes, k)
			break
		end
	end
end

function DragAndDropManager:isMoveInside(node, touch)
	if not node:getParent() then return false end
    local TouchPosition = node:getParent():convertToNodeSpace(touch:getLocationInView())
    local box = node:getBoundingBox()
    return cc.rectContainsPoint(box, TouchPosition)
end

function DragAndDropManager:onMouseDown(event)
	-- dump(event:getMouseButton())
end

function DragAndDropManager:onMouseUp(event)
	-- dump(event:getMouseButton())
end

function DragAndDropManager:onMouseMove(event)
	if self.__isTouchDown then return end
	for _, node in pairs(self._DragNodes) do
    	if self:isMoveInside(node, event) then
    		if not node.__drawNode.drawing then
    			local size = node:getContentSize()
			    node.__drawNode:drawPolygon({cc.p(0, 0), cc.p(size.width, 0), cc.p(size.width, size.height), cc.p(0, size.height)}, 4, cc.c4f(0,0,0,0), 1, cc.c4f(1,1,1,1))
			    node.__drawNode.drawing = true
			end
    	else
    		if node.__drawNode.drawing then
    			node.__drawNode:clear()
    			node.__drawNode.drawing = false
    		end
    	end
    end
end

function DragAndDropManager:onMouseScroll(event)
	-- print(event:getScrollX(), event:getScrollY())
end

function DragAndDropManager:regiestMouseListener()
    local listener = cc.EventListenerMouse:create()
    listener:registerScriptHandler(handler(self, self.onMouseDown), cc.Handler.EVENT_MOUSE_DOWN)
    listener:registerScriptHandler(handler(self, self.onMouseUp), cc.Handler.EVENT_MOUSE_UP)
    listener:registerScriptHandler(handler(self, self.onMouseMove), cc.Handler.EVENT_MOUSE_MOVE)
    listener:registerScriptHandler(handler(self, self.onMouseScroll), cc.Handler.EVENT_MOUSE_SCROLL)
    local eventDispatcher = display.getRunningScene():getEventDispatcher()
    eventDispatcher:addEventListenerWithSceneGraphPriority(listener, display.getRunningScene())
end



return DragAndDropManager:getInstance()
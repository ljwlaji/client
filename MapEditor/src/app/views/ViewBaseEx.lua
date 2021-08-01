local DragAndDrop = require("app.components.DragAndDropManager")
local ViewBaseEx = class("ViewBaseEx", cc.load("mvc").ViewBase)

function ViewBaseEx:autoAlgin()
	self:setContentSize(display.width, display.height)
	if self:getResourceNode() then
		self:getResourceNode():setContentSize(display.width, display.height)
	end

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

function ViewBaseEx:createLayout(param)
    param = param or {}
    local btn  = ccui.Layout:create()
                            :setBackGroundColorType(ccui.LayoutBackGroundColorType.solid)
                            :setContentSize(param.size or cc.size(0, 0))
                            :setBackGroundColor(param.color or cc.c3b(255, 255, 255))
                            :setBackGroundColorOpacity(param.op or 30)
                            :setAnchorPoint(param.ap and param.ap or cc.p(0.5, 0.5))

    if param.dad then -- Drag And Drop Issus
        DragAndDrop:enableDragAndDrop(btn)
        btn.___onNormalTouchCallBack = param.cb
        btn:setSwallowTouches(param.st == nil and true or param.st)
        btn.__onDrop = type(param.dad) == "function" and param.dad or nil
    elseif param.cb then -- onTouchEnded Only
        btn:setTouchEnabled(true)
        btn:onTouch(param.cb)
        btn:setSwallowTouches(param.st == nil and true or param.st)
    end
    if param.str then
        local label = cc.LabelTTF:create()
        label:setFontSize(param.fs and param.fs or 22)
        label:addTo(btn)
        btn.setTitleStr = function(this, str) 
                                label:setString(str)
                                local size = btn:getContentSize()
                                size.width = math.max(label:getContentSize().width + 10, size.width)
                                btn:setContentSize(size)
                                label:alignCenter()
                                return this 
                        end 
        btn.getTitleStr = function(this) return label:getString() end
        btn.getStringSize = function(this) return label:getContentSize() end
        btn:setTitleStr(param.str or "")
    end
    return btn
end

function ViewBaseEx:cEditBox(param)
    param = param or {}
    local layouter = self:createLayout(param)

    local box  = ccui.EditBox:create(param.size or cc.size(300, 40), "")
                             :setAnchorPoint(0.5, 0.5)
                             :addTo(layouter)
                             :alignCenter()
                             :setFontSize(20)
                             :setPlaceholderFontSize(20)

    if param.cb then
    	box:registerScriptEditBoxHandler(param.cb)
    end

    layouter.getText = function() return box:getText() end
    if param.ph then
        box:setPlaceHolder(param.ph)
    end
    return layouter
end


return ViewBaseEx
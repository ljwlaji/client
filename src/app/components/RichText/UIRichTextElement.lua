local UIViewBase = import("..UIViewBase")
local UIRichTextElement = class("UIRichTextElement", UIViewBase)

--[[
	--RichText 基础元素
]]

UIRichTextElement.IDXs = {
	["value"] 			= "t",
	["fontColor"]		= "c",
	["fontPath"]		= "p",
	["fontSize"]		= "s",
	["underLine"]		= "ul",
	["outLine"]			= "ol",
	["outLineColor"]	= "olc",
	["outLineSize"]		= "ols",
	["imgPath"]			= "ip",
}

-- 从MathToolBox内移动过来
local function isTouchInside(checkNode, checkPoint)
	return cc.rectContainsPoint(checkNode:getBoundingBox(), checkNode:convertToNodeSpace(checkPoint))
end

function UIRichTextElement:onCreate()
	self:setDefaultValue("elementType",		"label"--[[font]])
	UIViewBase.onCreate(self)


	self.drawNode = nil
	self.onTouchLayouter = nil
end

---------Generatting------

function UIRichTextElement.isShortIdx(idx)
	local isShort = false
		for k, v in pairs(UIRichTextElement.IDXs) do
		if v == idx then
			isShort = true
			break
		end
	end

	return isShort
end

function UIRichTextElement.toShortIdx(longIdx)
	local shortIdx = longIdx
	if UIRichTextElement.IDXs[longIdx] then
		shortIdx = UIRichTextElement.IDXs[longIdx]
	end
	return shortIdx
end

function UIRichTextElement.toLongIdx(shortIdx)
	local longIdx = shortIdx
	for k, v in pairs(UIRichTextElement.IDXs) do
		if v == shortIdx then
			longIdx = k
			break
		end
	end
	return longIdx
end

function UIRichTextElement:serialize()
	local data = "<"..self.context.elementType.." "
	for k, v in pairs(self.context) do
		if type(v) ~= "function" and k ~= "value" then
			data = data..k.."="..'"'..v..'"'..", "
		end
	end
	data = string.sub(data, 1, string.len(data) - 2)
	data = data..">"..self.context.value.."</"..self.context.elementType..">"
	return data
end

function UIRichTextElement:tableToLuaData(table)
	local data = "{"
	for k, v in pairs(table) do
		if type(v) ~= "function" then
			local vk = type(k) == "string" and '["'..k..'"]' or "["..k.."]"
			if type(v) == "table" then
				data = data..vk.."="..self:tableToLuaData(v)..","
			else
				if type(v) == "string" then
					if v == "\n" then v = "\\n" end
					data = data..vk.."="..'"'..v..'"'..","
				else
					data = data..vk.."="..v..","
				end
			end
		end
	end

	data = string.sub(data, 1, string.len(data) - 1)
	data = data.."}"
	return data
end

function UIRichTextElement:serializeToLuaData()
	return self:tableToLuaData(self.context)
end

function UIRichTextElement:getType()
	return self.context.elementType
end

function UIRichTextElement:getDrawSize()
	return self.drawNode:getContentSize()
end

function UIRichTextElement:refresh()
	if self.onTouchLayouter then return end
	self.onTouchLayouter = ccui.Layout:create()
  									  :addTo(self.drawNode)
  									  :setAnchorPoint(0, 0)
  									  :setContentSize(self.drawNode:getContentSize())

  	local listener = cc.EventListenerTouchOneByOne:create()
	listener:setSwallowTouches(true)
	listener:registerScriptHandler(handler(self, self.nativeOnTouchBegan), 		cc.Handler.EVENT_TOUCH_BEGAN)
	listener:registerScriptHandler(handler(self, self.nativeOnTouchMoved), 		cc.Handler.EVENT_TOUCH_MOVED)
	listener:registerScriptHandler(handler(self, self.nativeOnTouchEnded), 		cc.Handler.EVENT_TOUCH_ENDED)
	listener:registerScriptHandler(handler(self, self.nativeOnTouchCancelled), 	cc.Handler.EVENT_TOUCH_CANCELLED)
	local eventDispatcher = self:getEventDispatcher()
	eventDispatcher:addEventListenerWithSceneGraphPriority(listener, self.onTouchLayouter)
end

function UIRichTextElement:nativeOnTouchBegan(touch, event)

	if not isTouchInside(self.onTouchLayouter, touch:getLocation()) then
		return false
	end

	if not self.context.onTouched then return false end

	if not self:isParentVisible() then return false end
	return true
end

function UIRichTextElement:nativeOnTouchMoved(touch, event)

end

function UIRichTextElement:nativeOnTouchEnded(touch, event)
	if not isTouchInside(self.onTouchLayouter, touch:getLocation()) then return end
	--??????????????????
	self.context.onTouched(self.context.func, self.context.param)
	--!!!!!!!!!!!!!!!!!!
end

function UIRichTextElement:nativeOnTouchCancelled(touch, event)

end

function UIRichTextElement:onDisplayDataChanged()
	if self.onTouchLayouter then
		self.onTouchLayouter:setContentSize(self.drawNode:getContentSize())
	end
end


return UIRichTextElement
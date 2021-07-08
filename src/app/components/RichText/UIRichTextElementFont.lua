local UIRichTextElement = import(".UIRichTextElement")
local UIRichTextElementFont = class("UIRichTextElementFont", UIRichTextElement)

function UIRichTextElementFont:onCreate()
	UIRichTextElement.onCreate(self)
	self.context.fontSize = self.context.fontSize or 18
	self.context.fontColor = self.context.fontColor or "255,255,255"
	self:refresh()
end

function UIRichTextElementFont:setString(str)
	self.drawNode:setString(str)
	return self
end

function UIRichTextElementFont:refresh()
	if self.context.value == "nullSet" then
		error("Execption Catched In function UIRichTextElement:initWithFont()! elementType Is font But NO string context !")
	end
	if not self.drawNode then 
		self.drawNode = cc.LabelTTF:create()--(self.context.value, self.context.fontPath)
		self.drawNode:setString(self.context.value)
		self.drawNode:setFontSize(tonumber(self.context.fontSize))
	end
	self.drawNode:addTo(self):setAnchorPoint(0, 0)
	local colors = string.split(self.context.fontColor, ",")
	self.drawNode:setColor(cc.c3b(colors[1],colors[2],colors[3]))
	-- if self.context.underLine == "true" then self.drawNode:enableUnderline() end

	-- if self.context.outLine == "true" then
	-- 	local outLineColors = self.spiltString(self.context.outLineColor, ",")
	-- 	self.drawNode:enableOutline(cc.c4b(outLineColors[1],outLineColors[2],outLineColors[3], 255), self.context.outLineSize)
	-- end

	UIRichTextElement.refresh(self)
	return self
end

function UIRichTextElementFont:onTextChanged()
	if self.onTouchLayouter then self.onTouchLayouter:setContentSize(self.drawNode:getContentSize()) end
end

function UIRichTextElementFont:isSameContext(contextB)
	if string.byte(contextB.value) == 32 then return false end --空格则新建一个

	local isSame = true
	for k, v in pairs(self.context) do
		if type(v) ~= "function" and k ~= "value" then
			if type(v) == "table" and not self:compareTable(v, contextB[k]) then
				isSame = false
				break
			elseif contextB[k] ~= v then
				isSame = false
				break
			end
		end
	end

	return isSame
end

return UIRichTextElementFont
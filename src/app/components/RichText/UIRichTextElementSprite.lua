local UIRichTextElement = import(".UIRichTextElement")
local UIRichTextElementSprite = class("UIRichTextElementSprite", UIRichTextElement)


function UIRichTextElementSprite:onCreate()
	UIRichTextElement.onCreate(self)
	self:refresh()
end

function UIRichTextElementSprite:refresh()
	local path = self.context.imgPath
	if not self.drawNode then
		local obj = nil
		if string.byte(path) == 64 then
			path = string.sub(path, 2)
			obj = cc.Sprite:createWithSpriteFrameName(path)
		else
			obj = cc.Sprite:create(path)
		end
		if not obj then error("Method Catched Exeption : \n @UIDragBar:safeCreateSprite(plist, pngPath) \n ==> Create ProgressImage Failed ! Maybe The Texture File Dosen't Exist ? path = "..tostring(path)) end

		obj:addTo(self):setAnchorPoint(0, 0)

		self.drawNode = obj
	end
	UIRichTextElement.refresh(self)

	return self
end

function UIRichTextElement:fixSize(maxWidth, maxHeight)
	local nodeContentSize = self.drawNode:getContentSize()

	local seedWidth = nodeContentSize.width / maxWidth
	local seedHeight = nodeContentSize.height / maxHeight

	if seedWidth > 1 or seedHeight > 1 then
		local scaleSeed = seedWidth > seedHeight and maxWidth / nodeContentSize.width or maxHeight / nodeContentSize.height
		self.drawNode:setContentSize(self.drawNode:getContentSize().width * scaleSeed, self.drawNode:getContentSize().height * scaleSeed)
	end

	self.onTouchLayouter:setContentSize(self.drawNode:getContentSize())
	return self
end


return UIRichTextElementSprite
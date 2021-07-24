local obj = ccui.Text

obj.autoScaleHeight = function(self)
	local renderSize = self:getAutoRenderSize()
	self:setContentSize(self:getContentSize().width, renderSize.height)
	self:setTextAreaSize(self:getContentSize())
	return self
end

obj.autoScaleWidth = function(self)
	local renderSize = self:getAutoRenderSize()
	self:setContentSize(renderSize.width, self:getContentSize().height)
	self:setTextAreaSize(self:getContentSize())
	return self
end
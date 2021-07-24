assert(cc.Node)


function cc.Node.alignCenter(this)
	local parent = this:getParent()
	if not parent then return end
	local size = parent:getContentSize()
	this:setAnchorPoint(0.5, 0.5):move(size.width * 0.5, size.height * 0.5)
	return this
end

local Camera = class("Camera")

function Camera:ctor(focusUnit, followBoxSize)
	self.focusUnit = focusUnit
	self.followBoxSize = followBoxSize or {x = 5, y = 5}
end

function Camera:move(offSetX, offSetY)
	local currentPosX, currentPosY = self.focusUnit:getMap():getPosition()
	self.focusUnit:getMap():move(currentPosX + offSetX, currentPosY + offSetY)
end

--[[
	@return void
	@param
	@focusUnit 传入需要对角的单位
	@skipAnim 是否跳过动画
]]
function Camera:changeFocus(focusUnit, skipAnim)
	assert(focusUnit)
	self.focusUnit = focusUnit
	if skipAnim then self:move(self:getMoveOffset()) end
end

function Camera:getMoveOffset(seed)
	-- TODO
	-- 计算出Unit世界位置
	local Map = self.focusUnit:getMap()
	local MapPosX, MapPosY = Map:getPosition()
	local UnitPosX, UnitPosY = self.focusUnit:getPosition()
	local UnitWorldPosX = UnitPosX + MapPosX
	local UnitWorldPosY = UnitPosY + MapPosY
	-- 计算出移动偏移量
	local MovePosX = display.cx - UnitWorldPosX
	local MovePosY = display.cy - UnitWorldPosY
	-- 是否在误差范围内
	MovePosX = math.abs(MovePosX) <= self.followBoxSize.x and 0 or MovePosX * (seed or 1)
	MovePosY = math.abs(MovePosY) <= self.followBoxSize.y and 0 or MovePosY * (seed or 1)
	-- 计算是否地图超过边缘
	-- 待完善
	-- 是否
	return MovePosX, MovePosY
end

function Camera:onUpdate()
	if not self.canUpdate or not self.focusUnit then return end
	self:move(self:getMoveOffset(0.05))
end


return Camera
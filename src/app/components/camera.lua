local Camera = class("Camera")

function Camera:ctor(focusUnit, followBoxSize)
	self.focusUnit = focusUnit

	self.followBoxSize = followBoxSize or {x = 5, y = 5}
end

function Camera:move(offSetX, offSetY)
	local currentPosX, currentPosY = self.focusUnit:getMap():getPosition()
	self.focusUnit:getMap():move(currentPosX + offSetX, currentPosY + offSetY)
end

function Camera:onUpdate(diff)
	if not self.focusUnit then return nil end

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
	if math.abs(MovePosX) <= self.followBoxSize.x or math.abs(MovePosY) <= self.followBoxSize.y then return end

	local MovePosX = MovePosX * 0.05
	local MovePosY = MovePosY * 0.05

	-- 计算是否地图超过边缘

	-- 是否
	self:move(MovePosX, MovePosY)
end


return Camera
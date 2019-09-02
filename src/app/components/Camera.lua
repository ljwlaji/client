local Camera = class("Camera")

Camera.instance = nil

function Camera.getInstance()
	if not Camera.instance then
		Camera.instance = Camera:create()
	end
	return Camera.instance
end

function Camera:ctor(focusUnit, followBoxSize)
	self.canUpdate = false
	self.focusUnit = focusUnit or nil
	self.followBoxSize = followBoxSize or {x = 20, y = 20}
end

function Camera:move(offSetX, offSetY)
	local currentPosX, currentPosY = self.focusUnit:getMap():getPosition()
	local finalPos = {
		x = currentPosX + offSetX,
		y = currentPosY + offSetY
	}

	if finalPos.x > 0 then finalPos.x = 0 end
	if finalPos.y > 0 then finalPos.y = 0 end
	self.focusUnit:getMap():move(finalPos.x, finalPos.y)
end

--[[
	@return void
	@param
	@focusUnit 传入需要对角的单位
	@skipAnim 是否跳过动画
]]
function Camera:changeFocus(focusUnit, skipAnim)
	self.focusUnit = focusUnit
	if not self.focusUnit then return end
	if skipAnim then self:move(self:getMoveOffset()) end
	self.canUpdate = true
end

function Camera:getFocusdUnit()
	return self.focusUnit
end

function Camera:stopFollow()
	self.canUpdate = false
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
	return MovePosX, MovePosY
end

function Camera:onUpdate()
	if not self.canUpdate or not self.focusUnit then return end
	self:move(self:getMoveOffset(0.05))
end


return Camera.getInstance()
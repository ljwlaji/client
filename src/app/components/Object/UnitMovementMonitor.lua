local StateMachine 			= import("app.components.StateMachine")
local Controller 			= import("app.views.node.vNodeController")
local UnitMovementMonitor 	= class("UnitMovementMonitor")


UnitMovementMonitor.MovementStates = {
	STATE_IDLE 				= 0,
	STATE_IDLE_RUN 			= 1,
	STATE_RUN_IDLE  		= 2,
	STATE_RUN  				= 3,
	STATE_JUMP_HIGH   		= 4,
	STATE_JUMP_FALL   		= 5,
	STATE_JUMP_FALL_LAND  	= 6,
}
local MovementStates 		= UnitMovementMonitor.MovementStates
local STATE_IDLE 			= 0
local STATE_IDLE_RUN 		= 1
local STATE_RUN_IDLE  		= 2
local STATE_RUN  			= 3
local STATE_JUMP_HIGH   	= 4
local STATE_JUMP_FALL   	= 5
local STATE_JUMP_FALL_LAND  = 6

local SPEED_REDUCTION 		= 0.7
local MAX_FALL_SPEED 		= 20

function UnitMovementMonitor:ctor(who)
	self.m_Direction = "right"
	self.m_MoveSpeed = 0
	self.m_FallSpeed = -1
	self.m_Unit = who
	self:init()
end

function UnitMovementMonitor:getOwner()
	assert(self.m_Unit)
	return self.m_Unit
end

function UnitMovementMonitor:init()
	-- For This StateMachine
	-- It's Just Dealling With Animation For Current Unit
	self.m_StateMachine = StateMachine:create()
	self.m_StateMachine:addState(MovementStates.STATE_IDLE, 			handler(self, self.onEnterIdle), 		handler(self, self.onExecuteIdle), 		handler(self, self.onExitIdle), 	nil)
					   :addState(MovementStates.STATE_IDLE_RUN, 		handler(self, self.onEnterIdleRun), 	handler(self, self.onExecuteIdleRun), 	handler(self, self.onExitIdleRun), 	nil)
					   :addState(MovementStates.STATE_RUN_IDLE, 		nil, nil, nil, nil)
					   :addState(MovementStates.STATE_RUN, 				handler(self, self.onEnterRun), 		handler(self, self.onExecuteRun), 		handler(self, self.onExitRun), 		nil)
					   :addState(MovementStates.STATE_JUMP_HIGH, 		handler(self, self.onEnterJumpHigh), 	handler(self, self.onExecuteJumpHigh), 	handler(self, self.onExitJumpHigh), nil)
					   :addState(MovementStates.STATE_JUMP_FALL, 		handler(self, self.onEnterJumpFall), 	handler(self, self.onExecuteJumpFall), 	handler(self, self.onExitJumpFall), nil)
					   :addState(MovementStates.STATE_JUMP_FALL_LAND, 	nil, nil, nil, nil)
					   :setState(MovementStates.STATE_IDLE)
					   :run()
end

function UnitMovementMonitor:update(diff)
	self.m_StateMachine:executeStateProgress(diff)
end

function UnitMovementMonitor:jump()
	local currentState = self.m_StateMachine:getCurrentState()
	release_print(currentState)
	if currentState == MovementStates.STATE_JUMP_HIGH or currentState == MovementStates.STATE_JUMP_FALL then return end
	self.m_StateMachine:setState(MovementStates.STATE_JUMP_HIGH)
end

function UnitMovementMonitor:updateDirection()
	local offset = Controller:getInstance():getHorizonOffset()
	if offset == 0 then return end
	self.m_Direction = offset > 0 and "right" or "left"
	self:getOwner():getPawn():setFlippedX(self.m_Direction == "left" and true or false)
end

function UnitMovementMonitor:updateHorizonOffset(diff, isJumpping)
	local offset = self:getOwner():isControlByPlayer() and self:onControllerMove(diff, isJumpping) or self:onAIMove(diff, isJumpping)
	if math.abs(offset.x) == 0 then return false end
	local finalPos = self:getOwner():getMap():tryFixPosition( self:getOwner(), offset )
	self:getOwner():move(finalPos)
	self:updateDirection()
	return true
end

function UnitMovementMonitor:updateVerticalOffset(diff)
	local offset = { x = 0, y = 0 }
	local currState = self.m_StateMachine:getCurrentState()
	if currState == MovementStates.STATE_JUMP_HIGH then
		self.m_FallSpeed = self.m_FallSpeed * 0.9
		if self.m_FallSpeed < 1 then self.m_StateMachine:setState(MovementStates.STATE_JUMP_FALL) end
	else
		local TotalYOffset = 0
		local calcTime = math.abs(math.modf(self.m_FallSpeed / MAX_FALL_SPEED))
		local extraFallOffset = math.fmod(self.m_FallSpeed , MAX_FALL_SPEED )
		offset.y = -MAX_FALL_SPEED
		while calcTime > 1 do
			local finalPos, hitGround = self:getOwner():getMap():tryFixPosition( self:getOwner(), offset )
			self:getOwner():move(finalPos)
			if hitGround then return true end
			calcTime = calcTime - 1
			return hitGround
		end
		offset.y = extraFallOffset
		local finalPos, hitGround = self:getOwner():getMap():tryFixPosition( self:getOwner(), offset )
		self.m_FallSpeed = self.m_FallSpeed * 1.1
	end
	offset.y = self.m_FallSpeed
	local finalPos, hitGround = self:getOwner():getMap():tryFixPosition( self:getOwner(), offset )
	if hitGround then self.m_FallSpeed = -1 end
	self:getOwner():move(finalPos)
	return hitGround
end

function UnitMovementMonitor:onControllerMove(diff, isJumpping)
	if isJumpping then
		self.m_MoveSpeed = self.m_JumpDirection == "left" and -math.abs(self.m_MoveSpeed) or math.abs(self.m_MoveSpeed)
	else
		local _c = Controller:getInstance()
		self.m_MoveSpeed = self.m_MoveSpeed * SPEED_REDUCTION + (_c and _c:getHorizonOffset() or 0)
		if math.abs(self.m_MoveSpeed) <= 0.1 then self.m_MoveSpeed = 0 end
	end
	return cc.p(self.m_MoveSpeed, 0)
end

function UnitMovementMonitor:onAIMove()
	return cc.p(0, 0)
end


---------------------------------
--	 State Machine Functions   --
---------------------------------
function UnitMovementMonitor:onEnterIdle()
	release_print("onEnterIdle")
end

function UnitMovementMonitor:onExecuteIdle(diff)
	local nextState = nil
	if self:updateHorizonOffset(diff) then nextState = MovementStates.STATE_RUN end
	if not self:updateVerticalOffset(diff) then nextState = MovementStates.STATE_JUMP_FALL end
	if nextState then self.m_StateMachine:setState(nextState) self.m_JumpDirection = self.m_Direction end
end

function UnitMovementMonitor:onExitIdle()

end

function UnitMovementMonitor:onEnterIdleRun()
	release_print("onEnterIdleRun")

end

function UnitMovementMonitor:onExecuteIdleRun(diff)
	self:updateHorizonOffset(diff)
	if not self:updateVerticalOffset(diff) then self.m_StateMachine:setState(MovementStates.STATE_JUMP_FALL) end
end

function UnitMovementMonitor:onExitIdleRun()

end

function UnitMovementMonitor:onEnterRun()
	release_print("onEnterRun")
end

function UnitMovementMonitor:onExecuteRun(diff)
	local nextState = nil
	if not self:updateHorizonOffset(diff) then nextState = MovementStates.STATE_IDLE end
	if not self:updateVerticalOffset(diff) then nextState = MovementStates.STATE_JUMP_FALL end
	if nextState then self.m_StateMachine:setState(nextState) self.m_JumpDirection = self.m_Direction end
end

function UnitMovementMonitor:onExitRun()

end

function UnitMovementMonitor:onEnterJumpHigh()
	release_print("onEnterJumpHigh")
	self.m_FallSpeed = self:getOwner():getBaseAttr("jumpForce")
	self.m_JumpDirection = self.m_Direction
end

function UnitMovementMonitor:onExecuteJumpHigh(diff)
	self:updateHorizonOffset(diff, true)
	self:updateVerticalOffset(diff)
end

function UnitMovementMonitor:onExitJumpHigh()
end

function UnitMovementMonitor:onEnterJumpFall()
	release_print("onEnterJumpFall")
	self.m_FallSpeed = -1
end

function UnitMovementMonitor:onExecuteJumpFall(diff)
	self:updateHorizonOffset(diff, true)
	if self:updateVerticalOffset(diff) then
		local offset = self:getOwner():isControlByPlayer() and self:onControllerMove(diff) or self:onAIMove(diff)
		self.m_StateMachine:setState(math.abs(offset.x) == 0 and MovementStates.STATE_IDLE or MovementStates.STATE_RUN)
	end
end

function UnitMovementMonitor:onExitJumpFall()

end

function UnitMovementMonitor:cleanUpBeforeDelete()
	self.m_StateMachine:stop()
	self.m_StateMachine = nil
end


return UnitMovementMonitor
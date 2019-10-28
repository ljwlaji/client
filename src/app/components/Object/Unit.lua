local Object 			= import("app.components.Object.Object")
local StateMachine 		= import("app.components.StateMachine")
local Controller 		= import("app.views.node.vNodeController")
local Pawn 				= import("app.views.node.vNodePawn")
local Unit 				= class("Unit", Object)

local STATE_IDLE 			= 0
local STATE_IDLE_RUN 		= 1
local STATE_RUN_IDLE  		= 2
local STATE_RUN  			= 3
local STATE_JUMP_HIGH   	= 4
local STATE_JUMP_FALL   	= 5
local STATE_JUMP_FALL_LAND  = 6

local MAX_MOVE_SPEED 		= 7.0
local SPEED_REDUCTION 		= 0.8
local MAX_FALL_SPEED 		= 20
local START_JUMP_FORCE 		= 9
--[[
	Unit Base Attrs

	1. maxHeath
	2. maxMana
	3. baseAttack
	4. baseMagicAttack
	5. baseDefence
	6. baseMagicDefence
	7. baseMoveSpeed
	8. baseJumpForce
]]

-- 关于攀爬 其实就是左右移动偏移值变成了上下移动偏移值
function Unit:onCreate(objType)
	self.m_MoveSpeed = 0
	self.m_FallSpeed = -1
	self.m_Direction = "right"
	self.m_ControlByPlayer = false
	self.m_Alive = true
	self.m_Pawn = Pawn:create():addTo(self)
	self.m_BaseAttrs = {
		maxHealth 				= 1,
		maxMana 				= 1,
		attackPower 			= 1,
		magicAttackPower 		= 1,
		defence 				= 1,
		magicDefence 			= 1,
		moveSpeed				= 7.0,
		jumpForce				= 7,
		attackSpeed 			= 1000,
	}
	self.m_Attrs = {}
	self:setAttrToBase()
	self:setupStateMechine()

	self:regiestCustomEventListenter("onTouchButtonX", function() release_print("onTouchButtonX") end)
	self:regiestCustomEventListenter("onTouchButtonY", function() release_print("onTouchButtonY") end)
	self:regiestCustomEventListenter("onTouchButtonA", function() release_print("onTouchButtonA") end)
	self:regiestCustomEventListenter("onTouchButtonB", handler(self, self.onButtonXPressed))

	Object.onCreate(self, objType)
end

function Unit:onButtonXPressed()
	if not self:isControlByPlayer() then return end
	self:jump()
end

function Unit:onUpdate(diff)
	self.m_StateMachine:executeStateProgress(diff)
	-- module for testting --
	-- end of testting --
	Object.onUpdate(self, diff)
end

function Unit:initAI(AIName)
	local currAITemplate = import(string.format("app.scripts.%s", AIName))
	assert(currAITemplate, "Cannot Find Current AI By Path Named: ["..AIName.."]")
	self:setAI(currAITemplate:create())
end

function Unit:setupStateMechine()
	-- For This StateMachine
	-- It's Just Dealling With Animation For Current Unit
	self.m_StateMachine = StateMachine:create()
	self.m_StateMachine:addState(STATE_IDLE, 			handler(self, self.onEnterIdle), 		handler(self, self.onExecuteIdle), 		handler(self, self.onExitIdle), 	nil)
					   :addState(STATE_IDLE_RUN, 		handler(self, self.onEnterIdleRun), 	handler(self, self.onExecuteIdleRun), 	handler(self, self.onExitIdleRun), 	nil)
					   :addState(STATE_RUN_IDLE, 		nil, nil, nil, nil)
					   :addState(STATE_RUN, 			handler(self, self.onEnterRun), 		handler(self, self.onExecuteRun), 		handler(self, self.onExitRun), 		nil)
					   :addState(STATE_JUMP_HIGH, 		handler(self, self.onEnterJumpHigh), 	handler(self, self.onExecuteJumpHigh), 	handler(self, self.onExitJumpHigh), nil)
					   :addState(STATE_JUMP_FALL, 		handler(self, self.onEnterJumpFall), 	handler(self, self.onExecuteJumpFall), 	handler(self, self.onExitJumpFall), nil)
					   :addState(STATE_JUMP_FALL_LAND, 	nil, nil, nil, nil)
					   :setState(STATE_IDLE)
					   :run()
end

			--------------------
			-- For Attr Issus --
			--------------------

function Unit:setAttrToBase()
	for k, v in pairs(self.m_BaseAttrs) do
		self.m_Attrs[k] = v
	end
	self.m_Attrs["health"] 	= self.m_BaseAttrs["maxHealth"]
	self.m_Attrs["mana"] 	= self.m_BaseAttrs["maxMana"]
end

function Unit:setAlive(alive)
	if alive == self.m_Alive then return end
	self.m_Alive = alive
end

function Unit:isAlive()
	return self.m_Alive
end

function Unit:setBaseAttr(attrName, value)
	assert(self.m_BaseAttrs[attrName])
	self.m_BaseAttrs[attrName] = value
end

function Unit:getBaseAttr(attrName, value)
	assert(self.m_BaseAttrs[attrName])
	return self.m_BaseAttrs[attrName]
end

function Unit:setAttr(attrName, value)
	assert(self.m_Attrs[attrName])
	self.m_Attrs[attrName] = value
end

function Unit:getAttr(attrName)
	assert(self.m_Attrs[attrName])
	return self.m_Attrs[attrName]
end

function Unit:modifyHealth(value)
	if value == 0 then return end
	local currHealth = self:getAttr("health")
	local maxHealth = self:getAttr("maxHealth")
	if value > 0 then
		value = currHealth + value > maxHealth and maxHealth - currHealth or value
	else
		value = currHealth - value < 0 and currHealth or value
	end
	local final = currHealth + value
	if final == 0 then self:justDie() end
	self:getPawn():modifyHealth(final, self:getAttr("maxHealth"))
	self:setAttr("health", final)
end

function Unit:justDie()
	self:setAlive(false)
	-- TODO
	-- CleanUp All Areas
	-- Play Animation
	-- CleanUp All Threats And Targets

	if self:getAI() then self:getAI():onDead() end
end
			-----------------------
			-- End Of Attr Issus --
			-----------------------

			--------------------
			-- For Pawn Issus --
			--------------------


function Unit:setPawn(pawnNode)
	self.m_Pawn = pawnNode
end

function Unit:getPawn()
	return self.m_Pawn
end

			-----------------------
			-- End Of Pawn Issus --
			-----------------------

function Unit:getMoveSpeed()
	return self.m_MoveSpeed
end

function Unit:getMaxMoveSpeed()
	return MAX_MOVE_SPEED
end

function Unit:jump()
	local currentState = self.m_StateMachine:getCurrentState()
	if currentState == STATE_JUMP_HIGH or currentState == STATE_JUMP_FALL then return end
	self.m_StateMachine:setState(STATE_JUMP_HIGH)
end

function Unit:setControlByPlayer(enabled)
	self.m_ControlByPlayer = enabled
end

function Unit:isControlByPlayer()
	return self.m_ControlByPlayer
end

function Unit:updateDirection(offset)
	self.m_Direction = offset.x > 0 and "right" or "left"
	self:getPawn():setFlippedX(self.m_Direction == "left" and true or false)
end

function Unit:updateHorizonOffset(diff)
	local offset = self:isControlByPlayer() and self:onControllerMove(diff) or self:onAIMove(diff)
	if math.abs(offset.x) > 0 then self:updateDirection(offset) end
	local finalPos = self:getMap():tryFixPosition( self, offset )
	self:move(finalPos)
end

function Unit:updateVerticalOffset(diff)
	local offset = { x = 0, y = 0 }
	local currState = self.m_StateMachine:getCurrentState()
	if currState == STATE_JUMP_HIGH then
		self.m_FallSpeed = self.m_FallSpeed * 0.9
		if self.m_FallSpeed < 1 then self.m_StateMachine:setState(STATE_JUMP_FALL) end
	else
		local TotalYOffset = 0
		local calcTime = math.abs(math.modf(self.m_FallSpeed / MAX_FALL_SPEED))
		local extraFallOffset = math.fmod(self.m_FallSpeed , MAX_FALL_SPEED )
		offset.y = -MAX_FALL_SPEED
		while calcTime > 1 do
			local finalPos, hitGround = self:getMap():tryFixPosition( self, offset )
			self:move(finalPos)
			if hitGround then return true end
			calcTime = calcTime - 1
			return hitGround
		end
		offset.y = extraFallOffset
		local finalPos, hitGround = self:getMap():tryFixPosition( self, offset )
		self.m_FallSpeed = self.m_FallSpeed * 1.1
	end
	offset.y = self.m_FallSpeed
	local finalPos, hitGround = self:getMap():tryFixPosition( self, offset )
	if hitGround then self.m_FallSpeed = -1 end
	self:move(finalPos)
	return hitGround
end

function Unit:onControllerMove()
	local _c = Controller:getInstance()
	self.m_MoveSpeed = self.m_MoveSpeed * SPEED_REDUCTION
	self.m_MoveSpeed = self.m_MoveSpeed + (_c and _c:getHorizonOffset() or 0)
	if math.abs(self.m_MoveSpeed) <= 0.1 then self.m_MoveSpeed = 0 end
	return cc.p(self.m_MoveSpeed, 0)
end

function Unit:onAIMove()
	return cc.p(0, 0)
end

function Unit:cleanUpBeforeDelete()
	self.m_StateMachine:stop()
	self.m_StateMachine = nil
	Object.cleanUpBeforeDelete(self)
end


---------------------------------
--	 State Machine Functions   --
---------------------------------
function Unit:onEnterIdle()
	release_print("onEnterIdle")
end

function Unit:onExecuteIdle(diff)
	self:updateHorizonOffset(diff)
	if not self:updateVerticalOffset(diff) then self.m_StateMachine:setState(STATE_JUMP_FALL) end
end

function Unit:onExitIdle()

end

function Unit:onEnterIdleRun()
	release_print("onEnterIdleRun")

end

function Unit:onExecuteIdleRun(diff)
	self:updateHorizonOffset(diff)
	if not self:updateVerticalOffset(diff) then self.m_StateMachine:setState(STATE_JUMP_FALL) end
end

function Unit:onExitIdleRun()

end

function Unit:onEnterRun()
	release_print("onEnterRun")

end

function Unit:onExecuteRun(diff)
	self:updateHorizonOffset(diff)
	if not self:updateVerticalOffset(diff) then self.m_StateMachine:setState(STATE_JUMP_FALL) end
end

function Unit:onExitRun()

end

function Unit:onEnterJumpHigh()
	release_print("onEnterJumpHigh")
	self.m_FallSpeed = START_JUMP_FORCE
end

function Unit:onExecuteJumpHigh(diff)
	self:updateHorizonOffset(diff)
	self:updateVerticalOffset(diff)
end

function Unit:onExitJumpHigh()
end

function Unit:onEnterJumpFall()
	release_print("onEnterJumpFall")
	self.m_FallSpeed = -1
end

function Unit:onExecuteJumpFall(diff)
	self:updateHorizonOffset(diff)
	if self:updateVerticalOffset(diff) then
		local offset = self:isControlByPlayer() and self:onControllerMove(diff) or self:onAIMove(diff)
		self.m_StateMachine:setState(math.abs(offset.x) == 0 and STATE_IDLE or STATE_RUN)
	end
end

function Unit:onExitJumpFall()

end

return Unit

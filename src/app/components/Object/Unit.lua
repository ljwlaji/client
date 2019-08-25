local Object 			= import("app.components.Object.Object")
local Unit 				= class("Unit", Object)
local StateMachine 		= import("app.components.StateMachine")

local STATE_IDLE 			= 0
local STATE_IDLE_RUN 		= 1
local STATE_RUN_IDLE  		= 2
local STATE_RUN  			= 3
local STATE_JUMP_START  	= 4
local STATE_JUMP_HIGH   	= 5
local STATE_JUMP_FALL   	= 6
local STATE_JUMP_FALL_LAND  = 7

function Unit:onCreate()
	self:setupStateMechine()
end

function Unit:onUpdate(diff)
	Object.onUpdate(self, diff)
	self.m_StateMechine:executeStateProgress(diff)
end

function Unit:setupStateMechine()
	self.m_StateMechine = StateMachine:create()
	self.m_StateMechine:addState(STATE_IDLE, 			nil, nil, nil, nil)
					   :addState(STATE_IDLE_RUN, 		nil, nil, nil, nil)
					   :addState(STATE_RUN_IDLE, 		nil, nil, nil, nil)
					   :addState(STATE_RUN, 			nil, nil, nil, nil)
					   :addState(STATE_JUMP_START, 		nil, nil, nil, nil)
					   :addState(STATE_JUMP_HIGH, 		nil, nil, nil, nil)
					   :addState(STATE_JUMP_FALL, 		nil, nil, nil, nil)
					   :addState(STATE_JUMP_FALL_LAND, 	nil, nil, nil, nil)
					   :setState(STATE_IDLE)
					   :run()
end

function Unit:onMovementUpdate()

end

function Unit:cleanUpBeforeDelete()
	self.m_StateMechine:stop()
	self.m_StateMechine = nil
	Object.cleanUpBeforeDelete(self)
end


return Unit

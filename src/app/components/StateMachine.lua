--[[
	状态机
	李经伟

	Sample:
		local MaxFPSTimer	= 0.016

		local STATE_IDLE 	= 0
		local STATE_WALK 	= 1
		local STATE_RUN 	= 2
		local STATE_IN_COMBAT = 3
		local STATE_DYING	= 20
		...

		local Player = player:create()
		Player.onEnterIdle = function(currPlr)
			currPlr.__isInCombat = false
			...
		end

		Player.onExecuteIde = function(currPlr, TimeDiff)
			for k, v in pairs(enemy) do
				if (currPlr:MoveInLineOfSight(v) == ENGAGE_COMBAT) then
					currPlr:EngageWith(v)
					currPlr.sm:setNextState(Player:IsInAttackRange(v) and STATE_IN_COMBAT or STATE_RUN)
					currPlr.__isInCombat = true
					break
				end
			end
			...
		end

		Player.onExitIdle = function(currPlr)
			if currPlr.__isInCombat then
				currPlr:TryShowWeapon()
			end
			...
		end
		
		...

		Player:CleanupAndDelete()
			self.sm = nil
		end

		local sm = StateMechine:new()
		sm:addState(STATE_IDLE, handler(Player, Player.onEnterIdle, handler(Player.onExecuteIdle, handler(Player, Player.onExitIdle), {} )
		sm:addState(...)
		...
		Player.StateMechine = sm
    	Player:schedule(function() Player.StateMechine:executeStateProgress(MaxFPSTimer) end, MaxFPSTimer) --这个方法的时间并不准确
    	Player.StateMechine:run()
]]

local StateMachine = class("StateMachine")

function StateMachine:ctor()
	if self.onCreate then self:onCreate() end
end

function StateMachine:onCreate(context)
	self.states = {}
	self.currStateIndex = nil
	self._running = false
end

--[[
	开始执行当前状态的Execute方法
	如果已经设置Execute方法回调的话
]]
function StateMachine:run()
	self._running = true
	return self
end

--[[
	执行状态
	@diff
		时间间隔
	@return
		nil
]]
function StateMachine:executeStateProgress(diff)
	if not self._running then return end
	local stateInfo = self.states[self.currStateIndex]
	if stateInfo then
		if stateInfo.onExecuteFunc then stateInfo.onExecuteFunc(diff) end
	else
		self._running = false
		error("State Mechine Running With An Invaild Index : "..self.currStateIndex.." !  Auto Terminated !")
	end
	return self
end

--[[
	停止运行当前状态的Execute方法
	如果已经设置Execute方法回调的话
]]
function StateMachine:stop()
	self._running = false
	return self
end
--[[
	获取当前状态
	@return
		int
]]
function StateMachine:getCurrentState()
	return self.currStateIndex
end

--[[
	增加一个状态
	@index
		状态标识符
	@onEnterFunc
		进入状态调用一次
	@onExecuteFunc
		_running = true 且激活之后循环调用
	@onExitFunc
		退出调用一次
	@params
		onExecuteFunc 第一个参数
	@return
		self
]]
function StateMachine:addState(index, onEnterFunc, onExecuteFunc, onExitFunc, params)
	if self.states[index] ~= nil then
		release_print("warning: Redefine StateMachine StateInfo : index = "..index.." !")
	end
	self.states[index] = {}
	self.states[index].onExecuteFunc = onExecuteFunc
	self.states[index].params = params
	self.states[index].onEnterFunc = onEnterFunc
	self.states[index].onExitFunc = onExitFunc
	return self
end

--[[
	进入下一个状态并退出当前状态
]]
function StateMachine:setState(index, restart)
	if not restart and (self.currStateIndex == index or self.states[index] == nil) then 
		return self
	end
	--调用退出方法
	local stateInfo = self.states[self.currStateIndex]
	if stateInfo and stateInfo.onExitFunc then 
		stateInfo.onExitFunc()
	end

	--调用进入方法
	stateInfo = self.states[index]
	if stateInfo and stateInfo.onEnterFunc then stateInfo.onEnterFunc() end
	self.currStateIndex = index

	return self
end



return StateMachine
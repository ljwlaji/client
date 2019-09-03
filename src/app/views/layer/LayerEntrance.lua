local ViewBaseEx 		= import("app.views.ViewBaseEx")
local StateMachine 		= import("app.components.StateMachine")
local Utils				= import("app.components.Utils")
local LayerEntrance 	= class("LayerEntrance", ViewBaseEx)


LayerEntrance.RESOURCE_FILENAME = "res/csb/layer/CSB_Layer_Entrance.csb"
LayerEntrance.RESOURCE_BINDING = {}

local STATE_CHECK_VERSION 	= 1
local STATE_FIRST_INIT 		= 2

function LayerEntrance:onCreate()
	self.m_Children["progressBar"]:setPercent(0)
	self:autoAlgin()
end

function LayerEntrance:onEnterTransitionFinish()
	self:initStateMachine()
	self:enableUpdate(handler(self, self.onUpdate))
end

function LayerEntrance:initStateMachine()
	self.m_SM = StateMachine:create()
							:addState(STATE_CHECK_VERSION, 	handler(self, self.onEnterCheckVersion), handler(self, self.onExecuteCheckVersion), nil, nil)
							:addState(STATE_FIRST_INIT, 	handler(self, self.onEnterFirstInit), handler(self, self.onExecuteirstInit), nil, nil)
							:run()
							:setState(STATE_CHECK_VERSION)
end

function LayerEntrance:onEnterCheckVersion()
	self.m_Children["textState"]:setString("STATE_CHECK_VERSION")
end

function LayerEntrance:onExecuteCheckVersion()
	-- TODO
	-- Check Version
	local versionFileExised = Utils.isFileExisted(Utils.getDownloadCachePath().."res/version")
	if not versionFileExised then self:setState(STATE_FIRST_INIT) return end
end

function LayerEntrance:onEnterFirstInit()
	self.m_Children["textState"]:setString("STATE_FIRST_INIT")
end

function LayerEntrance:onExecuteCheckVersion()
	dump(os.remove(Utils.getDownloadRootPath()))
end

function LayerEntrance:onUpdate(diff)
	self.m_SM:executeStateProgress(diff)
end

function LayerEntrance:setState(state)
	self.m_SM:setState(state)
end




return LayerEntrance
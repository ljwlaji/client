local ViewBaseEx 		= import("app.views.ViewBaseEx")
local StateMachine 		= import("app.components.StateMachine")
local Utils				= import("app.components.Utils")
local LayerEntrance 	= class("LayerEntrance", ViewBaseEx)


LayerEntrance.RESOURCE_FILENAME = "res/csb/layer/CSB_Layer_Entrance.csb"
LayerEntrance.RESOURCE_BINDING = {}

local STATE_CHECK_VERSION 			= 1
local STATE_FIRST_INIT 				= 2
local STATE_REQUEST_NEW_VERSION 	= 3
local STATE_TRY_DOWNLOAD_UPDATES	= 4

local STATE_REQUEST_NEW_VERSION_TIME_OUT = 100

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
							:addState(STATE_CHECK_VERSION, 					handler(self, self.onEnterCheckVersion), 		handler(self, self.onExecuteCheckVersion), 		nil, nil)
							:addState(STATE_FIRST_INIT, 					handler(self, self.onEnterFirstInit), 			handler(self, self.onExecuteFirstInit), 		nil, nil)
							:addState(STATE_REQUEST_NEW_VERSION, 			handler(self, self.onEnterRequestNewVersion), 	handler(self, self.onExecuteRequestNewVersion), nil, nil)
							:addState(STATE_TRY_DOWNLOAD_UPDATES, 			handler(self, self.onEnterTryDownloadUpdates), 	handler(self, self.onExecuteTryDownloadUpdates),nil, nil)
							:addState(STATE_REQUEST_NEW_VERSION_TIME_OUT, 	nil, nil, nil, nil)
							:setState(STATE_CHECK_VERSION)
							:run()
end

function LayerEntrance:onEnterCheckVersion()
	self.m_Children["textState"]:setString("STATE_CHECK_VERSION")
end

function LayerEntrance:onExecuteCheckVersion()
	-- TODO
	-- Check Version
	if not Utils.isFileExisted(Utils.getCurrentResPath().."res/version") then 
		self:setState(STATE_FIRST_INIT) 
		return 
	end
	self:setState(STATE_REQUEST_NEW_VERSION)
end

function LayerEntrance:onEnterFirstInit()
	self.m_Children["textState"]:setString("STATE_FIRST_INIT")
end

function LayerEntrance:onExecuteFirstInit()
	Utils.recursionCopy(Utils.getPackagePath().."res/", Utils.getCurrentResPath().."res/")
    Utils.recursionCopy(Utils.getPackagePath().."src/", Utils.getCurrentResPath().."src/")
    self:setState(STATE_CHECK_VERSION)
end

function LayerEntrance:requestVersionList()
	local url = "http://127.0.0.1/downloads/test.download"
	local xhr = cc.XMLHttpRequest:new()
	xhr.responseType = cc.XMLHTTPREQUEST_RESPONSE_STRING
	xhr:open("GET", url)
	local function onRespone()
	    local responseData = xhr.response
	    responseData = loadstring(responseData) and loadstring(responseData)() or nil
	    if responseData then self:onRequestNewVersionListCallBack(responseData) end
	end
	xhr:registerScriptHandler(onRespone)
	xhr:send()
end

function LayerEntrance:onRequestNewVersionListCallBack(RemoteVersionInfo)
	if self:getState() ~= STATE_REQUEST_NEW_VERSION and self:getState() ~= STATE_REQUEST_NEW_VERSION_TIME_OUT then return end
	local LocalVersionInfo = Utils.getVersionInfo()
	if not LocalVersionInfo then
		self.m_Children["textState"]:setString("获取本地版本信息失败, 尝试修复客户端.")
		return
	end
	LocalVersionInfo = LocalVersionInfo.version
	local DownloadResList = {}
	for k, v in pairs(RemoteVersionInfo) do
		if k > LocalVersionInfo then
			table.insert(DownloadResList, { ver = k, url = v })
		end
	end
	table.sort(DownloadResList, function(a, b) return a.ver < b.ver end)
	self.DownloadResList = DownloadResList
	self:setState(STATE_TRY_DOWNLOAD_UPDATES)
end

function LayerEntrance:onEnterRequestNewVersion()
	release_print("onEnterRequestNewVersion")
	self.m_MaxRetryTime = self.m_MaxRetryTime and self.m_MaxRetryTime - 1 or 3
	self.m_Children["textState"]:setString("STATE_REQUEST_NEW_VERSION RetryTimeLeft : "..self.m_MaxRetryTime)
	if self.m_MaxRetryTime < 0 then
		-- Break Loop
		self.m_Children["textState"]:setString("STATE_REQUEST_NEW_VERSION RetryTimeLeft : TimeOut")
		self:setState(STATE_REQUEST_NEW_VERSION_TIME_OUT)
		return
	end

	self:requestVersionList()
	self.m_WaitTime = 0
end

function LayerEntrance:onExecuteRequestNewVersion(diff)
	self.m_WaitTime = self.m_WaitTime + diff
	if self.m_WaitTime > 10000 then
		self.m_WaitTime = 0
		self:setState(STATE_REQUEST_NEW_VERSION, true)
	end
end

function LayerEntrance:onEnterTryDownloadUpdates()

end

function LayerEntrance:onExecuteTryDownloadUpdates(diff)

end

function LayerEntrance:onUpdate(diff)
	self.m_SM:executeStateProgress(diff)
end

function LayerEntrance:setState(...)
	self.m_SM:setState(...)
end

function LayerEntrance:getState()
	return self.m_SM:getCurrentState()
end



return LayerEntrance
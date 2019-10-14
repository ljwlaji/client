local ViewBaseEx 		= import("app.views.ViewBaseEx")
local StateMachine 		= import("app.components.StateMachine")
local Utils				= import("app.components.Utils")
local LayerEntrance 	= class("LayerEntrance", ViewBaseEx)


LayerEntrance.RESOURCE_FILENAME = "res/csb/layer/CSB_Layer_Entrance.csb"
LayerEntrance.RESOURCE_BINDING = {}

local RemoteVersionFile = "http://120.78.223.173/AllUpdates"
local RemoteUpdatePath = "http://120.78.223.173/downloads/"
local STATE_CHECK_VERSION 			= 1
local STATE_FIRST_INIT 				= 2
local STATE_REQUEST_NEW_VERSION 	= 3
local STATE_TRY_DOWNLOAD_UPDATES	= 4
local STATE_TRY_UNCOMPARESS			= 5

local STATE_REQUEST_NEW_VERSION_TIME_OUT = 100

function LayerEntrance:onCreate()
	release_print("OnCreate")
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
							:addState(STATE_TRY_UNCOMPARESS, 				handler(self, self.onEnterTryUncomparess), 		handler(self, self.onExecuteUncompress),		nil, nil)
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
	-- do return end
    release_print("检查是否需要初始化...")
	if not Utils.isFileExisted(Utils.fixDirByPlatform(Utils.getCurrentResPath().."res/version")) then 
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
    release_print("初始化完毕...")
    self:setState(STATE_CHECK_VERSION)
end

						------------------------------
						--		请求版本列表相关		--
						------------------------------

function LayerEntrance:requestVersionList()
	release_print("requestVersionList...")
	local xhr = cc.XMLHttpRequest:new()
	xhr.responseType = cc.XMLHTTPREQUEST_RESPONSE_STRING
	xhr:open("GET", RemoteVersionFile)
	local function onRespone()
		if xhr.readyState~=4 or xhr.status~=200 then release_print("http代码返回 : "..xhr.status) return end
	    local responseData = "return "..xhr.response
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
	release_print(string.format("本地版本: [%s]", LocalVersionInfo))
	local DownloadResList = {}
	for versionID, versionInfo in pairs(RemoteVersionInfo) do
		release_print(string.format("正在比对目标版本 [%s] ", versionID))
		if versionID > LocalVersionInfo then
			release_print(string.format("本地版本小于目标版本 [%s] 加入更新列表....", versionID))
			table.insert(DownloadResList, { versionID = versionID, updateInfo = versionInfo })
		end
	end
	table.sort(DownloadResList, function(a, b) return a.versionID < b.versionID end)
	self.DownloadResList = DownloadResList
	self:setState(STATE_TRY_DOWNLOAD_UPDATES)
end

function LayerEntrance:onEnterRequestNewVersion()
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

						------------------------------
						--		请求版本列表结束		--
						------------------------------

function LayerEntrance:onEnterTryDownloadUpdates()
	self.m_Children["textState"]:setString("STATE_TRY_DOWNLOAD_UPDATES")
	import("app.components.LFS").createDir(Utils.getDownloadRootPath())
	import("app.components.LFS").createDir(Utils.getDownloadCachePath())
	
	for k, v in pairs(self.DownloadResList) do
		v.DownloadUrl 	= string.format("%s%s.FCZip", RemoteUpdatePath, v.versionID)
		--添加下载任务
		release_print(string.format("添加下载任务: [%s]", v.DownloadUrl))
	end
end

function LayerEntrance:onExecuteTryDownloadUpdates(diff)
	--正在进行下载任务
	if self.CurrentTask then
		self:onDownloadProgress()
		return 
	end
	release_print("尝试添加新的下载任务...")

	--没有正在进行的下载任务 尝试添加新任务
	if not self:tryStartNewTask() then
		release_print("没有新的下载任务 停止下载")
		self.m_SM:setState(STATE_TRY_UNCOMPARESS)
	end
end

function LayerEntrance:tryStartNewTask()
	self.downloadIndex = self.downloadIndex or 1 --下载索引
	local UpdateMgr = cc.UpdateMgr:getInstance()
	if UpdateMgr:isStopped() then
		if self.CurrentTask == nil and self.downloadIndex <= #self.DownloadResList then
			self.CurrentTask = self.DownloadResList[self.downloadIndex]
			local path = Utils.getDownloadCachePath()..self.CurrentTask.versionID..".FCZip"
			release_print("添加新任务 : "..path)
			self.downloadIndex = self.downloadIndex + 1
			UpdateMgr:start(self.CurrentTask.DownloadUrl, path)
			return true
		end
		return false
	end
	assert(false)
end

function LayerEntrance:onDownloadProgress()
	local UpdateMgr 		= cc.UpdateMgr:getInstance()
	local nowDownloaded 	= UpdateMgr:getDownloadedSize()
	local totalToDownload 	= UpdateMgr:getTotalSize()
	release_print(string.format("%s/%s", nowDownloaded, totalToDownload))
	if UpdateMgr:isStopped() then
		release_print("进入验证解压阶段...")
		--验证/解压 等后续处理
		self.CurrentTask = nil
	end
end

function LayerEntrance:onEnterTryUncomparess()
	self.m_Children["textState"]:setString("STATE_TRY_UNCOMPARESS")
end

function LayerEntrance:onExecuteUncompress()
	if #self.DownloadResList == 0 then
		self.m_SM:stop()
		return
	end
	self.uncompressIndex = self.uncompressIndex or 1
	self.m_Children["textState"]:setString(string.format("Uncompress %d / %d", self.uncompressIndex, #self.DownloadResList))
	local currTask = self.DownloadResList[self.uncompressIndex]
	local path = Utils.getDownloadCachePath()..currTask.versionID..".FCZip"
	release_print(string.format("正在解压: [%s] To [%s]", path, Utils.getCurrentResPath()))
	cc.ZipReader.uncompress(path, Utils.getCurrentResPath())
	Utils.updateVersion(currTask)
	self.uncompressIndex = self.uncompressIndex + 1
	if self.uncompressIndex >= #self.DownloadResList then
		self.m_SM:stop()
		release_print("All Done!")
	end
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
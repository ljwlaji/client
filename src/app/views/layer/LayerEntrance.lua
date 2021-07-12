local ViewBaseEx 		= import("app.views.ViewBaseEx")
local StateMachine 		= import("app.components.StateMachine")
local Utils				= import("app.components.Utils")
local LayerEntrance 	= class("LayerEntrance", ViewBaseEx)


LayerEntrance.RESOURCE_FILENAME = "res/csb/layer/CSB_Layer_Entrance.csb"
LayerEntrance.RESOURCE_BINDING = {}

local DevMode 								= import("app.ShareDefine"):isDevMode()
local RemoteVersionFile 					= "http://vv2.azerothcn.com/AllUpdates"
local RemoteUpdatePath 						= "http://vv2.azerothcn.com/downloads/"
local STATE_CHECK_VERSION 					= 1
local STATE_FIRST_INIT 						= 2
local STATE_REQUEST_NEW_VERSION 			= 3
local STATE_TRY_DOWNLOAD_UPDATES			= 4
local STATE_REQUEST_NEW_VERSION_TIME_OUT 	= 6


function LayerEntrance:onCreate(onFinishedCallBack)
	release_print("OnCreate")
	self.onFinishedCallBack = onFinishedCallBack
	self.m_Children["progressBar"]:setPercent(0)
	self:autoAlgin()
	self.MD5 = cc.MD5:create()
end

function LayerEntrance:onEnterTransitionFinish()
	release_print("onEnterTransitionFinish")
	self:initStateMachine()
end

function LayerEntrance:initStateMachine()
	-- 如果是开发模式 则直接进入游戏
	self.m_SM = StateMachine:create()
							:addState(STATE_CHECK_VERSION, 					handler(self, self.onEnterCheckVersion), 		handler(self, self.onExecuteCheckVersion), 		nil, nil)
							:addState(STATE_FIRST_INIT, 					handler(self, self.onEnterFirstInit), 			handler(self, self.onExecuteFirstInit), 		nil, nil)
							:addState(STATE_REQUEST_NEW_VERSION, 			handler(self, self.onEnterRequestNewVersion), 	handler(self, self.onExecuteRequestNewVersion), nil, nil)
							:addState(STATE_TRY_DOWNLOAD_UPDATES, 			handler(self, self.onEnterTryDownloadUpdates), 	handler(self, self.onExecuteTryDownloadUpdates),nil, nil)
							:addState(STATE_REQUEST_NEW_VERSION_TIME_OUT, 	nil, nil, nil, nil)
							:setState(STATE_CHECK_VERSION)
							:run()
	cc.Node.onUpdate(self, handler(self, self.onUpdate))
end

function LayerEntrance:onEnterCheckVersion()
	self.m_Children["textState"]:setString("STATE_CHECK_VERSION")
end

function LayerEntrance:onExecuteCheckVersion()
    release_print("检查是否需要初始化...")
	if not Utils.isFileExisted(Utils.getCurrentResPath().."res/version") then 
		self:setState(STATE_FIRST_INIT) 
		return 
	end
	-- in DevMode we skip the version update progress
	if DevMode == true then release_print("开发模式 跳过更新直接进入游戏") self:enterGame() return end
	self:setState(STATE_REQUEST_NEW_VERSION)
end

function LayerEntrance:onEnterFirstInit()
	self.m_Children["textState"]:setString("STATE_FIRST_INIT")
end

function LayerEntrance:onExecuteFirstInit()
    Utils.copyFile(Utils.getPackagePath().."res/version", Utils.getCurrentResPath().."res/version")
    Utils.copyFile(Utils.getPackagePath().."res/datas.db", Utils.getCurrentResPath().."res/datas.db")
    -- release_print("初始化完毕...")
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
	Utils.createDirectory(Utils.getDownloadRootPath())
	Utils.createDirectory(Utils.getDownloadCachePath())
	
	for k, v in pairs(self.DownloadResList) do
		v.DownloadUrl 	= string.format("%s%s.FCZip", RemoteUpdatePath, v.versionID)
		release_print(string.format("添加下载任务: [%s]", v.DownloadUrl))
	end
	self.m_Children["progressBar"]:setPercent(0)
end

function LayerEntrance:onExecuteTryDownloadUpdates(diff)
	--正在进行下载任务
	if self:getCurrentTask() then
		self:onDownloadProgress()
		return 
	end
	--没有正在进行的下载任务 尝试添加新任务
	if not self:tryStartNewTask() then
		self:enterGame()
	end
end

function LayerEntrance:tryStartNewTask()
	self.downloadIndex = self.downloadIndex or 1 --下载索引
	local UpdateMgr = cc.UpdateMgr:getInstance()
	if UpdateMgr:isStopped() then
		if self:getCurrentTask() == nil and self.downloadIndex <= #self.DownloadResList then
			self:setCurrentTask(self.DownloadResList[self.downloadIndex])
			local path = Utils.getDownloadCachePath()..self:getCurrentTask().versionID..".FCZip"
			release_print("添加新任务 : "..path)
			self.downloadIndex = self.downloadIndex + 1
			UpdateMgr:start(self:getCurrentTask().DownloadUrl, path)
			return true
		end
		return false
	end
	assert(false)
end

function LayerEntrance:getMD5FromFile(path)
	local file = io.open(path, "rb")
	local content = file:read("*all")
	file:close()
	self.MD5:update(content)
	return self.MD5:getString()
end

function LayerEntrance:onDownloadProgress()
	local UpdateMgr 		= cc.UpdateMgr:getInstance()
	local nowDownloaded 	= UpdateMgr:getDownloadedSize()
	local totalToDownload 	= UpdateMgr:getTotalSize()
	release_print(string.format("%s/%s", nowDownloaded, totalToDownload))
	self.m_Children["progressBar"]:setPercent(nowDownloaded / totalToDownload * 100)
	if UpdateMgr:isStopped() then
		--验证/解压 等后续处理
		self:handleUpdateFiles()
		self:setCurrentTask(nil)
	end
end

function LayerEntrance:handleUpdateFiles()
	local zipFilePath = Utils.getDownloadCachePath()..self:getCurrentTask().versionID..".FCZip"
	local tempDir = Utils.getDownloadCachePath().."temp/"
	cc.ZipReader.uncompress(zipFilePath, tempDir)
	local needCheck = {}
	local allPassed = true

	for k, v in pairs(self:getCurrentTask()["updateInfo"]["FileList"]) do
		if self:getMD5FromFile(tempDir..v.Dir) ~= v.MD5 then
			allPassed = false
			release_print(tempDir..v.Dir)
			dump(v, "文件MD5检测失败: ")
			break
		end
	end

	-- 检测不通过
	if not allPassed then
		self.m_Children["textState"]:setString("FILE_MD5_CHECK_FAILED")
		self.m_SM:stop()
		return 
	end
	-- 文件全部检测通过
	-- 把临时文件复制到正式目录
	for k, v in pairs(self:getCurrentTask()["updateInfo"]["FileList"]) do 
		local oldDir = string.format("%s/%s", tempDir, v.Dir)
		Utils.copyFile(oldDir, string.format("%s/%s", Utils.getCurrentResPath(), v.Dir ))
		os.remove(oldDir)
	end
end

function LayerEntrance:setCurrentTask(task)
	self.m_task = task
end

function LayerEntrance:getCurrentTask()
	return self.m_task
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

function LayerEntrance:enterGame()
	release_print("enterGame")
	if self.MD5 then self.MD5:desotry() self.MD5 = nil end
	self.m_SM:stop()
	dump(Utils.getVersionInfo(), "本地版本信息: ")
	self:runSequence(cc.DelayTime:create(1), cc.CallFunc:create(function() self.onFinishedCallBack() self:removeFromParent() end))
end

return LayerEntrance
local AssetsMgr 		= class("AssetsMgr")
local Utils				= import("app.components.Utils")
local ShareDefine 		= import("app.ShareDefine")

AssetsMgr.instance = nil

local ERROR_CODES = ShareDefine:getDownloadErrorCodes()
--[[
	UpdateMgr:
		start(): Will Create a download thread if need
		stop():	Will join the download thread and destory it
		pause() just pause download progress
		resume() just resume download progress

	AssetsMgr: 业务流程
		1. 压入任务
			1. 排序任务
		2. 开始任务
			1. 任务进度查询
			2. 停止/暂停任务
			3. 任务完成回调
			4. 如果任务失败 则回栈 抛出异常
			5. 如果任务完成 则丢弃
		3. 停止
]]
function AssetsMgr:getInstance()
	if not AssetsMgr.instance then
		AssetsMgr.instance = AssetsMgr:create()
	end
	return AssetsMgr.instance
end

function AssetsMgr:ctor()
	assert(not AssetsMgr.instance, "This is a singleton class, don't construct it twice!")
	self:init()
end

function AssetsMgr:init()
	self.m_tasks = {}
	self.m_totalDownloadTime = 0
	self.m_Stopped = true
	self.MD5 = cc.MD5:create()
end

function AssetsMgr:pushTask(task, pushFront)
	assert(not self.m_tasks[taskId], "Try Add Duplicate Task Id ["..tostring(taskId).."]")
	table.insert(self.m_tasks, pushFront and 1 or #self.m_tasks, task)
end

function AssetsMgr:sortTask(sortFunc)
	table.sort(self.m_tasks, sortFunc)
	return self
end

function AssetsMgr:flushTask()
	self.m_tasks = {}
end

function AssetsMgr:getDownloadSize()
	return UpdateMgr:GetDownloadedSizeDisplay(), UpdateMgr:GetTotalSizeDisplay()
end

function AssetsMgr:tryStartNewTask()
	if #self.m_tasks == 0 then return false end
	self.m_CurrentTask = table.remove(self.m_tasks, 1)
	self.m_Stopped = false
	self.m_totalDownloadTime = 0
	return true
end

function AssetsMgr:start(onSuccess, onFailed, onProgress, onNewTaskStart)
	self.m_Stopped = false
	self.m_onCompletedCallback = onSuccess
	self.m_onFailedCallback = onFailed
	self.m_onProgressCallback = onProgress
	self.m_onNewTaskStartCallback = onNewTaskStart
end

function AssetsMgr:onUpdate()
	if self.m_CurrentTask then -- 已有下载的情况
		if not UpdateMgr:isStopped() then -- 正在下载中
			if self.m_onProgressCallback then self.m_onProgressCallback() end
			return
		end 
		-- 下载完成
		local errCode = UpdateMgr:getLastError()
		if errCode == ERROR_CODES.NO_ERROR then
			-- 下载过程未出错 检测md5
			if not self:checkDownloadFileVailed() then
				errCode = ERROR_CODES.MD5_CHECK_FAILED
			end
		end
		if errCode ~= ERROR_CODES.NO_ERROR then
			self:pushTask(self.m_CurrentTask, true) --把失败的任务重新入栈 由外部决定该任务去留
			if self.m_onFailedCallback then self.m_onFailedCallback(errCode) end
			self:stop()
		end
		self.m_CurrentTask = nil
	else --没有正在进行中的任务
		if self:tryStartNewTask() then --开启新任务
			if self.m_onNewTaskStartCallback then self.m_onNewTaskStartCallback() end
		else --全部任务完成
			if self.m_onCompletedCallback then self.m_onCompletedCallback() end
			self:stop()
		end
	end
end

function AssetsMgr:stop()
	self.m_Stopped = true
	if not UpdateMgr:isStopped() then UpdateMgr:stop() end
	return self
end

function AssetsMgr:pause()
	UpdateMgr:pause()
	return self
end

function AssetsMgr:resume()
	UpdateMgr:resume()
	return self
end

function AssetsMgr:destory()
	self.MD5:destory()
	self.MD5 = nil
	--[[
		This Act won't desotry the UpdateMgr itself,
		This Act will destory the workThread of the UpdateMgr only,
		The workThread will be created when the next startWithTask has been called ^^
	]]
	UpdateMgr:terminate()
	return self
end

function AssetsMgr:onUpdate(diff)
	if self.m_Stopped then return end
	self:onUpdate()\
	self.m_totalDownloadTime = self.m_totalDownloadTime + diff
end


function AssetsMgr:getMD5FromFile(path)
	local file = io.open(path, "rb")
	local content = file:read("*all")
	file:close()
	self.MD5:update(content)
	return self.MD5:getString()
end

function AssetsMgr:checkDownloadFileVailed()
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



return AssetsMgr:getInstance()
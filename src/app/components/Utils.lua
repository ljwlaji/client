local LFS 		= import("app.components.Lfs")
local LFile 	= import("app.components.LFile")
local Utils 	= class("Utils")


function Utils.fixDirByPlatform(str)
	str = string.gsub(str, "\\\\", "\\")
	str = string.gsub(str, "//", "/")
	if device.platform == "windows" then
		str = string.gsub(str, "/", "\\")
	else
		str = string.gsub(str, "\\", "/")
	end
	return str
end

local FileUtils 	= cc.FileUtils:getInstance()
local writeblePath 	= FileUtils:getWritablePath()
local DownloadPath  = Utils.fixDirByPlatform(writeblePath.."Download/Cache/")

function Utils.getDownloadPath()
	return DownloadPath
end

function Utils.createPath(RootFile, destPath)
	for k, v in pairs(RootFile:subFiles()) do
		if v:isDir() then
			local finalPath = destPath..v:getPath().."/"
			LFS.createDir(finalPath)
			release_print("createPath : "..finalPath)
			Utils.createPath(v, finalPath )
		end
	end
end

function Utils.dirCopy(RootFile, rootPath, destPath, middlePath)
	for k, v in pairs(RootFile:subFiles()) do
		if v:isDir() then
			local subDirs = rootPath
			Utils.dirCopy(v, rootPath, destPath, middlePath..v:getPath().."/")
		else
			-- dump(table.concat(middlePath, "/"))
			local currPath = middlePath.."/"..v:getPath()
			local currDestPath = destPath..currPath
			local dest = io.open(currDestPath)
			if dest then dest:close() os.remove(currDestPath) end
			Utils.bCopyFile(rootPath..currPath, currDestPath)
		end
	end
end

function Utils.recursionCopy(srcPath, destPath)
	-- TODO
	-- 生成所有目标目录的信息
	local dirs = string.split(destPath, "\\")
	local currPath = ""
	for k, v in pairs(dirs) do
		if v ~= "" then 
			currPath = Utils.fixDirByPlatform(currPath..v.."/")
			release_print("Try Create Path : "..currPath.." "..( LFS.createDir(currPath) and "Successed" or "Failed" ).."!")
		end
	end
	local RootFile = LFS.getAllFilesForPath(srcPath, RootFile)
	Utils.createPath(RootFile, destPath)
	Utils.dirCopy(RootFile, RootFile:getPath(), destPath, "")
end

function Utils.bCopyFile(srcPath, destPath)
	local src = io.open(srcPath,"rb")
	if not src then return false end
	local dest = io.open(destPath)
	if dest then dest:close() os.remove(destPath) end
	local len = src:seek("end")
	src:seek("set", 0)
	local data = src:read(len)
	dest = io.open(destPath,"wb")
	dest:write(data,len)
	src:close()
	dest:close()
end


return Utils
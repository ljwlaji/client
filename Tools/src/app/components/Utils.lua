local LFS 		= import("app.components.Lfs")
local Utils 	= class("Utils")

function Utils.fixDirByPlatform(str)
	str = string.gsub(str, "\\\\", "\\")
	str = string.gsub(str, "//", "/")
	return string.gsub(str, "/", "\\")
end

local FileUtils 			= cc.FileUtils:getInstance()
local writeblePath 			= FileUtils:getWritablePath()
local pointerPath 			= "res/packagePointer"
local currentResourcePath	= Utils.fixDirByPlatform(writeblePath).. "virtualDir/"
local DownloadRootPath  	= Utils.fixDirByPlatform(writeblePath.."Download/")
local DownloadCachePath  	= Utils.fixDirByPlatform(DownloadRootPath.."Cache/")

function Utils.getCurrentResPath()
	return currentResourcePath
end

function Utils.isFileExisted(path)
	return FileUtils:isFileExist(path)
end

function Utils.getDownloadRootPath()
	return DownloadRootPath
end

function Utils.getDownloadCachePath()
	return DownloadCachePath
end

function Utils.createPath(RootFile, destPath)
	for k, v in pairs(RootFile:subFiles()) do
		if v:isDir() then
			local finalPath = destPath..v:getPath().."/"
			LFS.createDir(finalPath)
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
	destPath = string.gsub(destPath, "\\", "/")
	local dirs = string.split(destPath, "/")
	local currPath = ""
	for k, v in pairs(dirs) do
		if k == 1 then
			currPath = v
		elseif v ~= "" then 
			currPath = Utils.fixDirByPlatform(currPath.."/"..v)
			release_print("Try Create Path : "..currPath.." "..( LFS.createDir(currPath) and "Successed" or "Failed" ).."!")
		end
	end
	local RootFile = LFS.getAllFilesForPath(srcPath)
	Utils.createPath(RootFile, destPath)
	Utils.dirCopy(RootFile, RootFile:getPath(), destPath, "")
end

function Utils.bCopyFile(sourcefile, destinationfile)
	local read_file =""
	local write_file=""
	local temp_content ="";
	read_file = io.open(sourcefile,"rb")
	if not read_file then
		release_print("Failed To Read File : "..sourcefile)
	else
		temp_content = read_file:read("*all")
		write_file = io.open(destinationfile,"wb")
		write_file:write(temp_content)
		read_file:close()
		write_file:close()
	end
end

function Utils.getVersionInfo()
	local file = io.open(Utils.getCurrentResPath().."res/version","r")
	local content = file:read("*a")
	file:close()
	return loadstring("return "..content)()
end

function Utils.TableToString(table)
	local data = "{"
	for k, v in pairs(table) do
		if type(v) ~= "function" then
			local vk = type(k) == "string" and '["'..k..'"]' or "["..k.."]"
			if type(v) == "table" then
				data = data..vk.."="..Utils.TableToString(v)..","
			else
				if type(v) == "string" then
					-- if v == "\n" then v = "\\n" end
					data = data..vk.."="..'"'..v..'"'..","
				else
					data = data..vk.."="..v..","
				end
			end
		end
	end

	data = string.sub(data, 1, string.len(data) - 1)
	data = data.."}"
	return data
end

function Utils.updateVersion(versionTable)
	local Info = versionTable.updateInfo
	local fileWrite = io.open(Utils.getCurrentResPath().."res/version","w")
	fileWrite:write(Utils.TableToString({
		Date 		= Info.Date,
		firstCommit = Info.commitBase,
		lastCommit 	= Info.commitLast,
		version 	= versionTable.versionID
	}))
	fileWrite:close()
end

-- function Utils.bCopyFile(srcPath, destPath)
-- 	local src = io.open(srcPath,"rb")
-- 	if not src then return false end
-- 	local dest = io.open(destPath)
-- 	if dest then dest:close() os.remove(destPath) end
-- 	local len = src:seek("end")
-- 	src:seek("set", 0)
-- 	local data = src:read(len)
-- 	dest = io.open(destPath,"wb")
-- 	dest:write(data,len)
-- 	src:close()
-- 	dest:close()
-- end


if not Utils.getPackagePath then
    if FileUtils:isFileExist(Utils.getCurrentResPath()..pointerPath) then
        os.remove(Utils.getCurrentResPath()..pointerPath)
        release_print("================Pointer In WriteblePath Removed!===============")
    end
    local path = string.gsub(FileUtils:fullPathForFilename(pointerPath), pointerPath, "")
    Utils.getPackagePath = function() return path end
    dump(Utils.getPackagePath(), "PackagePath : ")
end


return Utils
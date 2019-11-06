local Utils 	= class("Utils")

local FileUtils 			= cc.FileUtils:getInstance()
local writeblePath 			= FileUtils:getWritablePath()
local pointerPath 			= "res/packagePointer"
local currentResourcePath 	= (device.platform == "windows" or device.platform == "mac") and writeblePath .. "virtualDir/" or writeblePath
local DownloadRootPath  	= writeblePath.."Download/"
local DownloadCachePath  	= DownloadRootPath.."Cache/"

function Utils.getFilePathFromString(path)
	return string.gsub(path, string.match(path, ".+/(.+)"), "")
end

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

function Utils.createDirectory(currentDirectoryPath)
	FileUtils:createDirectory(currentDirectoryPath)
end

function Utils.getVersionInfo()
	local file = io.open(Utils.getCurrentResPath().."res/version","rb")
	local content = file:read("*a")
	file:close()
	return loadstring("return "..content)()
end

function Utils.copyFile(src, dest)
	Utils.createDirectory(Utils.getFilePathFromString(dest))
	FileUtils:copyFile(src, dest)
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
	local fileWrite = io.open(Utils.getCurrentResPath().."res/version", "wb")
	fileWrite:write(Utils.TableToString({
		Date 		= Info.Date,
		firstCommit = Info.commitBase,
		lastCommit 	= Info.commitLast,
		version 	= versionTable.versionID
	}))
	fileWrite:close()
end

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
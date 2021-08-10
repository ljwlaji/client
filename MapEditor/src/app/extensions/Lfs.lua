-- local Utils = import("app.components.Utils")
local LFile = require("app.extensions.LFile")
local LFS = class("LFS")


local function fixDirByPlatform(str)
	str = string.gsub(str, "\\\\", "\\")
	str = string.gsub(str, "//", "/")
	if device.platform == "windows" then
		str = string.gsub(str, "/", "\\")
	else
		str = string.gsub(str, "\\", "/")
	end
	return str
end

function LFS.getAllFilesForPath(rootPath, parentFile)
	if not parentFile then 
		parentFile = LFile:create() 
		parentFile:setPath(rootPath)
		parentFile:setAttr("directory")
	end
    for entry in lfs.dir(rootPath) do
        if entry ~='.' and entry ~= '..' then
            local path = fixDirByPlatform(string.format("%s/%s", rootPath, entry))
            local attr = lfs.attributes(path)
        	local tempFile = LFile:create()
        	tempFile:setPath(entry)
            if (attr.mode == "directory") then 
            	tempFile:setAttr(attr.mode) 
            	LFS.getAllFilesForPath(path, tempFile) 
            end
            parentFile:addSubFile(tempFile)
        end
    end

    return parentFile
end

function LFS.currentdir()
	return _G.lfs.currentdir()
end

function LFS.createDir(path)
	return _G.lfs.mkdir(path)
end

return LFS
-- local Utils = import("app.components.Utils")
local LFile = import("app.components.LFile")
local LFS = class("LFS")

function LFS.getAllFilesForPath(rootPath, parentFile)
	if not parentFile then 
		parentFile = LFile:create() 
		parentFile:setPath(rootPath)
		parentFile:setAttr("directory")
	end
    for entry in lfs.dir(rootPath) do
        if entry ~='.' and entry ~= '..' then
            local path = string.format("%s/%s", rootPath, entry)
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
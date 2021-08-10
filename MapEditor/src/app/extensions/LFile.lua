local LFile = class("LFile")



function LFile:ctor()
	self.m_Attr = "unknow"
	self.m_SubFiles = {}
	self.m_CurrentDir = ""
	self.m_TotalFileCount = nil
	self.m_Parent = nil
end

function LFile:isDir()
	return self.m_Attr == "directory"
end

function LFile:subFiles()
	return self.m_SubFiles
end

function LFile:setParent(LFile)
	self.m_Parent = LFile
end

function LFile:setAttr(attr)
	self.m_Attr = attr
end

function LFile:setPath(dir)
	self.m_CurrentDir = dir
end

function LFile:getPath()
	return self.m_CurrentDir
end

function LFile:getFullPath()
	local upperDir = self.m_Parent and self.m_Parent:getFullPath().."/" or nil
	return (upperDir or "")..self.m_CurrentDir
end

function LFile:addSubFile(file)
	table.insert(self.m_SubFiles, file)
	file:setParent(self)
end

function LFile:_getFileCount()
	local count = 0
	for k, v in pairs(self:subFiles()) do
		if v:isDir() then
			count = count + v:_getFileCount()
		else
			count = count + 1
		end
	end
	return count
end

function LFile:getFileCount()
	if not self.m_TotalFileCount then
		self.m_TotalFileCount = self:isDir() and 1 or self:_getFileCount()
	end
	return
end


return LFile
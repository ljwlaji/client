local LFile = class("LFile")



function LFile:ctor()
	self.m_Attr = "unknow"
	self.m_SubFiles = {}
	self.m_CurrentDir = ""
end

function LFile:isDir()
	return self.m_Attr == "directory"
end

function LFile:subFiles()
	return self.m_SubFiles
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

function LFile:addSubFile(file)
	table.insert(self.m_SubFiles, file)
end


return LFile
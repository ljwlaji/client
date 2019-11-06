local WindowMgr = class("WindowMgr")

WindowMgr.instance = nil

function WindowMgr:ctor()
	self.m_Windows = {}
end

function WindowMgr:getInstance()
	if not WindowMgr.instance then
		WindowMgr.instance = WindowMgr:create()
	end
	return WindowMgr.instance
end

function WindowMgr:createWindow(path, ...)
	local template = import(path)
	if true == rawget(template, "DisableDuplicateCreation") then
		local currentWindow = self.m_Windows[path]
		if currentWindow and currentWindow.onReset then
			currentWindow:onReset(...)
		end
	end
	local window = template:create(...)
	self.m_Windows[path] = window
	return window
end

return WindowMgr:getInstance()
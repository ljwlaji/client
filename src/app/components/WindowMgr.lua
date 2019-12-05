local WindowMgr 	= class("WindowMgr")
local ShareDefine 	= import("app.ShareDefine")

WindowMgr.instance 	= nil

function WindowMgr:ctor()
	self.m_Windows = {}
end

function WindowMgr:getInstance()
	if not WindowMgr.instance then
		WindowMgr.instance = WindowMgr:create()
	end
	return WindowMgr.instance
end

function WindowMgr:findWindowIndexByClassName(className)
	local ret = nil
	local index = nil
	for i=1, #self.m_Windows do
		if self.m_Windows[i].__cname == className then
			ret = self.m_Windows[i]
			index = i
			break
		end
	end
	return ret, index
end

function WindowMgr:removeWindow(window)
	for i=1, #self.m_Windows do
		if self.m_Windows[i] == window then
			table.remove(self.m_Windows, i)
			break
		end
	end
	self:sortZOrder()
end

function WindowMgr:sortZOrder()
	for i=1, #self.m_Windows do
		self.m_Windows[i]:setLocalZOrder(ShareDefine.getZOrderByType("ZORDER_WINDOW_START") + i)
	end
end

function WindowMgr:createWindow(path, ...)
	local template = import(path)
	if rawget(template, "DisableDuplicateCreation") == true and rawget(template, "inDisplay") then 
        print("\nModule <"..template.__cname.."> Was Disabled For Duplicate Creation, Call onReset Instead.")
        local currentWindow, index = self:findWindowIndexByClassName(template.__cname)
        if currentWindow and currentWindow.onReset then currentWindow:onReset(...) end
        table.insert(self.m_Windows, table.remove(self.m_Windows, index))
        self:sortZOrder()
        return
    end
	local window = template:create(display.getWorld():getApp(), template.__cname, ...):addTo(display.getWorld())
	rawset(template, "inDisplay", true)
    window:setAnchorPoint(0.5, 0.5):move(display.center)
	table.insert(self.m_Windows, window)
	self:sortZOrder()
	local temp = window.onCleanup
	window.onCleanup = function(...)
		rawset(template, "inDisplay", nil)
		self:removeWindow(window)
		if temp then temp(...) end
	end
	return window
end

return WindowMgr:getInstance()
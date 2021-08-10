
local ViewBaseEx = require("app.views.ViewBaseEx")
local WindowMgr = require("app.components.WindowMgr")
local LFS = require("app.extensions.LFS")
local vLayerMain = class("vLayerMain", ViewBaseEx)
local GridView			= import("app.components.GridView")
local TableViewEx = require("app.components.TableViewEx")

local LOCAL_PATH = "C:/Users/ljw/Documents/git/client/res/"
function vLayerMain:onCreate(context)
	-- body
	self:fetchAllFiles()
    self:autoAlgin()
    self:createUI()
end

function vLayerMain:createUI()

	self.bg = self:createLayout({
		size = cc.size(800, 500),
		color = cc.c3b(255, 255, 255),
		op = 30,
		ap = cc.p(0.5, 0.5)
	}):addTo(self):move(display.center)

	self:createLayout({
		size = cc.size(150, 30),
		color = cc.c3b(255, 255, 255),
		op = 30,
		str = "搜索",
		ap = cc.p(0.5, 1)
	}):addTo(self):move(display.width * 0.5, display.height - 3)

	self:cEditBox({
		size = cc.size(400, 30),
		cb = function(state, box)
			if state == "changed" then
			    self:reloadData(box:getText())
			end
		end
	}):addTo(self):move(display.cx, display.height - 100)

	self:createGridView()
end

function vLayerMain:reloadData(str)

end

function vLayerMain:createGridView()
	if self.gridView == nil then
		-- local itemCount = 100
		self.gridView = GridView:create({
	        viewSize    = cc.size(800, 500),
	        cellSize    = { width = 400, height = 40 },
	        -- rowCount    = 5,
	        fieldCount  = 2,
	        VGAP        = 3,
	        HGAP        = 0,
	    }):addTo(self):move(display.center):setAnchorPoint(0.5, 0.5)
	    self.gridView.onCellAtIndex = handler(self, self.onCellAtIndex)
	end
	self.gridView:setDatas({1, 2, 3, 4, 5, 6, 7, 8, 9, 10, 11, 12, 13, 14, 15, 16})
end

function vLayerMain:onCellAtIndex(cell, data)
	cell.label = cell.label or self:createLayout({
		size = cc.size(400, 40),
		color = cc.c3b(255, 255, 255),
		op = 30,
		str = data,
		ap = cc.p(0, 0)
	}):addTo(cell)

	cell.label:setTitleStr(data)
end

function vLayerMain:fetchSinglePath(rootPath)

end

function vLayerMain:fetchAllFiles()
	local ret = LFS.getAllFilesForPath(LOCAL_PATH)
	local newRet = {}
	local function printDirs(file)
		for _, v in ipairs(file:subFiles()) do
			print(v:getFullPath())
			if v:isDir() then
				printDirs(v)
			end
		end
	end
	dump(ret:subFiles())
	-- do return end
	for _, v in pairs(ret:subFiles()) do
		printDirs(v)
	end
end


return vLayerMain
local ViewBaseEx = require("app.views.ViewBaseEx")
local vNodeMainScene = class("vNodeMainScene", ViewBaseEx)

--[[
cc.Handler.EVENT_MOUSE_DOWN       = 48
cc.Handler.EVENT_MOUSE_UP         = 49
cc.Handler.EVENT_MOUSE_MOVE       = 50
cc.Handler.EVENT_MOUSE_SCROLL     = 51
]]


function vNodeMainScene:genGroundGrids()
	local mapInfo = self.mapInfo
	self.__gridWidth = mapInfo.width / 20
	self.__gridHeight = mapInfo.height / 20

	self._groundGridInfo = mapInfo.groundGridInfo or {}
	for width = 1, self.__gridWidth do
		for height = 1, self.__gridHeight do
			local grid = require("app.views.node.vNodeGroundGrid"):create(self._groundGridInfo[width + width * (height - 1)])
			grid:addTo(self.canvas)
			grid:move((width - 1) * 20, (height - 1) * 20)
			table.insert(self._groundGridInfo, grid)
		end
	end
end

function vNodeMainScene:genMapObjects()
	local mapInfo = self.mapInfo
	for _, v in ipairs(mapInfo.mapObjects or {}) do

	end
end

function vNodeMainScene:onCreate(size, mapInfo)
	self.__gridWidth = 0
	self.__gridHeight = 0
	self:setContentSize(size.width - 4, size.height - 4)
		:setAnchorPoint(0.5, 0.5)
		:move(0, 0)

	self.viewport = self:createLayout({
		size = cc.size(size.width - 4, size.height - 4),
		ap = cc.p(0, 0),
	}):addTo(self):setClippingEnabled(true)

	self.canvas = self:createLayout({
		size = cc.size(mapInfo.width, mapInfo.height),
		ap = cc.p(0, 0),
		dad = handler(self, self.onDropItemToCanvas),
		op = 0,
		cb = handler(self, self.onMoveCanvas)
	}):addTo(self.viewport)
	self.mapInfo = mapInfo
	-- dump(mapInfo)
	self:genGroundGrids()
end

function vNodeMainScene:onMoveCanvas(e)
	local touch = e.touch
	local target = e.target
	local delta = cc.pSub(touch:getLocation(), touch:getStartLocation())
	local finalPos = cc.pAdd(cc.p(target:getPosition()), delta)
	target:move(finalPos)	
end

function vNodeMainScene:onDropItemToCanvas(e)
	local node = e.otherNode
	local touch = e.touch
	
end

function vNodeMainScene:saveToFile()

end

return vNodeMainScene
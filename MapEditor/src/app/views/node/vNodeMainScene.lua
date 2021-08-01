local WindowMgr = require("app.components.WindowMgr")
local ViewBaseEx = require("app.views.ViewBaseEx")
local DragAndDropMgr = require("app.components.DragAndDropManager")
local vNodeMainScene = class("vNodeMainScene", ViewBaseEx)

local SINGLE_GRID_WIDTH = 20

function vNodeMainScene:genGroundGrids()
	local mapInfo = self.mapInfo
	self.__gridWidth = mapInfo.width / SINGLE_GRID_WIDTH
	self.__gridHeight = mapInfo.height / SINGLE_GRID_WIDTH

	self._groundGridInfo = mapInfo.groundGridInfo or {}
	for width = 1, self.__gridWidth do
		for height = 1, self.__gridHeight do
			local grid = require("app.views.node.vNodeGroundGrid"):create(self._groundGridInfo[width + width * (height - 1)])
			grid:addTo(self.canvas)
			grid:move((width - 1) * SINGLE_GRID_WIDTH, (height - 1) * SINGLE_GRID_WIDTH)
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
		color = cc.c3b(255, 0, 0),
		dad = handler(self, self.onDropItemToCanvas),
		op = 30,
		cb = handler(self, self.onMoveCanvas)
	}):addTo(self.viewport)
	self.canvas.onMouseMove = handler(self, self.onMouseMove)
	self.canvas.onMouseOutSide = handler(self, self.onMouseOutSide)
	DragAndDropMgr:enableMouseMoveEvents(self.canvas)
	self.canvas.____drawNode = cc.DrawNode:create():addTo(self.canvas)
	self.mapInfo = mapInfo
	self:genGroundGrids()
end

function vNodeMainScene:onMoveCanvas(e)
	local touch = e.touch
	local target = e.target
	local delta = cc.pSub(touch:getLocation(), touch:getStartLocation())
	local finalPos = cc.pAdd(cc.p(target:getPosition()), delta)
	target:move(finalPos)	
end

function vNodeMainScene:onDropItemToCanvas(node, touch)
	local itemType = node.getTitleStr and node:getTitleStr() or nil
	if not itemType then return end

	local pos = self.canvas:convertToNodeSpaceAR(touch:getLocation())
	local GridPosX = pos.x - pos.x % SINGLE_GRID_WIDTH
	local GridPosY = pos.y - pos.y % SINGLE_GRID_WIDTH
	local GridIndex = 1 + GridPosX / SINGLE_GRID_WIDTH + (self.mapInfo.width / SINGLE_GRID_WIDTH * GridPosY / SINGLE_GRID_WIDTH)
	
	if itemType == "建筑" then
		WindowMgr:createWindow("app.views.layer.vLayerChooseBuild", pos)
	elseif itemType == "生物" then
		WindowMgr:createWindow("app.views.layer.vLayerChooseCreature", pos)
	elseif itemType == "采集物" then
		WindowMgr:createWindow("app.views.layer.vLayerChoosePickable", pos)
	elseif itemType == "传送门" then
		WindowMgr:createWindow("app.views.layer.vLayerChoosePortal", pos)
	elseif itemType == "游戏物体" then
		WindowMgr:createWindow("app.views.layer.vLayerChooseGameObject", pos)
	end
end

function vNodeMainScene:tryUpdatePointerGrid(pos)
	local GridPosX = pos.x - pos.x % SINGLE_GRID_WIDTH
	local GridPosY = pos.y - pos.y % SINGLE_GRID_WIDTH
	local GridIndex = 1 + GridPosX / SINGLE_GRID_WIDTH + (self.mapInfo.width / SINGLE_GRID_WIDTH * GridPosY / SINGLE_GRID_WIDTH)
	if GridIndex == self.___GridIndex then return end
	self.___GridIndex = GridIndex
	self.canvas.____drawNode:clear()
    self.canvas.____drawNode:drawPolygon({cc.p(GridPosX, GridPosY), cc.p(GridPosX + SINGLE_GRID_WIDTH, GridPosY), cc.p(GridPosX + SINGLE_GRID_WIDTH, GridPosY + SINGLE_GRID_WIDTH), cc.p(GridPosX, GridPosY + SINGLE_GRID_WIDTH)}, 4, cc.c4f(0,0,0,0), 1, cc.c4f(1,1,1,1))
end

function vNodeMainScene:onMouseMove(touch)
	if WindowMgr:getTopWindowName() ~= "vLayerEditor" then return end
	local pos = self.canvas:convertToNodeSpaceAR(touch:getLocationInView())
	self:tryUpdatePointerGrid(pos)
end

function vNodeMainScene:onMouseOutSide()
	self.canvas.____drawNode:clear()
end

return vNodeMainScene

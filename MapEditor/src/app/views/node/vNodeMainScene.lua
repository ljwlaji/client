local WindowMgr = require("app.components.WindowMgr")
local MapLoader = require("app.components.MapLoader")
local ViewBaseEx = require("app.views.ViewBaseEx")
local DragAndDropMgr = require("app.components.DragAndDropManager")
local vNodeMainScene = class("vNodeMainScene", ViewBaseEx)

local SINGLE_GRID_WIDTH = 20

function vNodeMainScene:genGroundGrids()
	local mapInfo = self.mapInfo
	self.__gridWidth = mapInfo.width / SINGLE_GRID_WIDTH
	self.__gridHeight = mapInfo.height / SINGLE_GRID_WIDTH
	local totalLength = self.__gridWidth * self.__gridHeight
	mapInfo.groundGridInfo = mapInfo.groundGridInfo or {}

	for i = 1, totalLength do
		mapInfo.groundGridInfo[i] = mapInfo.groundGridInfo[i] or { index = i, plist = "", path = "default_ground.png", area = -1 }
		local currGroundInfo = mapInfo.groundGridInfo[i]
		local grid = require("app.views.node.vNodeGroundGrid"):create(currGroundInfo)
		grid:addTo(self.canvas)
		local x = i % self.__gridWidth
		local y = math.floor(i / self.__gridWidth)
		grid:move((x - 1) * SINGLE_GRID_WIDTH, (y - 1) * SINGLE_GRID_WIDTH)
	end
end

function vNodeMainScene:genMapObjects()
	local mapInfo = self.mapInfo
	for _, v in ipairs(mapInfo.mapObjects or {}) do
		require("app.views.node.vNodeGroundGrid"):create(v):addTo(self.canvas)
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

	self:regiestCustomEventListenter("MSG_ON_SAVE_BTN_CLICKED", handler(self, self.saveToFile))
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
	
	if itemType == "??????" then
		WindowMgr:createWindow("app.views.layer.vLayerChooseBuild", pos)
	elseif itemType == "??????" then
		WindowMgr:createWindow("app.views.layer.vLayerChooseCreature", pos)
	elseif itemType == "?????????" then
		WindowMgr:createWindow("app.views.layer.vLayerChoosePickable", pos)
	elseif itemType == "?????????" then
		WindowMgr:createWindow("app.views.layer.vLayerChoosePortal", pos)
	elseif itemType == "????????????" then
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

function vNodeMainScene:saveToFile(...)
	MapLoader.saveToFile(self.mapInfo)
end

return vNodeMainScene

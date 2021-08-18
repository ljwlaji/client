local WindowMgr 			= require("app.components.WindowMgr")
local DataBase 				= require("app.components.DataBase")
local ViewBaseEx 			= require("app.views.ViewBaseEx")
local TableViewEx 			= require("app.components.TableViewEx")
local Utils 				= require("app.components.Utils")
local vLayerChooseCreature 	= class("vLayerChooseCreature", ViewBaseEx)


local WINDOW_SIZE = {
	width = 500,
	height = 600
}

local CELL_SIZE = {
	width = 450,
	height = 100,
}

function vLayerChooseCreature:onCreate()
	self:setAnchorPoint(0.5, 0.5)
	self:setContentSize(WINDOW_SIZE)
	local bg = self:createLayout({
		size = WINDOW_SIZE,
		ap = cc.p(0, 0),
		st = true,
	}):addTo(self)

	self:createLayout({
		size = cc.size(40, 40),
		ap = cc.p(1, 1),
		cb = function() WindowMgr:removeWindow(self) end,
		st = true,
	}):addTo(self):move(WINDOW_SIZE.width, WINDOW_SIZE.height)

	self:createLayout({
		size = cc.size(300, 40),
		ap = cc.p(0.5, 1),
		str = "選擇生物",
	}):addTo(self):move(WINDOW_SIZE.width * 0.5, WINDOW_SIZE.height)

	self:cEditBox({
		size = cc.size(400, 30),
		cb = function(state, box)
			if state == "changed" then
			    self:onTextChange(box:getText())
			end	
		end,
		ph = "输入需要查询的生物名称或id",
	}):addTo(self):move(WINDOW_SIZE.width * 0.5, WINDOW_SIZE.height - 100)


	self.tableView = import("app.components.TableViewEx"):create({
        cellSize = CELL_SIZE,
        direction = cc.SCROLLVIEW_DIRECTION_VERTICAL,
        fillOrder = cc.TABLEVIEW_FILL_TOPDOWN,
        size = cc.size(450, 300),
    }):addTo(self):move(WINDOW_SIZE.width * 0.5, WINDOW_SIZE.height * 0.5):setAnchorPoint(0.5, 0.5)
    self.tableView:onCellAtIndex(handler(self, self.onCellAtIndex))
end

function vLayerChooseCreature:createModelNode(data)
	local currModelData = DataBase:query(string.format("SELECT * FROM model_template WHERE entry = %d", data.model_id))[1]
	local model = nil
	if currModelData.model_type == "image" then
		model = cc.Sprite:create(string.format("res/model/image/%s", currModelData.file_path))
	elseif currModelData.model_type == "spine" then
		xpcall(function() 
			model = sp.SkeletonAnimation:createWithJsonFile(string.format("res/model/spine/%s", currModelData.json_path), string.format("res/model/spine/%s", currModelData.altas_path))
		end, function(...)	dump({...}) end)
	elseif currModelData.model_type == "animation" then
		
	end
	return model
end

function vLayerChooseCreature:onCellAtIndex(cell, index)
	local data = self._creatureDatas[index + 1]
	cell.item = cell.item or self:createLayout({
		size = CELL_SIZE,
		str = "none",
		ap = cc.p(0, 0),
		cb = handler(self, self.onTouchCell),
		st = false,
	}):addTo(cell)
	cell.item:setTitleStr(data.zh_cn)
	if cell.item.model then sell.item.model:removeFromParent() end
	self:createModelNode(data):addTo(cell.item):setScale(0.3):move(40, 20)
end

function vLayerChooseCreature:reloadData(datas)
	self._creatureDatas = datas or {}
    self.tableView:setNumbers(#self._creatureDatas)
    self.tableView:reloadData()
end

function vLayerChooseCreature:onTextChange(inputStr)
	local sql = [[
		SELECT * FROM creature_template AS template JOIN string_template AS string ON template.name_id == string.id WHERE string.zh_cn like '%%%s%%' or template.entry == %d;
	]]

	local querySql = string.format(sql, tostring(inputStr), tonumber(inputStr) or 0)
	local result = DataBase:getInstance():query(querySql)
	self:reloadData(result)
end

function vLayerChooseCreature:onTouchCell(e)
	if e.name ~= "ended" then return end
	local beginPos = e.target:getTouchBeganPosition()
	local endPos = e.target:getTouchEndPosition()
	local diffX = math.abs(beginPos.x - endPos.x)
	local diffY = math.abs(beginPos.y - endPos.y)
	if math.max(diffY, diffX) > 2 then release_print("偏移量過大, 丟棄這個touch") return end
	release_print("Touched")
end

return vLayerChooseCreature
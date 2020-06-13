local ViewBaseEx 		= import("app.views.ViewBaseEx")
local DataBase 			= import("app.components.DataBase")
local TableView      	= import("app.components.TableViewEx")
local vLayerQuestMenu 	= class("vLayerQuestMenu", ViewBaseEx)

vLayerQuestMenu.DisableDuplicateCreation = true
vLayerQuestMenu.RESOURCE_FILENAME = "res/csb/layer/CSB_Layer_QuestMenu.csb"
vLayerQuestMenu.RESOURCE_BINDING = {
	Panel_Exit = "onTouchOutside",
	Button_Accept = "onTouchButtonAccept"
}

local MAX_LINE_WIDTH = 380

function vLayerQuestMenu:onCreate(context)
    self.tableView = TableView:create({
                size = cc.size(380, 480),
                cellSize = handler(self, self.cellSize),
            })
        :onCellAtIndex(handler(self, self.showCell))
        :addTo(self.m_Children["Panel_Frame"])
        :setPosition(10, 80)

	self:onReset(context)
	self:debugDraw(self.tableView, cc.c4f(1, 0, 0, 1))
end

function vLayerQuestMenu:onReset(context)
	local str = DataBase:getStringByID(context.description_string)
	self.m_Children["Text_QuestDesc"]:setString(str)
	self.m_Children["Text_QuestDesc"]:retain()
	self.m_Children["Text_QuestDesc"]:removeFromParent()
	local renderSize = self.m_Children["Text_QuestDesc"]:getAutoRenderSize()
	local lineCount = math.ceil(renderSize.width / MAX_LINE_WIDTH)
	self.m_Children["Text_QuestDesc"]:setTextAreaSize(cc.size(MAX_LINE_WIDTH, lineCount * renderSize.height))

	self.m_Children["Text_QuestTitle"]:setString(DataBase:getStringByID(context.title_string))

	self.tableView:setNumbers(1)
	self.tableView:reloadData()


	self.context = context
end

function vLayerQuestMenu:showCell(cell, idx)
	cell.label = cell.label or self.m_Children["Text_QuestDesc"]:addTo(cell)
end

function vLayerQuestMenu:cellSize(_, idx)
	idx = idx + 1
	return idx == 1 and self.m_Children["Text_QuestDesc"]:getContentSize() or cc.size(0, 0)
end

function vLayerQuestMenu:onTouchButtonAccept(e)
	if e.name ~= "ended" then return end
	local plr = import("app.components.Object.Player"):getInstance()
	if plr and plr:canAcceptQuest(self.context) then
		plr:acceptQuest(self.context.entry)
	end
end

function vLayerQuestMenu:onTouchOutside(e)
	if e.name ~= "ended" then return end
	self:removeFromParent()
end



return vLayerQuestMenu
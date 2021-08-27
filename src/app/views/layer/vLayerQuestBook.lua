local ViewBaseEx 		= require("app.views.ViewBaseEx")
local DataBase 			= require("app.components.DataBase")
local TableView      	= require("app.components.TableViewEx")
local Player 			= require("app.components.Object.Player")
local ShareDefine       = require("app.ShareDefine")
local Cell 				= require("app.views.node.vNodeQuestBookTargetCell")
local vLayerQuestBook 	= class("vLayerQuestBook", ViewBaseEx)

vLayerQuestBook.DisableDuplicateCreation = true
vLayerQuestBook.RESOURCE_FILENAME 	= "res/csb/layer/CSB_Layer_QuestBook.csb"
vLayerQuestBook.RESOURCE_BINDING 	= { PanelExit = "onTouchPanelExit" }

local questStates = ShareDefine.questStates()

function vLayerQuestBook:onCreate()
	local contentSize = self.m_Children["Panel_TableView"]:getContentSize()
	self.leftView = TableView:create({
        cellSize = cc.size(contentSize.width, 42),
        direction = cc.SCROLLVIEW_DIRECTION_VERTICAL,
        fillOrder = cc.TABLEVIEW_FILL_TOPDOWN,
        size = contentSize,
    }):addTo(self.m_Children["Panel_TableView"])
    self.rightView = TableView:create({size = cc.size(460, 480),cellSize = handler(self, self.rightSize)})
						      :onCellAtIndex(handler(self, self.RefreshRightView))
						      :addTo(self.m_Children["Panel_Frame"])
						      :setPosition(180, 0)
	self.m_Children["Title_Targets"]:setString(DataBase:getStringByID(400003))
    self.m_Children["Title_Awards"]:setString(DataBase:getStringByID(400004))
    self.leftView:onCellAtIndex(handler(self, self.onCellAtIndex))
	self:onReset()
end

function vLayerQuestBook:onReset()
	local plr = Player:getInstance()
	if not plr then self:removeFromParent() return end

	local datas = plr:getQuestDatas()
	local newdatas = {}
	for questEntry, questInfo in pairs(datas) do
		if questInfo.state == questStates.IN_PROGRESS or questInfo.state == questStates.WAIT_FOR_SUBMIT then
			table.insert(newdatas, questInfo)
		end
	end
	self.datas = newdatas
	self.leftView:setNumbers(#newdatas)
	self.leftView:reloadData()
	if #self.datas == 0 then return end
	self:switchToQuest(self.datas[1])
end

function vLayerQuestBook:onCellAtIndex(cell, idx)
	cell.item = require("app.views.node.vNodeQuestBookCell"):create()
														   :addTo(cell)
														   :onTouch(handler(self, self.switchToQuest))
														   :move(0, 0)
	cell.item:onReset(self.datas[idx + 1])
end

function vLayerQuestBook:rightSize(_, idx)
	local totalHeight = 0
	for k, v in pairs({"Panel_Awards", "Panel_Targets", "Text_Desc"}) do
		totalHeight = totalHeight + self.m_Children[v]:getContentSize().height
	end
	return idx == 0 and cc.size(480, totalHeight or 0) or cc.size(0, 0)
end

function vLayerQuestBook:RefreshRightView(cell, idx)
	cell.item = cell.item or self.m_Children["RightNode"]:retain():removeFromParent():addTo(cell):release():move(0, 0)
	local height = 0
	for k, v in pairs({"Panel_Awards", "Panel_Targets", "Text_Desc"}) do
		self.m_Children[v]:retain()
						  :removeFromParent()
		self.m_Children[v]:addTo(self.m_Children["RightNode"])
						  :move(0, height):release()
		height = height + self.m_Children[v]:getContentSize().height
	end
end

function vLayerQuestBook:updateQuestTargets(targets)
	local plr = Player:getInstance()
	for _, v in pairs(self.m_Children["Panel_Targets"].items or {}) do v:removeFromParent() end
	self.m_Children["Panel_Targets"].items = {}
	local height = 0
	for target_type, target_info in pairs(targets) do
		for target_entry, target_amount in pairs(target_info) do
			local item 			= Cell:create()
			local name_str 		= ""
			local progress_str 	= ""
			if target_type == "items" then
				name_str = DataBase:getStringByID(DataBase:getItemTemplateByEntry(target_entry).name_string)
				progress_str = string.format("%d/%d", plr:getItemCount(target_entry), target_amount)
			else
				name_str = "achive"
				progress_str = tostring(target_amount)
			end
			item:onReset(name_str, progress_str)
				:addTo(self.m_Children["Panel_Targets"])
				:move(0, height)
			table.insert(self.m_Children["Panel_Targets"].items, item)
			height = height + item:getContentSize().height
		end
	end
	self.m_Children["Title_Targets"]:setPositionY(height)
	height = height + self.m_Children["Title_Targets"]:getContentSize().height
	self.m_Children["Panel_Targets"]:setContentSize(480, height)
end

function vLayerQuestBook:updateQuestAwards(awards)
	for _, v in pairs(self.m_Children["Panel_Awards"].items or {}) do v:removeFromParent() end
	self.m_Children["Panel_Awards"].items = {}
	local height = 0
	for awards_type, awards_info in pairs(awards) do
		for entry, amount in pairs(awards_info) do
			local item 			= Cell:create()
			local name_str 		= ""
			if awards_type == "money" then
				name_str = DataBase:getStringByID(50)
			elseif awards_type == "reputation" then
				name_str = DataBase:getStringByID(51)
			elseif awards_type == "exp" then
				name_str = DataBase:getStringByID(52)
			elseif awards_type == "items" then
				name_str = DataBase:getStringByID(DataBase:getItemTemplateByEntry(entry).name_string)
			end
			item:onReset(name_str, string.format(" *%d", amount))
				:addTo(self.m_Children["Panel_Awards"])
				:move(0, height)
			table.insert(self.m_Children["Panel_Awards"].items, item)
			height = height + item:getContentSize().height
		end
	end
	self.m_Children["Title_Awards"]:setPositionY(height)
	height = height + self.m_Children["Title_Awards"]:getContentSize().height
	self.m_Children["Panel_Awards"]:setContentSize(480, height)
end

function vLayerQuestBook:switchToQuest(questInfo)
	local questTemplate = DataBase:getQuestTemplateByEntry(questInfo.quest_entry)
	self.m_Children["Text_Desc"]:setString(DataBase:getStringByID(questTemplate.description_string)):autoScaleHeight()
	self:updateQuestTargets(questTemplate.quest_targets)
	self:updateQuestAwards(questTemplate.awards)
	self.rightView:setNumbers(1)
				  :reloadData()
				  :reloadData()
end

function vLayerQuestBook:onTouchPanelExit(e)
	if e.name ~= "ended" then return end
	self:removeSelf()
end

return vLayerQuestBook
local ViewBaseEx 		= import("app.views.ViewBaseEx")
local DataBase 			= import("app.components.DataBase")
local TableView      	= import("app.components.TableViewEx")
local vLayerQuestMenu 	= class("vLayerQuestMenu", ViewBaseEx)

vLayerQuestMenu.DisableDuplicateCreation = true
vLayerQuestMenu.RESOURCE_FILENAME = "res/csb/layer/CSB_Layer_QuestMenu.csb"
vLayerQuestMenu.RESOURCE_BINDING = {
	Panel_Exit 		= "onTouchOutside",
	Button_Accept 	= "onTouchButtonAccept"
}

function vLayerQuestMenu:onCreate(questEntry)
    self.tableView = TableView:create({
                size = cc.size(380, 480),
                cellSize = handler(self, self.cellSize),
            })
        :onCellAtIndex(handler(self, self.showCell))
        :addTo(self.m_Children["Panel_Frame"])
        :setPosition(10, 80)
		:setNumbers(1)

	self:onReset(questEntry)
end

function vLayerQuestMenu:onReset(questEntry)
	local questTemplate = DataBase:getQuestTemplateByEntry(questEntry)
	self.m_Children["Text_QuestDesc"]:setString(self:fillQuestDesc(questTemplate)):autoScaleHeight()
	self.m_Children["Text_QuestTitle"]:setString(DataBase:getStringByID(questTemplate.title_string))

	local strID = 10000
	local ButtonVisible = true
	local plr = import("app.components.Object.Player"):getInstance()
	if plr:canAcceptQuest(questEntry) then
		release_print("可以接取任务")
	elseif plr:canSubmitQuest(questEntry) then
		release_print("可以提交任务")
		strID = 10001
	else
		ButtonVisible = false
	end
	self.m_Children["Button_Accept"]:setVisible(ButtonVisible)
	self.m_Children["Text_Accept"]:setString(DataBase:getStringByID(strID))
	self.tableView:reloadData()
	self.context = questEntry
end

function vLayerQuestMenu:fillQuestTargets(questTemplate)
	local ret = ""
	for target_type, target_info in pairs(questTemplate.quest_targets) do
		if target_type == "items" then
			for itemEntry, requireAmount in pairs(target_info) do
				local itemTemplate = DataBase:getItemTemplateByEntry(itemEntry)
				ret = string.format("%s%s x%d\n",ret, DataBase:getStringByID(itemTemplate.name_string), requireAmount)
			end
			ret = string.sub(ret, 1, string.len(ret) - 1)
		elseif target_type == "achive" then

		else
			assert(false, "Undefined target typge : "..tostring(target_type))
		end
	end
	return ret
end

function vLayerQuestMenu:fillQuestAwards(questTemplate)
	local ret = ""
	for awards_type, awards_info in pairs(questTemplate.awards) do
		if awards_type == "items" then
			for itemEntry, itemAmount in pairs(awards_info) do
				local itemTemplate = DataBase:getItemTemplateByEntry(itemEntry)
				ret = string.format("%s%s x%d\n",ret, DataBase:getStringByID(itemTemplate.name_string), itemAmount)
			end
			ret = string.sub(ret, 1, string.len(ret) - 1)
		end
	end

	return ret
end

function vLayerQuestMenu:fillQuestDesc(questTemplate)
	return string.format(DataBase:getStringByID(400000), DataBase:getStringByID(questTemplate.description_string), self:fillQuestTargets(questTemplate), self:fillQuestAwards(questTemplate))
end

function vLayerQuestMenu:showCell(cell, idx)
	cell.label = cell.label or self.m_Children["Text_QuestDesc"]:retain():removeFromParent():addTo(cell):release()
end

function vLayerQuestMenu:cellSize(_, idx)
	idx = idx + 1
	return idx == 1 and self.m_Children["Text_QuestDesc"]:getContentSize() or cc.size(0, 0)
end

function vLayerQuestMenu:onTouchButtonAccept(e)
	if e.name ~= "ended" then return end
	local plr = import("app.components.Object.Player"):getInstance()
	if not plr then return end
	if plr:canAcceptQuest(self.context) then
		plr:acceptQuest(self.context)
	elseif plr:canSubmitQuest(self.context) then
		release_print("trySubmit")
		plr:trySubmitQuest(self.context)
	end
	self:removeFromParent()
end

function vLayerQuestMenu:onTouchOutside(e)
	if e.name ~= "ended" then return end
	self:removeFromParent()
end



return vLayerQuestMenu
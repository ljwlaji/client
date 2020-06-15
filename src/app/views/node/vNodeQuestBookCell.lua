local ViewBaseEx 			= import("app.views.ViewBaseEx")
local DataBase 				= import("app.components.DataBase")
local ShareDefine       	= import("app.ShareDefine")
local vNodeQuestBookCell 	= class("vNodeQuestBookCell", ViewBaseEx)


vNodeQuestBookCell.RESOURCE_FILENAME = "res/csb/node/CSB_Node_QuestBookCell.csb"
vNodeQuestBookCell.RESOURCE_BINDING = {
	Panel_Touch = "onTouchCell"
}

local questStates = ShareDefine.questStates()


function vNodeQuestBookCell:onCreate()
	self.m_Children["Panel_Touch"]:setSwallowTouches(false)
end

function vNodeQuestBookCell:onReset(context)
	local questTemplate = DataBase:getQuestTemplateByEntry(context.quest_entry)
	self.m_Children["Text_Title"]:setString(string.format("%s%s", DataBase:getStringByID(questTemplate.title_string), 
																  DataBase:getStringByID(context.state == questStates.IN_PROGRESS and 10030 or 10031 )))
	self.context = context
end

function vNodeQuestBookCell:onTouch(foo)
	self.__onTouchFoo = foo
	return self
end

function vNodeQuestBookCell:onTouchCell(e)
	if e.name ~= "ended" then return end
	if cc.pGetDistance(e.target:getTouchBeganPosition(), e.target:getTouchEndPosition()) > 20 then return end
	self.__onTouchFoo(self.context)
end

return vNodeQuestBookCell

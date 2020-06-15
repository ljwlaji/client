local ViewBaseEx 					= import("app.views.ViewBaseEx")
local DataBase 						= import("app.components.DataBase")
local vNodeQuestBookTargetCell 		= class("vNodeQuestBookTargetCell", ViewBaseEx)

vNodeQuestBookTargetCell.RESOURCE_FILENAME = "res/csb/node/CSB_Node_QuestBook_Target_Cell.csb"
vNodeQuestBookTargetCell.RESOURCE_BINDING = {}

function vNodeQuestBookTargetCell:onCreate()
	self:setContentSize(cc.size(400, 25))
end

function vNodeQuestBookTargetCell:onReset(str1, str2)
	self.m_Children["Target_Name"]:setString(str1)
	self.m_Children["Target_Progress"]:setString(str2)
	return self
end

return vNodeQuestBookTargetCell

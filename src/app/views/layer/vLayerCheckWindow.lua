local ViewBaseEx 			= require("app.views.ViewBaseEx")
local DataBase 				= require("app.components.DataBase")
local Utils             	= require("app.components.Utils")
local WindowMgr 			= require("app.components.WindowMgr")
local vLayerCheckWindow 	= class("vLayerCheckBox", ViewBaseEx)

vLayerCheckWindow.DisableDuplicateCreation = true
vLayerCheckWindow.RESOURCE_FILENAME = "res/csb/layer/CSB_Layer_CheckWindow.csb"
vLayerCheckWindow.RESOURCE_BINDING = {
	Button_Confirm 	= "onTouchButtonComfirm",
	Button_Cancel 	= "onTouchButtonCancel",
	ButtonBlock		= "onTouchButtonBlock"
}


function vLayerCheckWindow:onCreate(context)
	self:onReset(context)
end

function vLayerCheckWindow:onReset(context)
	self.context = context
	self.m_Children["Text_Title"]:setString(DataBase:getStringByID(context.title or 10025))
	local desc = table.concat(Utils.splitStrToTable(DataBase:getStringByID(context.desc or 10026), 30), "\n")
	self.m_Children["Text_Desc"]:setString(desc)
	self.m_Children["Button_Confirm"]:setTitleText(DataBase:getStringByID(context.confirm or 10023))
	self.m_Children["Button_Cancel"]:setTitleText(DataBase:getStringByID(context.cancel or 10024))
end

function vLayerCheckWindow:onTouchButtonComfirm(e)
	if e.name ~= "ended" then return end
	if self.context.onConfirm then self.context.onConfirm() end
	WindowMgr:removeWindow(self)
end

function vLayerCheckWindow:onTouchButtonCancel(e)
	if e.name ~= "ended" then return end
	if self.context.onCancel then self.context.onCancel() end
	WindowMgr:removeWindow(self)
end

function vLayerCheckWindow:onTouchButtonBlock(e)
	if e.name ~= "ended" then return end
	if not self.context.block then self:removeFromParent() end
end

return vLayerCheckWindow
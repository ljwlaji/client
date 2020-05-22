local ShareDefine 			= import("app.ShareDefine")
local Controller    		= import("app.views.node.vNodeControllerNew")
local HUDButtons 			= import("app.views.node.vNodeSkillButtons")
local vNodeMainMenuBar 		= import("app.views.node.vNodeMainMenuBar")
local vNodeLoggingTable 	= import("app.views.node.vNodeLoggingTable")
local ViewBaseEX 			= import("app.views.ViewBaseEx")
local vLayerHUD 			= class("vLayerHUD", ViewBaseEX)

vLayerHUD.RESOURCE_FILENAME = "res/csb/layer/CSB_Layer_HUD.csb"
vLayerHUD.RESOURCE_BINDING = {
	-- CSB_Button_Test = "OnTouchButtonTest"
}

local ZORDER_CONTROLLER = 1

function vLayerHUD:onCreate()
	self:autoAlgin()
	self:setupController()
	self:setupHUDButtons()
	self:setupMainMenuBar()

	-- Init LoggingTable If Is DevMode
	-- if ShareDefine:isDevMode() then
	-- 	release_print("Init Right Up Logging Bar...")
	-- 	self.m_LoggingTable = vNodeLoggingTable:create()
	-- 										   :addTo(self.m_Children["node_Right_Up"])
	-- 										   :setAnchorPoint(1, 1)
	-- 										   :move(0, 0)
	-- 	self.m_LoggingTable:init(cc.size((display.width - 800) * 0.5, 500), 
	-- 							 20, 
	-- 							 cc.c3b(255, 0, 0), 
	-- 							 500)

	-- 	local old_func = release_print
	-- 	release_print = function(str, ...) self.m_LoggingTable:insertString(str) old_func(str, ...) end

	-- 	-- for testting
	-- 	release_print("1 : sadfwehurownreoew")
	-- 	release_print("2 : sadfwehurownreoew")
	-- 	release_print("3 : sadfwehurownreoew")
	-- 	release_print("4 : sadfwehurownreoew")
	-- 	release_print("5 : sadfwehurownreoew")
	-- 	release_print("6 : sadfwehurownreoew")
	-- 	release_print("7 : sadfwehurownreoew")
	-- 	release_print("8 : sadfwehurownreoew")
	-- 	release_print("9 : sadfwehurownreoew")
	-- end
end

function vLayerHUD:setupController()
	self.m_Children["node_Left"]:setContentSize(display.width * 0.4, display.height):setLocalZOrder(ZORDER_CONTROLLER)
	self.m_Controller = Controller:create():addTo(self.m_Children["node_Left"])
end

function vLayerHUD:setupHUDButtons()
	self.m_SkillButtons = HUDButtons:create():addTo(self.m_Children["node_Right_Buttom"])
end

function vLayerHUD:setupMainMenuBar()
	self.m_MainMenuBar = vNodeMainMenuBar:create():addTo(self.m_Children["node_Center_Up"])
end

function vLayerHUD:onReset()
	self.m_SkillButtons:onReset()
end

return vLayerHUD
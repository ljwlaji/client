local ShareDefine 			= import("app.ShareDefine")
local Controller    		= import("app.views.node.vNodeControllerNew")
local HUDButtons 			= import("app.views.node.vNodeSkillButtons")
local vNodeMainMenuBar 		= import("app.views.node.vNodeMainMenuBar")
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
local Controller    		= import("app.views.node.vNodeControllerNew")
local HUDButtons 			= import("app.views.node.vNodeSkillButtons")
local vNodeMainMenuBar 		= import("app.views.node.vNodeMainMenuBar")
local ViewBaseEX 			= import("app.views.ViewBaseEx")
local HUDLayer 				= class("HUDLayer", ViewBaseEX)

HUDLayer.RESOURCE_FILENAME = "res/csb/layer/CSB_HUD_Layer.csb"
HUDLayer.RESOURCE_BINDING = {
	-- CSB_Button_Test = "OnTouchButtonTest"
}

local ZORDER_CONTROLLER = 1

function HUDLayer:onCreate()
	self:autoAlgin()
	self:setupController()
	self:setupHUDButtons()
	self:setupMainMenuBar()
end

function HUDLayer:setupController()
	self.m_Children["node_Left"]:setContentSize(display.width * 0.4, display.height):setLocalZOrder(ZORDER_CONTROLLER)
	self.m_Controller = Controller:create():addTo(self.m_Children["node_Left"])
end

function HUDLayer:setupHUDButtons()
	self.m_SkillButtons = HUDButtons:create():addTo(self.m_Children["node_Right_Buttom"])
end

function HUDLayer:setupMainMenuBar()
	self.m_MainMenuBar = vNodeMainMenuBar:create():addTo(self.m_Children["node_Center_Up"])
end

function HUDLayer:onReset()
	self.m_SkillButtons:onReset()
end

return HUDLayer
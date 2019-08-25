local Controller    = import("app.components.Controller")
local ViewBaseEX 	= import("app.views.ViewBaseEX")
local HUDLayer 		= class("HUDLayer", ViewBaseEX)

HUDLayer.RESOURCE_FILENAME = "res/csb/layer/CSB_HUD_Layer.csb"
HUDLayer.RESOURCE_BINDING = {
	-- CSB_Button_Test = "OnTouchButtonTest"
}

local ZORDER_CONTROLLER = 1

function HUDLayer:onCreate()
	self:autoAlgin()
	self:setupControllerLayout()
end

function HUDLayer:setupControllerLayout()
	self.m_Children["node_Left"]:setContentSize(display.width * 0.4, display.height):setLocalZOrder(ZORDER_CONTROLLER)
	self.m_Controller = Controller:create():addTo(self.m_Children["node_Left"])
end

return HUDLayer
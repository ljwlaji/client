local ShareDefine 			= import("app.ShareDefine")
local Controller    		= import("app.views.node.vNodeControllerNew")
local HUDButtons 			= import("app.views.node.vNodeSkillButtons")
local vNodeMainMenuBar 		= import("app.views.node.vNodeMainMenuBar")
local DataBase 				= import("app.components.DataBase")
local Player        		= import("app.components.Object.Player")
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

	self.m_Children["CSB_ExpBar"]:setContentSize(display.width, 25)
	self:regiestCustomEventListenter("MSG_ON_EXP_DATA_CHANGED", handler(self, self.updateExpBar))
end

function vLayerHUD:setupController()
	self.m_Children["node_Left"]:setContentSize(display.width * 0.4, display.height):setLocalZOrder(ZORDER_CONTROLLER)
	self.m_Controller = Controller:create():addTo(self.m_Children["node_Left"]):setPositionY(25)
end

function vLayerHUD:setupHUDButtons()
	self.m_SkillButtons = HUDButtons:create():addTo(self.m_Children["node_Right_Buttom"]):setPositionY(25)
end

function vLayerHUD:setupMainMenuBar()
	self.m_MainMenuBar = vNodeMainMenuBar:create():addTo(self.m_Children["node_Center_Up"])
end

function vLayerHUD:updateExpBar(context)
	local maxExp = DataBase:query(string.format("SELECT exp FROM level_exp WHERE currLevel = '%d'", context.parameters.currLevel))[1]["exp"]
	self.m_Children["CSB_ExpBar"]:setPercent( context.parameters.currExp / maxExp * 100 )
end

function vLayerHUD:onReset()
	self.m_SkillButtons:onReset()
end

return vLayerHUD
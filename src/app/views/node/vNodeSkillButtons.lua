local ViewBaseEx 	= import("app.views.ViewBaseEx")
local WindowMgr			= import("app.components.WindowMgr")
local SkillButtons 	= class("SkillButtons", ViewBaseEx)

SkillButtons.RESOURCE_FILENAME = "res/csb/node/CSB_Node_HUD_Button.csb"
SkillButtons.RESOURCE_BINDING = {
	ButtonA = "onTouchButtonA",
	ButtonB = "onTouchButtonB",
	ButtonY = "onTouchButtonY",
	ButtonX = "onTouchButtonX",
}

function SkillButtons:onCreate()
	
end

function SkillButtons:onTouchButtonX(e)
	if e.name ~= "ended" then return end
	self:sendAppMsg("onTouchButtonX")

	WindowMgr:createWindow("app.views.layer.vLayerEquipments")
end

function SkillButtons:onTouchButtonY(e)
	if e.name ~= "ended" then return end
	self:sendAppMsg("onTouchButtonY")
	WindowMgr:createWindow("app.views.layer.vLayerInventory")
end

function SkillButtons:onTouchButtonA(e)
	if e.name ~= "ended" then return end
	self:sendAppMsg("onTouchButtonA")
end

function SkillButtons:onTouchButtonB(e)
	if e.name ~= "ended" then return end
	self:sendAppMsg("onTouchButtonB")
end

return SkillButtons
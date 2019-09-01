local ViewBaseEx 	= import("app.views.ViewBaseEx")
local SkillButtons 	= class("SkillButtons", ViewBaseEx)

SkillButtons.RESOURCE_FILENAME = "res/csb/node/CSB_Node_HUD_Button.csb"
SkillButtons.RESOURCE_BINDING = {
	ButtonA = "onTouchButtonA",
	ButtonB = "onTouchButtonB",
	ButtonY = "onTouchButtonY",
	ButtonX = "onTouchButtonX",
}

function SkillButtons:onCreate()
	self:regiestCustomEventListenter("onTouchButtonX", function() release_print("onTouchButtonX") end)
	self:regiestCustomEventListenter("onTouchButtonY", function() release_print("onTouchButtonY") end)
	self:regiestCustomEventListenter("onTouchButtonA", function() release_print("onTouchButtonA") end)
	self:regiestCustomEventListenter("onTouchButtonB", function() release_print("onTouchButtonB") end)
end

function SkillButtons:onTouchButtonX(e)
	if e.name ~= "ended" then return end
	self:sendAppMsg("onTouchButtonX")
end

function SkillButtons:onTouchButtonY(e)
	if e.name ~= "ended" then return end
	self:sendAppMsg("onTouchButtonY")
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
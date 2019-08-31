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

end

function SkillButtons:onTouchButtonX(e)
	if e.name ~= "ended" then return end
	release_print("onTouchButtonX")
end

function SkillButtons:onTouchButtonY(e)
	if e.name ~= "ended" then return end
	release_print("onTouchButtonY")

end

function SkillButtons:onTouchButtonA(e)
	if e.name ~= "ended" then return end
	release_print("onTouchButtonA")
end

function SkillButtons:onTouchButtonB(e)
	if e.name ~= "ended" then return end
	release_print("onTouchButtonB")
end

return SkillButtons
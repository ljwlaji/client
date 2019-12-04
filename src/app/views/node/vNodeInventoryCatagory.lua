local ViewBaseEx 				= import("app.views.ViewBaseEx")
local vNodeInventoryCatagory 	= class("vNodeInventoryCatagory", ViewBaseEx)

vNodeInventoryCatagory.RESOURCE_FILENAME = "res/csb/node/CSB_Node_InventoryCatagory.csb"
vNodeInventoryCatagory.RESOURCE_BINDING = {
	Panel_Catagory = "onTouchCatagory"
}

function vNodeInventoryCatagory:onCreate()

end

function vNodeInventoryCatagory:onReset()

end

function vNodeInventoryCatagory:onTouchCatagory(e)
	if e.name ~= "ended" then return end
	if cc.pGetDistance(e.target:getTouchBeganPosition(), e.target:getTouchEndPosition()) > 20 then return end
	release_print("onTouchCatagory")
end


return vNodeInventoryCatagory
local ViewBaseEx 			= import("app.views.ViewBaseEx")
local ShareDefine			= import("app.ShareDefine")
local vNodeInventorySlot 	= class("vNodeInventorySlot", ViewBaseEx)

vNodeInventorySlot.RESOURCE_FILENAME = "res/csb/node/CSB_Node_InventorySlot.csb"
vNodeInventorySlot.RESOURCE_BINDING = {
	Panel_Slot = "onTouchSlot"
}

function vNodeInventorySlot:onCreate()
	self.m_Children["Panel_Slot"]:setSwallowTouches(false)
end

function vNodeInventorySlot:onReset(context)
	self.context = context
	if context == "null" then
		self.m_Children["Panel_Icon"]:setVisible(false) 
		return
	end
	if context then self.m_Children["Sprite_Icon"]:setTexture(ShareDefine.getItemIconPath(context.template)) end
	self.m_Children["Panel_Icon"]:setVisible(true)
end

function vNodeInventorySlot:onTouchSlot(e)
	if e.name ~= "ended" then return end
	if cc.pGetDistance(e.target:getTouchBeganPosition(), e.target:getTouchEndPosition()) > 20 then return end
	release_print("onTouchSlot")
end

return vNodeInventorySlot
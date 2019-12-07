local ViewBaseEx 			= import("app.views.ViewBaseEx")
local ShareDefine			= import("app.ShareDefine")
local WindowMgr				= import("app.components.WindowMgr")
local vNodeInventorySlot 	= class("vNodeInventorySlot", ViewBaseEx)

vNodeInventorySlot.RESOURCE_FILENAME = "res/csb/node/CSB_Node_InventorySlot.csb"
vNodeInventorySlot.RESOURCE_BINDING = {
	Panel_Slot = "onTouchSlot"
}

function vNodeInventorySlot:onCreate()
	self.m_Children["Panel_Slot"]:setSwallowTouches(false)
end

function vNodeInventorySlot:onReset(context, forPreview)
	self.context = context
	self.forPreview = forPreview
	if context == "null" then
		self.m_Children["Panel_Icon"]:setVisible(false) 
		return
	end
	if context then self.m_Children["Sprite_Icon"]:setTexture(ShareDefine.getItemIconPath(context.template)) end
	self.m_Children["Panel_Icon"]:setVisible(true)
end

function vNodeInventorySlot:onTouchSlot(e)
	if e.name ~= "ended" or self.context == "null" then return end
	WindowMgr:createWindow("app.views.layer.vLayerItemDetail", self.context, self.forPreview and 0 or 2)
	do return end
	local window = WindowMgr:findWindowIndexByClassName("vLayerItemDetail")
	if e.name == "ended" or e.name == "cancelled" then
		if window then window:removeFromParent() end
		return 
	end
	if window then return end
	WindowMgr:createWindow("app.views.layer.vLayerItemDetail"):onReset(self.context, 2)
end

return vNodeInventorySlot
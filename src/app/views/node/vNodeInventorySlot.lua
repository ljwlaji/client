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
	self.m_Children["Text_Amount"]:setString(context.item_amount)
end

function vNodeInventorySlot:onTouchSlot(e)
	-- if self.__onTouchHold then return end
	-- if e.name == "began" then self:runSequence( cc.DelayTime:create(1), cc.CallFunc:create( handler(self, self.onTouchHoldCallback) ) ) return end
	if e.name ~= "ended" or self.context == "null" then return end
	WindowMgr:createWindow("app.views.layer.vLayerItemDetail", self.context, self.forPreview and 0 or 2)
end

return vNodeInventorySlot
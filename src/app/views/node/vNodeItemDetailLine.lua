local ViewBaseEx 				= import("app.views.ViewBaseEx")
local vNodeItemDetailLine 		= class("vNodeItemDetailLine", ViewBaseEx)

vNodeItemDetailLine.RESOURCE_FILENAME = "res/csb/node/CSB_Node_ItemDetail_Line.csb"
vNodeItemDetailLine.RESOURCE_BINDING = {
}

function vNodeItemDetailLine:onCreate()
	self.m_Children["Text_String"]:setString(self.context)
end

function vNodeItemDetailLine:onReset(context, color)
	self.m_Children["Text_String"]:setString(context)
	if color then self.m_Children["Text_String"]:setColor(color) end
end


return vNodeItemDetailLine
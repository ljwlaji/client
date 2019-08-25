local ViewBaseEx = class("ViewBaseEx", cc.load("mvc").ViewBase)

function ViewBaseEx:autoAlgin()
	self:setContentSize(display.width, display.height)

	if self.m_Children["node_Left_Up"] 			then self.m_Children["node_Left_Up"]:move(0, display.height):setAnchorPoint(0, 1) 	end
	if self.m_Children["node_Left"] 			then self.m_Children["node_Left"]:move(0, display.cy):setAnchorPoint(0, 0.5) 		end
	if self.m_Children["node_Left_Buttom"] 		then self.m_Children["node_Left_Buttom"]:move(0, 0):setAnchorPoint(0, 0) 			end

	if self.m_Children["node_Center_Up"] 		then self.m_Children["node_Center_Up"]:move(display.cx, display.height):setAnchorPoint(0.5, 1) end
	if self.m_Children["node_Center"] 			then self.m_Children["node_Center"]:move(display.cx, display.cy):setAnchorPoint(0.5, 0.5) end
	if self.m_Children["node_Center_Buttom"] 	then self.m_Children["node_Center_Buttom"]:move(display.cx, 0):setAnchorPoint(0.5, 0) end

	if self.m_Children["node_Right_Up"] 		then self.m_Children["node_Right_Up"]:move(display.width, display.height):setAnchorPoint(1, 1) end
	if self.m_Children["node_Right"] 			then self.m_Children["node_Right"]:move(display.width, display.cy):setAnchorPoint(1, 0.5) end
	if self.m_Children["node_Right_Buttom"] 	then self.m_Children["node_Right_Buttom"]:move(display.width, 0):setAnchorPoint(1, 0) end
end


return ViewBaseEx
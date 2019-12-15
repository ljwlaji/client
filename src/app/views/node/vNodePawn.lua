local ViewBaseEx 	= import("app.views.ViewBaseEx")
local DataBase 		= import("app.components.DataBase")
local vNodePawn 	= class("vNodePawn", ViewBaseEx)


vNodePawn.RESOURCE_FILENAME = "res/csb/node/CSB_Node_Pawn.csb"
vNodePawn.RESOURCE_BINDING = {}

function vNodePawn:onCreate()
	self.m_Children["LiveBar"]:setPercent(10)
	self.m_Children["ManaBar"]:setPercent(20)
end

function vNodePawn:init(owner)
	self.m_Model = owner:createModelByID():addTo(self.m_Children["Node_Character"]):setAnchorPoint(0.5, 0)
	return self
end

function vNodePawn:modifyHealth(curr, max)
	self.m_Children["LiveBar"]:setPercent(curr / max * 100)
	return self
end

function vNodePawn:setFlippedX(value)
	self.m_Children["Node_Character"]:setScaleX( value and -1 or 1 )
	return self
end

function vNodePawn:setName(name)
	self.m_Children["Label_Name"]:setString(name)
	return self
end


return vNodePawn
local ViewBaseEx 	= import("app.views.ViewBaseEx")
local DataBase 		= import("app.components.DataBase")
local vNodePawn 	= class("vNodePawn", ViewBaseEx)


vNodePawn.RESOURCE_FILENAME = "res/csb/node/CSB_Node_Pawn.csb"
vNodePawn.RESOURCE_BINDING = {}

function vNodePawn:onCreate()
	self.m_Children["LiveBar"]:setPercent(10)
	self.m_Children["ManaBar"]:setPercent(20)
end

function vNodePawn:modifyHealth(curr, max)
	self.m_Children["LiveBar"]:setPercent(curr / max * 100)
end

function vNodePawn:setFlippedX(value)
	self.m_Children["Node_Character"]:setScaleX( value and 1 or -1 )
end


return vNodePawn
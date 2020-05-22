local ViewBaseEx 	= import("app.views.ViewBaseEx")
local DataBase 		= import("app.components.DataBase")
local vNodePawn 	= class("vNodePawn", ViewBaseEx)


vNodePawn.RESOURCE_FILENAME = "res/csb/node/CSB_Node_Pawn.csb"
vNodePawn.RESOURCE_BINDING = {}

function vNodePawn:onCreate()
	self:regiestCustomEventListenter("MSG_ON_ATTR_CHANGED", function() self:setDataDirty(true) end)
	self:onUpdate(function() 
		if self:isDataDirty() then
			self:onReset()
			self:setDataDirty(false)
		end
	end)
	self:setDataDirty(true)
end

function vNodePawn:init(owner)
	self.getOwner = function() return owner end
	self.m_Model = self:getOwner():createModelByID():addTo(self.m_Children["Node_Character"]):setAnchorPoint(0.5, 0)
	return self
end

function vNodePawn:onReset()
	local owner = self:getOwner()
	self.m_Children["HealthBar"]:setPercent(owner:getAttr("health") / owner:getAttr("maxHealth") * 100)
	self.m_Children["ManaBar"]:setPercent(owner:getAttr("mana") / owner:getAttr("maxMana") * 100)
end

function vNodePawn:isDataDirty()
	return self.m_DataDirty
end

function vNodePawn:setDataDirty(dirty)
	self.m_DataDirty = dirty
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
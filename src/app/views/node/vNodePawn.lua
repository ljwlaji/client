local ViewBaseEx 	= import("app.views.ViewBaseEx")
local DataBase 		= import("app.components.DataBase")
local ShareDefine 	= import("app.ShareDefine")
local FactionMgr	= import("app.components.FactionMgr")
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
	self:onNodeEvent("cleanup", handler(self, self.cleanUpBeforeDelete))
end

function vNodePawn:init(owner)
	self.getOwner = function() return owner end
	self.m_Model = self.m_Model or self:getOwner():createModelByID():addTo(self.m_Children["Node_Character"]):setAnchorPoint(0.5, 0)
	return self
end

function vNodePawn:onReset()
	local plr = import("app.components.Object.Player"):getInstance()
	local owner = self:getOwner()
	self.m_Children["HealthBar"]:setPercent(owner:getAttr("health") / owner:getAttr("maxHealth") * 100)

	local class = owner:getClass()
	local displayManaName = "mana"
	local displayManaMaxName = "maxMana"
	if class == ShareDefine.classWarrior() then
		displayManaName = "rage"
		displayManaMaxName = "maxRage"
 	elseif class == ShareDefine.classThief() then
		displayManaName = "enegry"
		displayManaMaxName = "maxEnegry"
	end

	self.m_Children["ManaBar"]:setPercent(owner:getAttr(displayManaName) / owner:getAttr(displayManaMaxName) * 100)
	if owner:isPlayer() then
		self.m_Children["Label_Name"]:setColor(cc.c3b(0,0,0))
	else
		self.m_Children["Label_Name"]:setColor(FactionMgr:isHostile(owner:getFaction(), plr:getFaction()) and cc.c3b(255, 0, 0) or cc.c3b(0, 255, 0))
	end
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

function vNodePawn:cleanUpBeforeDelete()
	release_print("[vNodePawn]:cleanUpBeforeDelete()")
end


return vNodePawn
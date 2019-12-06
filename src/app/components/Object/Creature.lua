local Unit = import("app.components.Object.Unit")
local ShareDefine = import("app.ShareDefine")
local DataBase = import("app.components.DataBase")
local Creature = class("Creature", Unit)

function Creature:onCreate()
	Unit.onCreate(self, ShareDefine:creatureType())
	self.m_Faction = self.context.faction
	self:setAlive(self.context.alive)
	self.m_Entry = self.context.entry
	if self.context.script_name and self.context.script_name ~= "" then
		self:initAI(self.context.script_name)
	end
	self:move(self.context.x, self.context.y)

	self.m_Model = self:createModelByID(self.context.model_id)
	self.m_Model:addTo(self):setAnchorPoint(0.5, 0)
	self:setName(DataBase:getStringByID(self.context.name_id))

	self:updateAttrs()
	-- For Testting
	local anims = {
		"attack",
		"celebrate",
		"combskill",
		"death",
		"dizzy",
		"dodge",
		"injured",
		"skill",
		"stand",
	}
	xpcall(function() 
		self.m_Model:setAnimation(0, "attack", false)
		self.m_Model:registerSpineEventHandler(function(event) 
			local index = math.random(1, #anims)
			self.m_Model:setAnimation(0, anims[index], false)
		end, sp.EventType.ANIMATION_COMPLETE)  
	end, function(...) dump({...}) end)
	-- End of testting
	
    self:setContentSize(50, 90)
    self:debugDraw()
end

function Creature:initAvatar()

end

function Creature:onUpdate(diff)
	Unit.onUpdate(self, diff)
end

function Creature:cleanUpBeforeDelete()
	release_print("Creature : cleanUpBeforeDelete()")
	Unit.cleanUpBeforeDelete(self)
end



return Creature

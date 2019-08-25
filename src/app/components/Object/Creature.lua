local Unit = import("app.components.Object.Unit")
local Creature = class("Creature", Unit)

function Creature:onCreate()
	
end

function Creature:onUpdate(diff)
	Unit.onUpdate(self, diff)
end



return Creature

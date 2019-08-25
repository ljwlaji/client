local Object = import("app.components.Object.Object")
local GameObject = class("GameObject", Object)

function GameObject:onCreate()

end

function GameObject:onUpdate(diff)
	Unit.onUpdate(self, diff)
end


return GameObject

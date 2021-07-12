local AreaAI = class("AreaAI")

function AreaAI:ctor(me)
	self.getOwner = function() return me end
end

function AreaAI:onCreate()

end

function AreaAI:onExit()

end


return AreaAI
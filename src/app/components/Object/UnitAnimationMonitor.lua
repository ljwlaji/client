local UnitAnimationMonitor = class("UnitAnimationMonitor")

function UnitAnimationMonitor:ctor(unit)
	self.getUnit = function() return unit end
end

function UnitAnimationMonitor:update(diff)

end

function UnitAnimationMonitor:cleanUpBeforeDelete()
	
end

return UnitAnimationMonitor
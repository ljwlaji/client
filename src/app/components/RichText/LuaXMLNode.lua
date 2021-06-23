local LuaXMLNode = class("LuaXMLNode")

function LuaXMLNode:ctor(name)
    self.___value = nil
    self.___type = name
    self.___children = {}
end

function LuaXMLNode:value() 
	return self.___value 
end

function LuaXMLNode:setValue(val) 
	self.___value = val 
end

function LuaXMLNode:getType() 
	return self.___type
end

function LuaXMLNode:setType(_type) 
	self.___type = _type
end

function LuaXMLNode:children() 
	return self.___children 
end

function LuaXMLNode:numChildren() 
	return #self.___children 
end

function LuaXMLNode:addChild(child)
    table.insert(self.___children, child)
end

function LuaXMLNode:addProperty(name, value)
    local lName = name
    self[lName] = value
end




return LuaXMLNode
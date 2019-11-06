
local ViewBase = class("ViewBase", cc.Node)

function ViewBase:ctor(app, name, ...)
    self:enableNodeEvents()
    self.app_ = app
    self.name_ = name
    self.m_Children = {}
    -- check CSB resource file
    local res = rawget(self.class, "RESOURCE_FILENAME")
    if res then
        self:createResourceNode(res)
    end

    local binding = rawget(self.class, "RESOURCE_BINDING")
    if res and binding then
        self:createResourceBinding(binding)
    end
    if self.onCreate then self:onCreate(...) end
end

function ViewBase:getApp()
    return self.app_
end

function ViewBase:getName()
    return self.name_
end

function ViewBase:getResourceNode()
    return self.resourceNode_
end

function ViewBase:fillAllChildren(rootNode)
    for k, v in pairs(rootNode:getChildren()) do
        assert(not self.m_Children[v:getName()])
        self.m_Children[v:getName()] = v
        self:fillAllChildren(v)
    end
end

function ViewBase:createView(...)
    return self.app_:createView(...)
end

function ViewBase:createResourceNode(resourceFilename)
    if self.resourceNode_ then
        self.resourceNode_:removeSelf()
        self.resourceNode_ = nil
    end
    self.resourceNode_ = cc.CSLoader:createNode(resourceFilename)
    assert(self.resourceNode_, string.format("ViewBase:createResourceNode() - load resouce node from file \"%s\" failed", resourceFilename))
    self:addChild(self.resourceNode_)
end

function ViewBase:createResourceBinding(binding)
    assert(self.resourceNode_, "ViewBase:createResourceBinding() - not load resource node")
    self:fillAllChildren(self.resourceNode_)
    for nodeName, nodeBinding in pairs(binding) do
        local node = self.m_Children[nodeName]
        if node and nodeBinding then node:onTouch(handler(self, self[nodeBinding])) end
    end
end

function ViewBase:showWithScene(transition, time, more)
    self:setVisible(true)
    local scene = display.newScene(self.name_)
    scene:addChild(self)
    display.runScene(scene, transition, time, more)
    return self
end

return ViewBase

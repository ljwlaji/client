
local MainScene = class("MainScene", cc.load("mvc").ViewBase)

function MainScene:onCreate()
	-- self:testShader()
    -- self:onUpdate(handler(self, self.testting))
    self:testCamera()
end

function MainScene:testCamera()
    self.map = cc.Sprite:create("background.jpeg")
                        :addTo(self)
                        :setAnchorPoint(0, 0)
                        :setContentSize(display.width, display.height)

    self.unit = cc.Sprite:create("HelloWorld.png")
                        :move(200, 200)
                        :addTo(self.map)
                        :setScale(1)
                        :setAnchorPoint(0.5, 0.5)

    dump(self.map:getPosition())
    self.unit.getMap = function() return self.map end

    self.camera = import("app.components.camera"):create(self.unit)

    -- self.camera:onUpdate(diff)

    self:onUpdate(function(this, diff) self.camera:onUpdate(diff) end)

end

function MainScene:testShader()
    local prog = cc.GLProgram:create("res/shader/base.vsh","res/shader/gblur.fsh")
    prog:link()
    prog:updateUniforms()
    local progStat= cc.GLProgramState:create(prog)
 
    --[[]]
    local sp = cc.Sprite:create("HelloWorld.png")
                        :move(display.cx, display.cy)
                        :addTo(self)
                        :setScale(1)
                        :setAnchorPoint(0.5, 0.5)
 
    sp:setGLProgram(prog)
    sp:setGLProgramState(progStat)
    prog:updateUniforms()
 	self.modiplyer = 1
 	self.sp = sp
 	self.progStat = progStat
 	self.prog = prog
end

function MainScene:testting()
    self.progStat:setUniformVec2(self.prog:getUniform("blurSize").location, cc.p(250, 250));
    self.prog:updateUniforms()

end

return MainScene

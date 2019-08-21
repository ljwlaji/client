
local MainScene = class("MainScene", cc.load("mvc").ViewBase)

function MainScene:onCreate()
	self:testShader()
    self:onUpdate(handler(self, self.testting))
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

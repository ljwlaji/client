
local MainScene     = class("MainScene", cc.load("mvc").ViewBase)
local Map           = import("app.components.Map")
local DataBase      = import("app.components.DataBase")
local Camera        = import("app.components.Camera")

local ZOrder_HUD = 100

function MainScene:onCreate()
    self.m_HUDLayer = import("app.views.layer.HUDLayer"):create():addTo(self):setLocalZOrder(ZOrder_HUD)
    self:startGame(1)
end

function MainScene:startGame(chosedCharacterID)
    local MapEntry = DataBase:query(string.format("SELECT * FROM character WHERE character_id = %d", chosedCharacterID))[1]["curr_map_entry"]
    self:tryEnterMap(MapEntry, chosedCharacterID)
end

function MainScene:tryEnterMap(mapEntry, chosedCharacterID)
    if self.currentMap then
        if self.currentMap:getEntry() == mapEntry then return end
        Camera:changeFocus(nil)
        self.currentMap:cleanUpBeforeDelete()
        self.currentMap:removeFromParent()
        self.currentMap = nil
    end

    self.currentMap = Map:create(mapEntry, chosedCharacterID):addTo(self)

    if not self.Timmer then
        self.Timmer = cc.Timmer:create():addTo(self)
        self:onUpdate(handler(self, self.onNativeUpdate))
    end
end

function MainScene:onNativeUpdate()
    local diff = self.Timmer:getMSDiff()
    if diff >= 16 then
        self.Timmer:reset()
        if self.currentMap then self.currentMap:onUpdate(diff) end
        Camera:onUpdate(diff)
    end
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

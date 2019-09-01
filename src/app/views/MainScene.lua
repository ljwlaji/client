
local MainScene     = class("MainScene", cc.load("mvc").ViewBase)
local Map           = import("app.components.Map")
local DataBase      = import("app.components.DataBase")
local Camera        = import("app.components.Camera")
local GameObject    = import("app.components.Object.GameObject")
local GridView      = import("app.components.GridView")
local Utils         = import("app.components.Utils")
local MapExtractor  = import("devTools.MapExtractor")
local ZOrder_HUD    = 100

function MainScene:onCreate()
    self:fileCopy()
    self.m_HUDLayer = import("app.views.layer.HUDLayer"):create():addTo(self):setLocalZOrder(ZOrder_HUD)
    self:startGame(1)
end

function MainScene:fileCopy( ... )
    local path = cc.FileUtils:getInstance():getWritablePath()
    Utils.recursionCopy(path.."res\\", Utils.getDownloadPath())
end


function MainScene:testGridView()
    local datas = {}
    for i=1, 100 do
        table.insert(datas, i)
    end

    local gridView = GridView:create({
        viewSize    = { width = display.width, height = display.height},
        cellSize    = { width = display.width / 10,  height = display.height / 10 },
        rowCount    = 10,
        fieldCount  = 10,
        VGAP        = 5,
        HGAP        = 5,
    }):addTo(self):move(0, 0):setAnchorPoint(0, 0)

    gridView.onCellAtIndex = function(cell, data)
        release_print(data)
        cell.label = cell.label or cc.Label:createWithSystemFont(data, display.DEFAULT_TTF_FONT, 20):addTo(cell):setAnchorPoint(0, 0):move(0, 0)
        cell.label:setString(data)
    end
    gridView:setDatas(datas)
end

function MainScene:testTableView()
    self.tableView = import("app.components.TableViewEx"):create({
        cellSize = cc.size(300, 40),
        direction = cc.SCROLLVIEW_DIRECTION_VERTICAL,
        fillOrder = cc.TABLEVIEW_FILL_TOPDOWN,
        size = cc.size(300, 300),
    }):addTo(self)
    self.tableView:onCellAtIndex(
        function(cell, index)
            cell.label = cell.label or cc.Label:createWithSystemFont(index, display.DEFAULT_TTF_FONT, 20):addTo(cell):setAnchorPoint(0, 0):move(0, 0)
            cell.label:setString(index)
            return cell
        end)
    local datas = {1,2,3,4,5,6}
    self.tableView:setNumbers(#datas):reloadData()
end

function MainScene:debugDraw(parent, color, size)
    if parent.__drawNode then parent.__drawNode:removeFromParent() end
    local myDrawNode=cc.DrawNode:create()
    parent:addChild(myDrawNode)
    myDrawNode:setPosition(0, 0)
    size = size or cc.p(parent:getContentSize().width, parent:getContentSize().height)
    myDrawNode:drawSolidRect(cc.p(0, 0), size, color or cc.c4f(1,1,1,1))
    myDrawNode:setLocalZOrder(-10)
    parent.__drawNode = myDrawNode
end

function MainScene:testMapExtractor()
    MapExtractor:create(self):run()
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

function MainScene:testPixalCollisionMgr()
        -- self:testPixalCollisionMgr()
    local testpng = "res/image180.png"

    local sp = cc.Sprite:create(testpng):addTo(self):setAnchorPoint(1, 0):move(display.center)
    local width = sp:getContentSize().width
    local height = sp:getContentSize().height
    cc.PixalCollisionMgr:getInstance():loadPNGData(testpng)
    local output = ""
    local oldy = 0
    for y=0,height do
        for x=0,width do
            local visible = cc.PixalCollisionMgr:getInstance():getAlpha(testpng, x, y)
            cc.DrawNode:create():drawDot(cc.p(1,1), 1.0, cc.c4f(1,1,1, visible and 1 or 0)):addTo(self):move(display.cx + x, display.cy + y)
        end
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

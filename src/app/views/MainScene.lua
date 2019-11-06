
local MainScene     = class("MainScene", cc.load("mvc").ViewBase)
local Camera        = import("app.components.Camera")
local GridView      = import("app.components.GridView")
local LayerEntrance = import("app.views.layer.LayerEntrance")
local Map           = import("app.components.Map")

local updateCount = 0
local totalMS = 0


function MainScene:onCreate()
    self.sycnUpdateList = {}
end

function MainScene:onEnterTransitionFinish()

    self:testGausBlurSprite()
    do return end
    self:run()
    self:createView("layer.LayerEntrance", function() 
        self.m_HUDLayer = import("app.views.layer.HUDLayer"):create():addTo(self):setLocalZOrder(99999999)
        self:startGame(1)
    end):addTo(self)
end

function MainScene:run()
    if not self.Timmer then
        self.Timmer = cc.Timmer:create():addTo(self)
        self:onUpdate(handler(self, self.onNativeUpdate))
    end
end

function MainScene:onNativeUpdate()
    local diff = self.Timmer:getMSDiff()
    if diff >= 5 then
        self.Timmer:reset()
        -- Update All Sync Views
        for k, v in pairs(self.sycnUpdateList) do v(diff) end

        -- Update The World
        if self.currentMap then self.currentMap:onUpdate(diff) end

        -- Update Camera
        Camera:onUpdate(diff)
        totalMS = totalMS + diff
        updateCount = updateCount + 1
        if updateCount >= 500 then
            release_print(string.format("World Update Time Diff : [%d] ms(s)", totalMS / 500))
            totalMS = 0
            updateCount = 0
        end
    end
end


function MainScene:addNodeSyncUpdate(node, func)
    self.sycnUpdateList[node] = func
end

function MainScene:removeNodeFromSyncUpdateList(node)
    if self.sycnUpdateList[node] then self.sycnUpdateList[node] = nil end
end












function MainScene:testGausBlurSprite()

    local sp = cc.GausBlurSprite:createWithImage("player.png"):addTo(self):move(display.center)
    local img = self:ScreenImage()
    local ssp = cc.GausBlurSprite:createWithImage(img):addTo(self):move(display.center)
    sp:removeFromParent()


    self.diff = 350
    self:onUpdate(function() 
        if self.diff >= 300 then
            self.diff = self.diff - 1
            return
        end
        if self.diff < 0 then
            cc.SpriteFrameCache:getInstance():removeUnusedSpriteFrames()
            cc.Director:getInstance():getTextureCache():removeUnusedTextures()
            return
        end
        if self.diff == 0 then
            if ssp then
                ssp:removeFromParent()
                ssp = nil
            end
        else
            if ssp then ssp:override() end
            self.diff = self.diff - 1
        end
    end)

    dump(cc.GausBlurSprite)
end

function MainScene:ScreenShot()
    local texture = cc.RenderTexture:create(display.width, display.height, cc.TEXTURE2_D_PIXEL_FORMAT_RGB_A8888)
    texture:beginWithClear(0, 0, 0, 0)
    display.getRunningScene():visit()
    texture:endToLua()
    texture:saveToFile("test.png", cc.IMAGE_FORMAT_PNG); 
end

function MainScene:ScreenImage()
    local texture = cc.RenderTexture:create(display.width, display.height, cc.TEXTURE2_D_PIXEL_FORMAT_RGB_A8888)
    local img = nil
    texture:beginWithClear(0, 0, 0, 0)
    display.getRunningScene():visit()
    texture:endToLua()
    cc.Director:getInstance():drawScene();
    img = texture:newImage()
    return img
end


function MainScene:testGridView()
    local datas = {}
    for i=1, 100 do
        table.insert(datas, i)
    end

    local gridView = GridView:create({
        viewSize    = { width = display.width,          height = display.height},
        cellSize    = { width = display.width / 10,     height = display.height / 10 },
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
    local MapEntry = import("app.components.DataBase"):query(string.format("SELECT * FROM character WHERE character_id = %d", chosedCharacterID))[1]["curr_map_entry"]
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

function MainScene:testPixalCollisionMgr()
        -- self:testPixalCollisionMgr()
    local testpng = "res/player.png"

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

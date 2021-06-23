local MainScene     = class("MainScene", cc.load("mvc").ViewBase)
local Camera        = import("app.components.Camera")
local GridView      = import("app.components.GridView")
local LayerEntrance = import("app.views.layer.LayerEntrance")
local Map           = import("app.components.Map")
local ShareDefine   = import("app.ShareDefine")

local updateCount = 0
local totalMS = 0

function MainScene:onCreate()
    self.sycnUpdateList = {}
end

function MainScene:onEnterTransitionFinish()
    local chosedCharacterID = 1
    self:run()
    self:createView("layer.LayerEntrance", function()
        self.m_HUDLayer = import("app.views.layer.vLayerHUD"):create():addTo(self):setLocalZOrder(ShareDefine.getZOrderByType("ZORDER_HUD_LAYER"))
        self:startGame(chosedCharacterID)
        self.m_HUDLayer:onReset()
    end):addTo(self)
end

function MainScene:run()
    -- local sp = cc.Sprite:create("test_character.png")
    --                     :addTo(self)
    --                     :move(display.cx, display.cy)
    --                     :setScale(0.3)


    -- self:testShader(sp)
    -- do return end
    if not self.Timmer then
        self.Timmer = cc.Timmer:create():addTo(self)
        self:onUpdate(handler(self, self.onNativeUpdate))
    end
end

function MainScene:onNativeUpdate()
    local diff = self.Timmer:getMSDiff()
    if diff >= 15 then
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










function MainScene:testRichText()
    local richtext = import("app.components.RichText.UIRichText")
    
end

function MainScene:testGausBlurSprite(Scale)
    Scale = Scale or 0.2
    local img = self:ScreenImage(Scale)
    self.ssp = cc.GausBlurSprite:createWithImage(img):addTo(self):move(display.center):setScale(1 / Scale)
end

function MainScene:ScreenShot()
    local texture = cc.RenderTexture:create(display.width, display.height, cc.TEXTURE2_D_PIXEL_FORMAT_RGB_A8888)
    texture:beginWithClear(0, 0, 0, 0)
    display.getRunningScene():visit()
    texture:endToLua()
    texture:saveToFile("test.png", cc.IMAGE_FORMAT_PNG); 
end

function MainScene:ScreenImage(scale)
    scale = scale or 1
    local texture = cc.RenderTexture:create(display.width * scale, display.height * scale, cc.TEXTURE2_D_PIXEL_FORMAT_RGB_A8888)
    local img = nil
    self:setScale(scale)
    texture:beginWithClear(0, 0, 0, 0)
    display.getRunningScene():visit()
    texture:endToLua()
    cc.Director:getInstance():drawScene();
    img = texture:newImage()
    self:setScale(1)
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
    import("app.components.SpellMgr"):loadFromDB()
    import("app.components.FactionMgr"):loadFromDB()
    local MapEntry = import("app.components.DataBase"):query(string.format("SELECT * FROM character_instance WHERE guid = %d", chosedCharacterID))[1]["map"]
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

local vertSource = "\n"..
"attribute vec4 a_position; \n" ..
"attribute vec2 a_texCoord; \n" ..
"#ifdef GL_ES \n" .. 
"varying mediump vec2 v_texCoord;\n" ..
"#else \n" ..
"varying vec2 v_texCoord;\n" ..
"#endif\n" ..

"void main()\n" ..
    "{\n" .. 
    " gl_Position = CC_PMatrix * a_position;\n"..
    " v_texCoord = a_texCoord;\n" ..
"}\n"


local fragSource =  "\n" ..
"#ifdef GL_ES \n" ..
"precision mediump float; \n" ..
"#endif \n" ..
"varying vec4 v_fragmentColor; \n" ..
"varying vec2 v_texCoord; \n" ..
"uniform vec2 resolution; \n" ..
"uniform float blurRadius;\n" ..
"uniform float sampleNum; \n" ..
"vec4 blur(vec2);\n" ..
"\n" ..

"void main(void)\n" ..
"{\n" ..
"    vec4 col = blur(v_texCoord); //* v_fragmentColor.rgb;\n" ..
"    gl_FragColor = vec4(col);\n" ..
"}\n" ..
"\n" ..

"vec4 blur(vec2 p)\n" ..
"{\n" ..
"    if (blurRadius > 0.0 && sampleNum > 1.0)\n" ..
"    {\n" ..
"        vec4 col = vec4(0);\n" ..
"        vec2 unit = 1.0 / resolution.xy;\n" .. -- 这边是步进长度
" \n" ..       
"        float r = blurRadius;\n" ..
"        float sampleStep = r / sampleNum;\n" ..
"\n" ..        
"        float count = 0.0;\n" ..
"\n" ..        
"        for(float x = -r; x < r; x += sampleStep)\n" ..
"        {\n" ..
"            for(float y = -r; y < r; y += sampleStep)\n" ..
"            {\n" ..
"                float weight = (r - abs(x)) * (r - abs(y));\n" ..
"                col += texture2D(CC_Texture0, p + vec2(x * unit.x, y * unit.y)) * weight;\n" ..
"                count += weight;\n" ..
"            }\n" ..
"        }\n" ..
"\n" ..        
"        return col / count;\n" ..
"    }\n" ..
"\n" .. 
"    return texture2D(CC_Texture0, p);\n" ..
"}\n"

function MainScene:setShader(spr)
    local pProgram = cc.GLProgram:createWithByteArrays(vertSource,fragSource)
    -- local pProgram = cc.GLProgram:create("res/shader/base.vsh","res/shader/gblur.fsh")
    local glprogramstate = cc.GLProgramState:getOrCreateWithGLProgram(pProgram)
    local size = spr:getTexture():getContentSizeInPixels()
    spr.m_GLPrograme = pProgram
    spr.m_GLProgrameState = glprogramstate
    spr:setGLProgramState(glprogramstate)
    glprogramstate:setUniformVec2(pProgram:getUniform("resolution").location, cc.p(size.width, size.height));
    glprogramstate:setUniformFloat(pProgram:getUniform("blurRadius").location, 0);
    glprogramstate:setUniformFloat(pProgram:getUniform("sampleNum").location, 0)
end


function MainScene:testShader(sp)

    self:setShader(sp)
    local size = sp:getTexture():getContentSizeInPixels()

    local blurRadius = 0
    local sampleNum = 0
    local resolution = cc.p(size.width, size.height)
    local i = 2
    sp:onUpdate(function()
            if blurRadius > 30 then return end
            blurRadius = blurRadius + 0.2
            local glprogramstate = sp.m_GLProgrameState
            local prog = sp.m_GLPrograme

            glprogramstate:setUniformVec2(prog:getUniform("resolution").location, resolution);
            glprogramstate:setUniformFloat(prog:getUniform("blurRadius").location, blurRadius);
            glprogramstate:setUniformFloat(prog:getUniform("sampleNum").location, 5)
    end)
end

return MainScene

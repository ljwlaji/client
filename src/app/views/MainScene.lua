local MainScene     = class("MainScene", cc.load("mvc").ViewBase)
local Camera        = require("app.components.Camera")
local GridView      = require("app.components.GridView")
local Map           = require("app.components.Map")
local ShareDefine   = require("app.ShareDefine")
local LayerEntrance = require("app.views.layer.LayerEntrance")

local updateCount = 0
local totalMS = 0

function MainScene:onCreate()
    self.sycnUpdateList = {}
end

function MainScene:onEnterTransitionFinish()
end

function MainScene:run()
	self:testShader(cc.Sprite:create("res/HelloWorld.png"):addTo(self):move(display.center), 0.5)
	do return end
    local chosedCharacterID = 1
    if not self.Timmer then
        self.Timmer = cc.Timmer:create():addTo(self)
        self:onUpdate(handler(self, self.onNativeUpdate))
    end
    LayerEntrance:create(function() 
        self.m_HUDLayer = import("app.views.layer.vLayerHUD"):create():addTo(self):setLocalZOrder(ShareDefine.getZOrderByType("ZORDER_HUD_LAYER"))
        self:startGame(chosedCharacterID)
        self.m_HUDLayer:onReset()
    end):addTo(self)
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








function MainScene:testSqliteGetAllTables()
    local db = import("app.components.DataBase")
    local originDB = {}
    local results = db:query("select name from sqlite_master where type='table' order by name;")
    for _, v in pairs(results) do
        originDB[v.name] = db:query("SELECT * FROM ")
    end
end


function MainScene:testRichText()
    local UIRichText = import("app.components.RichText.UIRichText")
    local text = "| t=?????????????????????????????????123456789123456789123456789 @ s=30 @ c=FFFFFF @ ul = true @ ol = true @ ols = 2 @ olc=FF0000 |t=__?????????????????????12345678 @ c=FF00FF|t=__?????????????????????12345678 @ c=FF00FF | ip=res/Default/1.png"
    local rich = UIRichText:create({
            maxLineHeight = 30,
            maxLineWidth  = 500,
            VGAP = 0,
            HGAP = 0,
            VALIGN = "center",
        })
    rich:setAnchorPoint(0.5, 0.5)
    rich["???"] = handler(self, self.testFunction)
    rich:generateFromString(text):addTo(self):move(display.cx, display.cy)
    rich:debugDraw(rich, cc.c4f(1,1,0,0.3))
end

function MainScene:testGausBlurSprite(img, Scale)
    Scale = Scale or 0.2
    -- local img = self:ScreenImage(Scale)
    self.ssp = cc.GausBlurSprite:createWithImage(img):addTo(self):move(display.center):setScale(Scale)
    local timer = 500
    self:onUpdate(function() 
        if timer < 16 then
            timer = 500
            self.ssp:override()
        else
            timer = timer - 16
        end
    end)
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
    self:visit()
    texture:endToLua()
    cc.Director:getInstance():drawScene();
    img = texture:newImage()
    self:setScale(1)
    return img
end

function MainScene:testLineOfSight()
    require("app.dev.UnitTestLineOfSight")(self)
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


local fragSource =  [[#ifdef GL_ES 
precision mediump float; 
#endif 
varying vec4 v_fragmentColor; 
varying vec2 v_texCoord; 
uniform vec2 resolution; 
uniform float blurRadius;
uniform float time; 
uniform float offsetY; 


vec4 gray(void);
vec4 transform(void);
vec4 move(void);
vec4 center(void);
vec4 blackPoint(void);
vec4 pointLight(void);
vec4 wave(void);
vec4 wave2(void);
vec4 wave3(void);

float rand(vec2 co){
    return fract(sin(dot(co, vec2(12.9898, 78.233))) * 43758.5453);
}

void main(void)
{
    gl_FragColor = wave3();
}

vec4 gray(void)
{
	vec4 color = texture2D(CC_Texture0, v_texCoord);
	color.r = color.g;
	color.g = color.g;
	color.b = color.g;
    return color;
}

vec4 transform(void)
{
	vec4 color = texture2D(CC_Texture0, v_texCoord);
	color.r = color.r > 0.5 ? 1.0 : 0.0;
    return color;
}

vec4 center(void)
{
	vec2 cord = v_texCoord.xy;
	vec2 center = vec2(0.5, 0.5);
	vec2 distance = cord - center;
	float dis = sqrt( distance.x * distance.x + distance.y * distance.y );
	if (dis > time)
		return vec4(0, 0, 0, 1);
	return texture2D(CC_Texture0, v_texCoord);
}

vec4 blackPoint(void)
{
	vec2 cord = v_texCoord.xy;
	vec2 center = vec2(time, time);
	float radio = 0.5;
	vec2 distance = cord - center;
	float dis = sqrt( distance.x * distance.x + distance.y * distance.y );
	if (dis > radio)
		return texture2D(CC_Texture0, v_texCoord);
	//return texture2D(CC_Texture0, v_texCoord) * (dis / radio);
	return texture2D(CC_Texture0, v_texCoord) * abs(1.0 - (dis / radio)); // ????????????
}

vec4 pointLight(void)
{
	float radio = 0.5;
	float lightWidget = 1.5;

	vec2 cord = v_texCoord.xy;
	vec2 center = vec2(time, time);
	vec2 distance = cord - center;
	float dis = sqrt( distance.x * distance.x + distance.y * distance.y );
	if (dis > radio)
		return vec4(0.0, 0.0, 0.0, 0.0);
	return texture2D(CC_Texture0, v_texCoord) * abs(1.0 - (dis / radio)) * lightWidget/* ???????????? */;
}

vec4 wave(void)
{
	vec2 cord = v_texCoord.xy;
	float offsetX = cos((cord.y * time/*??????*/ / 0.0125 /*?????????????????????*/ ));
	//cord.x += offsetX * 0.025/*?????????????????????*/;
	cord.x += offsetX * 0.025/*?????????????????????*/;
	return texture2D(CC_Texture0, cord);
}

vec4 wave2(void)
{
	vec2 cord = v_texCoord.xy;
	float offsetX = cos(((cord.y + time/*??????*/) / 0.025 /*?????????????????????*/ ));
	//cord.x += offsetX * 0.025/*?????????????????????*/;
	cord.x += offsetX * 0.025/*?????????????????????*/;
	return texture2D(CC_Texture0, cord);
}

vec4 wave3(void)
{
	vec2 cord = v_texCoord.xy;
	float offsetX = sin(((cord.y + time/*??????*/) / 0.04 /*?????????????????????*/ ));
	float offsetY = cos(((cord.x + time/*??????*/) / 0.04 /*?????????????????????*/ ));
	cord.y += offsetY * 0.02/*?????????????????????*/;
	cord.x += offsetX * 0.02/*?????????????????????*/;
	return texture2D(CC_Texture0, cord);
}

vec4 circle(void)
{
	
	return texture2D(CC_Texture0, cord);
}

vec4 move(void)
{

	vec2 cord = v_texCoord.xy;
	cord.x *= 0.7;
    return texture2D(CC_Texture0, cord);
}

]]

local circleFrag =  [[#ifdef GL_ES 
precision mediump float; 
#endif 
varying vec4 v_fragmentColor; 
varying vec2 v_texCoord; 
uniform float time;
uniform float time2;
uniform float time3;
uniform float time4;


void render(float pRadio, float pRadio2, float pRadio3, float pRadio4)
{
	vec2 cord = vec2( abs( 0.5 - v_texCoord.x ), abs( 0.5 - v_texCoord.y) );
	float dis = sqrt((cord.x * cord.x + cord.y * cord.y));
	float radio = abs(dis - pRadio);
	float radio2 = abs(dis - pRadio2);
	float radio3 = abs(dis - pRadio3);
	float radio4 = abs(dis - pRadio4);
	if (abs(radio) <= 0.05)
		gl_FragColor = texture2D(CC_Texture0, v_texCoord - radio);
	else if (abs(radio2) <= 0.05)
		gl_FragColor = texture2D(CC_Texture0, v_texCoord - radio2);
	else if (abs(radio3) <= 0.05)
		gl_FragColor = texture2D(CC_Texture0, v_texCoord - radio3);
	else if (abs(radio4) <= 0.05)
		gl_FragColor = texture2D(CC_Texture0, v_texCoord - radio4);
	else
		gl_FragColor = texture2D(CC_Texture0, v_texCoord);
}

void main(void)
{
	render(mod(time, 1.0), mod(time2, 1.0), mod(time3, 1.0), mod(time4, 1.0));
}


]]

function MainScene:setShader(spr)
    -- local pProgram = cc.GLProgram:createWithByteArrays(vertSource,fragSource)
    local pProgram = cc.GLProgram:createWithByteArrays(vertSource,circleFrag)
    -- local pProgram = cc.GLProgram:create("res/shader/base.vsh","res/shader/gblur.fsh")
    local glprogramstate = cc.GLProgramState:getOrCreateWithGLProgram(pProgram)
    local size = spr:getTexture():getContentSizeInPixels()
    spr.m_GLPrograme = pProgram
    spr.m_GLProgrameState = glprogramstate
    spr:setGLProgramState(glprogramstate)
end


function MainScene:testShader(sp)
    self:setShader(sp)
    local time = 0
    local offsetY = 0
    local glprogramstate = sp.m_GLProgrameState
    local prog = sp.m_GLPrograme
    sp:onUpdate(function()
    	time = time + 0.005
        glprogramstate:setUniformFloat(prog:getUniform("time").location, time)
        glprogramstate:setUniformFloat(prog:getUniform("time2").location, time + 0.2)
        glprogramstate:setUniformFloat(prog:getUniform("time3").location, time + 0.4)
        glprogramstate:setUniformFloat(prog:getUniform("time4").location, time + 0.6)
        -- glprogramstate:setUniformFloat(prog:getUniform("offsetY").location, math.min(1, offsetY))
    end)
end

return MainScene

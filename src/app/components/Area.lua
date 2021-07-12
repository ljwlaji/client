local ViewBaseEx    = require("app.views.ViewBaseEx")
local Area          = class("Area", ViewBaseEx)

--[[
    Area 文档
    1. Area(区域) 隶属于Map
    2. 数据保存于数据库 Area_template
    3. 数据库数据结构
        1. entry 唯一ID
        2. parent_map 隶属于哪张地图(entry)
        3. width 宽度
        4. height 高度
        5. pos_x 坐标X 锚点统一为0.5, 0.5
        6. pos_y 坐标Y 锚点统一为0.5, 0.5
        7. scriptName 脚本名 --默认为 AreaAI.lua
    4. 地面数据(非可交互部分) 在/res/area/[entry].csb存放 加载时一次性加载到游戏内
    5. 可接触部分如(生物, 游戏对象) 在数据库内动态加载
]]
function Area:ctor(context)
    self:enableNodeEvents()
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
    
    self.m_context = context or {}
    self.m_ObjectArray = {}
    local scriptPath = (content.scriptName and content.scriptName ~= "") and "Area."..content.scriptName or "AreaAI" 
    self.m_Script = require(string.format("app.scripts.", scriptPath)):create(self)
    if self.onCreate then self:onCreate(...) end
end

function Area:onCreate()
    self:getScript():onCreate()
    self:loadObjectFromDB()
end

function Area:onExit()
    self:getScript():onExit()
end

function Area:cleanUpBeforeDelete()
    
end

function Area:onPlayerApproach()

end

function Area:onPlayerLeaveFar()

end

function Area:getScript()
    return self.m_Script
end

return Area
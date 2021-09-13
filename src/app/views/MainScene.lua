local MainScene     = class("MainScene", cc.load("mvc").ViewBase)
local WindowMgr 	= require("app.components.WindowMgr")
local ShareDefine   = require("app.ShareDefine")

local updateCount = 0
local totalMS = 0

local luaoc = {}

local callStaticMethod = LuaObjcBridge.callStaticMethod

function luaoc.callStaticMethod(className, methodName, args)
    local ok, ret = callStaticMethod(className, methodName, args)
    if not ok then
        local msg = string.format("luaoc.callStaticMethod(\"%s\", \"%s\", \"%s\") - error: [%s] ",
                className, methodName, tostring(args), tostring(ret))
        if ret == -1 then
            print(msg .. "INVALID PARAMETERS")
        elseif ret == -2 then
            print(msg .. "CLASS NOT FOUND")
        elseif ret == -3 then
            print(msg .. "METHOD NOT FOUND")
        elseif ret == -4 then
            print(msg .. "EXCEPTION OCCURRED")
        elseif ret == -5 then
            print(msg .. "INVALID METHOD SIGNATURE")
        else
            print(msg .. "UNKNOWN")
        end
    end
    return ok, ret
end

function MainScene:onCreate()
	-- require("app.components.DataBase"):openDB(cc.FileUtils:getInstance():getWritablePath().."res/datas.db")
end

function MainScene:run()

end

function MainScene:testTouchID()
    local ok, ret = luaoc.callStaticMethod("YZAuthID", "test", {
    	callback = function(...) dump({...}) end
    })
end

function MainScene:onEnterTransitionFinish()

-- 点击回调函数
	self:runAction(cc.Sequence:create(
		cc.DelayTime:create(1),
		cc.CallFunc:create(function() 
   			WindowMgr:createWindow("app.views.layer.LayerEntrance", function()
                WindowMgr:createWindow("app.views.layer.vLayerPasswordKeeper")
                self:testTouchID()
            end)
		end)
	))
end

return MainScene

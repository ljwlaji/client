applicationDidEnterBackground = function()
    local pEvent = cc.EventCustom:new("MSG_APP_DID_ENTER_BACKGROUND")
    cc.Director:getInstance():getEventDispatcher():dispatchEvent(pEvent)
end

applicationWillEnterForeground = function()
    local pEvent = cc.EventCustom:new("MSG_APP_WILL_ENTER_FOREGROUND")
    cc.Director:getInstance():getEventDispatcher():dispatchEvent(pEvent)
end


cc.FileUtils:getInstance():setPopupNotify(false)

devRequire = function(path)
    if package.loaded[path] then
        package.loaded[path] = nil
    end
    return require(path)
end


require "config"
require "cocos.init"
require "app.components.UITextEx"
require "app.extensions.NodeEx"


__G__TRACKBACK__ = function(msg)
    local tbStr=debug.traceback("", 2)
    release_print("----------------------------------------")
    release_print("LUA ERROR: " .. tostring(msg) .. "\n")
    release_print(tbStr)
    release_print("----------------------------------------")

    return msg
end

local function main()
    require("app.MyApp"):create():run()
end

local status, msg = xpcall(main, __G__TRACKBACK__)
if not status then
    print(msg)
end

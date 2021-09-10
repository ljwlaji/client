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

    -- report lua exception
    if device.platform == "ios" or device.platform == "android" then
        buglyReportLuaException(tostring(tbStr), debug.traceback())
    end

    return msg
end

local function main()
    require("app.MyApp"):create():run()
end

local status, msg = xpcall(main, __G__TRACKBACK__)
if not status then
    print(msg)
end

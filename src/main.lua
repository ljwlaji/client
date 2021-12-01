applicationDidEnterBackground = function()
    local pEvent = cc.EventCustom:new("MSG_APP_DID_ENTER_BACKGROUND")
    cc.Director:getInstance():getEventDispatcher():dispatchEvent(pEvent)
end

applicationWillEnterForeground = function()
    local pEvent = cc.EventCustom:new("MSG_APP_WILL_ENTER_FOREGROUND")
    cc.Director:getInstance():getEventDispatcher():dispatchEvent(pEvent)
end

-- clear Log File
local LOG_FILE = io.open(cc.FileUtils:getInstance():getWritablePath().."persentLog.txt", "w")
LOG_FILE:write("")
LOG_FILE:close()
local __RELEASE_PRINT__ = release_print
print("LogFilePath : "..cc.FileUtils:getInstance():getWritablePath().."persentLog.txt")
function release_print(...)
    __RELEASE_PRINT__(...)
    -- if device.platform ~= "ios" or device.platform ~= "android" then return end
    local LOG_FILE = io.open(cc.FileUtils:getInstance():getWritablePath().."persentLog.txt", "a")
    local logStr = ""
    for _, v in ipairs({...}) do
        logStr = logStr..tostring(v).."\t"
    end
    LOG_FILE:write(logStr.."\n")
    LOG_FILE:close()
end

function print(...)
    release_print(...)
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

local NATIVE_HELPER = nil
__G__TRACKBACK__ = function(msg)
    local tbStr=debug.traceback("", 3)
    reportStr = reportStr.."----------------------------------------\n"
    reportStr = reportStr.."LUA ERROR: " .. tostring(msg) .. "\n"
    reportStr = reportStr..tbStr.."\n"
    reportStr = reportStr.."----------------------------------------\n"
    release_print(reportStr)
    NATIVE_HELPER = NATIVE_HELPER or require("app.components.NativeHelper")
    NATIVE_HELPER:reportLuaError(reportStr)
    return msg
end

local function main()
    require("app.MyApp"):create():run()
end

local status, msg = xpcall(main, __G__TRACKBACK__)
if not status then
    print(msg)
end

cc.FileUtils:getInstance():setPopupNotify(false)

require "config"
require "cocos.init"

__G__TRACKBACK__ = function(msg)
    -- record the message
    local message = msg;

    -- auto genretated
    local msg = debug.traceback(msg, 3)
    release_print(msg)

    -- report lua exception
    if device.platform == "ios" then
        buglyReportLuaException(tostring(message), debug.traceback())
    end

    return msg
end

--Director::restart()

local function main()
    require("app.MyApp"):create():run()
end

local status, msg = xpcall(main, __G__TRACKBACK__)
if not status then
    print(msg)
end

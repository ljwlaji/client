cc.FileUtils:getInstance():setPopupNotify(false)

require "config"
require "cocos.init"


__G__TRACKBACK__ = function(msg)
    -- record the message
    local message = msg;

    -- auto genretated
    local msg = debug.traceback(msg, 3)
    print(msg)

    -- report lua exception
    buglyReportLuaException(tostring(message), debug.traceback())

    return msg
end

__G__TRACKBACK__("This is a test message....")

--Director::restart()

local function main()
    require("app.MyApp"):create():run()
end

local status, msg = xpcall(main, __G__TRACKBACK__)
if not status then
    print(msg)
end

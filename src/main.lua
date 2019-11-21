cc.FileUtils:getInstance():setPopupNotify(false)

require "config"
require "cocos.init"

--Director::restart()

local function main()
    require("app.MyApp"):create():run()
	__G__TRACKBACK__("This is a test message for tencent bugly....")
end

local status, msg = xpcall(main, __G__TRACKBACK__)
if not status then
    print(msg)
end

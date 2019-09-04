

local tempDofile = dofile

dofile = function(...)
	dump({...})
	tempDofile(...)
end

cc.FileUtils:getInstance():setPopupNotify(false)

require "config"
require "cocos.init"


--Director::restart()

local function main()
    require("app.MyApp"):create():run()
    display.getWorld():initlize()
end

local status, msg = xpcall(main, __G__TRACKBACK__)
if not status then
    print(msg)
end

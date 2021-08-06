local MainScene     = class("MainScene", cc.load("mvc").ViewBase)
local WindowMgr = require("app.components.WindowMgr")
local ShareDefine   = require("app.ShareDefine")

local updateCount = 0
local totalMS = 0

function MainScene:onCreate()
end

function MainScene:run()
end

function MainScene:onEnterTransitionFinish()
	self:runAction(cc.Sequence:create(
		cc.DelayTime:create(1),
		cc.CallFunc:create(function() 
   			WindowMgr:createWindow("app.views.layer.vLayerModeChoose")
		end)
	))
end

return MainScene

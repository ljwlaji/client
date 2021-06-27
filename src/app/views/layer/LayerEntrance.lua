local ViewBaseEx 		= import("app.views.ViewBaseEx")
local StateMachine 		= import("app.components.StateMachine")
local Utils				= import("app.components.Utils")
local AssetsMgr     	= import("app.components.AssetsMgr")
local LayerEntrance 	= class("LayerEntrance", ViewBaseEx)


LayerEntrance.RESOURCE_FILENAME = "res/csb/layer/CSB_Layer_Entrance.csb"
LayerEntrance.RESOURCE_BINDING = {}


function LayerEntrance:onCreate(onFinishedCallBack)
	self.onFinishedCallBack = onFinishedCallBack
	self.m_Children["progressBar"]:setPercent(0)
	self:autoAlgin()
end

function LayerEntrance:onEnterTransitionFinish()
	self:enableUpdate(handler(self, self.onUpdate))
	AssetsMgr:start()
end

function LayerEntrance:onUpdate(diff)
	AssetsMgr:onUpdate(diff)
end

function LayerEntrance:enterGame()
	release_print("enterGame")
	dump(Utils.getVersionInfo(), "本地版本信息: ")
	self:runSequence(cc.DelayTime:create(1), cc.CallFunc:create(function() self.onFinishedCallBack() self:removeFromParent() end))
end

return LayerEntrance
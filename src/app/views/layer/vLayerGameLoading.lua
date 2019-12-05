local ViewBaseEx 		= import("app.views.ViewBaseEx")
local vLayerGameLoading = class("vLayerGameLoading", ViewBaseEx)

LayerEntrance.RESOURCE_FILENAME = "res/csb/layer/CSB_Layer_Entrance.csb"
LayerEntrance.RESOURCE_BINDING = {

}

--[[
	这边主要处理一些需要预加载的项目
	比如基础的音频文件的preload
	以及一些数据文件的preload
	处理一些预设值 如地区等..
]]



function vLayerGameLoading:onCreate()

end

function vLayerGameLoading:onEnterTransitionFinish()

end

function vLayerGameLoading:onLoadFinished()
	
end

return vLayerGameLoading
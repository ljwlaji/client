local ViewBaseEx 		= import("app.views.ViewBaseEx")
local vLayerCasttingBar = class("vLayerCasttingBar", ViewBaseEx)

vLayerCasttingBar.DisableDuplicateCreation = true
vLayerCasttingBar.RESOURCE_FILENAME = "res/csb/layer/CSB_Layer_CasttingBar.csb"
vLayerCasttingBar.RESOURCE_BINDING = {

}

function vLayerCasttingBar:onCreate(spellInfo, progress)
	self:autoAlgin()
	self:onReset(spellInfo, progress)
end

function vLayerCasttingBar:onReset(spellInfo, progress)
	self.m_Children["Timer"]:setPercent(progress)
	self:show()
end

return vLayerCasttingBar
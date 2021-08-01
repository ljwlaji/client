local WindowMgr = require("app.components.WindowMgr")
local ViewBaseEx = require("app.views.ViewBaseEx")
local TableViewEx = require("app.components.TableViewEx")
local MapLoader = require("app.components.MapLoader")
local vLayerEditor = class("vLayerEditor", ViewBaseEx)

vLayerEditor.DisableDuplicateCreation = true

function vLayerEditor:createAlignNodes()
	self.m_Children = self.m_Children or {}
	for _, v in ipairs({"node_Center", "node_Left_Up", "node_Left", "node_Left_Buttom", "node_Center_Up", 
						"node_Center_Buttom", "node_Right_Up", "node_Right", "node_Right_Buttom"}) do
		self.m_Children[v] = display.newNode():addTo(self)
	end
	-- BG
	local bg = self:createLayout({
		size = display.size,
		color = cc.c3b(0, 0, 0),
		op = 255,
		cb = function() end
	}):addTo(self.m_Children.node_Center)
end

function vLayerEditor:createMenus()
	local topMenu = require("app.views.node.vNodeTopMenu"):create(self.maptbl.name)
														  :addTo(self.m_Children["node_Center_Up"])
	local leftMenu = require("app.views.node.vNodeLeftMenu"):create()
														  	:addTo(self.m_Children["node_Left_Up"])
	local rightMenu = require("app.views.node.vNodeRightMenu"):create()
														  	  :addTo(self.m_Children["node_Right_Up"])
	local centerMenu = require("app.views.node.vNodeMainScene"):create(cc.size(display.width - leftMenu:getContentSize().width - rightMenu:getContentSize().width, display.height - topMenu:getContentSize().height * 2), self.maptbl)
														  	   :addTo(self.m_Children["node_Center"])

end

function vLayerEditor:onCreate(context)
	self.context = context
	self.maptbl  = MapLoader.loadFromFile(self.context)
	self:createAlignNodes()
	self:autoAlgin()
	self:createMenus()
end


return vLayerEditor
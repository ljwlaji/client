local ViewBaseEx 		= require("app.views.ViewBaseEx")
local Player			= require("app.components.Object.Player")
local SpellBookCell 	= require("app.views.node.vNodeSpellBookCell")
local WindowMgr			= require("app.components.WindowMgr")
local SpellMgr 			= require("app.components.SpellMgr")
local vLayerSpellBook 	= class("vLayerSpellBook", ViewBaseEx)

vLayerSpellBook.DisableDuplicateCreation = true
vLayerSpellBook.RESOURCE_FILENAME = "res/csb/layer/CSB_Layer_SpellBook.csb"
vLayerSpellBook.RESOURCE_BINDING = {
	ButtonExit = "onTouchButtonExit"
}

function vLayerSpellBook:onCreate()
	self.tableView = require("app.components.TableViewEx"):create({
        cellSize = cc.size(430, 80),
        direction = cc.SCROLLVIEW_DIRECTION_VERTICAL,
        fillOrder = cc.TABLEVIEW_FILL_TOPDOWN,
        size = self.m_Children["Panel_TableView"]:getContentSize(),
    }):addTo(self.m_Children["Panel_TableView"])

    self.tableView:onCellAtIndex(handler(self, self.onCellAtIndex))
    self:onReset()
end

function vLayerSpellBook:onCellAtIndex(cell, index)
	local spellEntry = self.datas[index + 1]
	local data = SpellMgr:getSpellTemplate(spellEntry)
	assert(data, string.format("Cannot Find SpellEntry : %d", spellEntry))
	cell.item = cell.item or SpellBookCell:create():addTo(cell)
	cell.item:onReset(data)
end

function vLayerSpellBook:onReset()
	local plr = Player:getInstance()
	if not plr then return end
	self.datas = plr:getLearnedSpells() or {}
    self.tableView:setNumbers(#self.datas):reloadData()
end

function vLayerSpellBook:onTouchButtonExit(e)
	if e.name ~= "ended" then return end
	self:removeSelf()
end


return vLayerSpellBook
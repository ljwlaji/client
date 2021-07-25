local WindowMgr = require("app.components.WindowMgr")
local ViewBaseEx = require("app.views.ViewBaseEx")
local TableViewEx = require("app.components.TableViewEx")
local MapLoader = require("app.components.MapLoader")
local vLayerCreateNewMap = class("vLayerCreateNewMap", ViewBaseEx)

function vLayerCreateNewMap:createEB(title, cb, size)
	return self:cEditBox({
		size = size or cc.size(400, 30),
		ph = title,
		cb = cb，
	}):addTo(self)
end
function vLayerCreateNewMap:onCreate( ... )
    self:autoAlgin()
	local bg = self:createLayout({
		size = display.size,
		color = cc.c3b(0, 0, 0),
		op = 255,
		cb = function() end
	}):addTo(self):move(display.center)

	self:createLayout({
		size = cc.size(300, 40),
		color = cc.c3b(255, 255, 255),
		op = 30,
		str = "创建新的地图"
	}):addTo(bg):move(display.cx, display.height - 50)

	self:createLayout({
		size = cc.size(300, 40),
		color = cc.c3b(255, 255, 255),
		op = 30,
		str = "返回",
		cb = function(e) if e.name ~= "ended" then return end WindowMgr:removeWindow(self) end
	}):addTo(bg):move(display.cx, 80)


	self:createLayout({
		size = cc.size(300, 40),
		color = cc.c3b(255, 255, 255),
		op = 30,
		str = "确认",
		cb = handler(self, self.onTouchBtnConfirm),
	}):addTo(bg):move(display.cx, 140)

	self.entry = self:createEB("地图Entry", function()
	end):move(display.cx, display.height - 100)

	self.name = self:createEB("地图名称", function()
	end):move(display.cx, display.height - 140)

	self.width = self:createEB("地图宽度", function()
	end, cc.size(190, 30)):move(display.cx - 10, display.height - 180):setAnchorPoint(1, 0.5)

	self.height = self:createEB("地图高度", function()
	end, cc.size(190, 30)):move(display.cx + 10, display.height - 180):setAnchorPoint(0, 0.5)

	self.script = self:createEB("脚本名", function()
	end):move(display.cx, display.height - 220)

	self.desc = self:createEB("描述", function()
	end, cc.size(400, 120)):move(display.cx, display.height - 245):setAnchorPoint(0.5, 1)
end

function vLayerCreateNewMap:checkKeyExisted(tbl, key)
	if tbl[key] == nil then release_print(key.."不能为空!") return false end
	return true
end

function vLayerCreateNewMap:checkKeyType(tbl, key, t)
	local vailed = true
	if not tbl[key] then
		release_print(key.."为空!")
		return false
	end
	if t == "number" and tonumber(tbl[key]) == nil then
		vailed = false
	elseif t == "boolean" and tbl[key] ~= false and tbl[key] ~= true then
		vailed = false
	end
	if not vailed then release_print(key.."只能为["..t.."]类型!") return false end
	return true
end

function vLayerCreateNewMap:isDataVailed(mapStruct)
	if not self:checkKeyExisted(mapStruct, "entry") 		or
	   not self:checkKeyExisted(mapStruct, "name") 			or
	   not self:checkKeyExisted(mapStruct, "height") 		or
	   not self:checkKeyExisted(mapStruct, "width") 		or
	   not self:checkKeyType(mapStruct, "entry", "number") 	or
	   not self:checkKeyType(mapStruct, "width", "number") 	or
	   not self:checkKeyType(mapStruct, "height", "number") then
	   	return false
	end


	return true
end

function vLayerCreateNewMap:onTouchBtnConfirm(e)
	if e.name ~= "ended" then return end
	local mapStruct = {
		entry = tonumber(self.entry:getText()),
		name = self.name:getText(),
		height = tonumber(self.height:getText()),
		width = tonumber(self.width:getText()),
		script = self.script:getText(),
		desc = self.desc:getText(),
	}
	print(mapStruct.width % 20)
	print(mapStruct.height % 20)
	if mapStruct.height % 20 ~= 0 or mapStruct.width % 20 ~= 0 then
		release_print("宽高只能是20的整数倍!")
		return
	end
	if not self:isDataVailed(mapStruct) then return end
	local ret = {}
    for dir in lfs.dir(lfs.currentdir().."/../../../../../maps/") do
    	if string.sub(dir, 1, 1) ~= "." then
    		if name == dir then
    			release_print("地图重名!")
    			return
    		end
    	end
    end
    local path = MapLoader.saveToFile(mapStruct)
	if path then
		WindowMgr:createWindow("app.views.layer.vLayerEditor", path)
		WindowMgr:removeWindow(self)
	end

end

return vLayerCreateNewMap
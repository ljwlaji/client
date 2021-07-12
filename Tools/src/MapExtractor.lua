local MapExtractor = class("MapExtractor")
local ViewBaseEx = import("app.views.ViewBaseEx")
local MapTemplate = class("MapTemplate", ViewBaseEx)
local DataBase = import("app.components.DataBase")

local rootPath = cc.FileUtils:getInstance():getDefaultResourceRootPath()
rootPath = string.sub(rootPath, 1, string.len(rootPath) - 1)

local subPath = "res/csb/maps/"

local TYPE_ERROR				= 0
local TYPE_GOBJECT 				= 1
local TYPE_CREATURE				= 2

--[[
	csb格式标准
		1. 层级关系
			rootNode
				MAP_[map_entry] -- 地图节点
					AREA_[area_entry] -- 区域节点
						GOBJECT_[game_object_entry] -- 实例节点
						CREATURE_[creature_entry] -- 生物节点
]]

function MapTemplate:onCreate()

end

function MapExtractor:ctor()
end

function MapExtractor:run()
	self:loadAllMaps()
	self:extractOneByOne()
end

function MapExtractor:loadAllMaps()
	release_print("Running...")
	self.datas = {}
	local suffix = "csb"
	local suffixFitter = "%."..suffix.."$"
	local dirs = io.popen("dir "..rootPath..subPath.." /b /s")
	for dir in dirs:lines() do
		if string.find(dir, suffixFitter) then
			local tempDir = dir
			dir = string.sub(dir, string.len(rootPath) + string.len(subPath) + 1)
			release_print(dir)
			local Entry = string.gsub( dir, ".csb", "" )
			self.datas[tonumber(Entry)] = tempDir
        end
	end
	dump(self.datas)
end

function MapExtractor:extractOneByOne()
	for MapEntry, Dir in pairs(self.datas) do
		MapTemplate.RESOURCE_FILENAME = Dir
		MapTemplate.RESOURCE_BINDING = {}
		self:extractSingleMap(MapTemplate:create(), MapEntry, AreaEntry)
	end
end

function MapExtractor:decodeNameString(ccbName, keys)
	local ret = {}
	string.gsub(ccbName, '[^_]+', function(word) 
		ret[table.remove(keys, 1)] = word
	end)
	return ret
end

function MapExtractor:fillAreaInfo(AreaNode, callback)
	for _, v in ipairs(AreaNode:getChildren()) do
		local content = {
			posX 		= v:getPositionX(), 
			posY 		= v:getPositionY(),
			AnchorPoint = v:getAnchorPoint(),
			ScaleX 		= v:getScaleX(),
			ScaleY 		= v:getScaleY(),
		}
		local infos = self:decodeNameString( v:getName(), {"type", "guid", "entry"} )
		content.type 	= infos.type
		content.entry 	= infos.entry
		callback(content)
	end
end

function MapExtractor:extractSingleMap(map, MapEntry, AreaEntry)
	local rootNode = map:getResourceNode()
	for _, v in ipairs(rootNode:getChildren()) do
		local info = self:decodeNameString(v:getName(), {"type", "guid", "entry"})

		self:fillAreaInfo(v, function(nodeContent)
			dump(nodeContent)
		end)
	end
end



return MapExtractor
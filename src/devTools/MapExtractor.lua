local MapExtractor = class("MapExtractor")
local ViewBaseEx = import("app.views.ViewBaseEx")
local MapTemplate = class("MapTemplate", ViewBaseEx)
local DataBase = import("app.components.DataBase")

local rootPath = cc.FileUtils:getInstance():getDefaultResourceRootPath()
-- rootPath = string.gsub(rootPath, "\\", "/")
rootPath = string.sub(rootPath, 1, string.len(rootPath) - 1)

local subPath = "res\\csb\\maps\\"

local TYPE_ERROR				= 0
local TYPE_GOBJECT 				= 1
local TYPE_BACK_GROUND 			= 2
local TYPE_FRONT_GROUND 		= 3
local TYPE_CREATURE				= 4
local TYPE_CLOUD				= 5
local TYPE_NORMAL_OBJECT		= 6


function MapTemplate:onCreate()

end

function MapExtractor:ctor(currentScene)
	self.scene = currentScene
end

function MapExtractor:run()
	self:loadAllMaps()
	self:extractOneByOne()
end

function MapExtractor:loadAllMaps()
	self.datas = {}
	local suffix = "csb"
	local suffixFitter = "%."..suffix.."$"
	local dirs = io.popen("dir "..rootPath..subPath.." /b /s")
	for dir in dirs:lines() do
		if string.find(dir, suffixFitter) then
			dir = string.sub(dir, string.len(rootPath) + 1)
			local MapEntry, AreaEntry = self:getCurrentMapEntryAndAreaEntry(dir)
			self.datas[MapEntry] = self.datas[MapEntry] and self.datas[MapEntry] or {}
			self.datas[MapEntry][AreaEntry] = dir
        end
	end
end

function MapExtractor:getCurrentMapEntryAndAreaEntry(fullPath)
	local _begin, _end = string.find(fullPath, "res\\csb\\maps\\")
	local str = string.sub( fullPath, _end + 1)
	str = string.gsub(str, ".csb", "")
	local temp = string.split( str, "\\" )
	return tonumber(temp[1]), tonumber(temp[2])
end

function MapExtractor:extractOneByOne()
	for MapEntry, MapInfo in pairs(self.datas) do
		for AreaEntry, AreaDir in pairs(MapInfo) do
			MapTemplate.RESOURCE_FILENAME = AreaDir
			MapTemplate.RESOURCE_BINDING = {}
			self:extractSingleMap(MapTemplate:create(), MapEntry, AreaEntry)
		end
	end
end

function MapExtractor:getTypeFormObjName(name)
	if string.find(name, "Gobject_") then
		return TYPE_GOBJECT
	elseif string.find(name, "Back_Ground_") then
		return TYPE_BACK_GROUND
	elseif string.find(name, "Front_Ground_") then
		return TYPE_FRONT_GROUND
	elseif string.find(name, "Creature_") then
		return TYPE_CREATURE
	elseif string.find(name, "Cloud_") then
		return TYPE_CLOUD
	else
		return TYPE_ERROR
	end
end

function MapExtractor:extractSingleMap(map, MapEntry, AreaEntry)
	for k, v in pairs( map.m_Children ) do
		-- TODO
		-- 判断类型rootPath
		local contexts = {
			resName 	= v:getTexture():getPath(),
			posX 		= v:getPositionX(), 
			posY 		= v:getPositionY(),
			AnchorPoint = v:getAnchorPoint(),
			ScaleX 		= v:getScaleX(),
			ScaleY 		= v:getScaleY(),
			name 		= v:getName()
		}

		contexts.entry = contexts.resName
		while true do
			local _begin = string.find(contexts.entry, "/")
			if not _begin then break end
			contexts.entry = string.sub(contexts.entry, _begin + 1)
		end

		local _begin = string.find(contexts.entry, ".")
		contexts.entry = tonumber(string.sub(contexts.entry, 1, _begin))

		local obj_type = self:getTypeFormObjName(contexts.name)
		if obj_type == TYPE_ERROR then
			assert(false, "Fitting UnDefined Type Name : ".. contexts.name.." In Map : "..MapEntry.." Area : "..AreaEntry)
		end

		if obj_type == TYPE_CREATURE then
			-- TODO
			-- Replace To Creature_instance
			assert(false)
		else
			DataBase:query(string.format("REPLACE INTO game_object_instance(map_entry, area_entry, entry, x, y, scale_x, scale_y, zorder) VALUES('%d', '%d', '%d', '%d', '%d', '%d', '%d', '%d')", 
									--		1		2			3
										MapEntry, AreaEntry, contexts.entry, contexts.posX, contexts.posY, contexts.ScaleX, contexts.ScaleY, 0))
		end
	end
end



return MapExtractor
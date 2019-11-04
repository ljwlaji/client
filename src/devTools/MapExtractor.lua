local MapExtractor = class("MapExtractor")
local ViewBaseEx = import("app.views.ViewBaseEx")
local MapTemplate = class("MapTemplate", ViewBaseEx)
local DataBase = import("app.components.DataBase")

local rootPath = cc.FileUtils:getInstance():getDefaultResourceRootPath()
rootPath = string.sub(rootPath, 1, string.len(rootPath) - 1)

local subPath = "res\\csb\\maps\\"

local TYPE_ERROR				= 0
local TYPE_GOBJECT 				= 1
local TYPE_BACK_GROUND 			= 2
local TYPE_FRONT_GROUND 		= 3
local TYPE_CREATURE				= 4
local TYPE_GROUND 				= 5


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

function MapExtractor:getTypeFormObjName(name)
	if string.find(name, "Gobject_") then
		return TYPE_GOBJECT
	elseif string.find(name, "Back_Ground_") then
		return TYPE_BACK_GROUND
	elseif string.find(name, "Front_Ground_") then
		return TYPE_FRONT_GROUND
	elseif string.find(name, "Creature_") then
		return TYPE_CREATURE
	elseif string.find(name, "Ground_") then
		return TYPE_GROUND
	else
		return TYPE_ERROR
	end
end

function MapExtractor:extractSingleMap(map, MapEntry, AreaEntry)
	for k, v in pairs( map.m_Children ) do
		-- TODO
		-- 判断类型rootPath
		-- 图片名称(resName) 为 Entry res命名方式为 数字+ .png/jpg/...
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
		if obj_type == TYPE_ERROR then assert(false, "Fitting UnDefined Type Name : ".. contexts.name.." In Map : "..MapEntry.." Area : "..AreaEntry) return end

		if obj_type == TYPE_CREATURE then

		elseif obj_type == TYPE_FRONT_GROUND then

		elseif obj_type == TYPE_BACK_GROUND then

		elseif obj_type == TYPE_GOBJECT then
			DataBase:query(string.format("REPLACE INTO game_object_instance(map_entry, entry, x, y) VALUES('%d', '%d', '%d', '%d')", MapEntry, contexts.entry, contexts.posX, contexts.posY))
		elseif obj_type == TYPE_GROUND then
			DataBase:query(string.format("REPLACE INTO ground_instance(map_entry, entry, x, y) VALUES('%d', '%d', '%d', '%d')", MapEntry, contexts.entry, contexts.posX, contexts.posY))
		end
	end
end



return MapExtractor
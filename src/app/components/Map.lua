local Map 			= class("Map", cc.Node)
local DataBase 		= import("app.components.DataBase")
local Camera 		= import("app.components.Camera")
local Area 			= import("app.components.Area")
local Player        = import("app.components.Object.Player")

-- 需要实现的功能
-- 无缝地图
--[[ 
	开发头脑风暴
	
	加载模式:
		首先进入的时候是一张特别大的地图 这个大地图由很多小区域块组成
		玩家进入地图时优先加载视野内可以看到的地图区域
		每个区域在加载时会自动加载相关区域内的GameObject信息 并将这些GameObject构造并加入到 Map 由 Map 统一调度
		GameObject指针由区域持有 Map 也有一份
		在玩家离开区域一段距离之后 将自动销毁( 需要判断区域内的 GameObject 是否还与世界有关联 ) GameObject为Map的子节点 区域仅作为加载和卸载的触发器
		
		
		流程图:
			加载:
				触发地图加载事件->读取需要加载的GameObject


		-- 再议项 可以实现地图多精度

]]

local LoadRect = {
	width = display.width * 2,
	height = display.height * 2,
}

local RemoveRect = {
	width = display.width * 2.2,
	height = display.height * 2.2,
}


function Map:ctor(Entry, chosedCharacterID)
	self.m_Entry = Entry
	self.m_ObjectList = {}
	self.m_AreaTemplates = {}
	self.m_Areas = {}
	self:onCreate(chosedCharacterID)
end

function Map:onCreate(chosedCharacterID)
	self:loadFromDB()
	local plr = Player:create(chosedCharacterID)
    self:setPlayer(plr)
    Camera:changeFocus(plr)
end

function Map:loadFromDB()
	-- TODO
	-- 获取数据库信息
	self.context = DataBase:query(string.format("SELECT * FROM map_template WHERE entry = %d", self.m_Entry))[1]
	-- 初始化地区信息
	local areaTemplates = DataBase:query( string.format( "SELECT * FROM area_template WHERE entry IN (%s)", table.concat(loadstring(string.format("return %s", self.context["areas"]))(), ",") ) )
	for k, areaData in pairs( areaTemplates ) do
		areaData.rect = {
			x 		= areaData.x,
			y 		= areaData.y,
			width 	= areaData.width,
			height 	= areaData.height,
		}
		self.m_AreaTemplates[areaData.entry] = areaData
	end
end

function Map:onUpdate(diff)
	-- 更新Unit信息
	for _, v in pairs(self.m_ObjectList) do v:onUpdate(diff) end
	Camera:onUpdate(diff)
	-- 尝试加载Area
	self:tryLoadNewArea()
	self:tryRemoveArea()
end

-- 判断Area是否在加载范围内
function Map:isInLoadRange(areaRect)
	return cc.rectIntersectsRect(LoadRect, areaRect)
end

function Map:isInRemoveRange(areaRect)
	return not cc.rectIntersectsRect(RemoveRect, areaRect)
end

function Map:tryLoadNewArea()
	LoadRect.x = -self:getPositionX()
	LoadRect.y = -self:getPositionY()
	for k, currAreaData in pairs(self.m_AreaTemplates) do
		if not self.m_Areas[currAreaData.entry] and self:isInLoadRange(currAreaData.rect) then
				release_print("区域热加载: ", currAreaData.entry)
			local area = Area:create(currAreaData)
							 :addTo(self)
							 :move(currAreaData.x, currAreaData.y)
							 :setContentSize(currAreaData.width, currAreaData.height)
			self.m_Areas[currAreaData.entry] = area
		end
	end
end

function Map:tryRemoveArea()
	-- 移除的范围要稍微比加载的范围大一些
	RemoveRect.x = -self:getPositionX()
	RemoveRect.y = -self:getPositionY()
	local continue = true
	while continue == true do
		continue = false
		for k, currentArea in pairs(self.m_Areas) do
			if self:isInRemoveRange(currentArea:getRect()) then
				release_print("区域热卸载: ", currentArea:getEntry())
				if currentArea:isAreaLazy() then
					continue = true
					self.m_Areas[k] = nil
					currentArea:cleanUpBeforeDelete():removeFromParent()
					break
				end
			end
		end
	end
end

function Map:addObject(object)
	table.insert(self.m_ObjectList, object)
	object:addTo(self)
	object:onAddToWorld(self)
end

function Map:removeObject(object)
	local successed = false
	for k, v in pairs(self.m_ObjectList) do
		if v == object then
			table.remove(self.m_ObjectList, k)
			successed = true
			break
		end
	end
	return successed
end

function Map:setPlayer(pPlayer)
	self.mPlayer = pPlayer
	self:addObject(self.mPlayer)
end

function Map:cleanUpBeforeDelete()
	-- TODO
	-- Remove Player
	self.mPlayer:cleanUpBeforeDelete()
	self.mPlayer:removeFromParent()
	-- CleanUp Areas
	for k, v in pairs( self.m_Areas ) do
		v:cleanUpBeforeDelete():removeFromParent()
	end
	self.m_Areas = {}
end

return Map
local Map 			= class("Map", cc.Node)
local DataBase 		= import("app.components.DataBase")
local Camera 		= import("app.components.Camera")
local Player        = import("app.components.Object.Player")
local GameObject    = import("app.components.Object.GameObject")
local Ground    	= import("app.components.Object.Ground")

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

local DISTANCE_FOR_SHOWN 		= 600--display.width * 1.3
local DISTANCE_FOR_DISAPPEAR 	= 1000--display.width * 2

function Map:ctor(Entry, chosedCharacterID)
	self.m_Entry = Entry
	self.m_GroundDatas = {}
	self.m_ObjectList = {}
	self:onCreate(chosedCharacterID)
end

function Map:getEntry()
	return self.m_Entry
end

function Map:onCreate(chosedCharacterID)
	local plr = Player:create(chosedCharacterID)
    self:setPlayer(plr)
    Camera:changeFocus(plr)
	self:loadFromDB()
end

function Map:loadFromDB()
	self:loadAllGroundInfoFromDB()
	self:loadAllCreatureInfoFromDB()
	self:loadAllGameObjectInfoFromDB()
	self:loadAllBackGroundInfoFromDB()
	self:loadAllFrontGroundInfoFromDB()
end

function Map:loadAllGroundInfoFromDB()
	local sql = string.format("SELECT * FROM ground_instance AS I JOIN ground_template AS T ON I.entry == T.entry WHERE I.map_entry == %d", self:getEntry())
	local queryResults = DataBase:query(sql)
	for k, v in pairs(queryResults) do
		self.m_GroundDatas[v.guid] = v
	end
end

function Map:loadAllCreatureInfoFromDB()

end

function Map:loadAllGameObjectInfoFromDB()

end

function Map:loadAllFrontGroundInfoFromDB()

end

function Map:loadAllBackGroundInfoFromDB()

end

function Map:onUpdate(diff)
	-- 更新Unit信息
	for _, v in pairs(self.m_ObjectList) do v:onUpdate(diff) end
	Camera:onUpdate(diff)
	self:tryLoadNewObjects()
	self:tryRemoveObjects()
end

function Map:tryLoadNewObjects() 
	for k, v in pairs(self.m_GroundDatas) do 
		if not v.instance and cc.pGetDistance(cc.p(self.mPlayer:getPosition()), cc.p(v.x,v.y)) < DISTANCE_FOR_SHOWN then 
			v.instance = Ground:create(v)
			self:addObject(v.instance)
		end
	end 
end

function Map:tryRemoveObjects()
	for k, v in pairs(self.m_GroundDatas) do 
		if v.instance and cc.pGetDistance(cc.p(self.mPlayer:getPosition()), cc.p(v.x,v.y)) > DISTANCE_FOR_DISAPPEAR then 
			self:removeObject(v.instance)
			v.instance:removeFromParent()
			v.instance = nil
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
	Camera:changeFocus(nil)
	local obj = nil
	while #self.m_ObjectList > 0 do
		obj = table.remove(self.m_ObjectList)
		obj:cleanUpBeforeDelete()
		obj:removeFromParent()
	end
end

function Map:tryFixPosition(unit, offset)
	local hitGround = false
	local nowPosX, nowPosY = unit:getPosition()
	local nextPos = {
		x = nowPosX + offset.x,
		y = nowPosY,
	}
	if math.abs(offset.x) ~= 0 then
		for k, v in pairs(self.m_ObjectList) do
			if (v:isGameObject() or v:isGround()) and cc.rectContainsPoint(v:getBoundingBox(), nextPos) then
				if offset.x > 0 then
					nextPos.x = v:getPositionX() - 1
				elseif offset.x < 0 then
					nextPos.x = v:getPositionX() + v:getContentSize().width + 1
				end
				break
			end
		end
	end

	nextPos.y = nextPos.y + offset.y
	if math.abs(offset.y) ~= 0 then
		for k, v in pairs(self.m_ObjectList) do
			if (v:isGameObject() or v:isGround()) and cc.rectContainsPoint(v:getBoundingBox(), nextPos) then
				nextPos.y = v:getPositionY() + v:getContentSize().height + 1
				hitGround = true
				break
			end
		end
	end

	return nextPos, hitGround
end

function Map:getStandingObject(nextPos)
	local obj = nil
	for k, v in pairs(self.m_ObjectList) do
		if (v:isGameObject() or v:isGround()) then
			if cc.rectContainsPoint(v:getBoundingBox(), nextPos) then
				if v:hasPixalCollision() then
				else
					obj = v
				end
			end
			if obj then break end
		end
	end
	return obj
end

return Map
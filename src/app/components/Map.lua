local Map 			= class("Map", cc.Node)
local DataBase 		= import("app.components.DataBase")
local Camera 		= import("app.components.Camera")
local Player        = import("app.components.Object.Player")
local GameObject    = import("app.components.Object.GameObject")
local Ground    	= import("app.components.Object.Ground")
local Creature    	= import("app.components.Object.Creature")
local FactionMgr	= import("app.components.FactionMgr")
local Pawn 			= import("app.views.node.vNodePawn")

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

local DISTANCE_FOR_SHOWN 				= 1000
local DISTANCE_FOR_DISAPPEAR 			= 1200

-- 生物的加载和消失范围都比地面更小
local DISTANCE_FOR_SHOWN_CREATURE 		= DISTANCE_FOR_SHOWN 		* 0.5
local DISTANCE_FOR_DISAPPEAR_CREATURE 	= DISTANCE_FOR_DISAPPEAR 	* 0.5


function Map:ctor(Entry, chosedCharacterID)
	self.m_Entry 			= Entry
	self.m_GroundDatas 		= {}
	self.m_CreatureDatas 	= {}
	self.m_ObjectList 		= {}
	self.m_SpellObjects		= {}
	self.m_HotloadTimer 	= 0
	self.m_PawnRecyclePool	= {}
	self:onCreate(chosedCharacterID)

	--For Testting
	self.m_BG = cc.Sprite:create("cloud.png"):addTo(display.getWorld()):setAnchorPoint(0, 0):setLocalZOrder(-99999999)
	self.m_Sky = cc.Sprite:create("sky.jpg"):addTo(display.getWorld()):setAnchorPoint(0, 0):setLocalZOrder(-99999999 - 1):setScale(0.7)
	self.m_Sky = cc.Sprite:create("Sun.png"):addTo(display.getWorld()):setAnchorPoint(0, 1):setLocalZOrder(-99999998):move(0, display.height)
	-- self.m_Sky = cc.Sprite:create("skyring.png"):addTo(display.getWorld()):setAnchorPoint(0, 0):setLocalZOrder(-99999998):setScale(2.9)
	self:onNodeEvent("cleanup", handler(self, self.cleanUpBeforeDelete))
end

function Map:getEntry()
	return self.m_Entry
end

function Map:onCreate(characterGuid)
	local plr = Player:create(characterGuid)
    self:setPlayer(plr)
    Camera:changeFocus(plr)
	self:loadFromDB()
	self:tryLoadNewObjects()
	self:tryRemoveObjects()
	self:setupEventListener()
end

function Map:setupEventListener()
    local listener = cc.EventListenerTouchOneByOne:create()
    listener:registerScriptHandler(handler(self, self.onTouchBegan), cc.Handler.EVENT_TOUCH_BEGAN)
    listener:registerScriptHandler(handler(self, self.onTouchEnded), cc.Handler.EVENT_TOUCH_ENDED)
    -- listener:registerScriptHandler(handler(self, self.onTouchEnded), cc.Handler.EVENT_TOUCH_CANCELLED)
    local eventDispatcher = self:getEventDispatcher()
    eventDispatcher:addEventListenerWithSceneGraphPriority(listener, self)
end

function Map:onTouchBegan(touch, event)
	return true
end

function Map:onTouchEnded(touch, event)
	local Delta = cc.pSub(touch:getStartLocation(), touch:getLocation())
	if math.abs(Delta.x) >= 10 or math.abs(Delta.y) >= 10 then release_print("偏移量过大, 丢弃这个触摸!") return end
	local TouchPosition = self:getParent():convertToNodeSpace(touch:getLocation())
	for k, object in pairs(self.m_ObjectList) do
		if 	object:isCreature() and 
			cc.rectContainsPoint(object:getBoundingBox(), self:convertToNodeSpace(touch:getLocation())) and 
			object:onTouched(self.mPlayer) then
			break
		end
	end
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
	local sql = string.format("SELECT * FROM creature_instance AS I JOIN creature_template AS T ON I.entry == T.entry WHERE I.map_entry == %d", self:getEntry())
	local queryResults = DataBase:query(sql)
	for k, v in pairs(queryResults) do
		self.m_CreatureDatas[v.guid] = v
	end
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

	if self.m_HotloadTimer >= 1000 then
		self:tryLoadNewObjects()
		self:tryRemoveObjects()
		self.m_HotloadTimer = 0
	else
		self.m_HotloadTimer = self.m_HotloadTimer + diff
	end
end

function Map:tryLoadNewObjects() 
	for k, v in pairs(self.m_GroundDatas) do 
		if not v.instance and cc.pGetDistance(cc.p(self.mPlayer:getPosition()), cc.p(v.x,v.y)) < DISTANCE_FOR_SHOWN then 
			v.instance = Ground:create(v)
			self:addObject(v.instance)
		end
	end
	for k, v in pairs(self.m_CreatureDatas) do 
		if not v.instance and cc.pGetDistance(cc.p(self.mPlayer:getPosition()), cc.p(v.x,v.y)) < DISTANCE_FOR_SHOWN_CREATURE then
			local pawn = self:dequeuePawn()
			v.instance = Creature:create(v, pawn)
			pawn:release()
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
	for k, v in pairs(self.m_CreatureDatas) do
		if v.instance and cc.pGetDistance(cc.p(self.mPlayer:getPosition()), cc.p(v.instance:getPosition())) > DISTANCE_FOR_DISAPPEAR_CREATURE then 
			self:removeObject(v.instance)
			self:queuePawn(v.instance:getPawn())
			v.instance:removeFromParent()
			v.instance = nil
		end
	end 
end

function Map:fetchUnitInRange(who, range, ingnoreSelf, aliveOnly, hostileOnly, maxNumber, checkFacing)
	local ret = {}
	maxNumber = maxNumber or 999
	for k, v in pairs(self.m_ObjectList) do
		local distance = who:getDistance(v)
		if v:isUnit() and distance <= range 
					  and (not ingnoreSelf or who ~= v) 
					  and (not aliveOnly or v:isAlive()) 
					  and (not hostileOnly or FactionMgr:isHostile(who:getFaction(), v:getFaction()))
					  and (not checkFacing or who:isFacingTo(v))
			then
			table.insert(ret, {obj = v, dist = distance})
		end
		if #ret >= maxNumber then break end
	end

	table.sort(ret, function(a, b) return a.dist < b.dist end)
	return ret
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
	self:getParent().currentMap = nil
	Camera:changeFocus(nil)
	local obj = nil
	while #self.m_ObjectList > 0 do
		obj = table.remove(self.m_ObjectList)
		obj:removeFromParent()
	end
	while #self.m_PawnRecyclePool > 0 do
		obj = table.remove(self.m_ObjectList)
		obj:release()
	end

	release_print("CleanFinished With Object List : "..#self.m_ObjectList)
	release_print("CleanFinished With Pawn List : "..#self.m_PawnRecyclePool)
end

function Map:queuePawn(pawnInstance)
	pawnInstance:retain():removeFromParent()
	table.insert(self.m_PawnRecyclePool, pawnInstance)
end

function Map:dequeuePawn()
	local ret = #self.m_PawnRecyclePool == 0 and Pawn:create():retain() or table.remove(self.m_PawnRecyclePool, 1)
	return ret
end

function Map:tryFixPosition(unit, offset)
	local hitGround = false
	local hitGObject = false
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
				hitGObject = true
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

	-- Out Of Left Edge
	if nextPos.x < 10 then nextPos.x = 10 end
	return nextPos, hitGround, hitGObject
end

return Map
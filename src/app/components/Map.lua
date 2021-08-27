local Map 				= class("Map", cc.Node)
local DataBase 			= require("app.components.DataBase")
local Camera 			= require("app.components.Camera")
local Player        	= require("app.components.Object.Player")
local GameObject    	= require("app.components.Object.GameObject")
local Ground    		= require("app.components.Object.Ground")
local Creature    		= require("app.components.Object.Creature")
local DamageEffectNode 	= require("app.views.node.vNodeDamageEffect")
local ShareDefine 		= require("app.ShareDefine")
local FactionMgr		= require("app.components.FactionMgr")

-- 需要实现的功能
-- 无缝地图
--[[ 
	加载模式:
		首先进入的时候是一张特别大的地图 这个大地图由很多小区域块组成
		玩家进入地图后会加载一定区域内的 Area 实例, 这个实例将一直存在(或很长距离后销毁?)
		每个区域在加载时会自动加载相关区域内的GameObject信息 并将这些GameObject构造并加入到 Map 由 Map 统一调度
		GameObject指针由Area 和 Map 共同持有
		在玩家离开区域一段距离之后 将创建一个计时器, 在计时器到期后将销毁这个 Area 内所有GameObject(SaveToDB) -- 或直接销毁Area?
		期间玩家靠近这个Area计时器将被删除
		
		
		流程图:
			加载:
				触发地图加载事件->读取需要加载的GameObject
		-- 再议项 可以实现地图多精度
]]

local DISTANCE_FOR_SHOWN 				= 1000
local DISTANCE_FOR_DISAPPEAR 			= 1500

-- 生物的加载和消失范围都比地面更小
local DISTANCE_FOR_SHOWN_CREATURE 		= DISTANCE_FOR_SHOWN 		* 0.5
local DISTANCE_FOR_DISAPPEAR_CREATURE 	= DISTANCE_FOR_DISAPPEAR 	* 0.5


function Map:ctor(Entry, chosedCharacterID)
	self.m_Entry 				= Entry
	self.m_GroundDatas 			= {}
	self.m_CreatureDatas 		= {}
	self.m_ObjectList 			= {}
	self.m_SpellObjects			= {}
	self.m_DamageEffectNodes	= {}
	self.m_HotloadTimer 		= 0
	self:onCreate(chosedCharacterID)

	--For Testting
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
			--非生物不对话
			cc.rectContainsPoint(object:getTouchBox(), self:convertToNodeSpace(touch:getLocation())) and 
			--未触摸不对话
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
			v.instance = Creature:create(v)
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

function Map:queueEffectNode(node)
	table.insert(self.m_DamageEffectNodes, node:retain():removeFromParent():hide())
end

function Map:DequeueEffectNode()
	local node = nil
	if #self.m_DamageEffectNodes > 0 then
		node = table.remove(self.m_DamageEffectNodes, 1):addTo(self):show():release()
	end
	return node or DamageEffectNode:create(queueFunc):setLocalZOrder(ShareDefine.getZOrderByType("ZORDER_DAMAGE_EFFECT")):addTo(self)
end

function Map:createDamageEffect(pos, number)
	local number = number > 99999999 and 99999999 or number
	local numbers = {}
	while true do
		table.insert(numbers, #numbers, number % 10)
		number = math.floor(number / 10)
		if number == 0 then break end
	end
	self:DequeueEffectNode():move(pos):reset(numbers)
end

function Map:cleanUpBeforeDelete()
	-- TODO
	-- Remove Player
	self:getParent().currentMap = nil
	Camera:changeFocus(nil)
	while #self.m_ObjectList > 0 do
		table.remove(self.m_ObjectList, 1):removeFromParent()
	end

	while #self.m_DamageEffectNodes > 0 do
		table.remove(self.m_DamageEffectNodes, 1):release()
	end
	release_print("CleanFinished With Object List : "..#self.m_ObjectList)
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
local Map = class("Map", cc.Node)

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

Map.instance = nil

function Map:ctor()
	Map.instance = self
	self.ObjectList = {}

end

function Map:onUpdate(diff)
	for _, v in pairs(self.ObjectList) do v:onUpdate(diff) end
end

function Map:addObject(object)
	table.insert(self.ObjectList, object)
end

function Map:removeObject(object)
	local successed = false
	for k, v in pairs(self.ObjectList) do
		if v == object then
			table.remove(self.ObjectList, k)
			successed = true
			break
		end
	end
	return successed
end

return Map
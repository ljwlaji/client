local MapLoader = class("MapLoader")

function MapLoader.toString(tbl, tabs)
	tabs = tabs or ""
    local upperTabs = tabs
    tabs = tabs..'\t'
    local data = "{\n"
    for k, v in pairs(tbl) do
        if type(v) ~= "function" then
            local vk = tabs..(type(k) == "string" and '["'..k..'"]' or "["..k.."]")
            if type(v) == "table" then
                data = data..vk.." = ".. MapLoader.toString(v, tabs)..","
            else
                if type(v) == "string" then
                    if v == "\n" then v = "\\n" end
                    data = data..vk.." = "..'"'..v..'"'..","
                else
                    data = data..vk.." = "..tostring(v)..","
                end
            end
            data = data.."\n"
        end
    end

    data = string.sub(data, 1, string.len(data) - 2).."\n"
    data = data..upperTabs.."}"
    return data
end

function MapLoader.isSameTbl(left, right)
	local ret = true
	for k, v in pairs(left) do
		if type(right[k]) ~= type(v) or not right[k] then
			ret = false
			break
		end
		if type(right[k]) == "table" then
			if not MapLoader.isSameTbl(v, right[k]) then 
				ret = false
				break 
			end
		else
			if right[k] ~= v then ret = false break end
		end
	end
	return ret
end

function MapLoader.saveToFile(mapStruct)
	local currPath = lfs.currentdir().."/../../../../../maps/"..mapStruct.name..".map"
	local file = io.open(currPath, "wb")
	file:write(MapLoader.toString(mapStruct))
	file:close()
	file = io.open(currPath, "rb")
	local str = file:read("*a")
	local tbl = loadstring("return "..str)()
	assert(MapLoader.isSameTbl(mapStruct, tbl))
	assert(MapLoader.isSameTbl(tbl, mapStruct))
	release_print("保存成功!!!")
	return currPath
end	

function MapLoader.loadFromFile(path)
	local file = io.open(path, "rb")
	local str = file:read("*a")
	local tbl = loadstring("return "..str)()
	return tbl
end


return MapLoader
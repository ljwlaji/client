
local MyApp = class("MyApp", cc.load("mvc").AppBase)


-- string.split = function(str, reps)
--     local ret = {}
--     string.gsub(str,'[^'..reps..']+',function ( w )
--         table.insert(ret, w)
--     end)
--     return ret
-- end

-- table.clone = function(tb)
-- 	local ret = {}
-- 	for k, v in pairs(tb) do
-- 		ret[k] = type(v) == "table" and table.clone(v) or v
-- 	end
-- 	return ret
-- end

function MyApp:onCreate()
    math.randomseed(os.time())
end

return MyApp

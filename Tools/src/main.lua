-- require "config"
-- require "cocos.init"

-- local function runCMD(cmd, echo, callback)
-- 	local ret = io.popen(cmd):read("*all")
-- 	if echo then print(ret) end
-- 	if callback then callback(ret) end
-- end

-- local execDir = "/runtime/mac/framework%-desktop.app/Contents/Resources"

-- runCMD("pwd", true, function(ret) 
-- 	local rootPath = string.gsub(ret, execDir, "")
-- 	runCMD(string.format("cd %s | pwd", rootPath), true)
-- 	runCMD("pwd", true)
-- end)
-- do return end

require "functions"
local rootPath = "/Users/ljw/WorkSpace/db_compare/"
import("SQLiteCompare"):start(rootPath.."datas_Old.db", rootPath.."datas_New.db")
-- import("AutoUpdater").run("e371842", "5692539")


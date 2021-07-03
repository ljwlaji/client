-- require "config"
-- require "cocos.init"

require "functions"
local rootPath = "/Users/ljw/WorkSpace/db_compare/"
import("SQLiteCompare"):start(rootPath.."datas_Old.db", rootPath.."datas_New.db")
-- import("AutoUpdater").run("e371842", "5692539")


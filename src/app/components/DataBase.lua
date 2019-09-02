local Utils = import("app.components.Utils")
local DataBase = class("DataBase")

DataBase.instance = nil

local DBPATH = "res/datas.db"

function DataBase:ctor()
	self:openDB()
end

function DataBase:openDB(filename)
	if self.db then return self.db end
    self.db = sqlite3.open(Utils.getDownloadRootPath()..DBPATH)
	return self.db
end

function DataBase.getInstance()
	if DataBase.instance == nil then
		DataBase.instance = DataBase:create()
	end
	return DataBase.instance
end

function DataBase:query(sql)
    local ret = {}
    for row in self.db:nrows(sql) do
        ret[#ret + 1] = row
    end
    return ret
end

function DataBase:close()
    if self.db then
        self.db:close()
        self.db = nil
    end
end

return DataBase.getInstance()
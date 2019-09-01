local DataBase = class("DataBase")

DataBase.instance = nil

local DBPATH = "res/datas.db"

function DataBase:ctor()
	assert(not DataBase.instance)
	self.db = self:openDB(DBPATH)
	assert(self.db)
end

function DataBase:openDB(filename)
	if not self.db then self.db = sqlite3.open(filename) end
	return self.db
end

function DataBase.getInstance()
	if DataBase.instance == nil then
		DataBase.instance = DataBase:create()
	end
	return DataBase.instance
end

function DataBase:query(sql)
    local t = {}
    for row in self.db:nrows(sql) do
        t[#t + 1] = row
    end
    return t
end

function DataBase:close()
    if self.db then
        self.db:close()
        self.db = nil
    end
end

return DataBase.getInstance()
local DataBase = class("DataBase")

DataBase.instance = nil

local DBPATH = "res/datas.db"
local DBPackagePath = cc.FileUtils:getInstance():fullPathForFilename("res/datas.db")
local DBWriteblePath = device.writablePath.."datas.db"         --操作数据库路径

function DataBase:ctor()
	self:openDB(DBPATH)
end

function DataBase:openDB(filename)
	if self.db then return self.db end
	if not io.exists(DBWriteblePath) then
        local content = io.readfile(DBPackagePath)
        if content then
            dump(io.writefile(DBWriteblePath, content))
        end
    end
	self.db = sqlite3.open(DBWriteblePath)
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
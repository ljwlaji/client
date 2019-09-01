local DataBase = class("DataBase")

DataBase.instance = nil

local DBPATH = "res/datas.db"
local DBPackagePath = cc.FileUtils:getInstance():fullPathForFilename(DBPATH)
local DBWriteblePath = device.writablePath.."datas.db"         --操作数据库路径

function DataBase:ctor()
	self:openDB()
end

function DataBase:openDB(filename)
	if self.db then return self.db end
    if device.platform ~= "windows" then
    	if not io.exists(DBWriteblePath) then
            local content = io.readfile(DBPackagePath)
            if content then
                io.writefile(DBWriteblePath, content)
            end
        end
        self.db = sqlite3.open(DBWriteblePath)
    else
        self.db = sqlite3.open(DBPATH)
    end
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
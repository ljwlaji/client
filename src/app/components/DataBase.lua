local Utils = import("app.components.Utils")
local DataBase = class("DataBase")

DataBase.instance = nil
local DevMode   = import("app.ShareDefine"):isDevMode()
local DBPATH    = "res/datas.db"


function DataBase:ctor()
	self:openDB()
    self.m_ItemTemplate = nil
end

function DataBase:fetchItemTemplate()
    local queryResult = self:query("SELECT * FROM item_template")
    local itemTmeplate = {}
    for k, v in pairs(queryResult) do
        v.attrs = loadstring("return "..v.attrs)()
        v.spells = loadstring("return "..v.spells)()
        itemTmeplate[v.entry] = v
    end

    return itemTmeplate
end

function DataBase:getItemTemplateByEntry(itemEntry)
    self.m_ItemTemplate = self.m_ItemTemplate or self:fetchItemTemplate()
    return self.m_ItemTemplate[itemEntry]
end

function DataBase:openDB()
	if self.db then return self.db end
    self.db = sqlite3.open(Utils.getCurrentResPath()..DBPATH)
	return self.db
end

function DataBase:getStringByID(id)
    local location = "zh_cn"
    local queryResult = self:query("SELECT * FROM string_template WHERE id = "..id)
    return #queryResult == 1 and queryResult[1][location] or "NullString"
end

function DataBase.getInstance()
	if DataBase.instance == nil then
		DataBase.instance = DataBase:create()
	end
	return DataBase.instance
end

function DataBase:query(sql)
    if not self.db then self:openDB() end
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
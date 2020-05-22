local Utils             = import("app.components.Utils")
local ShareDefine       = import("app.ShareDefine")
local DataBase          = class("DataBase")

DataBase.instance = nil

local languageMode  = ShareDefine.getLanguageMode()
local DevMode       = ShareDefine.isDevMode()
local DBPATH        = "res/datas.db"


function DataBase:ctor()
	self:openDB()
    self.m_ItemTemplate = nil
end

function DataBase:fetchItemTemplate()
    local queryResult = self:query("SELECT * FROM item_template")
    local itemTmeplate = {}
    for k, v in pairs(queryResult) do
        v.attrs     = v.attrs   and loadstring("return "..v.attrs)()  or {}
        v.spells    = v.spells  and loadstring("return "..v.spells)() or {}
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
    local queryResult = self:query(string.format("SELECT * FROM string_template WHERE id = %d", id))
    return #queryResult == 1 and queryResult[1][languageMode] or "NullString"
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
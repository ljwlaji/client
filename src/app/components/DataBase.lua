local Utils             = import("app.components.Utils")
local ShareDefine       = import("app.ShareDefine")
local DataBase          = class("DataBase")

DataBase.instance = nil

local languageMode  = ShareDefine.getLanguageMode()
local DevMode       = ShareDefine.isDevMode()
local DBPATH        = "res/datas.db"


function DataBase:ctor()
	self:openDB()
    self.m_ItemTemplate = {}
end

function DataBase:fetchItemTemplate(itemEntry)
    local queryResult = self:query(string.format("SELECT * FROM item_template WHERE entry = '%d'", itemEntry))[1]
    queryResult.attrs             = queryResult.attrs   and loadstring("return "..queryResult.attrs)()  or {}
    queryResult.spells            = queryResult.spells  and loadstring("return "..queryResult.spells)() or {}
    queryResult.isQuestItem       = queryResult.is_quest_item == 1
    self.m_ItemTemplate[queryResult.entry] = queryResult
    return queryResult
end

function DataBase:getItemTemplateByEntry(itemEntry)
    return self.m_ItemTemplate[itemEntry] or self:fetchItemTemplate(itemEntry)
end

function DataBase:openDB()
	if self.db then return self.db end
    self.db = sqlite3.open(Utils.getCurrentResPath()..DBPATH)
	return self.db
end

function DataBase:newItemGuid()
    return self:query("SELECT max(item_guid) AS g FROM character_inventory")[1]["g"] + 1
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
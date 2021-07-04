local SQLiteCompare = class("SQLiteCompare")

-- 可以新增和删除(列/表) 不允许修改列属性, 不允许新增主键列
-- 表操作是无法使用事务来做的 所以这边如果失败则直接回滚数据库(本地在做这个操作时会先做备份)


function SQLiteCompare:ctor()

end

function SQLiteCompare:query(db, sql)
	local ret = {}
    for row in db:nrows(sql) do
        ret[#ret + 1] = row
    end
    return ret
end


function SQLiteCompare:openDB(path)
	-- assert(FileUtils:isFileExist(path), "No Such File : "..path)
	return assert(sqlite3.open(path), "Load DB Error : "..path)
end

function SQLiteCompare:fillSqlData(db)
	-- 获取所有表名
	local retDBTempalte = {}
	local tables = {}
	local results = self:query(db, "SELECT tbl_name FROM sqlite_master WHERE type == 'table';")
	--获取所有表名
	for _, v in pairs(results) do
		local tbl_name = v.tbl_name
		if string.sub(tbl_name, 1, 1) ~= "_" and not string.find(tbl_name, "sqlite_sequence") then
			table.insert(tables, tbl_name)
		end
	end

	--获取表结构
	for _, tableName in pairs(tables) do
		results = self:query(db, string.format("PRAGMA table_info(%s)", tableName))
		local template = {
			names = {},
			pks = {},
			records = self:query(db, string.format("SELECT * FROM %s", tableName))
		}
		for _, info in ipairs(results) do
			template.names[info.name] = {
				type = info.type,
				notnull = info.notnull == 1,
				dflt_value = info.dflt_value
			}
			if info.pk > 0 then
				template.pks[info.pk] = info.name
			end
		end

		retDBTempalte[tableName] = template
	end
	db:close()
	return retDBTempalte
end

function SQLiteCompare:compareMissingFields(oldTempalte, newTempalte)
	local retTableNames = {}
	local ret = nil
	for name, _ in pairs(oldTempalte.names) do
		if not newTempalte.names[name] then
			for name, _ in pairs(newTempalte.names) do
				table.insert(retTableNames, name)
			end
			ret = true
			break
		end
	end
	return ret and retTableNames or nil
end

function SQLiteCompare:compareFields(newTempalte, oldTempalte)
	local modifies = {}
	local ret = false
	for name, template in pairs(newTempalte.names) do
		if not oldTempalte.names[name] then
			modifies[name] = template
			ret = true
		end
	end
	return ret and modifies or nil
end

local function clone(source)
	local ret = {}
	for k, v in pairs(source) do
		ret[k] = type(v) == "table" and clone(v) or v
	end
	return ret
end

function SQLiteCompare:isEqual(new, old)

end

function SQLiteCompare:isSamePK(newRecord, oldRecord, pks)
	local isSame = true
	local index = 1
	repeat
		local pk = pks[index]
		if newRecord[pk] ~= oldRecord[pk] then
			isSame = false
			break
		end
	until index > #pks
	return isSame
end

function SQLiteCompare:compareSqlRecords(newTableRecords, oldTableRecords, tableName)
	-- 如果存在已删除的列 这边不用管旧数据库 对比以新数据库的列为准
	-- 首先进行字段属性差异检查 主要是检查已有的字段属性是否一致
	for fieldName, fieldInfo in pairs(newTableRecords.names) do
		local oldInfo = oldTableRecords.names[fieldName]
		if oldInfo then
			local compare = clone(oldInfo)
			for k, v in pairs(fieldInfo) do
				-- print(k, v, oldInfo[k])
				assert(oldInfo[k] == v, string.format("检查到[%s]表内[%s]字段属性[%s]变更", tableName, fieldName, k))
				string.format("检查到[%s]表内[%s]字段属性[%s]检查通过", tableName, fieldName, k)
				oldInfo[k] = nil
			end
		end
	end

	local pks = newTableRecords.pks
	local len = #pks
	print(table.concat(newTableRecords.pks, ","))
	local function comp(a, b, index)
		if a[pks[index]] < b[pks[index]] then
			return true
		else
			return index < len and comp(a, b, index + 1) or false
		end
	end

	table.sort(newTableRecords.records, function(a, b) return comp(a, b, 1) end)
	table.sort(oldTableRecords.records, function(a, b) return comp(a, b, 1) end)
	local adds = {}
	local modifies = {}
	local deletes = {}
	local index = 1
	repeat
		local newRecord = table.remove(newTableRecords.records)
		local oldRecord = oldTableRecords.records[k]
		if self:isSamePK(newRecord, oldRecord, pks) then
			 if not self:isEqual(v, oldRecord) then
			 	-- 部分不同 更新条目
			 	table.insert(modifies, newRecord)
			 end
			 table.remove(oldTableRecords.records, 1)
		else -- 新条目 插入
			table.insert(adds, newRecord)
		end
		index = index + 1
	until #newTableRecords.records == 0
	deletes = oldTableRecords.records
	
end

function SQLiteCompare:start(pathOrigin, pathNew)
	local oldDB = self:fillSqlData(self:openDB(pathOrigin))
	local newDB = self:fillSqlData(self:openDB(pathNew))
	local droppedTables = {}
	local drpopedFields = {}
	-- 查询删除的表和列
	for tableName, tableTempalte in pairs(oldDB) do
		local newTableTemplate = newDB[tableName]
		if newTableTemplate then
			drpopedFields[tableName] = self:compareMissingFields(tableTempalte, newTableTemplate)
		else
			-- 这个表被删除了
			table.insert(droppedTables, tableName)
		end
	end

	-- 查询新增的表和列
	-- 用新的对比老的
	local addedTables = {}
	local addedFields = {}
	for tableName, tableTempalte in pairs(newDB) do
		local oldTempalte = oldDB[tableName]
		if oldTempalte then
			addedFields[tableName] = self:compareFields(tableTempalte, oldTempalte)
		else
			-- 新增了表
			addedTables[tableName] = tableTempalte
		end
	end

	local sql_query_strs = {}

	-- 开始处理差异
	-- 顺序不能乱
	-- 删除的表
	table.insert(sql_query_strs, "--Deleted Tables")
	for tableName, tableName in pairs(droppedTables) do
		table.insert(sql_query_strs, string.format([[DROP TABLE "%s";]], tableName))
	end

	table.insert(sql_query_strs, "--Deleted Fields")
	-- 删除的列
	for tableName, fields in pairs(drpopedFields) do
			local sql = string.format([[CREATE TABLE %s_temp_swap AS SELECT %s FROM %s;]], tableName, table.concat(fields, ","), tableName)
			sql = sql..string.format([[DROP TABLE %s;]], tableName)
			sql = sql..string.format([[ALTER TABLE %s_temp_swap RENAME TO %s;]], tableName, tableName)
			table.insert(sql_query_strs, sql)
	end

	table.insert(sql_query_strs, "--Added Fields")
	-- 增加的列
	for tableName, fields in pairs(addedFields) do
		for fieldName, fieldInfo in pairs(fields) do
			local sql = string.format([[ALTER TABLE %s ADD COLUMN ]], tableName)
			sql = sql..string.format([["%s" %s%s%s;]], fieldName, 
													   fieldInfo.type, 
													   fieldInfo.notnull and " NOT NULL" or "", 
													   fieldInfo.dflt_value and (" DEFAULT "..tostring(fieldInfo.dflt_value)) or "")
			table.insert(sql_query_strs, sql)
		end
	end

	table.insert(sql_query_strs, "--Added Tables")
	-- 增加的表
	for tableName, tableTempalte in pairs(addedTables) do
		local sql = string.format([[CREATE TABLE "%s" (]], tableName)
		for fieldName, fieldInfo in pairs(tableTempalte.names) do
			sql = sql..string.format([["%s" %s%s%s]], fieldName, 
													   fieldInfo.type, 
													   fieldInfo.notnull and " NOT NULL" or "", 
													   fieldInfo.dflt_value and (" DEFAULT "..tostring(fieldInfo.dflt_value)) or "")
			if fieldInfo.pks and #fieldInfo.pks > 0 then
				sql = sql..string.format([[,PRIMARY KEY ("%s")]], table.concat( fieldInfo.pks, [[","]] ))
			end
			sql = sql..");"
			table.insert(sql_query_strs, sql)
		end
	end
	dump(sql_query_strs)
	for name, info in pairs(newDB) do
		if oldDB[name] then
			self:compareSqlRecords(info, oldDB[name], name)
		end
	end
end


return SQLiteCompare:create()
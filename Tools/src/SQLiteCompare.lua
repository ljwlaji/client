local SQLiteCompare = class("SQLiteCompare")

-- 可以新增和删除(列/表) 不允许修改列属性,
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
	local results = self:query(db, "select tbl_name from sqlite_master where type == 'table';")
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
			pks = {}
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
			local sql = string.format([[create table %s_temp_swap as select %s from %s;]], tableName, table.concat(fields, ","), tableName)
			sql = sql..string.format([[drop table %s;]], tableName)
			sql = sql..string.format([[alter table %s_temp_swap rename to %s;]], tableName, tableName)
			table.insert(sql_query_strs, sql)
	end

	table.insert(sql_query_strs, "--Added Fields")
	-- 增加的列
	for tableName, fields in pairs(addedFields) do
		for fieldName, fieldInfo in pairs(fields) do
			local sql = string.format([[ALTER TABLE %s ADD COLUMN ]], tableName)
			sql = sql..string.format([["%s" %s%s%s,]], fieldName, 
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
end


return SQLiteCompare:create()
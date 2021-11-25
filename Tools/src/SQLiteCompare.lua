local SQLiteCompare = class("SQLiteCompare")
local LFS 		= import("app.components.Lfs")
local Utils 		= import("app.components.Utils")

-- 可以新增和删除(列/表) 不允许修改列属性, 不允许新增主键列
-- 表操作是无法使用事务来做的 所以这边如果失败则直接回滚数据库(本地在做这个操作时会先做备份)
-- 除instance后缀表外不允许有自增列


local logs = {}

local currentDir = nil

function string.split(input, delimiter)
    input = tostring(input)
    delimiter = tostring(delimiter)
    if (delimiter=='') then return false end
    local pos,arr = 0, {}
    -- for each divider found
    for st,sp in function() return string.find(input, delimiter, pos, true) end do
        table.insert(arr, string.sub(input, pos, st - 1))
        pos = sp + 1
    end
    table.insert(arr, string.sub(input, pos))
    return arr
end

local function dump_value_(v)
    if type(v) == "string" then
        v = "\"" .. v .. "\""
    end
    return tostring(v)
end

local function release_print(...)
	table.insert(logs, table.concat({...}, "\t"))
	print(...)
end


local function dump(value, description, nesting)
    if type(nesting) ~= "number" then nesting = 3 end

    local lookupTable = {}
    local result = {}

    local traceback = string.split(debug.traceback("", 2), "\n")
    print("dump from: " .. string.trim(traceback[3]))

    local function dump_(value, description, indent, nest, keylen)
        description = description or "<var>"
        local spc = ""
        if type(keylen) == "number" then
            spc = string.rep(" ", keylen - string.len(dump_value_(description)))
        end
        if type(value) ~= "table" then
            result[#result +1 ] = string.format("%s%s%s = %s", indent, dump_value_(description), spc, dump_value_(value))
        elseif lookupTable[tostring(value)] then
            result[#result +1 ] = string.format("%s%s%s = *REF*", indent, dump_value_(description), spc)
        else
            lookupTable[tostring(value)] = true
            if nest > nesting then
                result[#result +1 ] = string.format("%s%s = *MAX NESTING*", indent, dump_value_(description))
            else
                result[#result +1 ] = string.format("%s%s = {", indent, dump_value_(description))
                local indent2 = indent.."    "
                local keys = {}
                local keylen = 0
                local values = {}
                for k, v in pairs(value) do
                    keys[#keys + 1] = k
                    local vk = dump_value_(k)
                    local vkl = string.len(vk)
                    if vkl > keylen then keylen = vkl end
                    values[k] = v
                end
                table.sort(keys, function(a, b)
                    if type(a) == "number" and type(b) == "number" then
                        return a < b
                    else
                        return tostring(a) < tostring(b)
                    end
                end)
                for i, k in ipairs(keys) do
                    dump_(values[k], k, indent2, nest + 1, keylen)
                end
                result[#result +1] = string.format("%s}", indent)
            end
        end
    end
    dump_(value, description, "- ", 1)

    for i, line in ipairs(result) do
        release_print(line)
    end
end

local function outLog(path)
	local fileWrite = io.open(path,"w")
	fileWrite:write(table.concat(logs, "\n"))
	fileWrite:close()
end

local function exit(msg)
	if msg then release_print(msg) end
	LFS.createDir(currentDir.."/../Log")
	outLog(currentDir.."/../Log/sql_compare_log.txt")
    cc.Director:getInstance():endToLua()
end


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
	local db = sqlite3.open(path)
	if not db then exit("打开数据库出错 : "..path) end
	return db
end

function SQLiteCompare:fillSqlData(db, keepAlive)
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
	if not keepAlive then
		db:close()
	end
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
	local isEqual = true
	for key, value in pairs(new) do
		if value ~= old[key] then
			isEqual = false
			break
		end
	end
	return isEqual
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
		index = index + 1
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
				if (oldInfo[k] ~= v) then release_print(string.format("检查到[%s]表内[%s]字段属性[%s]变更", tableName, fieldName, k)) end
				oldInfo[k] = nil
			end
		end
	end

	local pks = newTableRecords.pks
	local len = #pks
	local function comp(a, b, index)
		if a[pks[index]] < b[pks[index]] then
			return true
		else
			return index < len and comp(a, b, index + 1) or false
		end
	end

	if #newTableRecords.pks == 0 or #oldTableRecords.pks == 0 then
		release_print(string.format("无主键的表 : [%s]", tableName))
		return {
			pks = newTableRecords.pks,
			adds = newTableRecords.records,
			modifies = {},
			deletes = {},
		}
	end
	table.sort(newTableRecords.records, function(a, b) return comp(a, b, 1) end)
	table.sort(oldTableRecords.records, function(a, b) return comp(a, b, 1) end)
	local adds = {}
	local modifies = {}
	local deletes = {}
	while #newTableRecords.records > 0 do
		local newRecord = table.remove(newTableRecords.records, 1)
		local oldRecord = oldTableRecords.records[1]
		if oldRecord and self:isSamePK(newRecord, oldRecord, pks) then
			 if not self:isEqual(newRecord, oldRecord) then
		-- 	 	-- 部分不同 更新条目
			 	table.insert(modifies, newRecord)
			 end
			 table.remove(oldTableRecords.records, 1)
		else -- 新条目 插入
			table.insert(adds, newRecord)
		end
	end
	deletes = oldTableRecords.records
	return {
		pks = pks,
		adds = adds,
		deletes = deletes,
		modifies = modifies
	}
end

function SQLiteCompare:start(pathOrigin, pathNew)
	local path = string.gsub(io.popen("pwd"):read("*all"), "/runtime/mac/framework%-desktop.app/Contents/Resources", "") -- For MacOS
	path = string.gsub(path, "\n", "")
	path = string.gsub(path, "/runtime/mac/framework-desktop.app/Contents/Resources", "").."/sqlcompare/"
	local oldDB = self:fillSqlData(self:openDB(path.."data_old.db"))
	local newDB = self:fillSqlData(self:openDB(path.."data_new.db"))
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
	for tableName, tableName in pairs(droppedTables) do
		table.insert(sql_query_strs, string.format([[DROP TABLE %s;]], tableName))
	end

	-- 增加的表
	for tableName, tableTempalte in pairs(addedTables) do
		local suffix = {}
		for fieldName, fieldInfo in pairs(newDB[tableName].names) do
			table.insert(suffix, string.format([[ "%s" %s%s%s]], fieldName, 
													   fieldInfo.type, 
													   fieldInfo.notnull and " NOT NULL" or "", 
													   fieldInfo.dflt_value and (" DEFAULT".." "..tostring(fieldInfo.dflt_value)) or ""))
		end
		local pks = ""
		if newDB[tableName].pks and #newDB[tableName].pks > 0 then
			pks = string.format([[,PRIMARY KEY ("%s")]], table.concat( newDB[tableName].pks, [[","]] ))
		end
		table.insert(sql_query_strs, string.format([[CREATE TABLE "%s" (%s %s);]], tableName, table.concat(suffix, ","), pks))
	end

	-- 增加的列
	for tableName, fields in pairs(addedFields) do
		if not droppedTables[tableName] then -- 如果整个表都删掉了 那就不管表内变更了
			for fieldName, fieldInfo in pairs(fields) do
				local sql = string.format([[ALTER TABLE %s ADD COLUMN ]], tableName)
				sql = sql..string.format([[ "%s" %s%s%s;]], fieldName, 
														   fieldInfo.type, 
														   fieldInfo.notnull and " NOT NULL" or "", 
														   fieldInfo.dflt_value and (" DEFAULT".." "..tostring(fieldInfo.dflt_value)) or "")
				table.insert(sql_query_strs, sql)
			end
		end
	end

	local fullCopyTables = {}
	-- 删除的列
	for tableName, fields in pairs(drpopedFields) do
		if not droppedTables[tableName] then -- 如果整个表都删掉了 那就不管表内变更了
			--创建一个新表 只含有新db的列信息
			local suffix = {}
			for fieldName, fieldInfo in pairs(newDB[tableName].names) do
				table.insert(suffix, string.format([[ "%s" %s%s%s]], fieldName, 
														   fieldInfo.type, 
														   fieldInfo.notnull and " NOT NULL" or "", 
														   fieldInfo.dflt_value and (" DEFAULT".." "..tostring(fieldInfo.dflt_value)) or ""))
			end
			local pks = ""
			if newDB[tableName].pks and #newDB[tableName].pks > 0 then
				pks = string.format([[,PRIMARY KEY ("%s")]], table.concat( newDB[tableName].pks, [[","]] ))
			end
			table.insert(sql_query_strs, string.format([[CREATE TABLE "%s_temp_swap" (%s %s);]], tableName, table.concat(suffix, ","), pks))

			-- -- 把旧数据导入
			-- local names = {}
			-- for key, _ in pairs(newDB[tableName].names) do table.insert(names, key) end
			-- table.insert(sql_query_strs, string.format("INSERT INTO %s_temp_swap SELECT %s FROM %s;", tableName, table.concat(names, ","), tableName))

			-- 删除旧表
			table.insert(sql_query_strs, string.format("DROP TABLE %s;", tableName))

			-- 新表更名
			table.insert(sql_query_strs, string.format("ALTER TABLE %s_temp_swap RENAME TO %s;", tableName, tableName))

			-- 加入到需要全拷贝的表内
			table.insert(fullCopyTables, tableName)
		end
	end

	--导出sql文件

	local date = os.time()

	currentDir = string.gsub(io.popen("pwd"):read("*all"), "/runtime/mac/framework%-desktop.app/Contents/Resources", "") -- For MacOS
	currentDir = string.gsub(currentDir, "\n", "")
	LFS.createDir(currentDir.."/Update")
	LFS.createDir(currentDir.."/Update/sql")
	currentDir = currentDir.."/Update/sql/"

	local fileWrite = io.open(currentDir.."tables.sql","w")
	fileWrite:write(table.concat(sql_query_strs, "\n"))
	fileWrite:close()


	local tableModifys = {}
	for name, info in pairs(newDB) do
		if oldDB[name] then
			tableModifys[name] = self:compareSqlRecords(info, oldDB[name], name)
		end
	end

	local function replaceDangerStr(str)
		return string.gsub(str, "%%[a-zA-Z]", "&&")
	end
	for tableName, modifies in pairs(tableModifys) do
		local sqls = {}
		for k, v in ipairs(modifies.adds) do
			local sql = [[INSERT INTO ]]..tableName..[[(%s) VALUES(%s);]]
			for fieldName, fieldValue in pairs(v) do
				fieldValue = string.upper(newDB[tableName].names[fieldName].type) == "TEXT" and "'"..fieldValue.."'" or fieldValue
				sql = string.format(sql, (fieldName..",%s"), (fieldValue..",%s"))
			end
			sql = string.gsub(sql, ",%%s", "")
			table.insert(sqls, sql)
		end
		for k, v in ipairs(modifies.modifies) do
			local sql = [[REPLACE INTO ]]..tableName..[[(%s) VALUES(%s);]] --这边语句要熟悉一下
			for fieldName, fieldValue in pairs(v) do
				fieldValue = string.upper(newDB[tableName].names[fieldName].type) == "TEXT" and "'"..fieldValue.."'" or fieldValue
				sql = string.format(sql, (fieldName..",%s"), (fieldValue..",%s"))
			end
			sql = string.gsub(sql, ",%%s", "")
			table.insert(sqls, sql)
		end
		for k, v in ipairs(modifies.deletes) do
			local sql = [[DELETE FROM ]]..tableName..[[ WHERE %s;]]
			for _, pkName in ipairs(modifies.pks) do
				sql = string.format(sql, pkName.." = "..v[pkName].." AND %s")
			end
			sql = string.gsub(sql, "AND %%s", "")
			table.insert(sqls, sql)
		end
		if #sqls > 0 then
			local fileWrite = io.open(currentDir..tableName..".sql","w")
			fileWrite:write(table.concat(sqls, "\n"))
			fileWrite:close()
		end
	end


	self:verifySQLChanges()
	exit("执行完成. 正常退出!")
end

function SQLiteCompare:readFileLineByLine(path, cb)
	local f = io.open(path, "rb")
	if not f then exit("读取文件失败 : "..path) end
	for line in f:lines() do
		cb(line)
	end
end

function SQLiteCompare:verifySQLChanges()
	--select <column_one>, <column_two> from <table_name> order by <column_one>, <column_two>; --[[ASC, DESC]]
	local tbs = {}
	local sqls = {}
	for file in lfs.dir(currentDir) do
		if string.sub(file, 1, 1) ~= "." then
			local tb = file == "tables.sql" and tbs or sqls
			self:readFileLineByLine(currentDir..file, function(l)
				table.insert(tb, l)
			end)
		end
	end

	local originFile = io.open(string.gsub(currentDir.."tables.sql", "\\", "/"),"rb")
	local path = string.gsub(io.popen("pwd"):read("*all"), "/runtime/mac/framework%-desktop.app/Contents/Resources", "") -- For MacOS
	path = string.gsub(path, "\n", "")
	path = string.gsub(path, "/runtime/mac/framework-desktop.app/Contents/Resources", "").."/sqlcompare/"
	local oldDB = self:openDB(path.."data_old.db")

	for _, sql in ipairs(tbs) do
		release_print("Running SQL : ["..tostring(sql).."]")
		release_print("Result :")
		release_print(_)
		dump(self:query(oldDB, sql))
		if _  > 200 then break end
	end
	
	for _, sql in ipairs(sqls) do
		release_print("Running SQL : ["..tostring(sql).."]")
		release_print("Result :")
		release_print(_)
		dump(self:query(oldDB, sql))
		if _  > 200 then break end
	end
end

return SQLiteCompare:create()

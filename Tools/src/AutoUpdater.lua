local LFS 				= require("app.components.Lfs")
local Utils 			= require("app.components.Utils")
local AutoUpdater 		= class("AutoUpdater")

local MD5 = cc.MD5:create()

--[[
--差-滤波器=[(A，C，D，M，R，T，U，X，B)…​*] 只选择添加(A)、复制(C)、删除(D)、修改(M)、重命名(R)、更改其类型(即常规文件、符号链接、子模块、…​)的文件(T)、未合并(U)、未知(X)或其配对中断(B)的文件。
可以使用筛选器字符的任何组合(包括无)。 何时*(全部或无)添加到组合中，如果有任何文件与比较中的其他条件匹配，
则选择所有路径；如果没有匹配其他条件的文件，则不会选择任何路径。 此外，这些大写字母也可以降大写以排除.。例如---diff-filter=广告排除了添加和删除的路径。

]]

local logs = {}

local updateDir = nil

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
	local str = ""
	for _, v in ipairs({...}) do
		str = str..tostring(v).."\t"
	end
	table.insert(logs, v)
	print(...)
end


local function dump(value, description, nesting)
    if type(nesting) ~= "number" then nesting = 3 end

    local lookupTable = {}
    local result = {}

    local traceback = string.split(debug.traceback("", 2), "\n")
    release_print("dump from: " .. string.trim(traceback[3]))

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
	LFS.createDir(updateDir.."/Log")
	outLog(updateDir.."/Log/log.txt")
    cc.Director:getInstance():endToLua()
end

function AutoUpdater.checkModified(currentDir)
	local file = io.open(currentDir.."/Update/changes.txt")
	local str = {}
	for line in file:lines() do
		table.insert(str, line)
	end
	print(#str)
	return files
end

function AutoUpdater.getMD5(filePath)
	local file = io.open(filePath, "rb")
	local content = file:read("*all")
	file:close()
	MD5:update(content)
	return MD5:getString()
end

local function TableToString(table)
	local data = "{"
	for k, v in pairs(table) do
		if type(v) ~= "function" then
			local vk = type(k) == "string" and '["'..k..'"]' or "["..k.."]"
			if type(v) == "table" then
				data = data..vk.."="..TableToString(v)..","
			else
				if type(v) == "string" then
					-- if v == "\n" then v = "\\n" end
					data = data..vk.."="..'"'..v..'"'..","
				else
					data = data..vk.."="..v..","
				end
			end
		end
	end

	data = string.sub(data, 1, string.len(data) - 1)
	data = data.."}"
	return data
end

function AutoUpdater.run()
	release_print("")
	release_print("")
	release_print("==========================================================")
	release_print("=============热更新自动打包工具已经启动..哔哔哔..===============")
	release_print("==========================================================")
	release_print("")
	release_print("")
	release_print("======================================================================")
	release_print(string.format("======正在自动检测提交[%s]到[%s]的差异文件(自动忽略删除的文件)=====", firstCommit, lastCommit))
	release_print("======================================================================")
	release_print("")
	release_print("")
	local currentDir = string.gsub(io.popen("echo %CD%/../"):read("*all"), "\n", "") -- For Win Only
	local currentDir = string.gsub(io.popen("pwd"):read("*all"), "/runtime/mac/framework%-desktop.app/Contents/Resources", "") -- For MacOS
	currentDir = string.gsub(currentDir, "\n", "")
	release_print(currentDir)
	local modifiedFiles = AutoUpdater.checkModified(currentDir)


	do return end
	-- Create Update Dir
	-- dump(modifiedFiles)

	updateDir = currentDir.."/Update"
	LFS.createDir(updateDir)


	local tasks = {}
	for k, v in pairs(modifiedFiles) do
		local dirs = string.split( v, "/" )
		local tempDir = updateDir
		for index, dir in pairs(dirs) do
			if index < #dirs then
				tempDir = tempDir.."/"..dir
				LFS.createDir(tempDir)
			else
				local From = string.gsub(currentDir.."/"..v, "\\", "/")
				local To = string.gsub(updateDir.."/"..v, "\\", "/")
				release_print(string.format("正在处理差异文件 [%s] ", v))
				table.insert(tasks, {
					From = From,
					To = To,
					ShortDir = v
				})
				Utils.bCopyFile(From, To)
			end
		end
	end

	release_print("")
	release_print("")
	release_print("==========================================================")
	release_print("==============所有文件处理完毕...正在对比MD5值..===============")
	release_print("==========================================================")
	release_print("")
	release_print("")
	if #tasks == 0 then
		exit("没有找到需要打包的文件...")
	end
	dump(tasks)

	for k, v in pairs(tasks) do
		v.FromMD5 	= AutoUpdater.getMD5(v.From)
		v.ToMD5 	= AutoUpdater.getMD5(v.To)
	end

	for k, v in pairs(tasks) do
		local successed = v.FromMD5 == v.ToMD5
        release_print(string.format("文件MD5检测 [%s] : [%s] !", successed and "通过" or "错误", v.ShortDir ))
		if not successed then
			exit("检测到错误...停止程序....")
		end
	end

	-- dump(tasks)
	release_print("")
	release_print("开始打包文件...")
	local path = updateDir.."/Update.FCZip"
	local unZipDir = updateDir.."/testUnZip"
	os.remove(path)
	-- local ZipperPath = currentDir.."/Tools/Zipper/Buildings/Src/Debug/Zipper.exe"
	-- local callBack = io.popen(string.format("%s %s %s", ZipperPath, updateDir, updateDir))
	local ZipperPath = currentDir.."/Tools/bin/Zipper"
	local callBack = io.popen(string.format("%s %s %s compress", ZipperPath, updateDir, updateDir))

	local Successed = false
	for line in callBack:lines() do
		if line == "successed" then
			Successed = true
			break
		end
	end
	if not Successed then
		exit("检测到错误...停止程序....")
	end
	release_print("打包文件成功 !")
	release_print(string.format("更新包路径 : [%s]", path))

	release_print("")
	release_print("")
	release_print("============================================")
	release_print("=================尝试解压文件=================")
	release_print("============================================")

	LFS.createDir(unZipDir)
	release_print("")
	release_print("文件解压完毕! 正在写入更新数据....")
	release_print("")
	local callBack = io.popen(string.format("%s %s %s unCompress", ZipperPath, path, updateDir.."/TestUnZip")):read("*all")
	local originFile = io.open(string.gsub(currentDir.."/AllUpdates", "\\", "/"),"rb")
	local originData = originFile and loadstring("return "..originFile:read("*a"))() or {}
	if originFile then
		originFile:close()
		originFile = nil
	end

	for k, v in pairs(tasks) do
		v.MD5 = v.FromMD5
		v.FromMD5 = nil
		v.ToMD5 = nil
		v.From = nil
		v.To = nil
		v.Dir = v.ShortDir
		v.ShortDir = nil
	end

	originData[#originData + 1] = {
		FileList = tasks,
		Date = os.date(),
		commitBase = firstCommit,
		commitLast = lastCommit
	}
    os.rename(updateDir.."/Update.FCZip", updateDir.."/"..#originData..".FCZip")
	dump(originData, "", 2)


	local fileTo = string.gsub(updateDir.."/AllUpdates", "\\", "/")
	local fileWrite = io.open(fileTo, "w")
	fileWrite:write(TableToString(originData))
	fileWrite:close()

	release_print("正在更新根目录[AllUpdates]文件")
	Utils.bCopyFile(fileTo, currentDir.."/AllUpdates")

	release_print("正在更新本地[version]文件")
	local Info = originData[#originData]
	fileWrite = io.open(currentDir.."/res/version","w")
	fileWrite:write(Utils.TableToString({
		Date 		= Info.Date,
		firstCommit = Info.commitBase,
		lastCommit 	= Info.commitLast,
		version 	= #originData
	}))
	fileWrite:close()

	release_print("")
	release_print("")
	release_print("===========全部操作完成!===========")
	exit("lua打包脚本正常退出!")
end

return AutoUpdater
local LFS 				= import("app.components.Lfs")
local Utils 			= import("app.components.Utils")
local AutoUpdater 		= class("AutoUpdater")

local MD5 = cc.MD5:create()

--[[
--差-滤波器=[(A，C，D，M，R，T，U，X，B)…​*] 只选择添加(A)、复制(C)、删除(D)、修改(M)、重命名(R)、更改其类型(即常规文件、符号链接、子模块、…​)的文件(T)、未合并(U)、未知(X)或其配对中断(B)的文件。
可以使用筛选器字符的任何组合(包括无)。 何时*(全部或无)添加到组合中，如果有任何文件与比较中的其他条件匹配，
则选择所有路径；如果没有匹配其他条件的文件，则不会选择任何路径。 此外，这些大写字母也可以降大写以排除.。例如---diff-filter=广告排除了添加和删除的路径。

]]

local WLSPath = "ubuntu1604.exe"

function AutoUpdater.checkModified(firstCommit, lastCommit)
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
	local rsfile = io.popen(string.format( "git diff --diff-filter=AM %s %s --name-only", firstCommit, lastCommit ) )
	local files = {}
	for line in rsfile:lines() do
		local compare = string.sub(line, 1, 4)
		if compare == "src/" or compare == "res/" then
			table.insert(files, line)
		end
	end
	return files
end

function AutoUpdater.runLinuxCMD(cmd)
	local file = io.popen(string.format('D:/WorkSpace/prj_framework/client/framework/Tools/Upload.bat "%s"', cmd))
	dump(file:read("*a"))
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

function AutoUpdater.run(firstCommit, lastCommit)
	-- local currentDir = string.gsub(io.popen("echo %CD%/../"):read("*all"), "\n", "") -- For Win Only
	local currentDir = string.gsub(io.popen("pwd"):read("*all"), "/runtime/mac/framework%-desktop.app/Contents/Resources", "") -- For MacOS
	currentDir = string.gsub(currentDir, "\n", "")
	print(currentDir)
	local modifiedFiles = AutoUpdater.checkModified(firstCommit, lastCommit)

	-- Create Update Dir
	-- dump(modifiedFiles)

	local updateDir = currentDir.."/Update"
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

	dump(tasks)
	for k, v in pairs(tasks) do
		v.FromMD5 	= AutoUpdater.getMD5(v.From)
		v.ToMD5 	= AutoUpdater.getMD5(v.To)
	end

	for k, v in pairs(tasks) do
		local successed = v.FromMD5 == v.ToMD5
        release_print(string.format("文件MD5检测 [%s] : [%s] !", successed and "通过" or "错误", v.ShortDir ))
		assert(successed, "检测到错误...停止程序....")
	end

	-- dump(tasks)
	release_print("")
	release_print("开始打包文件...")
	local path = updateDir.."/Update.FCZip"
	local unZipDir = updateDir.."/testUnZip"
	os.remove(path)
	-- local ZipperPath = currentDir.."/Tools/Zipper/Buildings/Src/Debug/Zipper.exe"
	-- local callBack = io.popen(string.format("%s %s %s", ZipperPath, updateDir, updateDir))
	local ZipperPath = currentDir.."/Tools/Zipper/Buildings/Src/Debug/Zipper"
	local callBack = io.popen(string.format("%s %s %s", ZipperPath, updateDir, updateDir))

	local Successed = false
	for line in callBack:lines() do
		if line == "successed" then
			Successed = true
			break
		end
	end
	assert(Successed, "检测到错误...停止程序....")
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
	local ZipperPath = currentDir.."/Tools/Zipper/Buildings/Src/Debug/Zipper"
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
end

return AutoUpdater
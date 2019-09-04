local LFS 				= import("app.components.Lfs")
local Utils 			= import("app.components.Utils")
local AutoUpdater 		= class("AutoUpdater")

local MD5 = cc.MD5:create()

--[[
--差-滤波器=[(A，C，D，M，R，T，U，X，B)…​*] 只选择添加(A)、复制(C)、删除(D)、修改(M)、重命名(R)、更改其类型(即常规文件、符号链接、子模块、…​)的文件(T)、未合并(U)、未知(X)或其配对中断(B)的文件。
可以使用筛选器字符的任何组合(包括无)。 何时*(全部或无)添加到组合中，如果有任何文件与比较中的其他条件匹配，
则选择所有路径；如果没有匹配其他条件的文件，则不会选择任何路径。 此外，这些大写字母也可以降大写以排除.。例如---diff-filter=广告排除了添加和删除的路径。

]]

function AutoUpdater.checkModified(firstCommit, lastCommit)
	release_print("")
	release_print("")
	release_print("==========================================================")
	release_print("===========热更新自动打包工具已经启动..哔哔哔..===========")
	release_print("==========================================================")
	release_print("")
	release_print("")
	release_print("======================================================================")
	release_print(string.format("==正在自动检测提交[%s]到[%s]的差异文件(自动忽略删除的文件)==", firstCommit, lastCommit))
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

function AutoUpdater.getMD5(filePath)
	MD5:updateFromFile(filePath)
	return MD5:getString()
end

function AutoUpdater.run(firstCommit, lastCommit)
	local currentDir = string.gsub(io.popen("echo %CD%"):read("*all"), "\n", "")
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
				local From = currentDir.."/"..v
				local To = updateDir.."/"..v
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
	release_print("============所有文件处理完毕...正在对比MD5值..============")
	release_print("==========================================================")
	release_print("")
	release_print("")
	for k, v in pairs(tasks) do
		v.FromMD5 	= AutoUpdater.getMD5(v.From)
		v.ToMD5 	= AutoUpdater.getMD5(v.To)
	end

	for k, v in pairs(tasks) do
		local successed = v.FromMD5 == v.ToMD5
		release_print(string.format("文件MD5检测 [%s] : [%s] !", successed and "通过" or "错误", v.ShortDir ))
		assert(successed, "检测到错误...停止程序....")
	end
	release_print("")
	release_print("")
end

return AutoUpdater
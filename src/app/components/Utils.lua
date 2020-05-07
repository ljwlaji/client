local Utils 	= class("Utils")

local FileUtils 			= cc.FileUtils:getInstance()
local writeblePath 			= FileUtils:getWritablePath()
local pointerPath 			= "res/packagePointer"
local currentResourcePath 	= (device.platform == "windows" or device.platform == "mac") and writeblePath .. "virtualDir/" or writeblePath
local DownloadRootPath  	= writeblePath.."Download/"
local DownloadCachePath  	= DownloadRootPath.."Cache/"

function Utils.getFilePathFromString(path)
	return string.gsub(path, string.match(path, ".+/(.+)"), "")
end

function Utils.getCurrentResPath()
	return currentResourcePath
end

function Utils.isFileExisted(path)
	return FileUtils:isFileExist(path)
end

function Utils.getDownloadRootPath()
	return DownloadRootPath
end

function Utils.getDownloadCachePath()
	return DownloadCachePath
end

function Utils.createDirectory(currentDirectoryPath)
	FileUtils:createDirectory(currentDirectoryPath)
end

function Utils.getVersionInfo()
	local file = io.open(Utils.getCurrentResPath().."res/version","rb")
	local content = file:read("*a")
	file:close()
	return loadstring("return "..content)()
end

function Utils.copyFile(src, dest)
	Utils.createDirectory(Utils.getFilePathFromString(dest))
	FileUtils:copyFile(src, dest)
end

function Utils.TableToString(table)
	local data = "{"
	for k, v in pairs(table) do
		if type(v) ~= "function" then
			local vk = type(k) == "string" and '["'..k..'"]' or "["..k.."]"
			if type(v) == "table" then
				data = data..vk.."="..Utils.TableToString(v)..","
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

function Utils.updateVersion(versionTable)
	local Info = versionTable.updateInfo
	local fileWrite = io.open(Utils.getCurrentResPath().."res/version", "wb")
	fileWrite:write(Utils.TableToString({
		Date 		= Info.Date,
		firstCommit = Info.commitBase,
		lastCommit 	= Info.commitLast,
		version 	= versionTable.versionID
	}))
	fileWrite:close()
end

if not Utils.getPackagePath then
    if FileUtils:isFileExist(Utils.getCurrentResPath()..pointerPath) then
        os.remove(Utils.getCurrentResPath()..pointerPath)
        release_print("================Pointer In WriteblePath Removed!===============")
    end
    local path = string.gsub(FileUtils:fullPathForFilename(pointerPath), pointerPath, "")
    Utils.getPackagePath = function() return path end
    dump(Utils.getPackagePath(), "PackagePath : ")
end

function Utils.changeParent( child, parent )
    assert(parent and child:getParent(), "Error! Parent Not Found...")
    child:retain():removeFromParent():addTo(parent):release()
    return child
end

function Utils.autoAlginChildrenH(parent, GAPH)
    local maxWidth      = 0
    local maxHeight     = 0
    local currWidth     = 0
    local currHeight    = 0
    for k, v in pairs(parent:getChildren()) do
        if v:isVisible() then
            currWidth = v:getContentSize().width
            currHeight = v:getContentSize().height
            if maxHeight < currHeight then maxHeight = currHeight end
            v:setAnchorPoint(0, 0):move(maxWidth, 0)
            maxWidth = maxWidth + currWidth + GAPH
        end
    end
    return maxWidth, maxHeight
end

function Utils.createScrollableLayouter(baseNode, onNotEnoughWidth)
    assert(not baseNode.__scrollableLayouter, "\n Try Call CommonUtils.createScrollableLayouter Twice !\nFor Refresh Case Please Use node.startScroll(scrollTime, waitTime) Instead.")
    local layouter = ccui.Layout:create()
                                :addTo(baseNode:getParent())
                                :setAnchorPoint(baseNode:getAnchorPoint().x, baseNode:getAnchorPoint().y)
                                :setContentSize(baseNode:getContentSize().width, baseNode:getContentSize().height)
                                :move(baseNode:getPositionX(), baseNode:getPositionY())
                                :setClippingEnabled(true)

    Utils.changeParent(baseNode, layouter)
    baseNode.__scrollableLayouter = layouter

    baseNode.startScroll = function(time, waitTime)
        baseNode:setContentSize(Utils.autoAlginChildrenH(baseNode))
                :setAnchorPoint(0, 0)
                :stopAllActions()
                :pos(0, 0)
        if layouter:getContentSize().width - baseNode:getContentSize().width > 0 then
            if onNotEnoughWidth then onNotEnoughWidth(baseNode) end
            return
        end
        waitTime    = waitTime  or 1
        time        = time      or 2
        baseNode:runAction( 
            cc.RepeatForever:create( 
                cc.Sequence:create(
                    cc.MoveTo:create(time, cc.p(layouter:getContentSize().width - baseNode:getContentSize().width ,0)),
                    cc.DelayTime:create(waitTime),
                    cc.MoveTo:create(time, cc.p(0, 0)),
                    cc.DelayTime:create(waitTime)
                )
             )
         )
    end
end

function Utils.splitStrToTable(input, maxLetterPreLine)
    local ret = {}
    while Utils.subStringGetTotalIndex(input) > maxLetterPreLine do
        table.insert(ret, Utils.subStringUTF8(input, 1, maxLetterPreLine))
        input = Utils.subStringUTF8(input, maxLetterPreLine + 1)
    end
    if string.len(input) > 0 then
        table.insert(ret, input)
    end
    return ret
end

function Utils.subStringUTF8(str, startIndex, endIndex)
    if startIndex < 0 then
        startIndex = Utils.subStringGetTotalIndex(str) + startIndex + 1
    end

    if endIndex ~= nil and endIndex < 0 then
        endIndex = Utils.subStringGetTotalIndex(str) + endIndex + 1
    end

    if endIndex == nil then 
        return string.sub(str, Utils.subStringGetTrueIndex(str, startIndex))
    else
        return string.sub(str, Utils.subStringGetTrueIndex(str, startIndex), Utils.subStringGetTrueIndex(str, endIndex + 1) - 1)
    end
end

function Utils.subStringGetTotalIndex(str)
    local curIndex = 0;
    local i = 1;
    local lastCount = 1;
    repeat 
        lastCount = Utils.subStringGetByteCount(str, i)
        i = i + lastCount;
        curIndex = curIndex + 1;
    until(lastCount == 0);
    return curIndex - 1;
end

function Utils.subStringGetTrueIndex(str, index)
    local curIndex = 0;
    local i = 1;
    local lastCount = 1;
    repeat 
        lastCount = Utils.subStringGetByteCount(str, i)
        i = i + lastCount;
        curIndex = curIndex + 1;
    until(curIndex >= index);
    return i - lastCount;
end

function Utils.subStringGetByteCount(str, index)
    local curByte = string.byte(str, index)
    local byteCount = 1;
    if curByte == nil then
        byteCount = 0
    elseif curByte == 9 then --For '\t' Issus
        byteCount = 4
    elseif curByte > 0 and curByte <= 127 then
        byteCount = 1
    elseif curByte>=192 and curByte<=223 then
        byteCount = 2
    elseif curByte>=224 and curByte<=239 then
        byteCount = 3
    elseif curByte>=240 and curByte<=247 then
        byteCount = 4
    end
    return byteCount;
end


return Utils
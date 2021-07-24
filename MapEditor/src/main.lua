cc.FileUtils:getInstance():setPopupNotify(false)

require "config"
require "cocos.init"
require "app.components.UITextEx"
require "app.extensions.NodeEx"

local function saveToFile(mapStruct, tabs)
    local upperTabs = tabs
    tabs = tabs..'\t'
    local data = "{\n"
    for k, v in pairs(mapStruct) do
        if type(v) ~= "function" then
            local vk = tabs..(type(k) == "string" and '["'..k..'"]' or "["..k.."]")
            if type(v) == "table" then
                data = data..vk.." = "..saveToFile(v, tabs)..","
            else
                if type(v) == "string" then
                    if v == "\n" then v = "\\n" end
                    data = data..vk.." = "..'"'..v..'"'..","
                else
                    data = data..vk.." = "..tostring(v)..","
                end
            end
            data = data.."\n"
        end
    end

    data = string.sub(data, 1, string.len(data) - 2).."\n"
    data = data..upperTabs.."}"
    return data
end 


__G__TRACKBACK__ = function(msg)
    local tbStr=debug.traceback("", 2)
    release_print("----------------------------------------")
    release_print("LUA ERROR: " .. tostring(msg) .. "\n")
    release_print(tbStr)
    release_print("----------------------------------------")

    -- report lua exception
    if device.platform == "ios" or device.platform == "android" then
        buglyReportLuaException(tostring(tbStr), debug.traceback())
    end

    return msg
end


release_print("===================")
release_print("\n"..saveToFile(display, ""))

local function main()
    require("app.MyApp"):create():run()
end

local status, msg = xpcall(main, __G__TRACKBACK__)
if not status then
    print(msg)
end

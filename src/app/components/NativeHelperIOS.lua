local NativeHelperIOS = class("NativeHelperIOS")
local callStaticMethod = LuaObjcBridge.callStaticMethod
local function callOC(className, methodName, args)
    local ok, ret = callStaticMethod(className, methodName, args)
    if not ok then
        local msg = string.format("luaoc.callStaticMethod(\"%s\", \"%s\", \"%s\") - error: [%s] ",
                className, methodName, tostring(args), tostring(ret))
        if ret == -1 then
            print(msg .. "INVALID PARAMETERS")
        elseif ret == -2 then
            print(msg .. "CLASS NOT FOUND")
        elseif ret == -3 then
            print(msg .. "METHOD NOT FOUND")
        elseif ret == -4 then
            print(msg .. "EXCEPTION OCCURRED")
        elseif ret == -5 then
            print(msg .. "INVALID METHOD SIGNATURE")
        else
            print(msg .. "UNKNOWN")
        end
    end
    return ok, ret
end

function NativeHelperIOS:pasteToClipBoard(str)
    local ok, ret = callOC("YZAuthID", "pasteToClipBoard", {
    	value = str
    })
end


function NativeHelperIOS:verify(callback)
   local ok, ret = callOC("YZAuthID", "verify", {
    	callback = function(ret) 
            release_print(ret)
    		callback(ret == "not support" or ret == "success")
    	end
    })
end


return NativeHelperIOS
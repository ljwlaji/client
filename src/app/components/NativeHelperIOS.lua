local NativeHelperIOS = class("NativeHelperIOS", require("app.components.NativeHelperBase"))
local callStaticMethod = LuaObjcBridge.callStaticMethod
local function callOC(className, methodName, args)
    local ok, ret = callStaticMethod(className, methodName, args)
    if not ok then
        local msg = string.format("luaoc.callStaticMethod(\"%s\", \"%s\", \"%s\") - error: [%s] ",
                className, methodName, tostring(args), tostring(ret))
        if ret == -1 then
            release_print(msg .. "INVALID PARAMETERS")
        elseif ret == -2 then
            release_print(msg .. "CLASS NOT FOUND")
        elseif ret == -3 then
            release_print(msg .. "METHOD NOT FOUND")
        elseif ret == -4 then
            release_print(msg .. "EXCEPTION OCCURRED")
        elseif ret == -5 then
            release_print(msg .. "INVALID METHOD SIGNATURE")
        else
            release_print(msg .. "UNKNOWN")
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

function NativeHelperIOS:canVerify()
    release_print("NativeHelperIOS:canVerify()")
    return true
end


return NativeHelperIOS
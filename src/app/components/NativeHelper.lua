local NativeHelper
if device.platform == "ios" then
	NativeHelper = class("NativeHelper", require("app.components.NativeHelperIOS"))
else

end

local function addMethod(name, func)
	if not NativeHelper[name] then
		NativeHelper[name] = function(this, ...)
			if this.super[name] then
				return this.super[name](this, ...)
			end
		end
	end
end

NativeHelper.instance = nil

function NativeHelper:getInstance()
	if not NativeHelper.instance then
		NativeHelper.instance = NativeHelper:create()
	end
	return NativeHelper.instance
end

addMethod("pasteToClipBoard")
addMethod("verify")



return NativeHelper:getInstance()
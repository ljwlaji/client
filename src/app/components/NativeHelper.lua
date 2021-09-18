local NativeHelper

if device.platform == "ios" then
	NativeHelper = require("app.components.NativeHelperIOS")
else
	NativeHelper = require("app.components.NativeHelperBase")
end

return NativeHelper:getInstance()
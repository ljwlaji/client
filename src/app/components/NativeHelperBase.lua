local NativeHelperBase = class("NativeHelperBase")

NativeHelperBase.instance = nil

function NativeHelperBase:getInstance()
	if not NativeHelperBase.instance then
		NativeHelperBase.instance = self:create()
	end
	return NativeHelperBase.instance
end

function NativeHelperBase:pasteToClipBoard(str)

end


function NativeHelperBase:verify(callback)
	callback(false)
end

function NativeHelperBase:canVerify()
    return false
end

function NativeHelperBase:reportLuaError()
end

return NativeHelperBase
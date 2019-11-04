local CCAudio 	= cc.SimpleAudioEngine:getInstance()
local AudioMgr 	= class("AudioMgr")

AudioMgr.instance = nil

function AudioMgr:getInstance()
	if AudioMgr.instance == nil then
		AudioMgr.instance = AudioMgr:create()
	end
	return AudioMgr.instance
end

function AudioMgr:playEffect(effectName, loop)
	CCAudio:playEffect(string.format("res/sound/effect/%s", effectName), loop)
end



return AudioMgr.getInstance()
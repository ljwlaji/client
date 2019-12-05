local CCAudio 	= cc.SimpleAudioEngine:getInstance()
local AudioMgr 	= class("AudioMgr")

AudioMgr.instance = nil


--[[
function audio.getMusicVolume()
function audio.setMusicVolume(volume)
function audio.preloadMusic(filename)
function audio.playMusic(filename, isLoop)
function audio.stopMusic(isReleaseData)
function audio.pauseMusic()
function audio.resumeMusic()
function audio.rewindMusic()
function audio.isMusicPlaying()
function audio.getSoundsVolume()
function audio.setSoundsVolume(volume)
function audio.playSound(filename, isLoop)
function audio.pauseSound(handle)
function audio.pauseAllSounds()
function audio.resumeSound(handle)
function audio.resumeAllSounds()
function audio.stopSound(handle)
function audio.stopAllSounds()
function audio.preloadSound(filename)
function audio.unloadSound(filename)
]]
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
local ScriptMgr = class("ScriptMgr")

ScriptMgr.instance = nil

function ScriptMgr.getInstance()
	ScriptMgr.instance = ScriptMgr.instance or ScriptMgr:create()
end

function ScriptMgr:ctor()
	ScriptMgr.instance = self
	self.scripts = {}
end

function ScriptMgr:registScript(Script)
	self.scripts[Script.Name] = Script.GetAI
end

return ScriptMgr.getInstance()
local ViewBaseEx 		= import("app.views.ViewBaseEx")
local vNodeDamageEffect = class("vNodeDamageEffect", ViewBaseEx)

vNodeDamageEffect.RESOURCE_FILENAME = "res/csb/node/CSB_Node_DamageEffecct.csb"
vNodeDamageEffect.RESOURCE_BINDING 	= {}

function vNodeDamageEffect:onCreate(context)
	-- self:reset(context)
end

function vNodeDamageEffect:reset(damage)
	self.m_Children["Text_Damage"]:setString(50)
end






return vNodeDamageEffect
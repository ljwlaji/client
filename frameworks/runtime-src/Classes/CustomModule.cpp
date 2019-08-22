#include "CustomModule.h"
#include "scripting/lua-bindings/manual/lua_module_register.h"
#include "scripting/lua-bindings/manual/cocostudio/lua_cocos2dx_coco_studio_manual.hpp"


int register_fire_timmer_module(lua_State* L)
{
	return 1;
}

int register_fire_core_curl_module(lua_State* L)
{
	return 1;
}

int register_fire_core_modules(lua_State* L)
{
	lua_getglobal(L, "_G");
	if (lua_istable(L, -1))
	{
#if (CC_TARGET_PLATFORM == CC_PLATFORM_ANDROID || CC_TARGET_PLATFORM == CC_PLATFORM_IOS) && !defined(CC_TARGET_OS_TVOS)
#endif
	}
	lua_pop(L, 1);

	return 1;
}

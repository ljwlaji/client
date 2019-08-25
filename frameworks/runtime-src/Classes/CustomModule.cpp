#include "CustomModule.h"
#include "scripting/lua-bindings/manual/lua_module_register.h"
#include "scripting/lua-bindings/manual/cocostudio/lua_cocos2dx_coco_studio_manual.hpp"
#include "scripting/lua-bindings/manual/tolua_fix.h"
#include "scripting/lua-bindings/manual/LuaBasicConversions.h"
#include "Timmer.h"


int tolua_firecore_timmer_create(lua_State* L)
{
	int argc = 0;
	bool ok = true;

#if COCOS2D_DEBUG >= 1
	tolua_Error tolua_err;
#endif

#if COCOS2D_DEBUG >= 1
	if (!tolua_isusertable(L, 1, "cc.Timmer", 0, &tolua_err)) goto tolua_lerror;
#endif

	argc = lua_gettop(L) - 1;

	if (argc == 0)
	{
		if (!ok)
		{
			tolua_error(L, "invalid arguments in function 'tolua_firecore_timmer_create'", nullptr);
			return 0;
		}
		Timmer* ret = Timmer::create();
		object_to_luaval<Timmer>(L, "cc.Timmer", (Timmer*)ret);
		return 1;
	}
	luaL_error(L, "%s has wrong number of arguments: %d, was expecting %d\n ", "cc.Timmer:create", argc, 0);
	return 0;
#if COCOS2D_DEBUG >= 1
	tolua_lerror:
		tolua_error(L, "#ferror in function 'tolua_firecore_timmer_create'.", &tolua_err);
#endif
	return 0;
}

int tolua_firecore_timmer_getMSDiff(lua_State* tolua_S)
{
    int argc = 0;
    Timmer* cobj = nullptr;
    bool ok  = true;

#if COCOS2D_DEBUG >= 1
    tolua_Error tolua_err;
#endif


#if COCOS2D_DEBUG >= 1
    if (!tolua_isusertype(tolua_S,1,"cc.Timmer",0,&tolua_err)) goto tolua_lerror;
#endif

    cobj = (Timmer*)tolua_tousertype(tolua_S,1,0);

#if COCOS2D_DEBUG >= 1
    if (!cobj) 
    {
        tolua_error(tolua_S,"invalid 'cobj' in function 'tolua_firecore_timmer_getMSDiff'", nullptr);
        return 0;
    }
#endif

    argc = lua_gettop(tolua_S)-1;
    if (argc == 0) 
    {
        if(!ok)
        {
            tolua_error(tolua_S,"invalid arguments in function 'tolua_firecore_timmer_getMSDiff'", nullptr);
            return 0;
        }
        uint32 ret = cobj->GetMSDiff();
		lua_pushinteger(tolua_S, ret);
        return 1;
    }
    luaL_error(tolua_S, "%s has wrong number of arguments: %d, was expecting %d \n", "cc.Timmer:GetMSDiff",argc, 0);
    return 0;

#if COCOS2D_DEBUG >= 1
    tolua_lerror:
    tolua_error(tolua_S,"#ferror in function 'tolua_firecore_timmer_getMSDiff'.",&tolua_err);
#endif

    return 0;
}

int tolua_firecore_timmer_reset(lua_State* tolua_S)
{
    int argc = 0;
	Timmer* cobj = nullptr;
    bool ok  = true;

#if COCOS2D_DEBUG >= 1
    tolua_Error tolua_err;
#endif


#if COCOS2D_DEBUG >= 1
    if (!tolua_isusertype(tolua_S,1,"cc.Timmer",0,&tolua_err)) goto tolua_lerror;
#endif

    cobj = (Timmer*)tolua_tousertype(tolua_S,1,0);

#if COCOS2D_DEBUG >= 1
    if (!cobj) 
    {
        tolua_error(tolua_S,"invalid 'cobj' in function 'tolua_firecore_timmer_reset'", nullptr);
        return 0;
    }
#endif

    argc = lua_gettop(tolua_S)-1;
    if (argc == 0) 
    {
        if(!ok)
        {
            tolua_error(tolua_S,"invalid arguments in function 'tolua_firecore_timmer_reset'", nullptr);
            return 0;
        }
        cobj->ResetTimmer();
        lua_settop(tolua_S, 1);
        return 1;
    }
    luaL_error(tolua_S, "%s has wrong number of arguments: %d, was expecting %d \n", "cc.Timmer:reset",argc, 0);
    return 0;

#if COCOS2D_DEBUG >= 1
    tolua_lerror:
    tolua_error(tolua_S,"#ferror in function 'tolua_firecore_timmer_reset'.",&tolua_err);
#endif
    return 0;
}

int register_fire_timmer_module(lua_State* L)
{
	tolua_usertype(L, "cc.Timmer");
	tolua_cclass(L, "Timmer", "cc.Timmer", "cc.Node", nullptr);

	tolua_beginmodule(L, "Timmer");
		tolua_function(L, "create", tolua_firecore_timmer_create);
		tolua_function(L, "reset", tolua_firecore_timmer_reset);
		tolua_function(L, "getMSDiff", tolua_firecore_timmer_getMSDiff);

	tolua_endmodule(L);
	std::string typeName = typeid(Timmer).name();
	g_luaType[typeName] = "cc.Timmer";
	g_typeCast["Timmer"] = "cc.Timmer";
	return 1;
}

int register_fire_core_curl_module(lua_State* L)
{
	return 1;
}

int register_fire_core_modules(lua_State* L)
{
	register_fire_timmer_module(L);
	return 1;
}

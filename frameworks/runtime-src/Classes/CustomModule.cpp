#include "CustomModule.h"
#include "scripting/lua-bindings/manual/lua_module_register.h"
#include "scripting/lua-bindings/manual/cocostudio/lua_cocos2dx_coco_studio_manual.hpp"
#include "scripting/lua-bindings/manual/tolua_fix.h"
#include "scripting/lua-bindings/manual/LuaBasicConversions.h"
#include "PixalCollisionMgr.h"
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

int tolua_firecore_PixalCollisionMgr_loadPNGData(lua_State* tolua_S)
{
    int argc = 0;
    PixalCollisionMgr* cobj = nullptr;
    bool ok  = true;

#if COCOS2D_DEBUG >= 1
    tolua_Error tolua_err;
#endif


#if COCOS2D_DEBUG >= 1
    if (!tolua_isusertype(tolua_S,1,"cc.PixalCollisionMgr",0,&tolua_err)) goto tolua_lerror;
#endif

    cobj = (PixalCollisionMgr*)tolua_tousertype(tolua_S,1,0);

#if COCOS2D_DEBUG >= 1
    if (!cobj) 
    {
        tolua_error(tolua_S,"invalid 'cobj' in function 'tolua_firecore_loadPNGData'", nullptr);
        return 0;
    }
#endif

    argc = lua_gettop(tolua_S)-1;
    if (argc == 1) 
    {
        std::string arg0;

        ok &= luaval_to_std_string(tolua_S, 2,&arg0, "cc.PixalCollisionMgr:loadPNGData");
        if(!ok)
        {
            tolua_error(tolua_S,"invalid arguments in function 'tolua_firecore_loadPNGData'", nullptr);
            return 0;
        }
        bool ret = cobj->loadPNGData(arg0.c_str());
		tolua_pushboolean(tolua_S, (bool)ret);
        return 1;
    }
    luaL_error(tolua_S, "%s has wrong number of arguments: %d, was expecting %d \n", "cc.Node:getChildByName",argc, 1);
    return 0;

#if COCOS2D_DEBUG >= 1
    tolua_lerror:
    tolua_error(tolua_S,"#ferror in function 'tolua_firecore_loadPNGData'.",&tolua_err);
#endif

    return 0;
}

int tolua_firecore_PixalCollisionMgr_getAlpha(lua_State* tolua_S)
{
    int argc = 0;
    PixalCollisionMgr* cobj = nullptr;
    bool ok  = true;

#if COCOS2D_DEBUG >= 1
    tolua_Error tolua_err;
#endif


#if COCOS2D_DEBUG >= 1
    if (!tolua_isusertype(tolua_S,1,"cc.PixalCollisionMgr",0,&tolua_err)) goto tolua_lerror;
#endif

    cobj = (PixalCollisionMgr*)tolua_tousertype(tolua_S,1,0);

#if COCOS2D_DEBUG >= 1
    if (!cobj) 
    {
        tolua_error(tolua_S,"invalid 'cobj' in function 'tolua_firecore_PixalCollisionMgr_getAlpha'", nullptr);
        return 0;
    }
#endif

    argc = lua_gettop(tolua_S)-1;
    if (argc == 3)
    {
		std::string arg1 = "";
		uint32 arg2 = 0;
		uint32 arg3 = 0;
		ok &= luaval_to_std_string(tolua_S, 2, &arg1, "cc.PixalCollisionMgr:getAlpha");
		ok &= luaval_to_int32(tolua_S, 3, (int *)&arg2, "cc.PixalCollisionMgr:getAlpha");
		ok &= luaval_to_int32(tolua_S, 4, (int *)&arg3, "cc.PixalCollisionMgr:getAlpha");

        if(!ok)
        {
            tolua_error(tolua_S,"invalid arguments in function 'tolua_firecore_PixalCollisionMgr_getAlpha", nullptr);
            return 0;
        }
		bool ret = cobj->GetAlpha(arg1.c_str(), arg2 - 1, arg3 - 1);
        tolua_pushboolean(tolua_S,(bool)ret);
        return 1;
    }
    luaL_error(tolua_S, "%s has wrong number of arguments: %d, was expecting %d \n", "cc.PixalCollisionMgr:getAlpha",argc, 3);
    return 0;

#if COCOS2D_DEBUG >= 1
    tolua_lerror:
    tolua_error(tolua_S,"#ferror in function 'tolua_firecore_PixalCollisionMgr_getAlpha'.",&tolua_err);
#endif

    return 0;
}

int tolua_firecore_PixalCollisionMgr_getInstance(lua_State* tolua_S)
{
    int argc = 0;
    bool ok  = true;

#if COCOS2D_DEBUG >= 1
    tolua_Error tolua_err;
#endif

#if COCOS2D_DEBUG >= 1
    if (!tolua_isusertable(tolua_S,1,"cc.PixalCollisionMgr",0,&tolua_err)) goto tolua_lerror;
#endif

    argc = lua_gettop(tolua_S) - 1;

    if (argc == 0)
    {
        if(!ok)
        {
            tolua_error(tolua_S,"invalid arguments in function 'tolua_firecore_PixalCollisionMgr_getInstance'", nullptr);
            return 0;
        }
		PixalCollisionMgr* ret = PixalCollisionMgr::GetInstance();
        object_to_luaval<PixalCollisionMgr>(tolua_S, "cc.PixalCollisionMgr",(PixalCollisionMgr*)ret);
        return 1;
    }
    luaL_error(tolua_S, "%s has wrong number of arguments: %d, was expecting %d\n ", "cc.PixalCollisionMgr:getInstance",argc, 0);
    return 0;
#if COCOS2D_DEBUG >= 1
    tolua_lerror:
    tolua_error(tolua_S,"#ferror in function 'tolua_firecore_PixalCollisionMgr_getInstance'.",&tolua_err);
#endif
    return 0;
}

int register_fire_PixalCollisionMgr_module(lua_State* L)
{
	tolua_usertype(L, "cc.PixalCollisionMgr");
	tolua_cclass(L, "PixalCollisionMgr", "cc.PixalCollisionMgr", "", nullptr);

	tolua_beginmodule(L, "PixalCollisionMgr");
		tolua_function(L, "getInstance", tolua_firecore_PixalCollisionMgr_getInstance);
		tolua_function(L, "loadPNGData", tolua_firecore_PixalCollisionMgr_loadPNGData);
		tolua_function(L, "getAlpha", tolua_firecore_PixalCollisionMgr_getAlpha);

	tolua_endmodule(L);
	std::string typeName = typeid(PixalCollisionMgr).name();
	g_luaType[typeName] = "cc.PixalCollisionMgr";
	g_typeCast["PixalCollisionMgr"] = "cc.PixalCollisionMgr";
	return 1;
}

int register_fire_core_curl_module(lua_State* L)
{
	return 1;
}

int register_fire_core_modules(lua_State* L)
{
	register_fire_PixalCollisionMgr_module(L);
	register_fire_timmer_module(L);
	return 1;
}

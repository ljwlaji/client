#include "CustomModule.h"
#include "scripting/lua-bindings/manual/lua_module_register.h"
#include "scripting/lua-bindings/manual/cocostudio/lua_cocos2dx_coco_studio_manual.hpp"
#include "scripting/lua-bindings/manual/tolua_fix.h"
#include "scripting/lua-bindings/manual/LuaBasicConversions.h"
#include "PixalCollisionMgr.h"
#include "UpdateMgr.h"
#include "Timmer.h"
#include "MD5.h"
#include "Zipper.h"
#include "GausBlurSprite/GausBlurSprite.h"


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

int tolua_firecore_PixalCollisionMgr_link(lua_State* tolua_S)
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
        tolua_error(tolua_S,"invalid 'cobj' in function 'tolua_firecore_PixalCollisionMgr_link'", nullptr);
        return 0;
    }
#endif

    argc = lua_gettop(tolua_S)-1;
    if (argc == 1)
    {
		std::string arg1 = "";
		ok &= luaval_to_std_string(tolua_S, 2, &arg1, "cc.PixalCollisionMgr:link");
		if(!ok)
        {
			tolua_error(tolua_S,"invalid arguments in function 'tolua_firecore_PixalCollisionMgr_link'", nullptr);
            return 0;
        }
        cobj->link(arg1.c_str());
        lua_settop(tolua_S, 1);
        return 1;
    }
    luaL_error(tolua_S, "%s has wrong number of arguments: %d, was expecting %d \n", "cc.PixalCollisionMgr:link",argc, 0);
    return 0;

#if COCOS2D_DEBUG >= 1
    tolua_lerror:
    tolua_error(tolua_S,"#ferror in function 'tolua_firecore_PixalCollisionMgr_link'.",&tolua_err);
#endif
    return 0;
}

int tolua_firecore_PixalCollisionMgr_unLink(lua_State* tolua_S)
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
        tolua_error(tolua_S,"invalid 'cobj' in function 'tolua_firecore_PixalCollisionMgr_unLink'", nullptr);
        return 0;
    }
#endif

    argc = lua_gettop(tolua_S)-1;
    if (argc == 1)
    {
		std::string arg1 = "";
		ok &= luaval_to_std_string(tolua_S, 2, &arg1, "cc.PixalCollisionMgr:unLink");
		if(!ok)
        {
			tolua_error(tolua_S,"invalid arguments in function 'tolua_firecore_PixalCollisionMgr_unLink'", nullptr);
            return 0;
        }
        cobj->unLink(arg1.c_str());
        lua_settop(tolua_S, 1);
        return 1;
    }
    luaL_error(tolua_S, "%s has wrong number of arguments: %d, was expecting %d \n", "cc.PixalCollisionMgr:unLink",argc, 0);
    return 0;

#if COCOS2D_DEBUG >= 1
    tolua_lerror:
    tolua_error(tolua_S,"#ferror in function 'tolua_firecore_PixalCollisionMgr_unLink'.",&tolua_err);
#endif
    return 0;
}

int register_fire_PixalCollisionMgr_module(lua_State* L)
{
	tolua_usertype(L, "cc.PixalCollisionMgr");
	tolua_cclass(L, "PixalCollisionMgr", "cc.PixalCollisionMgr", "", nullptr);

	tolua_beginmodule(L, "PixalCollisionMgr");
		tolua_function(L, "link", tolua_firecore_PixalCollisionMgr_link);
		tolua_function(L, "unLink", tolua_firecore_PixalCollisionMgr_unLink);
		tolua_function(L, "getInstance", tolua_firecore_PixalCollisionMgr_getInstance);
		tolua_function(L, "loadPNGData", tolua_firecore_PixalCollisionMgr_loadPNGData);
		tolua_function(L, "getAlpha", tolua_firecore_PixalCollisionMgr_getAlpha);

	tolua_endmodule(L);
	std::string typeName = typeid(PixalCollisionMgr).name();
	g_luaType[typeName] = "cc.PixalCollisionMgr";
	g_typeCast["PixalCollisionMgr"] = "cc.PixalCollisionMgr";
	return 1;
}

///////////////////////////////////////////////////////////////////////
///////////////////////////////////////////////////////////////////////
///////////////////////////////////////////////////////////////////////
///////////////////////////////////////////////////////////////////////
int tolua_firecore_UpdateMgr_getInstance(lua_State* tolua_S)
{
    int argc = 0;
    bool ok  = true;

#if COCOS2D_DEBUG >= 1
    tolua_Error tolua_err;
#endif

#if COCOS2D_DEBUG >= 1
    if (!tolua_isusertable(tolua_S,1,"cc.UpdateMgr",0,&tolua_err)) goto tolua_lerror;
#endif

    argc = lua_gettop(tolua_S) - 1;

    if (argc == 0)
    {
        if(!ok)
        {
            tolua_error(tolua_S,"invalid arguments in function 'tolua_firecore_UpdateMgr_getInstance'", nullptr);
            return 0;
        }
		UpdateMgr* ret = UpdateMgr::GetInstance();
        object_to_luaval<UpdateMgr>(tolua_S, "cc.UpdateMgr",(UpdateMgr*)ret);
        return 1;
    }
    luaL_error(tolua_S, "%s has wrong number of arguments: %d, was expecting %d\n ", "cc.UpdateMgr:getInstance",argc, 0);
    return 0;
#if COCOS2D_DEBUG >= 1
    tolua_lerror:
    tolua_error(tolua_S,"#ferror in function 'tolua_firecore_UpdateMgr_getInstance'.",&tolua_err);
#endif
    return 0;
}

int tolua_firecore_UpdateMgr_stop(lua_State* tolua_S)
{
    UpdateMgr* cobj = nullptr;
    cobj = (UpdateMgr*)tolua_tousertype(tolua_S,1,0);
    cobj->Stop();
    lua_settop(tolua_S, 1);
    return 1;
}

int tolua_firecore_UpdateMgr_pause(lua_State* tolua_S)
{
    UpdateMgr* cobj = nullptr;
    cobj = (UpdateMgr*)tolua_tousertype(tolua_S,1,0);
    cobj->Pauese();
    lua_settop(tolua_S, 1);
    return 1;
}

int tolua_firecore_UpdateMgr_resume(lua_State* tolua_S)
{
    UpdateMgr* cobj = nullptr;
    cobj = (UpdateMgr*)tolua_tousertype(tolua_S,1,0);
    cobj->Resume();
    lua_settop(tolua_S, 1);
    return 1;
}

int tolua_firecore_UpdateMgr_start(lua_State* tolua_S)
{
    int argc = 0;
    UpdateMgr* cobj = nullptr;
    bool ok  = true;
#if COCOS2D_DEBUG >= 1
    tolua_Error tolua_err;
#endif

#if COCOS2D_DEBUG >= 1
    if (!tolua_isusertype(tolua_S,1,"cc.UpdateMgr",0,&tolua_err)) goto tolua_lerror;
#endif
    cobj = (UpdateMgr*)tolua_tousertype(tolua_S,1,0);
#if COCOS2D_DEBUG >= 1
    if (!cobj)
    {
        tolua_error(tolua_S,"invalid 'cobj' in function 'tolua_firecore_UpdateMgr_start'", nullptr);
        return 0;
    }
#endif
    argc = lua_gettop(tolua_S)-1;
    if (argc == 2) 
	{
		std::string arg0;
		ok &= luaval_to_std_string(tolua_S, 2, &arg0, "cc.UpdateMgr:start");
		if (!ok) return 0;
        std::string arg1;
		ok &= luaval_to_std_string(tolua_S, 3, &arg1, "cc.UpdateMgr:start");
		if (!ok) return 0;

		cobj->StartWithTask(arg0, arg1);
		lua_settop(tolua_S, 1);
		return 1;
	}
	else
		luaL_error(tolua_S, "%s has wrong number of arguments: %d, was expecting %d \n",  "cc.UpdateMgr:start",argc, 1);
    return 0;

#if COCOS2D_DEBUG >= 1
    tolua_lerror:
    tolua_error(tolua_S,"#ferror in function 'tolua_firecore_UpdateMgr_start'.",&tolua_err);
#endif
    return 0;
}

int tolua_firecore_UpdateMgr_isStopped(lua_State* tolua_S)
{
    int argc = 0;
	UpdateMgr* cobj = nullptr;
    bool ok  = true;

#if COCOS2D_DEBUG >= 1
    tolua_Error tolua_err;
#endif


#if COCOS2D_DEBUG >= 1
    if (!tolua_isusertype(tolua_S,1,"cc.UpdateMgr",0,&tolua_err)) goto tolua_lerror;
#endif

    cobj = (UpdateMgr*)tolua_tousertype(tolua_S,1,0);

#if COCOS2D_DEBUG >= 1
    if (!cobj) 
    {
        tolua_error(tolua_S,"invalid 'cobj' in function 'tolua_firecore_UpdateMgr_isStopped'", nullptr);
        return 0;
    }
#endif
    argc = lua_gettop(tolua_S)-1;
    if (argc == 0) 
    {
        if(!ok)
        {
            tolua_error(tolua_S,"invalid arguments in function 'tolua_firecore_UpdateMgr_isStopped'", nullptr);
            return 0;
        }
		lua_pushboolean(tolua_S, cobj->IsStopped());
        return 1;
    }
    luaL_error(tolua_S, "%s has wrong number of arguments: %d, was expecting %d \n", "cc.UpdateMgr:isStopped",argc, 0);
    return 0;

#if COCOS2D_DEBUG >= 1
    tolua_lerror:
    tolua_error(tolua_S,"#ferror in function 'tolua_firecore_UpdateMgr_isStopped'.",&tolua_err);
#endif
    return 0;
}

int tolua_firecore_UpdateMgr_getDownloadedSize(lua_State* tolua_S)
{
    int argc = 0;
	UpdateMgr* cobj = nullptr;
    bool ok  = true;

#if COCOS2D_DEBUG >= 1
    tolua_Error tolua_err;
#endif


#if COCOS2D_DEBUG >= 1
    if (!tolua_isusertype(tolua_S,1,"cc.UpdateMgr",0,&tolua_err)) goto tolua_lerror;
#endif

    cobj = (UpdateMgr*)tolua_tousertype(tolua_S,1,0);

#if COCOS2D_DEBUG >= 1
    if (!cobj) 
    {
        tolua_error(tolua_S,"invalid 'cobj' in function 'tolua_firecore_UpdateMgr_getDownloadedSize'", nullptr);
        return 0;
    }
#endif
    argc = lua_gettop(tolua_S)-1;
    if (argc == 0) 
    {
        if(!ok)
        {
            tolua_error(tolua_S,"invalid arguments in function 'tolua_firecore_UpdateMgr_getDownloadedSize'", nullptr);
            return 0;
        }
		lua_pushinteger(tolua_S, cobj->GetDownloadedSizeDisplay());
        return 1;
    }
    luaL_error(tolua_S, "%s has wrong number of arguments: %d, was expecting %d \n", "cc.UpdateMgr:getDownloadedSize",argc, 0);
    return 0;

#if COCOS2D_DEBUG >= 1
    tolua_lerror:
    tolua_error(tolua_S,"#ferror in function 'tolua_firecore_UpdateMgr_getDownloadedSize'.",&tolua_err);
#endif
    return 0;
}

int tolua_firecore_UpdateMgr_terminate(lua_State* tolua_S)
{
    
    int argc = 0;
    UpdateMgr* cobj = nullptr;
    bool ok  = true;

#if COCOS2D_DEBUG >= 1
    tolua_Error tolua_err;
#endif


#if COCOS2D_DEBUG >= 1
    if (!tolua_isusertype(tolua_S,1,"cc.UpdateMgr",0,&tolua_err)) goto tolua_lerror;
#endif

    cobj = (UpdateMgr*)tolua_tousertype(tolua_S,1,0);

#if COCOS2D_DEBUG >= 1
    if (!cobj)
    {
        tolua_error(tolua_S,"invalid 'cobj' in function 'tolua_firecore_UpdateMgr_terminate'", nullptr);
        return 0;
    }
#endif
    argc = lua_gettop(tolua_S)-1;
    if (argc == 0)
    {
        cobj->TerminateAllTasks();
        lua_settop(tolua_S, 1);
        return 1;
    }
    luaL_error(tolua_S, "%s has wrong number of arguments: %d, was expecting %d \n", "cc.UpdateMgr:tolua_firecore_UpdateMgr_terminate",argc, 0);
    return 0;

#if COCOS2D_DEBUG >= 1
    tolua_lerror:
    tolua_error(tolua_S,"#ferror in function 'tolua_firecore_UpdateMgr_terminate'.",&tolua_err);
#endif
    
    
    return 0;
}

int tolua_firecore_UpdateMgr_getTotalSize(lua_State* tolua_S)
{
    int argc = 0;
	UpdateMgr* cobj = nullptr;
    bool ok  = true;

#if COCOS2D_DEBUG >= 1
    tolua_Error tolua_err;
#endif


#if COCOS2D_DEBUG >= 1
    if (!tolua_isusertype(tolua_S,1,"cc.UpdateMgr",0,&tolua_err)) goto tolua_lerror;
#endif

    cobj = (UpdateMgr*)tolua_tousertype(tolua_S,1,0);

#if COCOS2D_DEBUG >= 1
    if (!cobj) 
    {
        tolua_error(tolua_S,"invalid 'cobj' in function 'tolua_firecore_UpdateMgr_getTotalSize'", nullptr);
        return 0;
    }
#endif
    argc = lua_gettop(tolua_S)-1;
    if (argc == 0) 
    {
        if(!ok)
        {
            tolua_error(tolua_S,"invalid arguments in function 'tolua_firecore_UpdateMgr_getTotalSize'", nullptr);
            return 0;
        }
		lua_pushinteger(tolua_S, cobj->GetTotalSizeDisplay());
        return 1;
    }
    luaL_error(tolua_S, "%s has wrong number of arguments: %d, was expecting %d \n", "cc.UpdateMgr:getTotalSize",argc, 0);
    return 0;

#if COCOS2D_DEBUG >= 1
    tolua_lerror:
    tolua_error(tolua_S,"#ferror in function 'tolua_firecore_UpdateMgr_getTotalSize'.",&tolua_err);
#endif
    return 0;
}

int register_fire_core_assets_manager_module(lua_State* L)
{
	tolua_usertype(L, "cc.UpdateMgr");
	tolua_cclass(L, "UpdateMgr", "cc.UpdateMgr", "", nullptr);

	tolua_beginmodule(L, "UpdateMgr");
		tolua_function(L, "getInstance",		tolua_firecore_UpdateMgr_getInstance);
		tolua_function(L, "startWithTask",		tolua_firecore_UpdateMgr_start);
		tolua_function(L, "isStopped",			tolua_firecore_UpdateMgr_isStopped);
		tolua_function(L, "getDownloadedSize",	tolua_firecore_UpdateMgr_getDownloadedSize);
		tolua_function(L, "getTotalSize",		tolua_firecore_UpdateMgr_getTotalSize);
        tolua_function(L, "terminate",          tolua_firecore_UpdateMgr_terminate);
        tolua_function(L, "stop",          tolua_firecore_UpdateMgr_stop);
        tolua_function(L, "pause",          tolua_firecore_UpdateMgr_pause);
        tolua_function(L, "resume",          tolua_firecore_UpdateMgr_resume);
        

	tolua_endmodule(L);
	std::string typeName	= typeid(UpdateMgr).name();
	g_luaType[typeName]		= "cc.UpdateMgr";
	g_typeCast["UpdateMgr"] = "cc.UpdateMgr";
	return 1;
}

int tolua_firecore_MD5_create(lua_State* L)
{
	int argc = 0;
	bool ok = true;

#if COCOS2D_DEBUG >= 1
	tolua_Error tolua_err;
#endif

#if COCOS2D_DEBUG >= 1
	if (!tolua_isusertable(L, 1, "cc.MD5", 0, &tolua_err)) goto tolua_lerror;
#endif

	argc = lua_gettop(L) - 1;

	if (argc == 0)
	{
		if (!ok)
		{
			tolua_error(L, "invalid arguments in function 'tolua_firecore_MD5_create'", nullptr);
			return 0;
		}
		MD5* ret = new (std::nothrow)MD5();
		if (ret)
			object_to_luaval<MD5>(L, "cc.MD5", (MD5*)ret);
		return 1;
	}
	luaL_error(L, "%s has wrong number of arguments: %d, was expecting %d\n ", "cc.MD5:create", argc, 0);
	return 0;
#if COCOS2D_DEBUG >= 1
	tolua_lerror:
		tolua_error(L, "#ferror in function 'tolua_firecore_MD5_create'.", &tolua_err);
#endif
	return 0;
}

int tolua_firecore_MD5_update(lua_State* tolua_S)
{
    int argc = 0;
    MD5* cobj = nullptr;
    bool ok  = true;

#if COCOS2D_DEBUG >= 1
    tolua_Error tolua_err;
#endif


#if COCOS2D_DEBUG >= 1
    if (!tolua_isusertype(tolua_S,1,"cc.MD5",0,&tolua_err)) goto tolua_lerror;
#endif

    cobj = (MD5*)tolua_tousertype(tolua_S,1,0);

#if COCOS2D_DEBUG >= 1
    if (!cobj) 
    {
        tolua_error(tolua_S,"invalid 'cobj' in function 'tolua_firecore_MD5_update'", nullptr);
        return 0;
    }
#endif

    argc = lua_gettop(tolua_S)-1;
    if (argc == 1)
    {
		std::string arg1 = "";
		ok &= luaval_to_std_string(tolua_S, 2, &arg1, "cc.MD5:update");
		if(!ok)
        {
			tolua_error(tolua_S,"invalid arguments in function 'tolua_firecore_MD5_update'", nullptr);
            return 0;
        }
		cobj->reset();
        cobj->update(arg1);
        lua_settop(tolua_S, 1);
        return 1;
    }
    luaL_error(tolua_S, "%s has wrong number of arguments: %d, was expecting %d \n", "cc.MD5:update",argc, 0);
    return 0;

#if COCOS2D_DEBUG >= 1
    tolua_lerror:
    tolua_error(tolua_S,"#ferror in function 'tolua_firecore_MD5_update'.",&tolua_err);
#endif
    return 0;
}

int tolua_firecore_MD5_updateFromFile(lua_State* tolua_S)
{
    int argc = 0;
    MD5* cobj = nullptr;
    bool ok  = true;

#if COCOS2D_DEBUG >= 1
    tolua_Error tolua_err;
#endif


#if COCOS2D_DEBUG >= 1
    if (!tolua_isusertype(tolua_S,1,"cc.MD5",0,&tolua_err)) goto tolua_lerror;
#endif

    cobj = (MD5*)tolua_tousertype(tolua_S,1,0);

#if COCOS2D_DEBUG >= 1
    if (!cobj) 
    {
        tolua_error(tolua_S,"invalid 'cobj' in function 'tolua_firecore_MD5_updateFromFile'", nullptr);
        return 0;
    }
#endif

    argc = lua_gettop(tolua_S)-1;
    if (argc == 1)
    {
		std::string arg1 = "";
		ok &= luaval_to_std_string(tolua_S, 2, &arg1, "cc.MD5:updateFromFile");
		if(!ok)
        {
			tolua_error(tolua_S,"invalid arguments in function 'tolua_firecore_MD5_updateFromFile'", nullptr);
            return 0;
        }
		cobj->reset();
		std::ifstream ifs(arg1.c_str());
		cobj->update(ifs);
        lua_settop(tolua_S, 1);
        return 1;
    }
    luaL_error(tolua_S, "%s has wrong number of arguments: %d, was expecting %d \n", "cc.MD5:updateFromFile",argc, 0);
    return 0;

#if COCOS2D_DEBUG >= 1
    tolua_lerror:
    tolua_error(tolua_S,"#ferror in function 'tolua_firecore_MD5_update'.",&tolua_err);
#endif
    return 0;
}

int tolua_firecore_MD5_getString(lua_State* tolua_S)
{
    int argc = 0;
	MD5* cobj = nullptr;
    bool ok  = true;

#if COCOS2D_DEBUG >= 1
    tolua_Error tolua_err;
#endif


#if COCOS2D_DEBUG >= 1
    if (!tolua_isusertype(tolua_S,1,"cc.MD5",0,&tolua_err)) goto tolua_lerror;
#endif

    cobj = (MD5*)tolua_tousertype(tolua_S,1,0);

#if COCOS2D_DEBUG >= 1
    if (!cobj) 
    {
        tolua_error(tolua_S,"invalid 'cobj' in function 'tolua_firecore_MD5_getString'", nullptr);
        return 0;
    }
#endif

    argc = lua_gettop(tolua_S)-1;
    if (argc == 0) 
    {
        if(!ok)
        {
            tolua_error(tolua_S,"invalid arguments in function 'tolua_firecore_MD5_getString'", nullptr);
            return 0;
        }
		lua_pushstring(tolua_S, cobj->toString().c_str());
        return 1;
    }
    luaL_error(tolua_S, "%s has wrong number of arguments: %d, was expecting %d \n", "cc.MD5:getString",argc, 0);
    return 0;

#if COCOS2D_DEBUG >= 1
    tolua_lerror:
    tolua_error(tolua_S,"#ferror in function 'tolua_firecore_MD5_getString'.",&tolua_err);
#endif

    return 0;
}

int tolua_firecore_MD5_destory(lua_State* tolua_S)
{
    int argc = 0;
	MD5* cobj = nullptr;
    bool ok  = true;

#if COCOS2D_DEBUG >= 1
    tolua_Error tolua_err;
#endif


#if COCOS2D_DEBUG >= 1
    if (!tolua_isusertype(tolua_S,1,"cc.MD5",0,&tolua_err)) 
		goto tolua_lerror;
#endif

    cobj = (MD5*)tolua_tousertype(tolua_S,1,0);
	delete cobj;
	cobj = nullptr;
	return 1;

#if COCOS2D_DEBUG >= 1
    tolua_lerror:
    tolua_error(tolua_S,"#ferror in function 'tolua_firecore_MD5_destory'.",&tolua_err);
#endif

    return 0;
}

int register_fire_core_md5_module(lua_State* L)
{
	tolua_usertype(L, "cc.MD5");
	tolua_cclass(L, "MD5", "cc.MD5", "", nullptr);

	tolua_beginmodule(L, "MD5");
		tolua_function(L, "create", tolua_firecore_MD5_create);
		tolua_function(L, "update", tolua_firecore_MD5_update);
		tolua_function(L, "updateFromFile", tolua_firecore_MD5_updateFromFile);
		tolua_function(L, "getString", tolua_firecore_MD5_getString);
		tolua_function(L, "desotry", tolua_firecore_MD5_destory);

	tolua_endmodule(L);
	std::string typeName = typeid(MD5).name();
	g_luaType[typeName] = "cc.MD5";
	g_typeCast["MD5"] = "cc.MD5";
	return 1;
}


int tolua_firecore_ZipReader_uncompress(lua_State* tolua_S)
{
	bool ok = true;
    int argc = lua_gettop(tolua_S);
    if (argc == 2) 
	{
		std::string arg0;
		ok &= luaval_to_std_string(tolua_S, 1, &arg0, "cc.ZipReader:uncompress");
		if (!ok) return 0;
        std::string arg1;
		ok &= luaval_to_std_string(tolua_S, 2, &arg1, "cc.ZipReader:uncompress");
		if (!ok) return 0;
		ZipReader reader(arg0);
		reader.ExecuteAll(arg1);
		lua_settop(tolua_S, 1);
		return 1;
	}
	else
		luaL_error(tolua_S, "%s has wrong number of arguments: %d, was expecting %d \n",  "cc.ZipReader:uncompress",argc, 2);
    return 0;
}

int register_fire_Zipper_module(lua_State* L)
{
	tolua_usertype(L, "cc.ZipReader");
	tolua_cclass(L, "ZipReader", "cc.ZipReader", "", nullptr);

	tolua_beginmodule(L, "ZipReader");
		tolua_function(L, "uncompress", tolua_firecore_ZipReader_uncompress);

	tolua_endmodule(L);
	std::string typeName = typeid(ZipReader).name();
	g_luaType[typeName] = "cc.ZipReader";
	g_typeCast["ZipReader"] = "cc.ZipReader";
	return 1;
}


int lua_cocos2dx_GausBlurSprite_createWithImage(lua_State* tolua_S)
{
    int argc = 0;
    bool ok  = true;


    tolua_Error tolua_err;

#if COCOS2D_DEBUG >= 1
    if (!tolua_isusertable(tolua_S,1,"cc.GausBlurSprite",0,&tolua_err)) goto tolua_lerror;
#endif

    argc = lua_gettop(tolua_S) - 1;

    if (argc == 1)
    {
        std::string arg0;
        CCImage* iamge = nullptr;
        ok = tolua_isusertype(tolua_S,2,"cc.Image",0, &tolua_err);
        if(ok)
        {
            iamge = (CCImage*)tolua_tousertype(tolua_S,2,0);
            GausBlurSprite* ret = GausBlurSprite::createWithImage(iamge);
            object_to_luaval<GausBlurSprite>(tolua_S, "cc.GausBlurSprite",(GausBlurSprite*)ret);
            return 1;
        }
        
        ok = luaval_to_std_string(tolua_S, 2, &arg0, "cc.GausBlurSprite:createWithImage");
        if(ok)
        {
            GausBlurSprite* ret = GausBlurSprite::createWithImage(arg0.c_str());
            object_to_luaval<GausBlurSprite>(tolua_S, "cc.GausBlurSprite",(GausBlurSprite*)ret);
            return 1;
        }
        
        tolua_error(tolua_S,"invalid arguments in function 'lua_cocos2dx_GausBlurSprite_createWithImage'", nullptr);
        return 0;
    }
    luaL_error(tolua_S, "%s has wrong number of arguments: %d, was expecting %d\n ", "cc.GausBlurSprite:createWithImage",argc, 1);
    return 0;

    tolua_lerror:
    tolua_error(tolua_S,"#ferror in function 'lua_cocos2dx_GausBlurSprite_createWithImage'.",&tolua_err);

    return 0;
}


int lua_cocos2dx_GausBlurSprite_override(lua_State* tolua_S)
{
    int argc = 0;
    GausBlurSprite* cobj = nullptr;

#if COCOS2D_DEBUG >= 1
    tolua_Error tolua_err;
#endif


#if COCOS2D_DEBUG >= 1
    if (!tolua_isusertype(tolua_S,1,"cc.GausBlurSprite",0,&tolua_err)) goto tolua_lerror;
#endif

    cobj = (GausBlurSprite*)tolua_tousertype(tolua_S,1,0);

#if COCOS2D_DEBUG >= 1
    if (!cobj)
    {
        tolua_error(tolua_S,"invalid 'cobj' in function 'lua_cocos2dx_GausBlurSprite_override'", nullptr);
        return 0;
    }
#endif

    argc = lua_gettop(tolua_S)-1;
    if (argc == 0)
    {
        auto beg_t = std::chrono::system_clock::now();
        cobj->override();
        auto end_t = std::chrono::system_clock::now();
        auto t = std::chrono::duration_cast<std::chrono::milliseconds>(end_t - beg_t).count();
        log("%d ms(s)", (int)t);
        lua_settop(tolua_S, 1);
        return 1;
    }
    luaL_error(tolua_S, "%s has wrong number of arguments: %d, was expecting %d \n", "cc.GausBlurSprite:override",argc, 0);
    return 0;

#if COCOS2D_DEBUG >= 1
    tolua_lerror:
    tolua_error(tolua_S,"#ferror in function 'lua_cocos2dx_GausBlurSprite_override'.",&tolua_err);
#endif

    return 0;
}


int regiest_fire_core_gausblur_sprite(lua_State* tolua_S)
{
    tolua_usertype(tolua_S,        "cc.GausBlurSprite");
    tolua_cclass(tolua_S,        "GausBlurSprite", "cc.GausBlurSprite", "cc.Sprite", nullptr);
    tolua_beginmodule(tolua_S,    "GausBlurSprite");
        tolua_function(tolua_S, "createWithImage",    lua_cocos2dx_GausBlurSprite_createWithImage);
        tolua_function(tolua_S, "override",            lua_cocos2dx_GausBlurSprite_override);
    tolua_endmodule(tolua_S);
    std::string typeName = typeid(GausBlurSprite).name();
    g_luaType[typeName] = "cc.GausBlurSprite";
    g_typeCast["GausBlurSprite"] = "cc.GausBlurSprite";
    return 1;
}

int register_fire_core_modules(lua_State* L)
{
	register_fire_Zipper_module(L);
	register_fire_PixalCollisionMgr_module(L);
	register_fire_timmer_module(L);
	register_fire_core_assets_manager_module(L);
	register_fire_core_md5_module(L);
    regiest_fire_core_gausblur_sprite(L);
	return 1;
}

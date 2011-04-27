local ffi = require( "ffi" )

local libs = ffi_luajit_libs or {
   OSX     = { x86 = "bin/luajit.dylib", x64 = "bin/luajit.dylib" },
   Windows = { x86 = "bin/luajit32.dll", x64 = "bin/luajit64.dll" },
   Linux   = { x86 = "bin/luajit32.so",  x64 = "bin/luajit64.so" },
   BSD     = { x86 = "bin/luajit32.so",  x64 = "bin/luajit64.so" },
   POSIX   = { x86 = "bin/luajit32.so",  x64 = "bin/luajit64.so" },
   Other   = { x86 = "bin/luajit32.so",  x64 = "bin/luajit64.so" },
}

local lib  = ffi_luajit_lib or libs[ ffi.os ][ ffi.arch ]

local lj   = ffi.load( lib )

ffi.cdef[[
      enum {
	 LUAJIT_MODE_ENGINE,		
	 LUAJIT_MODE_DEBUG,		
	 LUAJIT_MODE_FUNC,		
	 LUAJIT_MODE_ALLFUNC,		
	 LUAJIT_MODE_ALLSUBFUNC,	
	 LUAJIT_MODE_TRACE,		
	 LUAJIT_MODE_WRAPCFUNC = 0x10,	
	 LUAJIT_MODE_MAX
      };
      
      typedef struct lua_State lua_State;
      typedef double           lua_Number;
      typedef ptrdiff_t        lua_Integer;
      
      typedef int         (* lua_CFunction)( lua_State *L );
      typedef const char* (* lua_Reader)(    lua_State *L, void *ud, size_t *sz );
      typedef int         (* lua_Writer)(    lua_State *L, const void* p, size_t sz, void* ud );
      typedef void*       (* lua_Alloc)(     void *ud, void *ptr, size_t osize, size_t nsize );

      lua_State*    lua_newstate(     lua_Alloc  f, void *ud );
      void          lua_close(        lua_State* L );
      lua_State*    lua_newthread(    lua_State* L );
      lua_CFunction lua_atpanic(      lua_State* L, lua_CFunction panicf );
      int           lua_gettop(       lua_State *L );
      void          lua_settop(       lua_State *L, int idx );
      void          lua_pushvalue(    lua_State *L, int idx );
      void          lua_remove(       lua_State *L, int idx );
      void          lua_insert(       lua_State *L, int idx );
      void          lua_replace(      lua_State *L, int idx );
      int           lua_checkstack(   lua_State *L, int sz  );
      void          lua_xmove(        lua_State *from, lua_State *to, int n );
      int           lua_isnumber(     lua_State *L, int idx );
      int           lua_isstring(     lua_State *L, int idx );
      int           lua_iscfunction(  lua_State *L, int idx );
      int           lua_isuserdata(   lua_State *L, int idx );
      int           lua_type(         lua_State *L, int idx );
      const char*   lua_typename(     lua_State *L, int tp );
      int           lua_equal(        lua_State *L, int idx1, int idx2 );
      int           lua_rawequal(     lua_State *L, int idx1, int idx2 );
      int           lua_lessthan(     lua_State *L, int idx1, int idx2 );
      lua_Number    lua_tonumber(     lua_State *L, int idx );
      lua_Integer   lua_tointeger(    lua_State *L, int idx );
      int           lua_toboolean(    lua_State *L, int idx );
      const char*   lua_tolstring(    lua_State *L, int idx, size_t *len );
      size_t        lua_objlen(       lua_State *L, int idx );
      lua_CFunction lua_tocfunction(       lua_State *L, int idx );
      void*         lua_touserdata(        lua_State *L, int idx );
      lua_State*    lua_tothread(          lua_State *L, int idx );
      const void*   lua_topointer(         lua_State *L, int idx );
      void          lua_pushnil(           lua_State *L  );
      void          lua_pushnumber(        lua_State *L, lua_Number n );
      void          lua_pushinteger(       lua_State *L, lua_Integer n );
      void          lua_pushlstring(       lua_State *L, const char *s, size_t l );
      void          lua_pushstring(        lua_State *L, const char *s );
      const char*   lua_pushvfstring(      lua_State *L, const char *fmt, va_list argp );
      const char*   lua_pushfstring(       lua_State *L, const char *fmt, ...);
      void          lua_pushcclosure(      lua_State *L, lua_CFunction fn, int n);
      void          lua_pushboolean(       lua_State *L, int b);
      void          lua_pushlightuserdata( lua_State *L, void *p);
      int           lua_pushthread(        lua_State *L);
      void          lua_gettable(          lua_State *L, int idx);
      void          lua_getfield(          lua_State *L, int idx, const char *k);
      void          lua_rawget(            lua_State *L, int idx);
      void          lua_rawgeti(           lua_State *L, int idx, int n);
      void          lua_createtable(       lua_State *L, int narr, int nrec);
      void*         lua_newuserdata(       lua_State *L, size_t sz);
      int           lua_getmetatable(      lua_State *L, int objindex);
      void          lua_getfenv(           lua_State *L, int idx);
      void          lua_settable(          lua_State *L, int idx);
      void          lua_setfield(          lua_State *L, int idx, const char *k);
      void          lua_rawset(            lua_State *L, int idx);
      void          lua_rawseti(           lua_State *L, int idx, int n);
      int           lua_setmetatable(      lua_State *L, int objindex);
      int           lua_setfenv(           lua_State *L, int idx);
      void          lua_call(              lua_State *L, int nargs, int nresults);
      int           lua_pcall(             lua_State *L, int nargs, int nresults, int errfunc);
      int           lua_cpcall(            lua_State *L, lua_CFunction func, void *ud);
      int           lua_load(              lua_State *L, lua_Reader r, void *dt, const char* chunkname);
      int           lua_dump(              lua_State *L, lua_Writer w, void *data );
      int           lua_yield(             lua_State *L, int nresults );
      int           lua_resume(            lua_State *L, int narg );
      int           lua_status(            lua_State *L );
      int           lua_gc(                lua_State *L, int what, int data );
      int           lua_error(             lua_State *L );
      int           lua_next(              lua_State *L, int idx );
      void          lua_concat(            lua_State *L, int n );
      lua_Alloc     lua_getallocf(         lua_State *L, void **ud );
      void          lua_setallocf(         lua_State *L, lua_Alloc f, void *ud );
      void          lua_setlevel(          lua_State *from, lua_State *to );
     
      typedef struct lua_Debug lua_Debug;  
      typedef void (*lua_Hook) (lua_State *L, lua_Debug *ar);

      int lua_getstack (lua_State *L, int level, lua_Debug *ar);
      int lua_getinfo (lua_State *L, const char *what, lua_Debug *ar);
      const char *lua_getlocal (lua_State *L, const lua_Debug *ar, int n);
      const char *lua_setlocal (lua_State *L, const lua_Debug *ar, int n);
      const char *lua_getupvalue (lua_State *L, int funcindex, int n);
      const char *lua_setupvalue (lua_State *L, int funcindex, int n);
      
      int lua_sethook (lua_State *L, lua_Hook func, int mask, int count);
      lua_Hook lua_gethook (lua_State *L);
      int lua_gethookmask (lua_State *L);
      int lua_gethookcount (lua_State *L);
      
typedef struct _lua_Debug {
  int event;
  const char *name;	
  const char *namewhat;	
  const char *what;	
  const char *source;	
  int currentline;	
  int nups;		
  int linedefined;	
  int lastlinedefined;	
  char short_src[60]; 
  int i_ci;  
} lua_Debug;

//int luaJIT_setmode(lua_State *L, int idx, int mode);

//void luaJIT_version_2_0_0_beta6(void);
]]

--[[
      lua_atpanic
      lua_call
      lua_checkstack
      lua_close
      lua_concat
      lua_cpcall
      lua_createtable
      lua_dump
      lua_equal
      lua_error
      lua_gc
      lua_getallocf
      lua_getfenv
      lua_getfield
      lua_gethook
      lua_gethookcount
      lua_gethookmask
      lua_getinfo
      lua_getlocal
      lua_getmetatable
      lua_getstack
      lua_gettable
      lua_gettop
      lua_getupvalue
      lua_insert
      lua_iscfunction
      lua_isnumber
      lua_isstring
      lua_isuserdata
      lua_lessthan
      lua_load
      lua_newstate
      lua_newthread
      lua_newuserdata
      lua_next
      lua_objlen
      lua_pcall
      lua_pushboolean
      lua_pushcclosure
      lua_pushfstring
      lua_pushinteger
      lua_pushlightuserdata
      lua_pushlstring
      lua_pushnil
      lua_pushnumber
      lua_pushstring
      lua_pushthread
      lua_pushvalue
      lua_pushvfstring
      lua_rawequal
      lua_rawget
      lua_rawgeti
      lua_rawset
      lua_rawseti
      lua_remove
      lua_replace
      lua_resume
      lua_setallocf
      lua_setfenv
      lua_setfield
      lua_sethook
      lua_setlocal
      lua_setmetatable
      lua_settable
      lua_settop
      lua_setupvalue
      lua_status
      lua_toboolean
      lua_tocfunction
      lua_tointeger
      lua_tolstring
      lua_tonumber
      lua_topointer
      lua_tothread
      lua_touserdata
      lua_type
      lua_typename
      lua_xmove
      lua_yield
      luajit_main
      luaJIT_setmode
      luaJIT_version_2_0_0_beta6
      luaL_addlstring
      luaL_addstring
      luaL_addvalue
      luaL_argerror
      luaL_buffinit
      luaL_callmeta
      luaL_checkany
      luaL_checkinteger
      luaL_checklstring
      luaL_checknumber
      luaL_checkoption
      luaL_checkstack
      luaL_checktype
      luaL_checkudata
      luaL_error
      luaL_findtable
      luaL_getmetafield
      luaL_gsub
      luaL_loadbuffer
      luaL_loadfile
      luaL_loadstring
      luaL_newmetatable
      luaL_newstate
      luaL_openlib
      luaL_openlibs
      luaL_optinteger
      luaL_optlstring
      luaL_optnumber
      luaL_prepbuffer
      luaL_pushresult
      luaL_ref
      luaL_register
      luaL_typerror
      luaL_unref
      luaL_where
      luaopen_base
      luaopen_bit
      luaopen_debug
      luaopen_ffi
      luaopen_io
      luaopen_jit
      luaopen_math
      luaopen_os
      luaopen_package
      luaopen_string
      luaopen_table
--]]

return lj

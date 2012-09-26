--jit.off()

local ffi = require( "ffi" )
--local uv = require( "ffi/uv" )

local libs = ffi_uv_libs or {
   OSX     = { x86 = "bin/OSX/uv.dylib",       x64 = "bin/OSX/uv.dylib" },
   Windows = { x86 = "bin/Windows/x86/uv.dll", x64 = "bin/Windows/x64/uv.dll" }}

local lib = ffi_uv_lib or libs[ ffi.os ][ ffi.arch ] or "uv"
local uv = ffi.load( lib )

ffi.cdef [[
   typedef struct uv_req  uv_req;
   typedef struct uv_loop uv_loop;
   typedef struct uv_fs   uv_fs;

   typedef enum uv_req_type {
     UV_UNKNOWN_REQ = 0,
     UV_REQ_TYPE_PRIVATE,
     UV_REQ_TYPE_MAX
   } uv_req_type;
   
   typedef enum uv_err_code {
     UV_ERR_DUMMY,
   } uv_err_code;

   typedef enum uv_fs_type {
     UV_FS_DUMMY,
   } uv_fs_type;
]]

if ffi.os == "Windows" then	
   ffi.cdef [[
      typedef struct uv_win32_overlapped {
        uint32_t Internal;
        uint32_t InternalHigh;
        union {
          struct {
            uint32_t Offset;
            uint32_t OffsetHigh;
          };
          void* Pointer;
        };
        void* hEvent;
      } uv_win32_overlapped;
      
      typedef struct uv_req_private_fields_s {
        union {
          struct {
            uv_win32_overlapped overlapped;
            size_t              queued_bytes;
          };
        };
        struct uv_req* next;
      } uv_req_private_fields;
   ]] 
else
   ffi.cdef [[
      
   ]]
end


ffi.cdef [[
   typedef struct uv_queue {
     struct uv_queue* prev;
     struct uv_queue* next;
   } uv_queue;

   typedef struct uv_req {
     void*                 data;
     uv_queue              active_queue;
     uv_req_private_fields private_fields; 
     uv_req_type           type;
   } uv_req;
]]

ffi.cdef [[

   typedef void (*uv_fs_cb)( uv_fs* req );

   typedef struct uv_fs {
   uv_req         fields;
   uv_fs_type     fs_type;
   uv_loop*       loop;
   uv_fs_cb       cb;
   size_t         result;
   void*          ptr;
   const char*    path;
   uv_err_code    errorno;
   char           private[10240];
//   UV_FS_PRIVATE_FIELDS
   } uv_fs;
   
   uv_loop* uv_default_loop();
   int      uv_fs_readdir(uv_loop*, uv_fs* req, const char* flags, int flags, uv_fs_cb cb);
   int      uv_run(uv_loop*);
   int      uv_run_once(uv_loop*);
   void uv_fs_req_cleanup(uv_fs* req);
]]

local function cstrings( cstrings, count )
   cstrings = ffi.cast("char*", cstrings)
   local t = {}
   for i = 1, count do
      local s = ffi.string(cstrings)
      cstrings = cstrings + #s + 1
      t[i] = s
   end
   return t;
end

local function uv_fs_readdir( uv, loop, path, flags, callback )
   local ad = {}
   ad.uv = uv
   ad.fs = ffi.new( "uv_fs" )
   ad.cb = ffi.cast(
      "uv_fs_cb",
      function( req )
	 local t = cstrings(req.ptr, tonumber(req.result))
	 callback(t)
	 ad.uv.uv_fs_req_cleanup(req);
	 ad.cb:free()
      end)
   -- TODO - if this fails, the CB won't be freed
   -- also even if it succeeds, I have to check the UV semantics
   -- whether there is not a case the callback to be not called
   -- (I think it's called, as someone has to call uv_fs_req_cleanup())
   return uv.uv_fs_readdir( loop, ad.fs, path, flags, ad.cb )
end

local function main()
   local loop = uv.uv_default_loop()
   print(loop) 
   print(uv.uv_run_once(loop))
   local fs = ffi.new( "uv_fs" )
   local path = "/"
   local flags = 0
   local t = os.clock()
   print('begin')
   local times = 0
   for i=0,20000 do
      if true then
	 -- Wrap uv_fs_readdir to cleanup fs_req the
	 -- luajit ffi's callback itself and provide
	 -- table with names rather than concatenated c strings
	 uv_fs_readdir(
	    uv, loop, path, flags,
	    function( names )
	       if i == 0 then
		  print( #names )
		  print( table.concat(names, '\n'))
	       end
	    end)
      else
	 uv.uv_fs_readdir(
	    loop, fs, path, flags, 
	    ffi.cast(
	       "uv_fs_cb",
	       function( req )
		  print(i)
		  if false then
		     print(
			'PTR', table.concat(cstrings(req.ptr),'\n'), req, req.fields.data, '\n',
			'Q',req.fields.active_queue,req.fields.active_queue.prev,req.fields.active_queue.next,'\n',
			req.fields.type, req.loop, req.cb, req.result, req.ptr, req.errorno)
		     print(req.path,ffi.string(req.path))
		     --	    while true do
		     --	    end
		  end
	       end))
      end
      if false then
	 -- This would return once everything is empty
	 uv.uv_run(loop)
      else
	 -- This should allow for more interactivity
	 while uv.uv_run_once(loop) ~= 0 do
	    -- e.g. do something here, for example in GTK call gtk_main_iteration()
	    -- print(times, os.clock() - t)
	    times = times + 1
	 end
      end
   end
   print('end', os.clock() - t, times)
end

main()


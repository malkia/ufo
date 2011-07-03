local ffi = require( "ffi" )
local sys = {}

if ffi.os == "Windows" then
   ffi.cdef[[
	 typedef struct _FILETIME {
	    DWORD dwLowDateTime;
	    DWORD dwHighDateTime;
	 } FILETIME;
	 typedef struct _WIN32_FIND_DATA {
	    uint32_t dwFileAttributes;
	    FILETIME ftCreationTime;
	    FILETIME ftLastAccessTime;
	    FILETIME ftLastWriteTime;
	    uint32_t nFileSizeHigh;
	    uint32_t nFileSizeLow;
	    uint32_t dwReserved0;
	    uint32_t dwReserved1;
	    char     cFileName[260];
	    char     cAlternateFileName[14];
	 } WIN32_FIND_DATA;
	 uint32_t GetCurrentDirectoryA(uint32_t size, char* dir);
	 int      SetCurrentDirectoryA(const char* dir);
	 int      CreateDirectoryA(const char*, void*);
	 int      RemoveDirectoryA(const char*);
	 void*    FindFirstFileA(const char*, WIN32_FIND_DATA*);
	 int      FindNextFileA(void*, WIN32_FIND_DATA*);
	 int      FindClose(void*);
   ]]
   local K = ffi.load( "KERNEL32" )
   sys = {
      getdir = function() 
		 local buf = ffi.new("char[1024]")
		 if K.GetCurrentDirectoryA(ffi.sizeof(buf), buf) ~= 0 then
		    return ffi.string(buf)
		 end
		 error( "getdir()" )
	      end,
      chdir = function(name)
		 if K.SetCurrentDirectoryA(name) == 0 then
		    error( "chdir("..name..")" )
		 end
	      end,
      mkdir = function(name)
		 if K.CreateDirectoryA(name, nil) == 0 then
		    error( "mkdir("..name..")" )
		 end
	      end,
      rmdir = function(name)
		 if K.RemoveDirectoryA(name) == 0 then
		    error( "rmdir("..name..")" )
		 end
	      end,
      lsdir = function(dir)
		 local files = {}
		 local fd = ffi.new( "WIN32_FIND_DATA" )
		 local h = K.FindFirstFileA(dir, fd)
		 while h do 
		    local file = { 
		       name = ffi.string( fd.cFileName ),
		       size = bit.and( bit.rshift(ffi.nFileSizeHigh, 32), ffi.nFileSizeLow )
		    }
		    if file.name ~= "." and file.name ~= ".." then
		       files[#files + 1] = file
		    end
		    if K.FindNextFile(h, fd) == 0 then
		       K.FindClose(h)
		       h = nil
		    end
		 end
		 return files
	      end,
   }
else
   ffi.cdef[[
	 char* getcwd(char *, size_t size);
	 int chdir(const char*);
	 int mkdir(const char*, int);
	 int rmdir(const char*); 
   ]]
   local C = ffi.C
   sys = {
      getdir = function() 
		 local buf = ffi.new("char[1024]")
		 if C.getcwd(ffi.sizeof(buf), buf) then
		    return ffi.string(buf)
		 end
		 error( "getdir()" )
	      end,
      chdir = function(name)
		 if C.chdir(name) ~= 0 then
		    error( "chdir("..name..")" )
		 end
	      end,
      mkdir = function(name)
		 if C.mkdir(name, 0x1FF) ~= 0 then
		    error( "mkdir("..name..")" )
		 end
	      end,
      rmdir = function(name)
		 if C.rmdir(name) ~= 0 then
		    error( "rmdir("..name..")" )
		 end
	      end,
      lsdir = function(dir)
		 local files = {}
		 local h = C.opendir(dir)
		 while (dentry = C.readdir(h)) do 
		    local file = { 
		       name = ffi.string( fd.cFileName ),
		       size = bit.and( bit.rshift(ffi.nFileSizeHigh, 32), ffi.nFileSizeLow )
		    }
		    if file.name ~= "." and file.name ~= ".." then
		       files[#files + 1] = file
		    end
		    if K.FindNextFile(h, fd) == 0 then
		       C.closedir(h)
		       h = nil
		    end
		 end
		 return files
	      end,
   }
end

return sys

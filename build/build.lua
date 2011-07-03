#!/usr/bin/env luajit

local ffi = require( "ffi" )
local sys = {}

local sys = function()
	       if ffi.os == "Windows" then
		  ffi.cdef[[
			int      SetCurrentDirectoryA( const char* dir );
			uint32_t GetCurrentDirectoryA( uint32_t size, char* dir );
			int      CreateDirectoryA(     const char*, void* );
			int      RemoveDirectoryA(     const char* );
		  ]]
		  K = ffi.load( "KERNEL32" )
		  sys.chdir = function(name) assert( K.SetCurrentDirectory(name), "chdir("..name) end
		  sys.mkdir = function(name) assert( K.CreateDirectoryA(name, nil) != 0, "mkdir " .. name .. " failed" ) end
		  sys.rmdir = function(name) assert( K.RemoveDirectoryA(name, nil) != 0, "rmdir " .. name .. " failed" ) end
	       else
		  ffi.cdef[[
			int chdir(const char*);
			
			
		  ]]
	       end
	    end


local ffi     = require( "ffi" )
local sandbox = ffi.load( "/usr/lib/libsandbox.dylib" )

ffi.cdef[[
      enum {
	 SANDBOX_NAMED = 1
      };

      extern const char kSBXProfileNoInternet[];
      extern const char kSBXProfileNoNetwork[];
      extern const char kSBXProfileNoWrite[];
      extern const char kSBXProfileNoWriteExceptTemporary[];
      extern const char kSBXProfilePureComputation[];

      int  sandbox_init( const char* profile, uint64_t flags, char **errorbuf );
      void sandbox_free_error( char* errorbuf );
]]

local args = ...
--print( '...', type(args), ... )

if ... then print('lib') return sandbox end

print( "Testing" )
local errorbuf = ffi.gc( ffi.new( "char*[1]"), sandbox.sandbox_free_error )

local profiles = {
   "NoInternet",
   "NoNetwork",
   "NoWrite",
   "NoWriteExceptTemporary",
   "PureComputation"
}

if arg then
   for k,v in pairs( arg ) do
      print(k,v)
   end
end

print(ffi.string(sandbox.kSBXProfilePureComputation))

print( 'sandbox_init', 
       sandbox.sandbox_init( 
	  sandbox.kSBXProfileNoInternet,
	  sandbox.SANDBOX_NAMED,
	  errorbuf ) )


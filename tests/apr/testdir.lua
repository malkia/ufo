local ffi = require( "ffi" )

local apr = require( "ffi/apr" )
assert( apr.apr_initialize() == 0 )

local pool = ffi.new( "apr_pool_t*[1]" )
assert( apr.apr_pool_create_ex( pool, nil, nil, nil ) == 0 )

local dir = ffi.new( "apr_dir_t*[1]" )
assert( apr.apr_dir_open(dir, ".", pool[0]) == 0 )

local finfo = ffi.new( "apr_finfo_t[1]" )
while apr.apr_dir_read(finfo, 0, dir[0]) == 0 do
   local info = finfo[0]
   local name = ffi.string( info.name )
   print( name, info.size, info.csize )
   if false then
      local fields = { "pool", "valid", "protection", "filetype", "user", "group", "inode", "device",
		       "nlink", "size", "csize", "atime", "mtime", "ctime", "fname", "name", "filehand" }
      for _, field in ipairs(fields) do
	 local v = finfo[0][field]
	 local v2, v3
	 print( field, tostring(v) )
      end
      print()
   end
end

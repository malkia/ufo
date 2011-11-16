local ffi = require( "ffi" )
local apr = require( "ffi/apr" )

local pool = ffi.new( "apr_pool_t*[1]" )

print('initialize',apr.apr_initialize())
print('create pool',apr.apr_pool_create_ex( pool, nil, nil, nil ))

print(pool)
print(pool[0])

local dir = ffi.new( "apr_dir_t*[1]" )
print('open dir', apr.apr_dir_open(dir, "e:/", pool[0]))

print(dir[0])

local finfo = ffi.new( "apr_finfo_t[1]" )

local fields = { "pool", "valid", "protection", "filetype", "user", "group", "inode", "device",
		 "nlink", "size", "csize", "atime", "mtime", "ctime", "fname", "name", "filehand" }

while apr.apr_dir_read(finfo, 0, dir[0]) == 0 do
   for _, field in ipairs(fields) do
      local v = finfo[0][field]
      local v2, v3
      if type(v) == "cdata" then
	 v2 = tostring(ffi.typeof(v))
	 if v2 == "ctype<const char *>" or v2 == "ctype<char *>" then
	    if v ~= nil then
	       v3 = ffi.string(v)
	    end
	 end
      end
      if v3 then
	 print(field, v3)
      else
--	 print(field, v)
      end
   end
end

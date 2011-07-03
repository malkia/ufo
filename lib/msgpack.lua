local ffi = require( "ffi" )

ffi.cdef [[
      typedef union msgpack_lua_union_helper {
	 float    f[2];
	 double   d;
	 uint64_t u64;
	 int64_t  s64;
	 uint8_t  u8[8];
	 uint16_t u16[4];
	 uint32_t u132[4];
      } msgpack_lua_union_helper;
]]

-- The next variable, union, would serve as a "register" to a lot of functions below
local union = ffi.new( "msgpack_lua_union_helper[1]" )

-- Based on msgpack_pack_real_int64. Can write up to 9 bytes
local function pack_integer( buf, pos )
   local d = union.s64
   if d < -32 then
      if d < -32768 then
	 if d < -2147483648 then
	    buf[pos+0] = 0xD3
	    buf[pos+1] = union.u8[0]
	    buf[pos+2] = union.u8[1]
	    buf[pos+3] = union.u8[2]
	    buf[pos+4] = union.u8[3]
	    buf[pos+5] = union.u8[4]
	    buf[pos+6] = union.u8[5]
	    buf[pos+7] = union.u8[6]
	    buf[pos+8] = union.u8[7]
	    return 9
	 else
	    buf[pos+0] = 0xD2
	    buf[pos+1] = union.u8[0]
	    buf[pos+1] = union.u8[1]
	    buf[pos+2] = union.u8[2]
	    buf[pos+3] = union.u8[3]
	    return 5
	 end
      else
	 if d < -128 then
	    buf[pos+0] = 0xD1
	    buf[pos+1] = union.u8[0]
	    buf[pos+2] = union.u8[1]
	    return 3
	 else
	    buf[pos+0] = 0xD0
	    buf[pos+1] = union.u8[0]
	    return 2
	 end
      end
   elseif d < 128 then
      buf[pos] = union.u8[0]
      return 1
   else
      if d < 65536 then
	 if d < 256 then
	    buf[pos+0] = 0xCC
	    buf[pos+1] = union.u8[0]
	    return 2
	 else
	    buf[pos+0] = 0xCD
	    buf[pos+1] = union.u8[0]
	    buf[pos+2] = union.u8[1]
	    return 3
	 end
      else
	 if d < 4294967296 then
	    buf[pos+0] = 0xCE
	    buf[pos+1] = union.u8[0]
	    buf[pos+1] = union.u8[1]
	    buf[pos+2] = union.u8[2]
	    buf[pos+3] = union.u8[3]
	    return 5
	 else
	    buf[pos+0] = 0xCF
	    buf[pos+1] = union.u8[0]
	    buf[pos+2] = union.u8[1]
	    buf[pos+3] = union.u8[2]
	    buf[pos+4] = union.u8[3]
	    buf[pos+5] = union.u8[4]
	    buf[pos+6] = union.u8[5]
	    buf[pos+7] = union.u8[6]
	    buf[pos+8] = union.u8[7]
	    return 9
	 end
      end
   end
end

local function pack_nil( buf, pos )
   buf[pos] = 0xC0
   return 1
end

local function pack_false( buf, pos )
   buf[pos] = 0xC2
   return 1
end

local function pack_true( buf, pos )
   buf[pos] = 0xC3
   return 1
end

local function pack_float( buf, pos )
   buf[pos+0] = 0xCA
   buf[pos+1] = union.u8[0]
   buf[pos+2] = union.u8[1]
   buf[pos+3] = union.u8[2]
   buf[pos+4] = union.u8[3]
   return 5
end

local function pack_double( buf, pos )
   buf[pos+0] = 0xCB
   buf[pos+1] = union.u8[0]
   buf[pos+2] = union.u8[1]
   buf[pos+3] = union.u8[2]
   buf[pos+4] = union.u8[3]
   buf[pos+5] = union.u8[4]
   buf[pos+6] = union.u8[5]
   buf[pos+7] = union.u8[6]
   buf[pos+8] = union.u8[7]
   return 9
end

local function pack_array_length( buf, pos )
   if len < 16 then
      buf[pos] = 0x90 + len
      return 1
   elseif len < 65536 then
      buf[pos] = 0xDC
   else
      buf[pos] = 0xDD
   end
   return 1 + pack_integer( buf, pos + 1 )
end

local function pack_map_length( buf, pos )
   if len < 16 then
      buf[pos] = 0x80 + len
      return 1
   elseif len < 65536 then
      buf[pos] = 0xDE
   else
      buf[pos] = 0xDF
   end
   return 1 + pack_integer( buf, pos + 1, len )
end

local function pack_string( buf, pos, string, start, len )
   start = start or 1
   len = len or #string
   if len < 32 then
      buf[pos] = 0xA0 + len
   else 
      if len < 65536 then
	 buf[pos] = 0xDA
      else
	 buf[pos] = 0xDB
      end
      pos = pos + pack_integer( buf, pos, len )
   end
   for i=0, len-1 do
      buf[pos+i] = string:byte(i+start)
   end
   return len
end

local function pack_table( buf, pos, table )
   local len = #table
   for k,v in pairs( table ) do
      local t = type(k)
   end
end

local function iter_table( table )
   local inext, it, is = ipairs(table)
   local next, t, s = pairs(table)
   local max = 10
   print( "I", inext, it, is )
   print( ">", next, t, s )
   local ik, iv = 0, 0
   local k, v = 0, 0
   while true do
--      ik,kv = inext(table, ik)
      k,v = next(table, k)
      max = max - 1
      if max < 0 then break end
   end
end

local st = { 10, 20, 30, 40, fifty="Petdeset", sixty="Shestdest" }

iter_table(st)

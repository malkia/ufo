local ffi = require( "ffi" )
local expat = require( "ffi/expat" )
local apis = require( "samples/Windows/apis" )
local root = "e:/p/API Monitor (rohitab.com)/"

local apis = {
--   "API/MAPI/IABContainer.xml"
--   "API/Windows/msvcrxx.xml" 
   "API/Headers/bluetooth.h.xml"
}

local stack = {}
local found = {}

print()

local symbols = {
   typedefs = {},
   structs = {},
   functions = {},
}

local function begin_struct()
   return {}
end 

local function end_struct()
   
end

local function collect()
end

local co = coroutine

local collect = coroutine.create(
   function()
      while true do
	 local Element = co.yield()
	 print( 'element', Element )
	 local n_attr = co.yield()
	 print( 'n_attr', n_attr )
	 for i = 1, n_attr, 2 do
	    local Key, Value = co.yield()
	    print( ' ', Key, Value )
	 end
      end
   end)

local startElementHandler = ffi.cast(
   "XML_StartElementHandler",
   function( udata, name, attr )
      local name = ffi.string(name)
      co.resume( collect, name )
      local attrs = {}
      local index = 0
      while attr[index] ~= nil do
	 attrs[ #attrs+1 ] = ffi.string(attr[index])
	 index = index + 1
      end
      --local kv = {}
      local pp = {}
      co.resume( collect, #attrs )
      for i = 1, #attrs, 2 do
	 --kv[ attrs[i] ] = attrs[i+1]
	 pp[ #pp+1 ] = '["'..tostring(attrs[i]) .. '"] = "' .. attrs[i+1].. '"'
	 co.resume( collect, attrs[i], attrs[i+1] )
      end
      table.insert( stack, name )
      local indent = string.rep(' ',#stack*2)
      local indent2 = string.rep(' ',(#stack+1)*2)
      local indent3 = string.rep(' ',(#stack+2)*2)
      local indent4 = string.rep(' ',(#stack+3)*2)
      if false then
	 if #pp == 0 then
	    print( indent..'["'..name ..  '"] =\n'..indent..'{' )
	 else
	    print( indent..'{\n'..indent2..'["'..name..'"] =\n'..indent2..'{\n'..
		   indent3..table.concat(pp, ',\n'..indent3)..'\n'..indent2..'},')
	 end
      end
   end)

local endElementHandler = ffi.cast(
   "XML_EndElementHandler",
   function( udata, name )
      local name = ffi.string(name)
      local indent = string.rep(' ',#stack*2)
--      print( indent..'},' )
      table.remove( stack )
      co.resume( collect )
   end)

local function parse( buffer )
   local parser = ffi.gc( expat.XML_ParserCreate( nil ), expat.XML_ParserFree )
   expat.XML_SetElementHandler( parser, startElementHandler, endElementHandler )
   expat.XML_Parse( parser, buffer, ffi.sizeof(buffer)-1, 1 )
end

local index = 0
for _, k in ipairs( apis ) do
   local filename = root .. k
   local file = assert(io.open(filename))
   local contents = file:read('*a')
   file:close()
   local buffer = ffi.new( "char[?]", contents:len()+1, contents )
--   print( contents:len(), ffi.sizeof(buffer), filename )
   parse( buffer )
--   assert( #stack == 0 )
   if index > 1 then break end
end


local xx = {
   [{ "Include" }] = "test",
   [{ "Include" }] = "test"
}

for k,v in pairs(xx) do print(k,v) end

local ffi = require( "ffi" )
local expat = require( "ffi/expat" )
local apis = require( "samples/Windows/apis" )
local root = "e:/apps/API Monitor (rohitab.com)/API/"
local dump = require("lib/dump2").dumpstring

local function fixpath(name)
   local fixed, pb = {}
   for i = 1, #name do
      local b = name:byte(i)
      if b == 92 then -- 99=\
	 b = 47 -- 47=/
      end
      if b >= 65 and b <= 90 then -- >=A && <= Z
	 b = b + 32 -- A->a
      end
      if b ~= pb or pb ~= 47 then
	 fixed[#fixed+1] = string.char(b)
      end
      pb = b
   end
   return table.concat(fixed)
end

local expanders = {
   ["Variable"] = {
      ["Type"] = {
	 ["Alias"] = function(t) return "typedef " .. t.Base .. " " .. t.Name .. ";"  end,
 --      ["Array"] = function(t) return "typedef ARRAY! " .. t.Base .. " " .. t.Name .. ";"  end
      },
   },
   ["Set"] = {
      function(t) return t.Name.." = "..t.Value.."," end
   },
}

local ONCE = 10

local function onlyOneKey(t, keyName)
   local onlyOneKey
   for k,v in pairs(t) do
      onlyOneKey = (k == keyName)
   end
   return onlyOneKey
end

local function onlyTwoKeys(t, keyName1, keyName2)
   local onlyTwoKeys
   for k,v in pairs(t) do
      onlyTwoKeys = (k == keyName1 or k == keyName2)
   end
   return onlyTwoKeys
end

local function parse( buffer, filename )
   local stack = {{}}

   local startElementHandler = ffi.cast(
      "XML_StartElementHandler",
      function(udata, name, attr)
	 local kind = ffi.string(name)
	 local kv, index = {}, 0
	 while attr[index] ~= nil do
	    local key   = ffi.string(attr[index])
	    local value = ffi.string(attr[index+1])
	    assert( kv[key] == nil )
	    if key=='Filename' then
	       value = fixpath(value)
	    end
	    kv[key] = value
	    index = index + 2
	 end
	 stack[#stack + 1] = { [kind] = kv }
      end)

   local endElementHandler = ffi.cast(
      "XML_EndElementHandler",
      function( udata, name )
	 local level = #stack
	 local parent = stack[level-1]
	 local child = stack[level]
	 stack[level] = nil

	 if false then
	    --
	 elseif parent.ApiMonitor and onlyOneKey(child,"Include") then
	    -- Normalize includes
	    parent, child = parent.ApiMonitor, child.Include
	 elseif parent.SourceModule and onlyOneKey(child,"Api") then
	    -- Normalize includes
	    parent, child = parent.SourceModule, child.Api
	 elseif parent.Headers and onlyOneKey(child,"Variable") then
	    -- Normalize headers
	    parent, child = parent.Headers, child.Variable
	 elseif parent.Variable and parent.Variable.Type=="Struct" and onlyOneKey(child, "Field") then
	    -- Normalize structures
	    parent, child = parent.Variable, child.Field
	 elseif parent.Variable and parent.Variable.Type=="Union" and onlyOneKey(child, "Field") then
	    -- Normalize unions
	    parent, child = parent.Variable, child.Field
	 elseif parent.Api then
	    -- Normalize apis
	    parent = parent.Api
	    if onlyOneKey(child, "Param") then
	       child = child.Param
	    else
	       for k,v in pairs(child) do
		  assert(parent[k]==nil)
		  parent[k] = v
	       end
	       parent = {}
	    end
	 elseif parent.Module and onlyOneKey(child, "Variable") then
	    -- Normalize modules
	    parent, child = parent.Module, child.Variable
	 elseif parent.Interface and onlyOneKey(child, "Api") then
	    -- Normalize interfaces
	    parent, child = parent.Interface, child.Api
	 elseif parent.Variable and onlyOneKey(child, "Enum") then
	    -- Normalize enums
	    parent = parent.Variable
	    for k,v in pairs(child.Enum) do
	       assert(parent[k]==nil)
--	       assert(onlyTwoKeys(v,"Name","Value"),dump(v))
	       parent[k] = v
	    end
	    parent = {}
	 elseif parent.Enum and onlyOneKey(child, "Set") then
	    -- Normalize enums
	    parent, child = parent.Enum, child.Set
	 elseif parent.Flag and onlyOneKey(child, "Set") then
	    -- Normalize flags
	    parent, child = parent.Flag, child.Set
	 end

	 parent[#parent+1] = child
      end)

   local parser = ffi.gc(expat.XML_ParserCreate(nil), expat.XML_ParserFree)
   expat.XML_SetElementHandler( parser, startElementHandler, endElementHandler )
   expat.XML_Parse( parser, buffer, ffi.sizeof(buffer)-1, 1 )
   startElementHandler:free()
   endElementHandler:free()

   return stack
end

local stack = {}

local t = os.clock()
for _, filename in ipairs( apis ) do
   filename = fixpath(filename):lower()
   local file = assert(io.open(root .. filename))
   local contents = file:read('*all')
   file:close()
   local buffer = ffi.new( "char[?]", contents:len()+1, contents )
   assert(stack[filename]==nil)
   stack[filename] = parse( buffer, filename )
end
local t1 = os.clock()

local log = io.open("c:/apis.log", "w")
log:write(dump(stack))
log:close()

print( t1 - t )

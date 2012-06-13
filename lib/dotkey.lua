local dotkey = {}

----------------------------------------------------------
-- Returns the value of a dot encoded key from the table t
-- Returns nil if the key is not found.
-- Example: local t = { one = { two = 12 } }
--          print( dotkey.get( t, "one.two" ) ) -- prints 12
function dotkey.get(t, key)
   local b, s, p = string.byte, string.sub, 1
   for i=1, key:len()+1 do
      local c = b(key, i)
      if c==nil or c==46 then
         if p==i then
            error( "DOTKEY: Invalid character '" .. string.char(c) .. "' (" .. c ..
		   ") found in key '"  .. tostring(key) .. "' at position: " .. p)
         end
	 -- Don't shortcut here. Check the whole key for errors!
         t,p = type(t)~="table" and nil or t[s(key, p, i-1)],i+1
      end
   end
   return t
end

if #{...}==0 then
   print( "dotkey: standalone test..." )
   local dk = dotkey
   local t = { one = { two = "12", t = true, f = false, ["end"] = "end" } }
   assert( dk.get(t, "one.two") == "12" )
   assert( dk.get(t, "one.t") == true )
   assert( dk.get(t, "one.t1") == nil )
   assert( dk.get(t, "one.f") == false )
   assert( dk.get(t, "one.f1") == nil )
   assert( dk.get(t, "one.end") == "end" )
   assert( type(dk.get(t, "one"))=="table" )
   assert( dk.get(t, "blah") == nil )
   assert( not xpcall(function() dk.get({}, "bad key.") end, type), "this should fail" )
   assert( not xpcall(function() dk.get({}, ".bad key") end, type), "this should fail" )
   assert( not xpcall(function() dk.get({}, ".") end, type), "this should fail" )
   assert( not xpcall(function() dk.get({}, "") end, type), "this should fail" )
end

return dotkey
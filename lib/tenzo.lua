----------------------------------------------------------
-- Returns the value of a dot encoded key from the table t
-- Returns nil if the key is not found.
-- Example: local t = { one = { two = 12 } }
--          print( read( t, "one.two" ) ) -- prints 12
local function read(t, key)
   local b,s,l = string.byte,string.sub,1
   for i=1, key:len()+1 do
      local c = b(key, i)
      if c==nil or c==46 then
         if l==i then
            error( "Unexpected character in key='" .. 
		   tostring(key) .. "' near position: " .. tostring(l) )
         end
	 -- Don't shortcut here. Check the whole key for errors!
         t,l = type(t)~="table" and nil or t[s(key, l, i-1)],i+1
      end
   end
   return t
end
do -- testing read(t, key)
   local t = { one = { two = "12", t = true, f = false } }
   assert( read(t, "one.two") == "12" )
   assert( read(t, "one.t") == true )
   assert( read(t, "one.t1") == nil )
   assert( read(t, "one.f") == false )
   assert( read(t, "one.f1") == nil )
   assert( type(read(t, "one"))=="table" )
   assert( read(t, "blah") == nil )
end

-- Evals a boolean "AND" expression of dotted keys
local function eval(t, expr)
   local b,s,r,l,plus = string.byte,string.sub,read
   for i=1, expr:len()+1 do
      local c = b(expr, i)
      if c==nil or c==43 or c==45 then
         if l==i or c==nil and l==nil then
            error( "Invalid expression" )
         end
         if l~=nil then
            local k = s(expr, l, i-1)
            local v = r(t, k)
            local f = v==plus
            if c==nil or not(f) then
--             print(k,v,f,plus)
               return f
            end
         end
         plus,l = c==43,i+1
      end
   end
   assert(nil)
end

local f = { a = { b = { c = false, d=true } } }
assert( eval(f, "-a.b.c") == true )
assert( eval(f, "+a.b.c") == false )
assert( eval(f, "-a.b.d") == false )
assert( eval(f, "+a.b.d") == true )

-- Splits a single line into word table. Handles and preserves quotes (' " `)
local function split(l)
   local t,n, b,s, p,q = {},1, string.byte,string.sub
   for i=1, l:len() do
      local c = b(l, i)
      if not(q) then
         if c==9 or c==32 then
            if p then
               t[n],n, p = s(l, p, i - 1),n + 1
            end
         else
            q = (c==34 or c==39 or c==96) and c
            p = p or i
         end
      elseif q==c then
         q = nil
      end
   end
   t[n] = p and s(l,p)
   return t
end

-- Splits each line from lines
-- Then finds all boolean expressions
-- And based on them leaves only these lines
local function expand(t, words)
   local more_expr, accepted = true
   local out, b = {}, string.byte
   for i=1, #words do
      local w = words[i]
      local c = b(w)
      if more_expr and (c==43 or c==45) then
         if not(accepted) then
            accepted = eval(t,w)
            print('AA',accepted,w)
         end
      elseif accepted~=false then
         out[ #out+1 ] = w
         more_expr = false
      else
         break
      end
   end
   return out
end

local function hostinfo()
   if jit then
      return {
         [ jit.os:lower()   ] = true,
         [ jit.arch:lower() ] = true,
      }
   end
   return {
      windows = true,
      x86 = true,
   }
end

local function dummy_targets()
   return {
      windows = { -- We are targeting Windows
         wdk = true, -- from the Windows Driver Kit
         msvcrt = true, -- and linking to MSVCRT.DLL
         init = "bin/setenv.bat" -- Fake - just template
      },
      cygwin = { -- cygwin, not windows :)
      },
      mingw = { -- mingw
         tdm = false, -- TDM GCC http://tdm-gcc.tdragon.net/
      },
      linux = {
      },
      osx = { -- Apple Mac OSX
      },
      ios = { -- Apple iOS
      },
      webos = { -- HP TouchPad WebOS
      },
      bbx = { -- BlackBerry PlayBook (QNX)
      },
      android = { -- Google Android
      },
      nacl = { -- Google NACL
      },
   }
end

local function dummy_config()
   return {
      debug = true,  -- Make debug mode
      shared = true, -- Make shared libs
   }
end

local build = {
   host = hostinfo()
}

for k,v in pairs( build.host ) do print(k,v) end

do
   local t = { debug=false }
   for l in io.lines('tenzo.test') do
   --   print(l)
--      print(table.concat(expand(t,split(l)), ' .. '))
   end
end


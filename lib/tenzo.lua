local dotkey = require( "lib/dotkey" )

-- Evals a boolean "AND" expression of dotted keys
local function eval(t, expr)
   local byte,sub,get,l,plus = string.byte,string.sub,dotkey.get
   for i=1, expr:len()+1 do
      local c = byte(expr, i)
      -- 43 is +, 45 is -
      if c==nil or c==43 or c==45 then
         if l==i or c==nil and l==nil then
            error( "Invalid expression" )
         end
         if l~=nil then
            local k = sub(expr, l, i-1)
            local v = get(t, k)
            local f = v==plus
            if c==nil or not(f) then
               return f
            end
         end
         plus,l = c==43,i+1
      end
   end
   assert(nil)
end
if #{...}==0 then
   print( 'testing eval' )
   local f = { a = { b = { c = false, d=true } } }
   assert( eval(f, "-a.b.c") == true )
   assert( eval(f, "+a.b.c") == false )
   assert( eval(f, "-a.b.d") == false )
   assert( eval(f, "+a.b.d") == true )
end

-- Splits a single line into word table. Handles and preserves quotes (' " `)
local function split(l)
   local t,n,b,s,p,q = {},1,string.byte,string.sub
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

do
   local code = {'do'}
   local build = {
      host = hostinfo(),
      target = hostinfo()
   }
   for l in io.lines('tenzo.test') do
      local l = table.concat(expand(build,split(l)), ' ')
      code[#code + 1] = l
   end
   code[#code + 1] = 'end'
   assert(loadstring(table.concat(code,'\n')))()
end

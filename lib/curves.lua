-- Translation directly of the awesome C# iTween Project

local min, max, pi, sin, cos, pow, sqrt = math.min, math.max, math.pi, math.sin, math.cos, math.pow, math.sqrt
local two_over_pi = 2 / pi

local curves = {
   linear = {
      IN     = function(t) return t end,
      OUT    = function(t) return t end,
      IN_OUT = function(t) return t end,
      OUT_IN = function(t) return t end,
   },
   quad = {
      IN     = function(t) return t*t end,
      OUT    = function(t) return -t*(t-2) end,
      IN_OUT = function(t)
		  t = t + t
		  if t < 1 then
		     return t*t * 0.5
		  end
		  t = t - 1
		  return (1 - t*(t-2)) * 0.5
	       end,
      OUT_IN = function(t)
		  if t < 0.5 then
		     return (1-t)*(t+t)
		  end
		  return (2*t-1)*(2*t-1) * 0.5 + 0.5
	       end,
   },
   cubic = {
      IN     = function(t)
		  return t*t*t
	       end,
      OUT    = function(t)  
		  t = t - 1
		  return t*t*t + 1
	       end,
      IN_OUT = function(t)
		  t = t+t
		  if t < 1 then
		     return t*t*t * 0.5
		  end
		  t = t - 2
		  return t*t*t * 0.5 + 1
	       end,
      OUT_IN = function(t)
		  if t < 0.5 then
		     t = t+t - 1
		     return (t*t*t + 1) * 0.5
		  end
		  t = t+t - 1
		  return (t*t*t + 1) * 0.5
	       end,
   },
}

if true then
   local c = ".:"
   local w, h = 24, 12
   local keys = {}
   for k,_ in pairs(curves) do
      keys[#keys+1] = k
   end
   table.sort(keys)
   for _,k in ipairs(keys) do
      local vv = curves[k]
      print()
      print(k)
      for y=h-1, 0, -1 do
	 local l = {}
	 for _,k in pairs{ "IN", "OUT", "IN_OUT", "OUT_IN" } do
	    local v = vv[k]
	    for x=0, w-1 do
	       local v = v(x / w) * h
	       if v - 1.0 > y then
		  l[#l+1] = '='
	       elseif v - 0.5 > y then 
		  l[#l+1] = "'"
	       elseif v + 0.0 > y then 
		  l[#l+1] = ':'
	       elseif v + 0.5 > y then
		  l[#l+1] = '.'
	       else
		  l[#l+1] = '-'
	       end
	    end
	    l[#l+1] = ' '
	 end
	 print(table.concat(l))
      end
   end
end

for _ = 1, 10 do print() end

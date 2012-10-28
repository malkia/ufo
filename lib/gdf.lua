--local dump = require("lib/dump2").dumpstring
local gdf = "/Users/malkia/p/t6/game/deffiles/xanim.gdf"

local gdfpath = "/Users/malkia/p/t6/game/deffiles/"
local gdfs = {
   "aitype", "attachment", "attachmentunique", "bullet_penetration",
   "bulletweapon", "character", "destructibledef", "destructiblepiece",
   "dualwieldprojectileweapon", "dualwieldweapon", "emblem", "flametable",
   "footstepfxtable", "gasweapon", "glass", "grenadeweapon", "light",
   "locdmgtable", "material", "meleeweapon", "mpbody", "mphead", "mptype",
   "physconstraints", "physpreset", "pimp_stage1", "pimp_stage2",
   "projectileweapon", "rumble", "siege", "tracer", "turretweapon",
   "vehicle", "weaponcamo", "xanim", "xmodel", "xmodelalias", "zbarrier",
}

local function parse(line)
   local tokens, last = {}, 1
   local in_quotes, has_quotes = false, false
   local bracket_level, has_brackets = 0, false
   for i=1, #line+1 do
      local c = line:byte(i)
      if c == 34 then 
	 in_quotes, has_quotes = not in_quotes, true 
      elseif c==123 then 
	 bracket_level, has_brackets = bracket_level + 1, true
      elseif c==125 then 
	 bracket_level = bracket_level - 1
      elseif bracket_level==0 and not in_quotes and (c==44 or c==32 or c==nil or c==13) then
	 if i-1 >= last then 
	    if has_brackets then
	       tokens[#tokens+1] = parse(line:sub(last+1,i-2),44)
	    elseif has_quotes then
	       tokens[#tokens+1] = line:sub(last+1,i-2) 
	    else
	       tokens[#tokens+1] = line:sub(last,i-1) 
	    end
	 end
	 last, has_brackets, has_quotes = i+1, false, false
      end
   end
   return tokens
end

local transforms = {
   float = { [4]={"default", "min", "max", "name"} },
   int = { [4]={"default", "min", "max", "name"} },
   string = { [1]={"name"}, [2]={"default", "name"} },
   enum = { [2]={"list", "name"} },
   color = { [5]={"r", "g", "b", "a", "name"} }
}

local function transform(tokens)
   local type = tokens[1]
   local transform = transforms[type]
   if transform then
      transform = transform[#tokens-1]
      if transform then
	 local r = {type=type}
	 for k,v in ipairs(transform) do r[v] = tokens[k+1] end
	 return r
      end
      error("no transform")
   end
   return tokens
end

local function load_gdf(gdf)
   local lines = { order={}, index={}, extra={} }
   for line in io.lines(gdf) do
      local tokens = transform(parse(line))
      if tokens.type then
	 local name = tokens.name
	 tokens.name = nil
	 lines.order[#lines.order+1] = name
	 lines.index[name] = tokens
      else
	 lines.extra[#lines.extra+1] = tokens
      end
   end
   return lines
end

local function load_gdfs()
   for _,v in ipairs(gdfs) do
      local gdf = load_gdf(gdfpath..v..".gdf")
--      print(dump(gdf))
   end
end

local t1=os.clock()
load_gdfs()
local t2=os.clock()

print(t2-t1)


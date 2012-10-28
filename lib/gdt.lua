local gdtpath="/Users/malkia/p/t6/game/"
local gdtfiles=require("lib/gdts")

local function parse(name)
   local gdt = { order={}, index={} }
   local angle_bracket_level = 0
   local square_bracket_level = 0
   local round_bracket_level = 0
   local quotes = {-1,-1,-1,-1}
   local in_quotes = false
   local entry = nil
   local file = assert(io.open(name, "rt"))
   for line in file:lines() do
      local quotes_found = 1
      local had_square_bracket = false
      local had_round_bracket = false
      local had_closing_angle_bracket = false
      local escaped = false
      for i=1,#line do
	 local c = line:byte(i)
	 if in_quotes and c == 92 then -- 92='\\'
	    escaped = true
	 elseif not escaped then
	    if c == 34 then -- 34='"'
	       quotes[quotes_found], quotes_found = i, quotes_found + 1
	       in_quotes = not in_quotes
	    elseif not in_quotes then
	       if c == 40 then -- 40='('
		  round_bracket_level = round_bracket_level + 1
		  had_round_bracket = true
	       elseif c == 41 then -- 41=')'
		  round_bracket_level = round_bracket_level - 1
		  had_round_bracket = true
		  assert(round_bracket_level >= 0)
	       elseif c == 91 then -- 91='['
		  had_square_bracket = true
		  square_bracket_level = square_bracket_level + 1
	       elseif c == 93 then -- 93=']'
		  square_bracket_level = square_bracket_level - 1
		  had_square_bracket = true
		  assert(square_bracket_level >= 0)
	       elseif c == 123 then -- 123='{'
		  angle_bracket_level = angle_bracket_level + 1
	       elseif c == 125 then -- 125='}'
		  angle_bracket_level = angle_bracket_level - 1
		  assert(angle_bracket_level >= 0)
		  had_closing_angle_bracket = true
	       end
	    end
	 else
	    escaped = false
	 end
      end
      assert(not in_quotes)
      assert(round_bracket_level==0)
      assert(square_bracket_level==0)
      assert(quotes_found==1 or quotes_found==5, line)
      if quotes_found==5 then
	 local token1 = line:sub(quotes[1]+1, quotes[2]-1)
	 local token2 = line:sub(quotes[3]+1, quotes[4]-1)
	 if angle_bracket_level == 1 then
	    assert(entry == nil)
	    entry = { name = token1, order={}, index={} } 
	    if had_round_bracket then
	       assert(not had_square_bracket)
	       entry.type = token2
	    else
	       print(line)
	       assert(had_square_bracket)
	       entry.parent = token2
	    end
	 else
	    assert(angle_bracket_level == 2)
	    assert(entry)
	    entry.order[#entry.order+1] = token1
	    entry.index[token1] = token2
	 end
      elseif had_closing_angle_bracket then
	 if angle_bracket_level == 1 then
	    gdt.order[#gdt.order+1] = entry.name
	    assert(gdt.index[entry.name] == nil)
	    gdt.index[entry.name] = entry
	    entry = nil
	 else
	    assert(angle_bracket_level==0)
	    break -- end processing
	 end
      end
   end
   file:close()
   return gdt
end

local function process()
   local gdts = { order={}, index={}}
   for _,gdt in ipairs(gdtfiles) do
      gdts.order[#gdts.order+1] = gdt
      gdts.index[gdt] = parse(gdtpath..gdt)
   end
   return gdts
end

local t1 = os.clock()
process()
local t2 = os.clock()
print(t2 -t1 )


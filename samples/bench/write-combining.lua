-- http://mechanical-sympathy.blogspot.com/2011/07/write-combining.html

local ffi = require( "ffi" )
local shl, band = bit.lshift, bit.band

local ITERATIONS = 0x80000000 / 64
local ITEMS      = shl( 1, 24 )
local MASK       = ITEMS - 1

local arrays = ffi.new( "uint8_t[6][" .. ITEMS .. "]" )

local function nanoTime()
   return os.clock()
end

local function runCaseOne()
   local start = nanoTime()
   local i = ITERATIONS - 1
   while i ~= 0 do
      local slot = band( i, MASK )
      arrays[0][slot] = slot
      arrays[1][slot] = slot
      arrays[2][slot] = slot
      arrays[3][slot] = slot
      arrays[4][slot] = slot
      arrays[5][slot] = slot
      i = i - 1
   end
   return nanoTime() - start
end

local function runCaseTwo()
   local start = nanoTime()
   local i = ITERATIONS - 1
   while i ~= 0 do
      local slot = band( i, MASK )
      arrays[0][slot] = slot
      arrays[1][slot] = slot
      arrays[2][slot] = slot
      i = i - 1
   end
   local i = ITERATIONS - 1
   while i ~= 0 do
      local slot = band( i, MASK )
      arrays[0][slot] = slot
      arrays[1][slot] = slot
      arrays[2][slot] = slot
      i = i - 1
   end
   return nanoTime() - start
end

local function main()
   for i = 1, 3 do
      print( i .. " SingleLoop duration (s) = " .. runCaseOne() )
      print( i .. " SplitLoop  duration (s) = " .. runCaseTwo() )
   end
   local result = arrays[0][1] + arrays[0][2] + arrays[0][3] + arrays[0][4] + arrays[0][5] + arrays[0][6]
   assert( result == 1 + 2 + 3 + 4 + 5 + 6 )
end

-- Windows 7 64-bit
-- 1 SingleLoop duration (ns) = 17.426
-- 1 SplitLoop  duration (ns) = 6.8
-- 2 SingleLoop duration (ns) = 17.462
-- 2 SplitLoop  duration (ns) = 6.801
-- 3 SingleLoop duration (ns) = 17.426
-- 3 SplitLoop  duration (ns) = 6.852

main()

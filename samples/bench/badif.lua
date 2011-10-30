-- http://igoro.com/archive/fast-and-slow-if-statements-branch-prediction-in-modern-processors/

local ffi = require("ffi")
local band = bit.band

local function test(n, m)
   local count = 0; for i=1, n do if band(i, m)==0 then count = count + 1 end end return count
end

local function timeit(m)
   local t = os.clock()
   test(0xFFFFFFFF,m)
   local t = os.clock() - t
   print(string.format("%08X",m),t)
end

timeit(0x80000000)
timeit(0xffffffff)
timeit(1)
timeit(3)
timeit(2)
timeit(4)
timeit(8)
timeit(16)

--[[
-- This is on OSX 10.7.2 MBP 2008 Jan build
 ./luajit samples/badif.lua
80000000	14.067395
FFFFFFFF	20.252955
00000001	13.497108
00000003	17.337942
00000002	14.142266
00000004	14.221376
00000008	14.42377
00000010	14.708237
--]]

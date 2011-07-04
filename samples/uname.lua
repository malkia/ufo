#!/usr/bin/env luajit

local ffi  = require('ffi')
local arch = ffi.os.." "..ffi.arch

for _,k in ipairs{ "32bit", "64bit", "le", "be", "fpu", "softfp", "hardfp", "eabi", "win" } do
   if ffi.abi(k) then
      arch = arch .. " " .. k
   end
end

print(arch)


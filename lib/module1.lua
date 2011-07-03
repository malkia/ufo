--module1.lua
assert( ... ) -- If this is not used as module it would assert
local name = ...
local dir = name:gsub( "%/", "%" )
print( dir )
print( name )

-- local module2 = require( (...):gsub("%/","%") .. "/" .. "module2" )

return {}

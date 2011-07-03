local name = ... or arg[0]
local dir = name:gsub( "(.*)/", "%" )
print( dir )
print( name )

--local module1 = require( "lib/module1" )
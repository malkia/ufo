local zmq = require( "ext/zmq" )( )

local content = "12345678ABCDEFGH12345678abcdefgh"

local function bounce( sb, sc )
   sc.send( content, 0 )
   local buf1 = sb.recv( #content, 0 )

   sb.send( buf1, 32, 0 )
   local buf2 = sc.recv( #buf1, 0 )

--   assert( #buf1 == #buf2 )
--   for i=1, #buf1 do
--      assert( buf1[i] == buf2[i] )
--   end

--   print( buf1 )
--   print( buf2 )
end

local ctx = zmq.init( 1 )
local sb = ctx.socket( zmq.PAIR )
local sc = ctx.socket( zmq.PAIR )
sb.bind( "inproc://a" )
sc.connect( "inproc://a" )
for i=0,1024*1024-1 do
  bounce( sb, sc )
end
sc.close()
sb.close()
ctx.term()

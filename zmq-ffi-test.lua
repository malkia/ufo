local ffi = require( "ffi" )
local zmq = require( "ffi/zmq" )

local content = "12345678ABCDEFGH12345678abcdefgh"
local buf1 = ffi.new( "char[32]" )
local buf2 = ffi.new( "char[32]" )

local function bounce( sb, sc )
   local rc = zmq.zmq_send( sc, content, 32, 0 )
--   assert( rc == 32 )

   rc = zmq.zmq_recv( sb, buf1, 32, 0 )
--   assert( rc == 32 )
   rc = zmq.zmq_send( sb, buf1, 32, 0 )
--   assert( rc == 32 )
   
   rc = zmq.zmq_recv( sc, buf2, 32, 0 )
--   assert( rc == 32 )

--   for i=0, 31 do
--      assert( buf1[i] == buf2[i] )
--   end

--   print( ffi.string(buf2,32))
end

local ctx = zmq.zmq_init (1);
assert (ctx);

print( "CONTEXT ", ctx )

local sb = zmq.zmq_socket (ctx, zmq.ZMQ_PAIR);
assert (sb);

local rc = zmq.zmq_bind (sb, "inproc://a");
assert (rc == 0);

local sc = zmq.zmq_socket (ctx, zmq.ZMQ_PAIR);
assert (sc);

local rc = zmq.zmq_connect (sc, "inproc://a");
assert (rc == 0);

for i=0, 1024*1024-1 do
bounce( sb, sc )   
end 

local rc = zmq.zmq_close (sc);
assert (rc == 0);

rc = zmq.zmq_close (sb);
assert (rc == 0);

rc = zmq.zmq_term (ctx);
assert (rc == 0);

print("DONE")


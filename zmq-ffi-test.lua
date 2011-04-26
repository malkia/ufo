local ffi = require( "ffi" )
local zmq = require( "ffi/zmq" )

local content = "12345678ABCDEFGH12345678abcdefgh"
local buf  = ffi.new( "char[32]", content )
local buf1 = ffi.new( "char[32]" )
local buf2 = ffi.new( "char[32]" )
local send, recv = zmq.zmq_send, zmq.zmq_recv

local function bounce( sb, sc )
   local r1, r2, r3, r4
   r1 = send( sc, buf,  32, 0 )
   r2 = recv( sb, buf1, 32, 0 )
   r3 = send( sb, buf1, 32, 0 )
   r4 = recv( sc, buf2, 32, 0 )
   print( r1, r2, r3, r4 )
   assert( r1 == 0 )
   assert( r2 == 0 )
   assert( r3 == 0 )
   assert( r4 == 0 )
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


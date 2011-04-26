local ffi = require( "ffi" )
local zmq = require( "ffi/zmq" )

content = {}

for i=0,65535 do
  content[#content + 1] = string.char(math.floor(math.random(255)))
end


content = table.concat(content)
print(#content)

--[[
local content = "12345678ABCDEFGH12345678abcdefgh"
content = content .. content
content = content .. content
content = content .. content
content = content .. content
content = content .. content
content = content .. content
content = content .. content
content = content .. content
content = content .. content
content = content .. content
content = content .. content
print(#content)
--]]

local buf  = ffi.new( "char[?]", #content, content )
local buf1 = ffi.new( "char[?]", #content )
local buf2 = ffi.new( "char[?]", #content )
local send, recv = zmq.zmq_send, zmq.zmq_recv

local len = #content

local function bounce( sb, sc )
   local r1, r2, r3, r4
   r1 = send( sc, buf,  len, 0 )
   r2 = recv( sb, buf1, len, 0 )
   r3 = send( sb, buf1, len, 0 )
   r4 = recv( sc, buf2, len, 0 )
   assert( r1 == len, r1 )
   assert( r2 == len, r2 )
   assert( r3 == len, r3 )
   assert( r4 == len, r4 )
end

local ctx = zmq.zmq_init (1);
assert (ctx);

print( "CONTEXT ", ctx )

local sb = zmq.zmq_socket (ctx, zmq.ZMQ_PAIR);
assert (sb);

local rc = zmq.zmq_bind (sb, "inproc://a" );
assert (rc == 0);

local sc = zmq.zmq_socket (ctx, zmq.ZMQ_PAIR);
assert (sc);

local rc = zmq.zmq_connect (sc, "inproc://a" );
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


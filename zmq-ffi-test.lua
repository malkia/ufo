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
<<<<<<< HEAD
--[[
=======
>>>>>>> df751bbc995212251e5ee30c49a76fbde7958175
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
<<<<<<< HEAD
--]]
=======
content = content .. content
print(#content)
--]]

>>>>>>> df751bbc995212251e5ee30c49a76fbde7958175
local buf  = ffi.new( "char[?]", #content, content )
local buf1 = ffi.new( "char[?]", #content )
local buf2 = ffi.new( "char[?]", #content )
local send, recv = zmq.zmq_send, zmq.zmq_recv

<<<<<<< HEAD
local size, size1, size2 = ffi.sizeof(buf), ffi.sizeof(buf1), ffi.sizeof(buf2)

local connection = { }

local function zmq_error()
   local errno = zmq.errno()
   local strerror = ffi.string( zmq.sterror( ernno ) )
   error( "ZMQ ERROR: " .. errno .. ": " .. strerror )
end

function connection.send( self, buf, len )
   local r = send( self.handle, buf, len, 0 )
   if r ~= len then zmq_error() end
   return r
end

function connection.recv( self, buf, len )
   local r = recv( self.handle, buf, len, 0 )
   if r ~= len then zmq_error() end
   return r
end

function new_connection( handle )
   local c = {}
   c.send = connection.send
   c.recv = connection.recv
   c.handle = handle
   return c
end

local function bounce( sb, sc )
   local r1, r2, r3, r4
   r1 = sc:send( buf,  size )
   r2 = sb:recv( buf1, size1 )
   r3 = sb:send( buf1, size1 )
   r4 = sc:recv( buf2, size2 )
   assert( r1 == size )
   assert( r2 == size1 )
   assert( r3 == size1 )
   assert( r4 == size2 )
=======
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
>>>>>>> df751bbc995212251e5ee30c49a76fbde7958175
end

local ctx = zmq.zmq_init (1);
assert (ctx);

local sb = zmq.zmq_socket (ctx, zmq.ZMQ_PAIR);
assert (sb);

<<<<<<< HEAD
local rc = zmq.zmq_bind (sb, "ipc://abcd"); --tcp://127.0.0.1:6666");
=======
local rc = zmq.zmq_bind (sb, "inproc://a" );
>>>>>>> df751bbc995212251e5ee30c49a76fbde7958175
assert (rc == 0);

local sc = zmq.zmq_socket (ctx, zmq.ZMQ_PAIR);
assert (sc);

<<<<<<< HEAD
local rc = zmq.zmq_connect (sc, "ipc://abcd" ); --tcp://127.0.0.1:6666");
=======
local rc = zmq.zmq_connect (sc, "inproc://a" );
>>>>>>> df751bbc995212251e5ee30c49a76fbde7958175
assert (rc == 0);

local sb = new_connection( sb )
local sc = new_connection( sc )
for i=0, 11200-1 do --1024*1024/64-1 do
bounce( sb, sc )   
end 
local sb = sb.handle
local sc = sc.handle

print(1024*1024/64)

local rc = zmq.zmq_close (sc);
assert (rc == 0);

rc = zmq.zmq_close (sb);
assert (rc == 0);

rc = zmq.zmq_term (ctx);
assert (rc == 0);

print("DONE")


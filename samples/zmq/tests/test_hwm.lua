--  Copyright (c) 2007-2011 iMatix Corporation
--  Copyright (c) 2007-2011 Other contributors as noted in the AUTHORS file

--  This file is part of 0MQ.

--  0MQ is free software; you can redistribute it and/or modify it under
--  the terms of the GNU Lesser General Public License as published by
--  the Free Software Foundation; either version 3 of the License, or
--  (at your option) any later version.

--  0MQ is distributed in the hope that it will be useful,
--  but WITHOUT ANY WARRANTY; without even the implied warranty of
--  MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the
--  GNU Lesser General Public License for more details.

--  You should have received a copy of the GNU Lesser General Public License
--  along with this program.  If not, see <http://www.gnu.org/licenses/>.

local ffi = require( "ffi" )
local zmq = require( "ffi/zmq" )
local testutil = require( "samples/zmq/tests/testutil" )
local errno = require( "ffi/errno" )

local ctx = zmq.zmq_init( 1 )
assert( ctx )

--  Create pair of socket, each with high watermark of 2. Thus the total
--  buffer space should be 4 messages.
local sb = zmq.zmq_socket( ctx, zmq.ZMQ_PULL )
assert( sb )

local hwm = ffi.new( "int[1]", 2 )
local rc = zmq.zmq_setsockopt( sb, zmq.ZMQ_RCVHWM, hwm, ffi.sizeof( hwm ))
assert( rc == 0 )
local rc = zmq.zmq_bind( sb, "inproc://a" )
assert( rc == 0 )

local sc = zmq.zmq_socket( ctx, zmq.ZMQ_PUSH )
assert( sc )
local rc = zmq.zmq_setsockopt( sc, zmq.ZMQ_SNDHWM, hwm, ffi.sizeof( hwm ))
assert( rc == 0 )
local rc = zmq.zmq_connect( sc, "inproc://a" )
assert( rc == 0 )

--  Try to send 10 messages. Only 4 should succeed.
for i=0, 9 do
   local rc = zmq.zmq_send( sc, nil, 0, zmq.ZMQ_DONTWAIT )
   if i < 4 then
      assert( rc == 0 )
   else
      assert( rc < 0 and zmq.zmq_errno() == errno.EAGAIN )
   end
end

-- There should be now 4 messages pending, consume them.
for i=0, 3 do
   local rc = zmq.zmq_recv( sb, nil, 0, 0 )
   assert( rc == 0 )
end

-- Now it should be possible to send one more.
local rc = zmq.zmq_send( sc, NULL, 0, 0 )
assert( rc == 0 )

--  Consume the remaining message.
local rc = zmq.zmq_recv( sb, NULL, 0, 0 )
assert( rc == 0 )

local rc = zmq.zmq_close( sc )
assert( rc == 0 )

local rc = zmq.zmq_close( sb )
assert( rc == 0 )

local rc = zmq.zmq_term( ctx )
assert( rc == 0 )

return 0

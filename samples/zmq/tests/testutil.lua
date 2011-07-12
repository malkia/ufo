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

local M = {}
local content = ffi.new( "char[32]", "12345678ABCDEFGH12345678abcdefgh" )
local buf1 = ffi.new( "char[32]" )
local buf2 = ffi.new( "char[32]" )
local rcvmore = ffi.new( "int[1]" )
local sz = ffi.new( "size_t[1]", ffi.sizeof( rcvmore ) )

ffi.cdef[[
      int memcmp(const void*, const void*, size_t);
]]

function M.bounce( sb, sc )
   --  Send the message.
   local rc = zmq.zmq_send( sc, content, 32, zmq.ZMQ_SNDMORE )
   assert( rc == 32 )
   local rc = zmq.zmq_send( sc, content, 32, 0 )
   assert( rc == 32 )

   --  Bounce the message back.
   local rc = zmq.zmq_recv( sb, buf1, 32, 0 )
   assert( rc == 32 )
   local rc = zmq.zmq_getsockopt( sb, zmq.ZMQ_RCVMORE, rcvmore, sz )
   assert( rc == 0 )
   assert( rcvmore[0] ~= 0 )
   local rc = zmq.zmq_recv( sb, buf1, 32, 0 )
   assert( rc == 32 )
   local rc = zmq.zmq_getsockopt( sb, zmq.ZMQ_RCVMORE, rcvmore, sz )
   assert( rc == 0 )
   assert( rcvmore[0] == 0 )
   local rc = zmq.zmq_send( sb, buf1, 32, zmq.ZMQ_SNDMORE )
   assert( rc == 32 )
   local rc = zmq.zmq_send( sb, buf1, 32, 0 )
   assert( rc == 32 )
   
   --  Receive the bounced message.
   local rc = zmq.zmq_recv( sc, buf2, 32, 0 )
   assert( rc == 32 )
   local rc = zmq.zmq_getsockopt( sc, zmq.ZMQ_RCVMORE, rcvmore, sz )
   assert( rc == 0 )
   assert( rcvmore[0] ~= 0)
   local rc = zmq.zmq_recv( sc, buf2, 32, 0 )
   assert( rc == 32 )
   local rc = zmq.zmq_getsockopt( sc, zmq.ZMQ_RCVMORE, rcvmore, sz )
   assert( rc == 0 )
   assert( rcvmore[0] == 0)
   
   --  Check whether the message is still the same.
   assert( ffi.C.memcmp( buf2, content, 32 ) == 0 )
end

return M


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

local zmq = require( "ffi/zmq" )
local testutil = require( "samples/zmq/tests/testutil" )

local ctx = zmq.zmq_init( 1 )
assert( ctx )

local sb = zmq.zmq_socket( ctx, zmq.ZMQ_PAIR )
assert( sb )
local rc = zmq.zmq_bind( sb, "tcp://127.0.0.1:5560" )
assert( rc == 0 )

local sc = zmq.zmq_socket( ctx, zmq.ZMQ_PAIR )
assert( sc )
local rc = zmq.zmq_connect( sc, "tcp://127.0.0.1:5560" )
assert( rc == 0 )

testutil.bounce( sb, sc )

local rc = zmq.zmq_close( sc )
assert( rc == 0 )

local rc = zmq.zmq_close( sb )
assert( rc == 0 )

local rc = zmq.zmq_term( ctx )
assert( rc == 0 )

return 0

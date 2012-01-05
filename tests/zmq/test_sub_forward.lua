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

local ctx = zmq.zmq_init( 1 )
assert( ctx )

-- First, create an intermediate device.
local xpub = zmq.zmq_socket( ctx, zmq.ZMQ_XPUB )
assert( xpub )
local rc = zmq.zmq_bind( xpub, "tcp://127.0.0.1:5560")
assert (rc == 0)

local xsub = zmq.zmq_socket( ctx, zmq.ZMQ_XSUB )
assert( xsub )
local rc = zmq.zmq_bind( xsub, "tcp://127.0.0.1:5561" )
assert( rc == 0 )

--  Create a publisher.
local pub = zmq.zmq_socket( ctx, zmq.ZMQ_PUB )
assert( pub )
local rc = zmq.zmq_connect( pub, "tcp://127.0.0.1:5561" )
assert( rc == 0 )

--  Create a subscriber.
local sub = zmq.zmq_socket( ctx, zmq.ZMQ_SUB )
assert( sub )
local rc = zmq.zmq_connect( sub, "tcp://127.0.0.1:5560" )
assert( rc == 0 )

--  Subscribe for all messages.
local rc = zmq.zmq_setsockopt( sub, zmq.ZMQ_SUBSCRIBE, "", 0 )
assert( rc == 0 )

--  Pass the subscription upstream through the device.
local buff = ffi.new( "char[32]" )
local rc = zmq.zmq_recv( xpub, buff, ffi.sizeof( buff ), 0 )
assert( rc >= 0 )
local rc = zmq.zmq_send( xsub, buff, rc, 0 )
assert( rc >= 0 )

--  Wait a bit till the subscription gets to the publisher.
zmq.zmq_sleep( 1 )

--  Send an empty message.
local rc = zmq.zmq_send( pub, nil, 0, 0 )
assert( rc == 0 )

--  Pass the message downstream through the device.
local rc = zmq.zmq_recv( xsub, buff, ffi.sizeof( buff ), 0 )
assert (rc >= 0)
local rc = zmq.zmq_send( xpub, buff, rc, 0 )
assert (rc >= 0)

--  Receive the message in the subscriber.
local rc = zmq.zmq_recv( sub, buff, ffi.sizeof( buff ), 0 )
assert( rc == 0 )

--  Clean up.
local rc = zmq.zmq_close( xpub )
assert( rc == 0 )
local rc = zmq.zmq_close( xsub )
assert( rc == 0 )
local rc = zmq.zmq_close( pub )
assert( rc == 0 )
local rc = zmq.zmq_close( sub )
assert( rc == 0 )
local rc = zmq.zmq_term( ctx )
assert( rc == 0 )

return 0

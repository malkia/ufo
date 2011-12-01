local ffi = require( "ffi" )
local zmq = require( "ffi/zmq" )

local bind_addr    = "tcp://*:5555"
local connect_addr = "tcp://localhost:5555"

local bind_addr = "ipc://zmq_forked_lua"
local connect_addr = bind_addr

-- local bind_addr = "inproc://#1"
-- local connect_addr = bind_addr

local loops = 10000

ffi.cdef( "int fork()" )

local fid = ffi.C.fork()
local context = zmq.zmq_init( 1 )

if fid ~= 0 then
--   print( 'parent, fid=', fid )
   local responder = zmq.zmq_socket( context, zmq.ZMQ_REP )
   zmq.zmq_bind( responder, bind_addr )
   
   local message = ffi.new( "zmq_msg_t" )
   
   for i=1,loops do
      zmq.zmq_msg_init( message )
--      print( "Received Hello\n" )
      zmq.zmq_recvmsg( responder, message, 0 )
      zmq.zmq_msg_close( message )
      
  --    zmq.zmq_sleep(1)
      
      zmq.zmq_msg_init_size( message, 5 )
      ffi.copy( zmq.zmq_msg_data( message ), "Hello", 5 )
      zmq.zmq_sendmsg( responder, message, 0 )
      zmq.zmq_msg_close( message )
   end
elseif fid == 0 then
--   print('child')
   local requester = zmq.zmq_socket( context, zmq.ZMQ_REQ )
   zmq.zmq_connect( requester, connect_addr )
   
   local message = ffi.new( "zmq_msg_t" )
   
   for i=1,loops do
--      print( 'C', i )
      zmq.zmq_msg_init_size( message, 5 )
      ffi.copy( zmq.zmq_msg_data( message ), "World", 5 )
      zmq.zmq_sendmsg( requester, message, 0 )
      zmq.zmq_msg_close( message )
      
      zmq.zmq_msg_init( message )
      zmq.zmq_recvmsg( requester, message, 0 )
      zmq.zmq_msg_close( message )
   end
end

--print( 'exit', fid )



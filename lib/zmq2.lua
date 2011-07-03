return function( zmq )
	  zmq = zmq or require( "ffi/zmq" )
	  local ffi = require( "ffi" )
	  local check =
	     function(cond, msg)
		if cond == nil or (type(cond)=="number" and cond ~= 0) then
		   local err = zmq.zmq_errno()
		   local errmsg = ffi.string( zmq.zmq_strerror( err ) )
		   error( msg .. ": error=" .. tostring(err) .. " " .. errmsg )
		end
	     end
	  return { -- module methods
	     PAIR = zmq.ZMQ_PAIR,
	     version = 
		function()
		   local major, minor, patch = ffi.new( "int[1]" ), ffi.new( "int[1]" ), ffi.new( "int[1]" )
		   zmq.zmq_version( major, minor, patch )
		   return major[0], minor[0], patch[0]
		end,
	     errno =
		function()
		   return zmq.zmq_errno()
		end,
	     strerror =
		function( error )
		   return ffi.string( zmq.zmq_strerror( error ) )
		end,
	     init = 
		function( io_threads )
		   local t = { -- context methods
		      context =
			 zmq.zmq_init( io_threads or 1 ),
		      socket = 
			 function( self, type )
			    local t = { -- socket methods,
			       socket =
				  zmq.zmq_socket( self.context, type ),
			       bind =
				  function( self, endpoint )
				     local r = zmq.zmq_bind( self.socket, endpoint )
				     check( r, "zmq.bind" )
				  end,
			       close =
				  function( self )
				     zmq.zmq_close( self.socket )
				  end,
			       connect =
				  function( self, endpoint )
				     return zmq.zmq_connect( self.socket, endpoint )
				  end,
			       getsockopt =
				  function( self, option_name, option_value, option_len )
				     error( "NYI" )
				  end,
			       recv =
				  function( self, len, flags )
				     local buf = ffi.new( "char[?]", len )
				     local r = zmq.zmq_recv( self.socket, buf, len, flags )
				     check( r, "zmq_recv" )
				     return ffi.string( buf, len )
				  end,
			       send =
				  function( self, msg, flags )
				     local r = zmq.zmq_send( self.socket, msg, #msg, flags )
				     check( r, "zmq_send" )
				  end,
			       setsockopt =
				  function( self, option_name, option_value, option_len )
				     error( "NYI" )
				  end,
			    }
			    check( t.socket, "zmq_socket" )
			    return t
			 end,
		      term = 
			 function( self )
			    return zmq.zmq_term( self.context )
			 end
		   }
		   check( t.context, "zmq_init" )
		   return t
		end,
	     msg_init =
		function()
		   return {
		      close = 
			 function()
			 end,
		      copy =
			 function()
			 end,
		      data =
			 function()
			 end,
		      move =
			 function()
			 end,
		      size =
			 function()
			 end,
		   }
		end,
	     poll =
		function()
		end
	  }
       end

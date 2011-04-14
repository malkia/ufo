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
		   local context = zmq.zmq_init( io_threads or 1 )
		   check( context, "zmq.init" )
		   return { -- context methods
		      socket = 
			 function( type )
			    local socket = zmq.zmq_socket( context, type )
			    -- TODO - checks
			    return { -- socket methods
			       bind =
				  function( endpoint )
				     local r = zmq.zmq_bind( socket, endpoint )
				     check( r, "zmq.bind" )
				  end,
			       close =
				  function()
				     zmq.zmq_close( socket )
				  end,
			       connect =
				  function( endpoint )
				     return zmq.zmq_connect( socket, endpoint )
				  end,
			       getsockopt =
				  function( option_name, option_value, option_len )
				     error( "NYI" )
				  end,
			       recv =
				  function( len, flags )
				     local buf = ffi.new( "char[?]", len )
				     zmq.zmq_recv( socket, buf, len, flags )
				     return ffi.string( buf, len )
				  end,
			       send =
				  function( msg, flags )
				     zmq.zmq_send( socket, msg, #msg, flags )
				  end,
			       setsockopt =
				  function( option_name, option_value, option_len )
				     error( "NYI" )
				  end,
			    }
			 end,
		      term = 
			 function()
			    return zmq.zmq_term( context )
			 end
		   }
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

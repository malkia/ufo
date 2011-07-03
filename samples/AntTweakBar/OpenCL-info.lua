#!/usr/bin/env luajit 

local ffi  = require( "ffi" )
local cl   = require( "ffi/OpenCL" )
local clx  = require( "lib/OpenCL" )( cl )
local gl   = require( "ffi/OpenGL" )
local glfw = require( "ffi/glfw" )
local tw   = require( "ffi/AntTweakBar" )

local function dump( value )
  if type(value) ~= "table" then
     return tostring(value)
  end
  local s, c = "{ ", ""
  for k,v in pairs(value) do
    s = s .. c .. dump(k) .. " = " .. dump(v)
    c = ", "
  end
  return s .. " }"
end

local function main()
   assert( glfw.glfwInit(), "Failed to initialize GLFW" )

   local desktop_mode = ffi.new( "GLFWvidmode[1]" )
   glfw.glfwGetDesktopMode( desktop_mode )
   local desktop_width, desktop_height = desktop_mode[0].width, desktop_mode[0].height
   local width, height = desktop_width * 0.8, desktop_height * 0.8

   local window = glfw.glfwOpenWindow( width, height, glfw.GLFW_WINDOWED,
				       "LuaJIT FFI demo - OpenGL, glu, glfw and AntTweakBar", nil )
   assert( window, "Failed to open GLFW window")
   glfw.glfwSetWindowPos( window, (desktop_width - width)/2, (desktop_height - height)/2 )
   glfw.glfwSwapInterval( 1 ) -- 60fps
 
   local mouse = { 
      x = 0, y = 0, wheel = 0,
      buttons = { {}, {}, {} },
   }

   -- We have to keep references to the FFI allocated data
   local bars = {}
   local strings = {}
   
   tw.TwInit( tw.TW_OPENGL, nil )
   for platform_index, platform in pairs( clx.GetPlatforms() ) 
   do
      for device_index, device in pairs( clx.GetDevices( platform.id ) )
      do
	 local title = "Platform " .. tostring(platform_index)..
	               ", Device " .. tostring(device_index) .. ": ".. device.name
         local bar = tw.TwNewBar( title )
	 local keys = {}
	 for key, _ in pairs( device ) do
	    keys[ #keys + 1 ] = key
	 end
	 table.sort( keys )
	 for _, key in pairs( keys ) do
	    local s
	    if type(device[key]) == "table" then
	       s = table.concat( device[key], "," )
	       s = ffi.new( "char[?]", #s + 1, s )
	       -- typename has to be something unique, guid would be more appropriate here for example
	       local typename = tostring(platform.id) .. "@" .. tostring(device.id) .. "@" .. key
	       local type = tw.TwDefineEnumFromString( typename, s )
	       local val = ffi.new( "int[1]" )
	       strings[ #strings + 1 ] = val
	       tw.TwAddVarRW( bar, key, type, val, nil )
	    else
	       s = dump( device[ key] )
	       local len = #s + 1 -- 0 character included
	       s = ffi.new( "char[?]", len, s )
	       tw.TwAddVarRO( bar, key, tw.TW_TYPE_CSSTRING_LEN0 + len, s, nil )
	    end
	    strings[ #strings + 1 ] = s
	 end
         bars[ #bars + 1 ] = bar
      end
   end
   
   width, height = nil, nil
   
   local int1, int2 = ffi.new( "int[1]" ), ffi.new( "int[1]" )
   while glfw.glfwIsWindow(window) 
   and   glfw.glfwGetKey(window, glfw.GLFW_KEY_ESCAPE) ~= glfw.GLFW_PRESS 
   do
      glfw.glfwGetWindowSize(window, int1, int2)
      if width ~= int1[0] or height ~= int2[0] then
         width, height = int1[0], int2[0]
	 tw.TwWindowSize( width, height )
	 for i=1,#bars do
	   local bar = bars[i]
	   local bar_x, bar_y = (i - 1) * (width - 64) / #bars + 32, 16
	   local bar_pos = ffi.new( "int32_t[2]", bar_x, bar_y )
           local bar_width, bar_height = (width - 64) / #bars - 6, height - 32
           local bar_size = ffi.new( "int32_t[2]", bar_width, bar_height )
	   tw.TwSetParam(bar, nil, "position", tw.TW_PARAM_INT32, 2, bar_pos )
	   tw.TwSetParam(bar, nil, "size",     tw.TW_PARAM_INT32, 2, bar_size )
	   local fit_width = ffi.new( "int32_t[1]", bar_width / 2 )
	   tw.TwSetParam(bar, nil, "valueswidth", tw.TW_PARAM_INT32, 1, fit_width )
	 end
      end
      
      gl.glClear(gl.GL_COLOR_BUFFER_BIT)
      gl.glMatrixMode(gl.GL_PROJECTION)
      gl.glLoadIdentity()
      gl.glMatrixMode( gl.GL_MODELVIEW )
      gl.glLoadIdentity()
 
      glfw.glfwGetMousePos(window, int1, int2)
      mouse.x, mouse.y = int1[0], int2[0]

      do -- AntTweakBar
	 for i=1, #mouse.buttons do
	    local should_update = nil
	    local b = mouse.buttons[i]
	    b.new_state = glfw.glfwGetMouseButton( window, glfw.GLFW_MOUSE_BUTTON_LEFT + i - 1 )
	    if b.old_state ~= b.new_state then
	       b.old_state = b.new_state
	       b.last_time = os.clock()
	       should_update = true
	    elseif b.new_state == glfw.GLFW_PRESS then
	       should_update = (os.clock() - b.last_time > 0.25)
	    end
	    if should_update then
	       tw.TwMouseButton( b.new_state, tw.TW_MOUSE_LEFT + i - 1 )
	    end
	 end
	 glfw.glfwGetScrollOffset( window, int1, int2 )
	 mouse.wheel = mouse.wheel + int2[0]
	 tw.TwMouseWheel( mouse.wheel )
	 tw.TwMouseMotion( mouse.x, mouse.y )
	 tw.TwDraw()
      end

      glfw.glfwSwapBuffers()
      glfw.glfwPollEvents()
   end

   tw.TwTerminate()
   glfw.glfwTerminate()
end

main()

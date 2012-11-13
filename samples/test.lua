#!/usr/bin/env luajit

local ffi  = require( "ffi" )
local gl   = require( "ffi/OpenGL" )
local glu  = require( "ffi/glu" )
local glfw = require( "ffi/glfw" )
local tw   = require( "ffi/AntTweakBar" )

local function main()
   local desktop_width  = 0
   local desktop_height = 0
   local width          = 640
   local height         = 480

   assert( glfw.glfwInit(), "Failed to initialize GLFW" )

   local desktop_mode = ffi.new( "GLFWvidmode[1]" )
   glfw.glfwGetDesktopMode( desktop_mode )
   desktop_width, desktop_height = desktop_mode[0].width, desktop_mode[0].height
   local window_x, window_y = ( desktop_width - width ) / 2, ( desktop_height - height ) / 2

   glfw.glfwWindowHint( glfw.GLFW_POSITION_X, (desktop_width  - width)/2  )
   glfw.glfwWindowHint( glfw.GLFW_POSITION_Y, (desktop_height - height)/2 )
   local window = glfw.glfwCreateWindow( width, height, glfw.GLFW_WINDOWED, "LuaJIT FFI demo - OpenGL, glu, glfw and AntTweakBar", nil )
   assert( window, "Failed to open GLFW window")

   glfw.glfwSwapInterval( 1 ) -- 60fps
   
   tw.TwInit( tw.TW_OPENGL, nil )
   local bar      = tw.TwNewBar( "Blah" )
   local var1data = ffi.new( "double[1]" )
   local var1     = tw.TwAddVarRW( bar, "Var1", tw.TW_TYPE_DOUBLE, var1data, nil)
   local var2data = ffi.new( "int32_t[1]" )
   local var2     = tw.TwAddVarRO( bar, "Var2", tw.TW_TYPE_INT32, var2data, nil)

   local mouse = { 
      x = 0, y = 0, wheel = 0,
      buttons = { {}, {}, {} },
   }

   ffi.cdef[[
       void* wglGetProcAddress(const char*);
       typedef GLuint (*pglCreateShader)(GLenum);
   ]]
   local glCreateShader = ffi.new( "pglCreateShader", gl.wglGetProcAddress( "glCreateShader" ) )
   print(glCreateShader(gl.GL_VERTEX_SHADER))
   print(gl.glCreateShader(gl.GL_VERTEX_SHADER))
   
   local int1, int2 = ffi.new( "int[1]" ), ffi.new( "int[1]" )
   local dbl1, dbl2 = ffi.new( "double[1]" ), ffi.new( "double[1]" )
   while not glfwGetWindowParam(window, glfw.GLFW_CLOSE_REQUESTED) 
   do
      glfw.glfwGetWindowSize(window, int1, int2)
      width, height = int1[0], int2[0]
      
      gl.glClear(gl.GL_COLOR_BUFFER_BIT)
      gl.glMatrixMode(gl.GL_PROJECTION)
      gl.glLoadIdentity()
      gl.glMatrixMode( gl.GL_MODELVIEW )
      gl.glLoadIdentity()
 
      glfw.glfwGetCursorPos(window, int1, int2)
      mouse.x, mouse.y = int1[0], int2[0]

      do -- AntTweakBar
	 for i=1, #mouse.buttons do
	    local should_signal = nil
	    local b = mouse.buttons[i]
	    b.repeat_after = b.repeat_after or 0.25
	    b.new_state = glfw.glfwGetMouseButton( window, glfw.GLFW_MOUSE_BUTTON_LEFT + i - 1 )
	    if b.old_state ~= b.new_state then
	       b.old_state = b.new_state
	       b.last_time = os.clock()
	       should_signal = true
	    elseif b.new_state == glfw.GLFW_PRESS then
	       should_signal = (os.clock() - b.last_time > b.repeat_after)
	    end
	    if should_signal then
	       tw.TwMouseButton( b.new_state, tw.TW_MOUSE_LEFT + i - 1 )
	    end
	 end
	 glfw.glfwGetScrollOffset( window, dbl1, dbl2 )
	 mouse.wheel = mouse.wheel + dbl2[0]
	 var2data[0] = mouse.wheel
	 tw.TwMouseWheel(mouse.wheel)
	 tw.TwMouseMotion(mouse.x, mouse.y)
	 tw.TwWindowSize(width, height)
	 tw.TwDraw()
      end

      glfw.glfwSwapBuffers()
      glfw.glfwPollEvents()
   end

   glfw.glfwTerminate()
end

--main()

ffi.cdef[[
    void glBegin1();
]]

local ffi = require( "ffi" )
local gl = require( "ffi/OpenGL" )

print()

-- Print error messages
print('glBegin',  pcall(function()return ffi.cast( "void*", gl.glBegin  )end))
print('glBegin1', pcall(function()return ffi.cast( "void*", gl.glBegin1 )end))
print('glBegin2', pcall(function()return ffi.cast( "void*", gl.glBegin2 )end))

-- Don't print anything
print('glBegin',  xpcall(function()return ffi.cast( "void*", gl.glBegin  )end,function()end))
print('glBegin1', xpcall(function()return ffi.cast( "void*", gl.glBegin1 )end,function()end))
print('glBegin2', xpcall(function()return ffi.cast( "void*", gl.glBegin2 )end,function()end))



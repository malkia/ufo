local ffi, bit = require( "ffi" ), require( "bit" )
local gl, glfw = require( "OpenGL" ), require( "glfw" )
local tw = require( "AntTweakBar" )

local font = require( "x-font" )
local font = ffi.new( "uint8_t[?]", #font, font )

local random = math.random
local rshift, band = bit.rshift, bit.band
local cos, sin = math.cos, math.sin

local desktop_width = 0
local desktop_height = 0
local width = 640
local height = 480

local vbo_capacity = width*height*2
local vbo_index = 0
local vbo = ffi.new( "float[?]", vbo_capacity )

local vertexShaderSource = [[
      void main()
      {
//	 gl_FrontColor = vec4(1, gl_Vertex.z/64.0, 0, 1);
ddd	 gl_TexCoord[0].x = mod(gl_Vertex.z/16.0, 16.0);
//	 gl_TexCoord[0].y = fract(gl_Vertex.z/16.0);
//	 gl_Position = gl_ModelViewProjectionMatrix * vec4(gl_Vertex.x, gl_Vertex.y, 0, 1);
      }
]]

local glErrorTable = {
   [gl.GL_NO_ERROR] = "No error has been recorded. The value of this symbolic constant is guaranteed to be 0.",
   [gl.GL_INVALID_ENUM] = "An unacceptable value is specified for an enumerated argument. The offending command is ignored and has no other side effect than to set the error flag.",
   [gl.GL_INVALID_VALUE] = "A numeric argument is out of range. The offending command is ignored and has no other side effect than to set the error flag.",
   [gl.GL_INVALID_OPERATION] = "The specified operation is not allowed in the current state. The offending command is ignored and has no other side effect than to set the error flag.",
   [gl.GL_STACK_OVERFLOW] = "This command would cause a stack overflow. The offending command is ignored and has no other side effect than to set the error flag.",
   [gl.GL_STACK_UNDERFLOW] = "This command would cause a stack underflow. The offending command is ignored and has no other side effect than to set the error flag.",
   [gl.GL_OUT_OF_MEMORY] = "There is not enough memory left to execute the command. The state of the GL is undefined, except for the state of the error flags, after this error is recorded.",
   [gl.GL_TABLE_TOO_LARGE] = "The specified table exceeds the implementation's maximum supported table size. The offending command is ignored and has no other side effect than to set the error flag."
}

local function glGetError()
   local error = gl.glGetError()
   if error == gl.GL_NO_ERROR then
      return true
   else
      local result = error
      while error ~= gl.GL_NO_ERROR do
	 error = gl.glGetError()
      end
      print( result, glErrorTable[result] )
      return false, result, glErrorTable[result]
   end
end

local function CHK(f)
   assert(glGetError())
   return f
end

function glCreateShader( gl_shader_type, source )
   local chk = gl.glGetError
   assert( gl_shader_type == gl.GL_VERTEX_SHADER or gl_shader_type == gl.GL_FRAGMENT_SHADER )
   local shader = CHK(gl.glCreateShader( gl_shader_type ))
   if shader == 0 then
      return nil
   end
   local text = ffi.new( "GLchar[?]", #source+1, source )
   local text_ptr = ffi.new( "const GLchar*[1]", text )
   local int = ffi.new( "GLint[1]", #source )
   CHK(gl.glShaderSource( shader, 1, text_ptr, int ))
   CHK(gl.glCompileShader( shader ))
   CHK(gl.glGetShaderiv( shader, gl.GL_INFO_LOG_LENGTH, int ))
   local info_log = ffi.new( "GLchar[?]", int[0] )
   CHK(gl.glGetShaderInfoLog( shader, int[0], int, info_log ))
   info_log = ffi.string( info_log, int[0] )
   CHK(gl.glGetShaderiv( shader, gl.GL_COMPILE_STATUS, int ))
   if status ~= gl.GL_TRUE then
      return nil, status, info_log
   end
   assert(gl.glIsShader(shader) == gl.GL_TRUE)
   return shader
end

function glCreateVertexShader(source)
   return gfxCreateShader( gl.GL_VERTEX_SHADER, source )
end

function glCreatePixelShader(source)
   return glCreateShader( gl.GL_FRAGMENT_SHADER, source )
end

local function draw_char(x,y,c)
   c = c * 8
   for i=0,7 do
      local b = font[c + i]
      for j=0,7 do
	 local m = band(rshift(b, 7-j), 1)
	 if m == 1 then
	    vbo[ vbo_index + 0 ] = x + j + 4
	    vbo[ vbo_index + 1 ] = y + i + 4
	    vbo_index = vbo_index + 2
	 end
      end
   end
end

local function draw_string(x,y,s,draw_char_function)
   for i=1,#s do
      local c = s:byte(i)
      if c == 10 or c == 13 then
	 y = y + 8 
	 if y > height then
	    break
	 end
	 x = 0
      else
	 draw_char(x,y,c)
	 x = x + 8
      end
   end
end

local function read_file(n)
   local f = io.input(n)
   return f:read("*all")
end

local text = read_file("x-font.lua")

local fullscreen = false

local function main()
   local frame = 0
   local c = 0
   glfw.glfwOpenWindowHint(glfw.GLFW_OPENGL_VERSION_MAJOR, 3);	
   glfw.glfwOpenWindowHint(glfw.GLFW_OPENGL_VERSION_MINOR, 3);
   glfw.glfwOpenWindowHint(glfw.GLFW_OPENGL_PROFILE, glfw.GLFW_OPENGL_COMPAT_PROFILE);
   assert( glfw.glfwInit() )
   local desktop_mode = ffi.new( "GLFWvidmode[1]" )
   glfw.glfwGetDesktopMode( desktop_mode )
   desktop_width, desktop_height = desktop_mode[0].width, desktop_mode[0].height
   local window_x = ( desktop_width - width ) / 2
   local window_y = ( desktop_height - height ) / 2
   glfw.glfwOpenWindowHint(glfw.GLFW_WINDOW_NO_RESIZE, 1)
   local window = glfw.glfwOpenWindow( width, height, glfw.GLFW_WINDOWED, "X", nil )

   tw.TwInit( tw.TW_OPENGL, nil )

--   local shader = glCreateShader( gl.GL_VERTEX_SHADER, vertexShaderSource )

   assert( window )
   glfw.glfwSetWindowPos(window, window_x, window_y)
   glfw.glfwEnable(window, glfw.GLFW_STICKY_KEYS)
   glfw.glfwEnable(window,glfw.GLFW_STICKY_MOUSE_BUTTONS)
   glfw.glfwSwapInterval(1);
   local ct = glfw.glfwGetTime()
   local pt = glfw.glfwGetTime()

   local bar = tw.TwNewBar( "Blah" )

   local int1, int2 = ffi.new( "int[1]" ), ffi.new( "int[1]" )

   while glfw.glfwIsWindow(window) 
   and   glfw.glfwGetKey(window, glfw.GLFW_KEY_ESCAPE) ~= glfw.GLFW_PRESS 
   do
      pt, ct = ct, glfw.glfwGetTime()
      frame = frame + 1

      glfw.glfwGetWindowSize(window, int1, int2)
      width, height = int1[0], int2[0]
      
      local mb1 = glfw.glfwGetMouseButton(window, glfw.GLFW_MOUSE_BUTTON_LEFT)
      local mb2 = glfw.glfwGetMouseButton(window, glfw.GLFW_MOUSE_BUTTON_MIDDLE)
      local mb3 = glfw.glfwGetMouseButton(window, glfw.GLFW_MOUSE_BUTTON_RIGHT)
      glfw.glfwGetMousePos(window, int1, int2)
      mx, my = int1[0], int2[0]

      tw.TwMouseButton(mb1, tw.TW_MOUSE_LEFT)
      tw.TwMouseButton(mb2, tw.TW_MOUSE_MIDDLE)
      tw.TwMouseButton(mb3, tw.TW_MOUSE_RIGHT)
      tw.TwMouseMotion(mx, my)
      tw.TwWindowSize(width, height)
      
      gl.glClear(gl.GL_COLOR_BUFFER_BIT);

      gl.glMatrixMode(gl.GL_PROJECTION);
      gl.glLoadIdentity();
      gl.glOrtho(0, width, height, 0, 0, 1)
      
      gl.glMatrixMode( gl.GL_MODELVIEW );
      gl.glLoadIdentity();
 
      draw_string( 0, 0, tostring(ct-pt) )

      gl.glEnableClientState(gl.GL_VERTEX_ARRAY);
      gl.glVertexPointer(2, gl.GL_FLOAT, 0, vbo);
      gl.glDrawArrays(gl.GL_POINTS, 0, vbo_index);
      gl.glDisableClientState(gl.GL_VERTEX_ARRAY);
      vbo_index = 0
      
      tw.TwDraw()

      glfw.glfwSwapBuffers();
      glfw.glfwPollEvents();
   end
   glfw.glfwTerminate();
end

main()

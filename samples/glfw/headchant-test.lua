local ffi = require( "ffi" )
local gl = require( "ffi/OpenGL" ) -- This is required on Windows to work with REGAL
local glfw = require( "ffi/glfw" )
local cr = require ( "ffi/cairo" )
assert( glfw.glfwInit() )

local function detect( window)
   local t, f = {}, function() end
   for _, id in ipairs({
	"Win32Window", "WGLContext",
	"CocoaWindow", "NSGLContext",
	"X11Display",  "X11Window",  "GLXContext"
      })
   do
      xpcall( function() t[id] = glfw[ "glfwGet" .. id ]( window ) end, f)
   end
   return t
end

local window = assert( ffi.gc(
   glfw.glfwCreateWindow(320,200,glfw.GLFW_WINDOWED, "GLFW Window System Detection", nil),
   glfw.glfwDestroyWindow
))

glfw.glfwSetInputMode( window, glfw.GLFW_STICKY_KEYS, 1 )
glfw.glfwMakeContextCurrent( window );
glfw.glfwSwapInterval( 0 ) -- 0=nosync 1=60fps

glfw.glfwSetCharCallback(
   window, -- newer glfw api requires window handle!
   ffi.cast(
      "GLFWcharfun", 
      function(w,c) 
	 print(w)
	 print(c)
      end
))

while glfw.glfwGetKey( window, glfw.GLFW_KEY_ESCAPE ) ~= glfw.GLFW_PRESS do
    glfw.glfwSwapBuffers(window)
    glfw.glfwPollEvents() 
 end

print()
print('GLFW Window', window)
local t = detect(window)
for k,v in pairs(t) do
   print(k,v)
end

local device

if t.Win32Window ~= nil and t.WGLContext ~= nil then
   -- Windows
--   device = cr.cairo_wgl_device_create( t.WGLContext );
end

print( device )

window = nil
collectgarbage()

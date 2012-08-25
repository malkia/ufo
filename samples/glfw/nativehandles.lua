local ffi = require( "ffi" )
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

local win = assert( ffi.gc(
   glfw.glfwCreateWindow(320,200,glfw.GLFW_WINDOWED, "GLFW Window System Detection", nil),
   glfw.glfwDestroyWindow
))

print()
print('GLFW Window', win)
local t = detect(win)
for k,v in pairs(t) do
   print(k,v)
end

local device

if t.Win32Window ~= nil and t.WGLContext ~= nil then
   -- Windows
--   device = cr.cairo_wgl_device_create( t.WGLContext );
end

print( device )

win = nil
collectgarbage()

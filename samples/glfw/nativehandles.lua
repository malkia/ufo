local ffi = require( "ffi" )
local glfw = require( "ffi/glfw" )
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
   glfw.glfwOpenWindow(320,200,glfw.GLFW_WINDOWED, "GLFW Window System Detection", nil),
   glfw.glfwCloseWindow
))

print()
print('GLFW Window', win)
local t = detect(win)
for k,v in pairs(t) do
   print(k,v)
end

win = nil
collectgarbage()

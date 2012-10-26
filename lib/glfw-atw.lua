return function(glfw, tw, ffi)
   local glfw = glfw or require( "ffi/glfw" )
   local atw = atw or require( "ffi/AntTweakBar" )
   local ffi = ffi or require( "ffi" )
   glfw.glfwSetKeyCallback(
      ffi.cast("GLFWkeyfun",         function(w,k,a)atw.TwEventKeyGLFW(k,a)end))
   glfw.glfwSetCharCallback(
      ffi.cast("GLFWcharfun",        function(w,c,a)atw.TwEventCharGLFW(c,glfw.GLFW_PRESS)end))
   glfw.glfwSetMouseButtonCallback(
      ffi.cast("GLFWmousebuttonfun", function(w,b,a)atw.TwEventMouseButtonGLFW(b,a)end))
   glfw.glfwSetCursorPosCallback(
      ffi.cast("GLFWcursorposfun",   function(w,x,y)atw.TwEventMousePosGLFW(x,y)end))
   glfw.glfwSetScrollCallback(
      ffi.cast("GLFWscrollfun",      function(w,x,y)atw.TwEventMouseWheelGLFW(y)end))
end

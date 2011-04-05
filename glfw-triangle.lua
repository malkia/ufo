local ffi = require( "ffi" )
local cl = require( "OpenCL" )
local gl = require( "OpenGL" )
local glu = require( "glu" )
local glfw = require( "glfw" )

local function main()
   assert( glfw.glfwInit() )
   local window = glfw.glfwOpenWindow( 640, 480, glfw.GLFW_WINDOWED, "Spinning Triangle", nil)
   assert( window )
   glfw.glfwEnable(window, glfw.GLFW_STICKY_KEYS);
   glfw.glfwSwapInterval(1);
   while glfw.glfwIsWindow(window) and glfw.glfwGetKey(window, glfw.GLFW_KEY_ESCAPE) ~= glfw.GLFW_PRESS 
   do
      local double t = glfw.glfwGetTime()

      local x = ffi.new( "int[1]" )
      glfw.glfwGetMousePos(window, x, nil)
      x = x[0]

      local width, height = ffi.new( "int[1]" ), ffi.new( "int[1]" )
      glfw.glfwGetWindowSize(window, width, height);
      width, height = width[0], height[0]
      if height < 1 then
	 height = 1
      end

      gl.glViewport(0, 0, width, height);
      gl.glClearColor(0, 0, 0, 0);
      gl.glClear(gl.GL_COLOR_BUFFER_BIT);

      gl.glMatrixMode(gl.GL_PROJECTION);
      gl.glLoadIdentity();
      glu.gluPerspective(65, width / height, 1, 100);
      
      gl.glMatrixMode( gl.GL_MODELVIEW );
      gl.glLoadIdentity();
      glu.gluLookAt(
	 0,  1, 0,   -- Eye-position
	 0, 20, 0,   -- View-point
	 0,  0, 1    -- Up Vector
      );
      
      gl.glTranslatef(0, 14, 0);
      gl.glRotatef(0.3 * x + t * 100, 0, 0, 1);
      
      gl.glBegin(gl.GL_TRIANGLES);
      gl.glColor3f(1, 0, 0);
      gl.glVertex3f(-5, 0, -4);
      gl.glColor3f(0, 1, 0);
      gl.glVertex3f(5, 0, -4);
      gl.glColor3f(0, 0, 1);
      gl.glVertex3f(0, 0, 6);
      gl.glEnd();
      
      glfw.glfwSwapBuffers();
      glfw.glfwPollEvents();
   end
   glfw.glfwTerminate();
end

main()

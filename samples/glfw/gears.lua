-- 3-D gear wheels.  This program is in the public domain.
--
-- Command line options:
--    -info      print GL implementation information
--    -exit      automatically exit after 30 seconds
--
--
-- Brian Paul
--
--
-- Marcus Geelnard:
--   - Conversion to GLFW
--   - Time based rendering (frame rate independent)
--   - Slightly modified camera that should work better for stereo viewing
--
--
-- Camilla Berglund:
--   - Removed FPS counter (this is not a benchmark)
--   - Added a few comments
--   - Enabled vsync

local ffi  = require( "ffi" )
local gl   = require( "ffi/OpenGL" )
local glfw = require( "ffi/glfw" )
local pi   = math.pi

local bor, sin, cos, sqrt, pi = bit.bor, math.sin, math.cos, math.sqrt, math.pi

--  Draw a gear wheel.  You'll probably want to call this function when
--  building a display list since we do a lot of trig here.
--
--  Input:  inner_radius - radius of hole at center
--          outer_radius - radius at center of teeth
--          width - width of gear teeth - number of teeth
--          tooth_depth - depth of tooth
local function gear( inner_radius, outer_radius, width, teeth, tooth_depth )
   local r0 = inner_radius;
   local r1 = outer_radius - tooth_depth / 2
   local r2 = outer_radius + tooth_depth / 2
   local da = 2 * pi / teeth / 4

   gl.glShadeModel( gl.GL_FLAT )
   gl.glNormal3d( 0, 0, 1 )

   gl.glBegin( gl.GL_QUAD_STRIP )
   for i = 0, teeth do
      local angle = i * 2 * pi / teeth
      gl.glVertex3d( r0*cos(angle), r0*sin(angle), width * 0.5 )
      gl.glVertex3d( r1*cos(angle), r1*sin(angle), width * 0.5 )
      if i < teeth then
	 gl.glVertex3d( r0*cos(angle),        r0*sin(angle), width * 0.5 )
	 gl.glVertex3d( r1*cos(angle + 3*da), r1*sin(angle + 3*da), width * 0.5)
      end
   end
   gl.glEnd()

   gl.glBegin( gl.GL_QUADS )
   local da = 2 * pi / teeth / 4
   for i = 0, teeth - 1 do
      local angle = i * 2 * pi / teeth
      gl.glVertex3d( r1*cos(angle),        r1*sin(angle),        width * 0.5 )
      gl.glVertex3d( r2*cos(angle + da),   r2*sin(angle + da),   width * 0.5 )
      gl.glVertex3d( r2*cos(angle + 2*da), r2*sin(angle + 2*da), width * 0.5 )
      gl.glVertex3d( r1*cos(angle + 3*da), r1*sin(angle + 3*da), width * 0.5 )
   end
   gl.glEnd()

   gl.glNormal3d( 0, 0, -1 )

   gl.glBegin( gl.GL_QUAD_STRIP )
   for i = 0, teeth do
      local angle = i * 2 * pi / teeth
      gl.glVertex3d( r1*cos(angle), r1*sin(angle), -width * 0.5 )
      gl.glVertex3d( r0*cos(angle), r0*sin(angle), -width * 0.5 )
      if i < teeth then
	 gl.glVertex3d( r1*cos(angle+ 3*da), r1*sin(angle+ 3*da), -width * 0.5)
	 gl.glVertex3d( r0*cos(angle),       r0*sin(angle),       -width * 0.5)
      end
   end
   gl.glEnd()
   
   gl.glBegin( gl.GL_QUADS )
   local da = 2 * pi / teeth / 4
   for i = 0, teeth - 1 do
      local angle = i * 2 * pi / teeth
      gl.glVertex3d( r1*cos(angle + 3*da), r1*sin(angle + 3*da), -width * 0.5 )
      gl.glVertex3d( r2*cos(angle + 2*da), r2*sin(angle + 2*da), -width * 0.5 )
      gl.glVertex3d( r2*cos(angle +   da), r2*sin(angle +   da), -width * 0.5 )
      gl.glVertex3d( r1*cos(angle),        r1*sin(angle),        -width * 0.5 ) 
   end
   gl.glEnd()
   
   gl.glBegin( gl.GL_QUAD_STRIP )
   for i = 0, teeth - 1 do
      local angle = i * 2 * pi / teeth
      gl.glVertex3d( r1*cos(angle), r1*sin(angle),  width * 0.5 )
      gl.glVertex3d( r1*cos(angle), r1*sin(angle), -width * 0.5 )
      local u = r2*cos( angle + da ) - r1*cos( angle )
      local v = r2*sin( angle + da ) - r1*sin( angle )
      local len = sqrt( u * u + v * v )
      u = u / len;
      v = v / len;
      gl.glNormal3d( v, -u, 0 )
      gl.glVertex3d( r2*cos(angle + da), r2*sin(angle + da),  width * 0.5 )
      gl.glVertex3d( r2*cos(angle + da), r2*sin(angle + da), -width * 0.5 )
      gl.glNormal3d( cos(angle), sin(angle), 0 )
      gl.glVertex3d( r2*cos(angle + 2*da), r2*sin(angle + 2*da),  width * 0.5 )
      gl.glVertex3d( r2*cos(angle + 2*da), r2*sin(angle + 2*da), -width * 0.5 )
      u = r1 * cos(angle + 3 * da) - r2*cos(angle + 2 * da)
      v = r1 * sin(angle + 3 * da) - r2*sin(angle + 2 * da)
      gl.glNormal3d( v, -u, 0 )
      gl.glVertex3d( r1*cos(angle + 3*da), r1*sin(angle + 3*da),  width * 0.5 )
      gl.glVertex3d( r1*cos(angle + 3*da), r1*sin(angle + 3*da), -width * 0.5 )
      gl.glNormal3d(    cos(angle),           sin(angle),         0 )
   end

   gl.glVertex3d( r1*cos(0), r1*sin(0),  width * 0.5 )
   gl.glVertex3d( r1*cos(0), r1*sin(0), -width * 0.5 )
   gl.glEnd();
   gl.glShadeModel( gl.GL_SMOOTH )

   gl.glBegin( gl.GL_QUAD_STRIP )
   for i = 0, teeth do
      local angle = i * 2 * pi / teeth
      gl.glNormal3d( -cos(angle), -sin(angle), 0 )
      gl.glVertex3d( r0*cos(angle), r0*sin(angle), -width * 0.5 )
      gl.glVertex3d( r0*cos(angle), r0*sin(angle),  width * 0.5 )
   end
   gl.glEnd()
end

local view_rotx, view_roty, view_rotz = 20, 30, 0
local gear1, gear2, gear3 = 0, 0, 0
local angle = 0

local function draw()
   gl.glClear( bor( gl.GL_COLOR_BUFFER_BIT, gl.GL_DEPTH_BUFFER_BIT ) )
   gl.glPushMatrix()
   do
      gl.glRotated( view_rotx, 1, 0, 0 )
      gl.glRotated( view_roty, 0, 1, 0 )
      gl.glRotated( view_rotz, 0, 0, 1 )
      
      gl.glPushMatrix()
      do
	 gl.glTranslatef( -3, -2, 0 )
	 gl.glRotated( angle, 0,  0, 1 )
	 gl.glCallList( gear1 )
      end
      gl.glPopMatrix()

      gl.glPushMatrix();
      do
	 gl.glTranslated( 3.1, -2, 0 )
	 gl.glRotated( -2 * angle - 9, 0, 0, 1 )
	 gl.glCallList( gear2 )
      end
      gl.glPopMatrix()

      gl.glPushMatrix();
      do
	 gl.glTranslated( -3.1, 4.2, 0 )
	 gl.glRotated( -2 * angle - 25, 0, 0, 1 )
	 gl.glCallList( gear3 )
      end
      gl.glPopMatrix()
   end
   gl.glPopMatrix()
end

local function animate()
   angle = 100 * glfw.glfwGetTime()
end

local function reshape( window, width, height )
   local h     = height / width
   local znear = 5
   local zfar  = 30
   local xmax  = znear * 0.5
   gl.glViewport( 0, 0, width, height )
   gl.glMatrixMode( gl.GL_PROJECTION )
   gl.glLoadIdentity()
   gl.glFrustum( -xmax, xmax, -xmax*h, xmax*h, znear, zfar )
   gl.glMatrixMode( gl.GL_MODELVIEW )
   gl.glLoadIdentity()
   gl.glTranslatef( 0, 0, -20 );
end

local function init()
   local pos   = ffi.new( "float[4]", 5, 5, 10, 0 )
   local red   = ffi.new( "float[4]", 0.8, 0.1, 0, 1 )
   local green = ffi.new( "float[4]", 0, 0.8, 0.2, 1 )
   local blue  = ffi.new( "float[4]", 0.2, 0.2, 1, 1 )

   gl.glLightfv( gl.GL_LIGHT0, gl.GL_POSITION, pos);
   gl.glEnable(  gl.GL_CULL_FACE  )
   gl.glEnable(  gl.GL_LIGHTING   )
   gl.glEnable(  gl.GL_LIGHT0     )
   gl.glEnable(  gl.GL_DEPTH_TEST )

   gear1 = gl.glGenLists(1)
   gl.glNewList( gear1, gl.GL_COMPILE )
   gl.glMaterialfv( gl.GL_FRONT, gl.GL_AMBIENT_AND_DIFFUSE, red )
   gear( 1, 4, 1, 20, 0.7 )
   gl.glEndList()
   
   gear2 = gl.glGenLists(1)
   gl.glNewList( gear2, gl.GL_COMPILE )
   gl.glMaterialfv( gl.GL_FRONT, gl.GL_AMBIENT_AND_DIFFUSE, green )
   gear( 0.5, 2, 2, 10, 0.7 )
   gl.glEndList()
   
   gear3 = gl.glGenLists(1)
   gl.glNewList( gear3, gl.GL_COMPILE )
   gl.glMaterialfv( gl.GL_FRONT, gl.GL_AMBIENT_AND_DIFFUSE, blue )
   gear( 1.3, 2, 0.5, 10, 0.7 )
   gl.glEndList()
   
   gl.glEnable( gl.GL_NORMALIZE )
end

local function pressed( window, key )
   return glfw.glfwGetKey( window, glfw["GLFW_KEY_" .. key:upper()] ) == glfw.GLFW_PRESS
end

local function holds( window, key )
   return glfw.glfwGetKey( window, glfw["GLFW_KEY_" .. key:upper()] ) == glfw.GLFW_PRESS
end

local function main()
   assert( glfw.glfwInit() )
   local window = assert(
      ffi.gc( glfw.glfwCreateWindow( 1024, 768, glfw.GLFW_WINDOWED, "Gears", nil ),
	      glfw.glfwDestroyWindow))
   glfw.glfwMakeContextCurrent(window)

   init()

   local sw, sh = ffi.new( "int[1]" ), ffi.new( "int[1]" )
   while glfw.glfwGetKey( window, glfw.GLFW_KEY_ESCAPE ) ~= glfw.GLFW_PRESS
   do
      glfw.glfwGetWindowSize(window, sw, sh)
      local sw, sh = sw[0], sh[0]
      reshape( window, sw, sh )
      draw();
      animate();
      glfw.glfwSwapBuffers(window);
      glfw.glfwPollEvents();
      if pressed( window, "Z" ) then
	 if holds( window, "LEFT_SHIFT" ) then
	    view_rotz = view_rotz - 5
	 else
	    view_rotz = view_rotz + 5
	 end
      elseif pressed( window, "ESCAPE" )then
	 break
      elseif pressed( window, "UP" ) then
	 view_rotx = view_rotx + 5
      elseif pressed( window, "DOWN" ) then
	 view_rotx = view_rotx - 5
      elseif pressed( window, "LEFT" ) then
	 view_roty = view_roty + 5
      elseif pressed( window, "RIGHT" ) then
	 view_roty = view_roty - 5
      end
   end
   
   glfw.glfwTerminate();
end    

main()



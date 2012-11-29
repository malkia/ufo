local ffi  = require( "ffi" )
local gl   = require( "ffi/OpenGL" )
local glu  = require( "ffi/glu" )
local glfw = require( "ffi/glfw" )
local tw   = require( "ffi/AntTweakBar" )

local function DrawModel( wireframe )
   local ON, OFF = gl.glEnable, gl.glDisable

   ON( gl.GL_BLEND )
   ON( gl.GL_DEPTH_TEST )
   ON( gl.GL_LIGHT0 )
   ON( gl.GL_COLOR_MATERIAL )
   ON( gl.GL_LINE_SMOOTH )

   gl.glBlendFunc(     gl.GL_SRC_ALPHA,            gl.GL_ONE_MINUS_SRC_ALPHA )
   gl.glLightModeli(   gl.GL_LIGHT_MODEL_TWO_SIDE, 1 )
   gl.glColorMaterial( gl.GL_FRONT_AND_BACK,       gl.GL_DIFFUSE )
   gl.glLineWidth(     3 )
    
   local num_pass
   if wireframe then
      OFF( gl.GL_CULL_FACE )
      OFF( gl.GL_LIGHTING )
      gl.glPolygonMode( gl.GL_FRONT_AND_BACK, gl.GL_LINE) 
      num_pass = 1
   else
      ON( gl.GL_CULL_FACE )
      ON( gl.GL_LIGHTING )
      gl.glPolygonMode( gl.GL_FRONT_AND_BACK, gl.GL_FILL )
      num_pass = 2
   end

   local N, V = gl.glNormal3f, gl.glVertex3f
   
   gl.glCullFace( gl.GL_FRONT )
   for pass=1, num_pass do
      
      gl.glBegin(gl.GL_QUADS)
      N( 0, 0,-1) V(0,0,0) V(0,1,0) V(1,1,0) V(1,0,0) -- front face
      N( 0, 0, 1) V(0,0,1) V(1,0,1) V(1,1,1) V(0,1,1) -- back face
      N(-1, 0, 0) V(0,0,0) V(0,0,1) V(0,1,1) V(0,1,0) -- left face
      N( 1, 0, 0) V(1,0,0) V(1,1,0) V(1,1,1) V(1,0,1) -- right face
      N( 0,-1, 0) V(0,0,0) V(1,0,0) V(1,0,1) V(0,0,1) -- bottom face
      N( 0, 1, 0) V(0,1,0) V(0,1,1) V(1,1,1) V(1,1,0) -- top face
      gl.glEnd()
      
      gl.glCullFace( gl.GL_BACK )
   end
end

local function main()
   assert( glfw.glfwInit(), "Failed to initialize GLFW" )
   assert( tw.TwInit(tw.TW_OPENGL, nil), "Failed to initialize AntTweakBar" )

   local desktop_mode = ffi.new( "GLFWvidmode[1]" )
   glfw.glfwGetDesktopMode( desktop_mode )
   local desktop_width, desktop_height = desktop_mode[0].width, desktop_mode[0].height
   local width, height = desktop_width * 0.8, desktop_height * 0.8

   glfw.glfwWindowHint( glfw.GLFW_POSITION_X, (desktop_width  - width)/2  )
   glfw.glfwWindowHint( glfw.GLFW_POSITION_Y, (desktop_height - height)/2 )
   local window = assert( glfw.glfwCreateWindow( width, height, glfw.GLFW_WINDOWED, "AntTweakBar with GLFW and OpenGL", nil ), "Failed to open GLFW window")
   require( "lib/glfw-atw" )( glfw, tw, ffi, window )

   glfw.glfwMakeContextCurrent( window )
   glfw.glfwSwapInterval(0)

   local var_speed      = ffi.new( "double[1]", 0.3 )
   local var_wire       = ffi.new( "int32_t[1]" )
   local var_time       = ffi.new( "double[1]" )
   local var_turn       = ffi.new( "double[1]" )
   local var_bg_color   = ffi.new( "float[3]", 0.1, 0.2, 0.4 )
   local var_cube_color = ffi.new( "uint8_t[4]", 255, 0, 0, 128 )

   local bar = tw.TwNewBar("TweakBar")
   local RW = tw.TwAddVarRW
   local RO = tw.TwAddVarRO

   tw.TwDefine("GLOBAL help='This example shows how to integrate AntTweakBar with GLFW and OpenGL.'")

   RW( bar, "speed",     tw.TW_TYPE_DOUBLE,  var_speed,
       "label='Rot speed' min=0 max=2 step=0.01 keyIncr=s keyDecr=S help='Rotation speed (turns/second)'" )

   RW( bar, "wire",      tw.TW_TYPE_BOOL32,  var_wire,
       "label='Wireframe mode' key=w help='Toggle wireframe display mode.'" )

   RW( bar, "time",      tw.TW_TYPE_DOUBLE,  var_time,
       "label='Time' precision=1 help='Time (in seconds).'")

   RW( bar, "turn",      tw.TW_TYPE_DOUBLE,  var_turn,
       "label='Turn' precision=1 help='Turn'")

   RW( bar, "bgColor",   tw.TW_TYPE_COLOR3F, var_bg_color,
       "label='Background color'")

   RW( bar, "cubeColor", tw.TW_TYPE_COLOR32, var_cube_color,
       "label='Cube color' alpha help='Color and transparency of the cube.'")

   width, height = nil, nil
   local int1, int2 = ffi.new( "int[1]" ), ffi.new( "int[1]" )
   while glfw.glfwGetKey( window, glfw.GLFW_KEY_ESCAPE ) ~= glfw.GLFW_PRESS do
      glfw.glfwGetWindowSize(window, int1, int2)
      if width ~= int1[0] or height ~= int2[0] then
         width, height = int1[0], int2[0]
	 gl.glViewport(0, 0, width, height)
	 gl.glMatrixMode(gl.GL_PROJECTION)
	 gl.glLoadIdentity()        
	 glu.gluPerspective(40, width/height, 1, 10)
	 glu.gluLookAt(-1,0,3, 0,0,0, 0,1,0)
	 tw.TwWindowSize(width, height)         
      end

      gl.glClearColor(var_bg_color[0], var_bg_color[1], var_bg_color[2], 1)
      gl.glClear(gl.GL_COLOR_BUFFER_BIT + gl.GL_DEPTH_BUFFER_BIT)

      local dt = os.clock() - var_time[0]
      var_time[0] = var_time[0] + dt
      var_turn[0] = var_turn[0] + var_speed[0] * dt

      gl.glMatrixMode(gl.GL_MODELVIEW)
      gl.glLoadIdentity()
      gl.glRotated(360 * var_turn[0], 0.4, 1, 0.2)
      gl.glTranslated(-0.5, -0.5, -0.5)
      
      gl.glColor4ubv( var_cube_color )
      DrawModel( var_wire[0] ~= 0 )
      tw.TwDraw()
 
      glfw.glfwSwapBuffers(window)
      glfw.glfwPollEvents()
   end

   tw.TwTerminate()
   glfw.glfwTerminate()
end

main()


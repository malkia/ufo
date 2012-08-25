local ffi  = require( "ffi" )
local glfw = require( "ffi/glfw" )
local gl   = require( "ffi/OpenGL" )
local glu  = require( "ffi/glu" )
local bit  = require( "bit" )

local BOING_DEBUG      = false
local RADIUS           = 70
local STEP_LONGITUDE   = 22.5 -- 22.5 makes 8 bands like original Boing
local STEP_LATITUDE    = 22.5
local DIST_BALL        = RADIUS * 2 + RADIUS * 0.1
local VIEW_SCENE_DIST  = DIST_BALL * 3 + 200
local GRID_SIZE        = RADIUS * 4.5 -- lenght (width) of grid
local BOUNCE_HEIGHT    = RADIUS * 2.1
local BOUNCE_WIDTH     = RADIUS * 2.1
local SHADOW_OFFSET_X  = -20
local SHADOW_OFFSET_Y  = 10
local SHADOW_OFFSET_Z  = 0
local WALL_L_OFFSET    = 0
local WALL_R_OFFSET    = 5
local ANIMATION_SPEED  = 50 -- Animation speed (50.0 mimics the original GLUT demo speed) 
local MAX_DELTA_T      = 0.02 -- Maximum allowed delta time per physics iteration 
local DRAW_BALL        = 0
local DRAW_BALL_SHADOW = 1
local deg_rot_y        = 0
local deg_rot_y_inc    = 2
local ball_x           = -RADIUS
local ball_y           = -RADIUS
local ball_x_inc       = 1
local y_ball_inc       = 2
local draw_ball_how    = DRAW_BALL
local sin, cos, PI     = math.sin, math.cos, math.pi
local atan2, random    = math.atan2, math.random

local function TruncateDeg( deg )
   if ( deg >= 360 ) then
      return deg - 360
   else
      return deg
   end
end

local function deg2rad( deg )
   return deg / 360 * (2 * PI)
end

local function sin_deg( deg )
   return sin( deg2rad( deg ) )
end

local function cos_deg( deg )
   return cos( deg2rad( deg ) )
end

local function CrossProduct( a, b, c )
   local n = {}
   
   local u1 = b.x - a.x
   local u2 = b.y - a.y
   local u3 = b.z - a.z
   
   local v1 = c.x - a.x
   local v2 = c.y - a.y
   local v3 = c.z - a.z
   
   n.x = u2 * v3 - v2 * v3
   n.y = u3 * v1 - v3 * u1
   n.z = u1 * v2 - v1 * u2
   
   return n
end

local function PerspectiveAngle( size, dist )
   local radTheta = 2 * atan2( size / 2, dist )
   local degTheta = (180 * radTheta) /  PI
   return degTheta
end

local function BounceBall(dt)
   if ball_x > BOUNCE_WIDTH/2 + WALL_R_OFFSET then
      ball_x_inc    = -0.5 - 0.75 * random()
      deg_rot_y_inc = -deg_rot_y_inc
   end
   
   if ball_x < -(BOUNCE_HEIGHT/2 + WALL_L_OFFSET) then
      ball_x_inc    =  0.5 + 0.75 * random()
      deg_rot_y_inc = -deg_rot_y_inc
   end
   
   if ball_y > BOUNCE_HEIGHT/2 then
      ball_y_inc = -0.75 - random()
   end
   
   if ball_y < -BOUNCE_HEIGHT/2*0.85 then
      ball_y_inc =  0.75 + random()
   end
   
   ball_x = ball_x + ball_x_inc * dt * ANIMATION_SPEED
   ball_y = ball_y + ball_y_inc * dt * ANIMATION_SPEED
   
   if ball_y_inc < 0 then
      sign = -1.0
   else 
      sign = 1.0
   end
   
   deg = (ball_y + BOUNCE_HEIGHT/2) * 90 / BOUNCE_HEIGHT
   
   if deg > 80 then 
      deg = 80
   end
   
   if deg < 10 then
      deg = 10
   end
   
   ball_y_inc = sign * 4 * sin_deg( deg )
end

local colorToggle = false
local function DrawBoingBallBand( long_lo, long_hi )
   for lat_deg = 0, 360 - STEP_LATITUDE, STEP_LATITUDE do
      if colorToggle then
	 gl.glColor3f( 0.8, 0.1, 0.1 )
      else
	 gl.glColor3f( 0.95, 0.95, 0.95 )
      end
      
      colorToggle = not colorToggle
      
      if drawBallHow == DRAW_BALL_SHADOW then
	 gl.glColor3f( 0.35, 0.35, 0.35 )
      end
      
      vert_nw = {}
      vert_ne = {}
      vert_se = {}
      vert_sw = {}
      
      vert_nw.y = cos_deg(long_hi) * RADIUS
      vert_se.y = cos_deg(long_lo) * RADIUS
      vert_ne.y = vert_nw.y
      vert_sw.y = vert_se.y
      vert_ne.x = cos_deg( lat_deg                 ) * (RADIUS * sin_deg( long_lo + STEP_LONGITUDE ))
      vert_se.x = cos_deg( lat_deg                 ) * (RADIUS * sin_deg( long_lo                  ))
      vert_nw.x = cos_deg( lat_deg + STEP_LATITUDE ) * (RADIUS * sin_deg( long_lo + STEP_LONGITUDE ))
      vert_sw.x = cos_deg( lat_deg + STEP_LATITUDE ) * (RADIUS * sin_deg( long_lo                  ))
      vert_ne.z = sin_deg( lat_deg                 ) * (RADIUS * sin_deg( long_lo + STEP_LONGITUDE ))
      vert_se.z = sin_deg( lat_deg                 ) * (RADIUS * sin_deg( long_lo                  ))
      vert_nw.z = sin_deg( lat_deg + STEP_LATITUDE ) * (RADIUS * sin_deg( long_lo + STEP_LONGITUDE ))
      vert_sw.z = sin_deg( lat_deg + STEP_LATITUDE ) * (RADIUS * sin_deg( long_lo                  ))
      
      gl.glBegin( gl.GL_POLYGON )
      vert_norm = CrossProduct( vert_ne, vert_nw, vert_sw )
      gl.glNormal3f( vert_norm.x, vert_norm.y, vert_norm.z )
      gl.glVertex3f( vert_ne.x, vert_ne.y, vert_ne.z )
      gl.glVertex3f( vert_nw.x, vert_nw.y, vert_nw.z )
      gl.glVertex3f( vert_sw.x, vert_sw.y, vert_sw.z )
      gl.glVertex3f( vert_se.x, vert_se.y, vert_se.z )
      gl.glEnd()
      
      if BOING_DEBUG then
	 print( "----------------------------------------------------------- \n" )
	 print( "lat = %f  long_lo = %f  long_hi = %f \n", lat_deg, long_lo, long_hi )
	 print( "vert_ne  x = %.8f  y = %.8f  z = %.8f \n", vert_ne.x, vert_ne.y, vert_ne.z )
	 print( "vert_nw  x = %.8f  y = %.8f  z = %.8f \n", vert_nw.x, vert_nw.y, vert_nw.z )
	 print( "vert_se  x = %.8f  y = %.8f  z = %.8f \n", vert_se.x, vert_se.y, vert_se.z )
	 print( "vert_sw  x = %.8f  y = %.8f  z = %.8f \n", vert_sw.x, vert_sw.y, vert_sw.z )
      end	
   end
   
   colorToggle = not colorToggle
end

local function DrawBoingBall(dt)
   gl.glPushMatrix()
   gl.glMatrixMode( gl.GL_MODELVIEW )
   gl.glTranslatef( 0, 0, DIST_BALL )
   
   local dt_total = dt
   while dt_total > 0  do
      local dt2 = dt_total
      if dt2 > MAX_DELTA_T then
	 dt2 = MAX_DELTA_T
      end
      dt_total  = dt_total - dt2
      BounceBall( dt2 )
      deg_rot_y = TruncateDeg( deg_rot_y + deg_rot_y_inc*dt2*ANIMATION_SPEED )
   end
   
   gl.glTranslatef( ball_x, ball_y, 0.0 )
   
   if drawBallHow == DRAW_BALL_SHADOW then
      gl.glTranslatef( SHADOW_OFFSET_X, SHADOW_OFFSET_Y, SHADOW_OFFSET_Z )
   end
   
   gl.glRotatef( -20, 0, 0, 1 )
   gl.glRotatef( deg_rot_y, 0, 1, 0 )
   gl.glCullFace( gl.GL_FRONT )
   gl.glEnable( gl.GL_CULL_FACE )
   gl.glEnable( gl.GL_NORMALIZE )
   
   for lon_deg = 0, 180 - STEP_LONGITUDE, STEP_LONGITUDE do
      DrawBoingBallBand( lon_deg, lon_deg + STEP_LONGITUDE )
   end
   
   gl.glPopMatrix()
end

local function DrawGrid()
   local rowTotal  = 12
   local colTotal  = rowTotal
   local widthLine = 2
   local sizeCell  = GRID_SIZE / rowTotal
   local z_offset  = -40
   
   gl.glPushMatrix()
   gl.glDisable( gl.GL_CULL_FACE )
   gl.glTranslatef( 0, 0, DIST_BALL )
   for col = 0, colTotal do
      local xl = -GRID_SIZE / 2 + col * sizeCell
      local xr = xl + widthLine
      local yt =  GRID_SIZE / 2
      local yb = -GRID_SIZE / 2 - widthLine
      gl.glBegin( gl.GL_POLYGON )
      gl.glColor3f( 0.6, 0.1, 0.6 )
      gl.glVertex3f( xr, yt, z_offset )
      gl.glVertex3f( xl, yt, z_offset )
      gl.glVertex3f( xl, yb, z_offset )
      gl.glVertex3f( xr, yb, z_offset )
      gl.glEnd()
   end
   for row = 0, rowTotal do
      local yt = GRID_SIZE / 2 - row * sizeCell
      local yb = yt - widthLine
      local xl = -GRID_SIZE / 2
      local xr =  GRID_SIZE / 2 + widthLine
      gl.glBegin( gl.GL_POLYGON )
      gl.glColor3f( 0.6, 0.1, 0.6 )
      gl.glVertex3f( xr, yt, z_offset )
      gl.glVertex3f( xl, yt, z_offset )
      gl.glVertex3f( xl, yb, z_offset )
      gl.glVertex3f( xr, yb, z_offset )
      gl.glEnd()
   end
   gl.glPopMatrix()
end

local function display(dt)
   gl.glClear( gl.GL_COLOR_BUFFER_BIT + gl.GL_DEPTH_BUFFER_BIT )
   gl.glPushMatrix()
   
   drawBallHow = DRAW_BALL_SHADOW
   DrawBoingBall(dt)
   
   DrawGrid()
   
   drawBallHow = DRAW_BALL
   DrawBoingBall(dt)
   
   gl.glPopMatrix()
   gl.glFlush()
end

local function reshape( window, w, h )
   gl.glViewport( 0, 0, w, h )
   gl.glMatrixMode( gl.GL_PROJECTION )
   gl.glLoadIdentity()
   glu.gluPerspective( PerspectiveAngle( RADIUS * 2, 200 ), w / h, 1.0, VIEW_SCENE_DIST )
   gl.glMatrixMode( gl.GL_MODELVIEW )
   gl.glLoadIdentity()
   glu.gluLookAt( 
      0,  0, VIEW_SCENE_DIST, -- eye
      0,  0,               0, -- center of vision
      0, -1,               0  -- up vector
   )    
end

local function main()
   assert( glfw.glfwInit() )
   local window = assert(
      ffi.gc( glfw.glfwCreateWindow( 1024, 768, glfw.GLFW_WINDOWED, "Boing (classic Amiga demo)", nil ),
	      glfw.glfwDestroyWindow))
   glfw.glfwMakeContextCurrent( window )

   gl.glClearColor( 0.55, 0.55, 0.55, 0 )
   gl.glShadeModel( gl.GL_FLAT )

   local ot = glfw.glfwGetTime()
   local width, height
   local ffi_w, ffi_h = ffi.new( "int[1]" ), ffi.new( "int[1]" )
   while glfw.glfwGetKey( window, glfw.GLFW_KEY_ESCAPE ) ~= glfw.GLFW_PRESS
   do
      glfw.glfwGetWindowSize(window, ffi_w, ffi_h)
      if ffi_w[0] ~= width or ffi_h[0] ~= height then
	 width, height = ffi_w[0], ffi_h[0]
	 reshape(window, width, height)
      end
      
      local nt = glfw.glfwGetTime()
      display(nt - ot)
      ot = nt
      
      glfw.glfwSwapBuffers(window)
      glfw.glfwPollEvents()
   end
   glfw.glfwTerminate()
end

main()

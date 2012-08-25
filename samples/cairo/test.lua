local ffi  = require( "ffi" )
local cr   = require( "ffi/cairo" )
local gl   = require( "ffi/OpenGL" )
local glfw = require( "ffi/glfw" )

local min, max, abs, sqrt, log, floor = math.min, math.max, math.abs, math.sqrt, math.log, math.floor

local function cairo_test()
   local surface = ffi.gc( 
      cr.cairo_image_surface_create( 
	 cr.CAIRO_FORMAT_ARGB32, 
	 240, 
	 80 
      ),
      cr.cairo_surface_destroy 
   )

   local c = ffi.gc( 
      cr.cairo_create( surface ), 
      cr.cairo_destroy 
   )

   cr.cairo_select_font_face(
      c, "bizarre", 
      cr.CAIRO_FONT_SLANT_OBLIQUE, 
      cr.CAIRO_FONT_WEIGHT_BOLD 
   )

   local font_face = cr.cairo_font_face_reference( cr.cairo_get_font_face( c ))
   print( 'font_face', font_face )
   assert( ffi.string( cr.cairo_toy_font_face_get_family( font_face )) == "bizarre"      )
   assert( cr.cairo_font_face_get_type(       font_face ) == cr.CAIRO_FONT_TYPE_TOY      )
   assert( cr.cairo_toy_font_face_get_slant(  font_face ) == cr.CAIRO_FONT_SLANT_OBLIQUE )
   assert( cr.cairo_toy_font_face_get_weight( font_face ) == cr.CAIRO_FONT_WEIGHT_BOLD   )
   assert( cr.cairo_font_face_status(         font_face ) == cr.CAIRO_STATUS_SUCCESS     )
   cr.cairo_font_face_destroy (font_face);
   
   print( 'font_face 1', font_face )

   font_face = cr.cairo_toy_font_face_create(
      "bozarre",
      cr.CAIRO_FONT_SLANT_OBLIQUE,
      cr.CAIRO_FONT_WEIGHT_BOLD
   )
   assert( ffi.string( cr.cairo_toy_font_face_get_family( font_face )) == "bozarre"      )
   assert( cr.cairo_font_face_get_type(       font_face ) == cr.CAIRO_FONT_TYPE_TOY      )
   assert( cr.cairo_toy_font_face_get_slant(  font_face ) == cr.CAIRO_FONT_SLANT_OBLIQUE )
   assert( cr.cairo_toy_font_face_get_weight( font_face ) == cr.CAIRO_FONT_WEIGHT_BOLD   )
   assert( cr.cairo_font_face_status(         font_face ) == cr.CAIRO_STATUS_SUCCESS     )
   cr.cairo_font_face_destroy( font_face )

   print( 'font_face 2', font_face )

   print( surface, c )

   local temp = [[

   cr.cairo_move_to( c, 10, 50 )
   cr.cairo_show_text( c, "Hello, world" )

   print( surface, c )


   cr.cairo_set_font_size(  c, 32 )
   cr.cairo_set_source_rgb( c,  0,  0, 1 )

--   cr.cairo_surface_write_to_png( surface, "hello.png" )
]]

end

local function kernel_1d_new( radius, deviation )
   assert( radius > 0 )

   local size = 2 * radius + 1

   local radius2 = radius + 1
   if deviation == 0 then
      deviation = sqrt( - radius2*radius2 / ( 2 * log(1/255)))
   end

   kernel = ffi.new( "double[?]", size + 1 )
   kernel[0] = size
   local value, sum = -radius, 0
   local oodeviation = 1 / deviation
   local oodeviationbyconst = oodeviation / 2.506628275
   local oodeviationsqhalf = oodeviation * oodeviation / 2
   for i=0, size do
      kernel[ i+1 ] = oodeviationbyconst * exp ( - value * value * oodeviationsqhalf )
      sum = sum + kernel[ i+1 ]
      value = value + 1
   end

   local oosum = 1 / sum
   for i=0, size do
      kernel[ i+1 ] = kernel[ i+1 ] * oosum
   end

   return kernel
end

local function cairo_image_surface_blur( surface, horzRadius, vertRadius )
   assert( surface )
   assert( horzSurface > 0 )
   assert( vertRadius > 0 )
   assert( cr.cairo_surface_get_type( surface ) == cr.CAIRO_SURFACE_TYPE_IMAGE )
   cr.cairo_surface_flush( surface )
   local src = cr.cairo_image_surface_get_data( surface )
   local width = cr.cairo_image_surface_get_width( surface )
   local height = cr.cairo_image_surface_get_height( surface )
   local format = cr.cairo_image_surface_get_format( surface )
   local chanmap = { 
      [cr.CAIRO_FORMAT_ARGB32] = 4, 
      [cr.CAIRO_FORMAT_RGB24]  = 3 
   }
   local channels = chanmap[ format ]
   assert( channels )
   local stride = width * channels
   local horzBlur = ffi.new( "double[?]", height * stride )
   local vertBlur = ffi.new( "double[?]", height * stride )
   local horzKernel = kernel_1d_new( horzRadius, 0 )
   local vertKernel = kernel_1d_new( vertRadius, 0 )
   local process = { 
      { src,      horzKernel, horzBlur }, 
      { horzBlur, vertKernel, verbBlur },
   }
   for p = 1, #process do
      local process = process[p]
      local src, kernel, blur = process[1], process[2], process[3]
      for iy = 0, height - 1 do
	 for ix = 0, width - 1 do
	    local R, G, B, A = 0, 0, 0, 0
	    local size = horzKernel[0]
	    local offset = floor(-size * 0.5)
	    local s, e = max(ix + offset, 0), min(ix + offset + size - 1, width)
	    for x = s, e do
	       local i = ix + offset - s + 1
	       local o = iy * stride + x * channels
	       if channels == 4 then
		  A = A + kernel[i] * src[o+3]
	       end
	       R = R + kernel[i] * src[o+2]
	       G = G + kernel[i] * src[o+1]
	       B = B + kernel[i] * src[o+0]
	    end
	    local o = iy * stride + ix * channels
	    if channels == 4 then
	       blur[ o+3 ] = A
	    end
	    blur[ o+2 ] = R
	    blur[ o+1 ] = G
	    blur[ o+0 ] = B
	 end
      end
   end
   for iy = 0, height - 1 do
      for ix = 0, width - 1 do
	 local o = iy * stride + ix * channels
	 if channels == 4 then
	    src[ o+3 ] = verBlur[ o+3 ]
	 end
	 src[ o+2 ] = vertBlur[ o+3 ]
	 src[ o+1 ] = vertBlur[ o+3 ]
	 src[ o+0 ] = vertBlur[ o+3 ]
      end
   end
   cr.cairo_surface_mark_dirty( surface )
end

local function main()
   local width, height

   assert( glfw.glfwInit() )
   local window = glfw.glfwCreateWindow( 640, 480, glfw.GLFW_WINDOWED, "Spinning Triangle", nil)
   assert( window )
   glfw.glfwSetInputMode(window, glfw.GLFW_STICKY_KEYS, 1);
   glfw.glfwSwapInterval(1);
   print( window )

   gl.glClearColor( 0, 0, 0, 0 )
   gl.glDisable( gl.GL_DEPTH_TEST )
   gl.glEnable( gl.GL_BLEND )	
   gl.glBlendFunc( gl.GL_SRC_ALPHA, gl.GL_ONE_MINUS_SRC_ALPHA )
   gl.glEnable( gl.GL_TEXTURE_RECTANGLE_ARB )

   local texture_id = ffi.new( "GLuint[1]" )

   local int1, int2 = ffi.new( "int[1]" ), ffi.new( "int[1]" )
   while not glfw.glfwGetWindowParam(window, glfw.GLFW_CLOSE_REQUESTED)
   do
      glfw.glfwGetWindowSize( window, int1, int2 )
      if width ~= int1[0] or height ~= int2[0] then
	 width, height = int1[0], int2[0]
	 gl.glViewport( 0, 0, width, height )
	 gl.glMatrixMode( gl.GL_PROJECTION )
	 gl.glLoadIdentity( )
	 gl.glOrtho( 0, 1, 0, 1, -1, 1 )
	 gl.glClear( gl.GL_COLOR_BUFFER_BIT )
	 gl.glDeleteTextures( 1, texture_id )
	 gl.glGenTextures( 1, texture_id )
	 gl.glBindTexture( gl.GL_TEXTURE_RECTANGLE_ARB, texture_id[0] )
	 gl.glTexImage2D(
	    gl.GL_TEXTURE_RECTANGLE_ARB, 0, gl.GL_RGBA, width, height, 0,
	    gl.GL_BGRA, gl.GL_UNSIGNED_BYTE, nil )
	 gl.glTexEnvi( gl.GL_TEXTURE_ENV, gl.GL_TEXTURE_ENV_MODE, gl.GL_DECAL )
      end
      gl.glMatrixMode( gl.GL_MODELVIEW )
      gl.glLoadIdentity()
      gl.glClear( gl.GL_COLOR_BUFFER_BIT )
      gl.glPushMatrix( )
      gl.glBindTexture( gl.GL_TEXTURE_RECTANGLE_ARB, texture_id[0] )
      gl.glTexImage2D(
	 gl.GL_TEXTURE_RECTANGLE_ARB, 0, gl.GL_RGBA, width, height, 0,
	 gl.GL_BGRA, gl.GL_UNSIGNED_BYTE, surf_data )
      gl.glColor3f( 0.25, 0.5, 1 )
      gl.glBegin( gl.GL_QUADS )
      if true then
	 gl.glTexCoord2f(     0,      0 ); gl.glVertex2f( 0, 0 )
	 gl.glTexCoord2f( width,      0 ); gl.glVertex2f( 1, 0 )
	 gl.glTexCoord2f( width, height ); gl.glVertex2f( 1, 1 )
	 gl.glTexCoord2f(     0, height ); gl.glVertex2f( 0, 1 )
      end
      gl.glEnd( )
      gl.glPopMatrix( )
   end
   glfw.glfwTerminate();
end


cairo_test()

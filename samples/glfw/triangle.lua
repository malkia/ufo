local ffi  = require( "ffi" )
local gl   = require( "ffi/OpenGL" )
local glu  = require( "ffi/glu" )
local glfw = require( "ffi/glfw" )
local fonts = require( "lib/fonts" )

local shr, band = bit.rshift, bit.band

local function checkGL( v )
   local r = gl.glGetError()
   if r ~= 0 then
      print( "OpenGL Error: "..tostring(r))
   end
   return v
end

-- withGL - mini OpenGL DSL for glPixelStore/glTexParameteri/glPixelTransfer funcs
local function withGL( t )
   local fun, key_prefix, val_prefix
   local fun_set, key_prefix_set, val_prefix_set = false, false, false
   for k,v in pairs( t ) do
      if fun_set == false then
	 assert( k == 1, "withGL: Expected OpenGL function (glPixelStored, glPixelTransferd, ...) as first item in the table" )
	 fun, fun_set = v, true
      elseif key_prefix_set == false then
	 assert( k == 2, "withGL: Expected OpenGL key prefix (GL_, GL_UNPACK_, GL_TEXTURE_, ...) as second item in the table" )
	 key_prefix, key_prefix_set = v, true
      else
	 if type(v) == "string" then
	    v = gl["GL_" .. v:upper()]
	 end
	 checkGL( fun( gl[key_prefix .. k:upper()], v ) )
      end
   end
end

local function bind_font( font )
   local tid = ffi.new( "GLuint[1]" )
   gl.glGenTextures( 1, tid )
   tid = tid[0]
   checkGL( gl.glBindTexture( gl.GL_TEXTURE_2D, tid ) )
   withGL{  gl.glPixelStorei, "GL_UNPACK_", SWAP_BYTES="FALSE", LSB_FIRST="FALSE", ROW_LENGTH=0, SKIP_ROWS=0, SKIP_PIXELS=0, ALIGNMENT=1 }
   withGL{  gl.glPixelTransferf, "GL_", ALPHA_SCALE=1, ALPHA_BIAS=0, RED_BIAS=1, GREEN_BIAS=1, BLUE_BIAS=1 }
   checkGL( gl.glTexImage2D( gl.GL_TEXTURE_2D, 0, 4, font.tw, font.th, 0, gl.GL_ALPHA, gl.GL_UNSIGNED_BYTE, font.td ) )
   withGL{ function(p,v) gl.glTexParameterf( gl.GL_TEXTURE_2D, p, v ) end, "GL_TEXTURE_",
	   WRAP_S="CLAMP", WRAP_T="CLAMP", MAG_FILTER="NEAREST", MIN_FILTER="NEAREST" }
   checkGL( gl.glTexEnvi( gl.GL_TEXTURE_ENV, gl.GL_TEXTURE_ENV_MODE, gl.GL_MODULATE ) )
   checkGL( gl.glBindTexture( gl.GL_TEXTURE_2D, 0 ) )
   withGL{  gl.glPixelTransferf, "GL_", ALPHA_BIAS=0, RED_BIAS=0, GREEN_BIAS=0, BLUE_BIAS=0 }
   return {
      tid = tid,
      font = font
   }
end

local function unbind_font( font )
   local tid = ffi.new( "GLuint[1]", font.tid )
   gl.glDeleteTextures(1, tid)
end

local function build_text( font, lines )
   local lines = type(lines)=="string" and { lines } or lines
   local top, bottom = 1, #lines

   local chars = 0
   for y = top, bottom do
      chars = chars + #lines[ y ] 
   end

   local v = ffi.new( "float[?]", chars * 12 )
   local uv = ffi.new( "float[?]", chars * 12 )
   local tid, font = font.tid, font.font
   local u0, v0, u1, v1, cw, ch = font.u0, font.v0, font.u1, font.v1, font.cw, font.ch
   local x0, y0, c = 0, 0, 0
   for y = top, bottom do
      local x0, y1, line = x0, y0 + ch, lines[y]
      for x = 1, #line do
	 local ch = line:byte(x)
	 local x1 = x0 + cw[ch]
	 local u0, v0, u1, v1 = u0[ch], v0[ch], u1[ch], v1[ch]
	 v[c +  0], v[c +  1], uv[c +  0], uv[c +  1] = x0, y0, u0, v0
	 v[c +  2], v[c +  3], uv[c +  2], uv[c +  3] = x1, y0, u1, v0
	 v[c +  4], v[c +  5], uv[c +  4], uv[c +  5] = x0, y1, u0, v1
	 v[c +  6], v[c +  7], uv[c +  6], uv[c +  7] = x1, y0, u1, v0
	 v[c +  8], v[c +  9], uv[c +  8], uv[c +  9] = x1, y1, u1, v1
	 v[c + 10], v[c + 11], uv[c + 10], uv[c + 11] = x0, y1, u0, v1
	 c = c + 12
	 x0 = x1
      end
      y0 = y1
   end
   
   return {
      tid = tid,
      n_verts = chars * 6,
      uvs = uv,
      verts = v,
      colors = colors,
      verts_bg = verts_bg,
      colors_bg = colors_bg
   }
end

local function draw_text( dc, x, y, color, bg_color )
   gl.glPushAttrib(gl.GL_ALL_ATTRIB_BITS)
   gl.glPushMatrix()

   gl.glTranslated( x, y, 0 )

   gl.glEnable(              gl.GL_TEXTURE_2D )
   gl.glBindTexture(         gl.GL_TEXTURE_2D, dc.tid )

   gl.glVertexPointer(    2, gl.GL_FLOAT, 0, dc.verts )
   gl.glTexCoordPointer(  2, gl.GL_FLOAT, 0, dc.uvs )

   gl.glEnableClientState(   gl.GL_VERTEX_ARRAY )
   gl.glEnableClientState(   gl.GL_TEXTURE_COORD_ARRAY )
   checkGL( gl.glDrawArrays( gl.GL_TRIANGLES, 0, dc.n_verts ) )
   gl.glDisableClientState(  gl.GL_VERTEX_ARRAY )
   gl.glDisableClientState(  gl.GL_TEXTURE_COORD_ARRAY )

   gl.glPopMatrix()
   gl.glPopAttrib()
end

local function read_file(n)
   local f = io.input(n)
   return f:read("*all")
end

local function read_file_2(n)
   local lines = {}
   for line in io.lines(n) do
      lines[#lines + 1] = line
   end
   return lines
end

local source = read_file_2( "README" )

local function main()
   local px, py = 0, 0
   assert( glfw.glfwInit() )

   local window = glfw.glfwOpenWindow( 1024, 768, glfw.GLFW_WINDOWED, "Spinning Triangle", nil)
   assert( window )
-- glfw.glfwEnable(window, glfw.GLFW_STICKY_KEYS)
   glfw.glfwSwapInterval(1)

   local font = bind_font( fonts[4] )

   gl.glEnable( gl.GL_BLEND )
   gl.glBlendFunc( gl.GL_SRC_ALPHA, gl.GL_ONE_MINUS_SRC_ALPHA )
   gl.glDisable( gl.GL_CULL_FACE)

   local mx, my = ffi.new( "int[1]" ), ffi.new( "int[1]" )
   local sw, sh = ffi.new( "int[1]" ), ffi.new( "int[1]" )
   while glfw.glfwIsWindow(window) and glfw.glfwGetKey(window, glfw.GLFW_KEY_ESCAPE) ~= glfw.GLFW_PRESS 
   do
      glfw.glfwGetMousePos(window, mx, my)
      local mx, my = mx[0], my[0]

      glfw.glfwGetWindowSize(window, sw, sh)
      local sw, sh = sw[0], sh[0]

      gl.glViewport(0, 0, sw, sh)
      gl.glClearColor(0, 0, 1, 0)
      gl.glClear(gl.GL_COLOR_BUFFER_BIT)

      gl.glMatrixMode(gl.GL_PROJECTION)
      gl.glLoadIdentity()
      
      gl.glOrtho(0, sw, sh, 0, -1, 1 )

--      draw_text( build_text( font, "Test" ), math.random(sw), math.random(sh))

--      draw_text( build_text( font, source ), px, py ) --mx[0], py + my[0] )
      py = py - 1

      glfw.glfwSwapBuffers()
      glfw.glfwPollEvents()
   end
   glfw.glfwTerminate()
end

main()

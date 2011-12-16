#!/usr/bin/env luajit

local shr, band, min, max = bit.rshift, bit.band, math.min, math.max

local ffi   = require( "ffi" )
local gl    = require( "ffi/OpenGL" )
local glu   = require( "ffi/glu" )
local glfw  = require( "ffi/glfw" )
local fonts = require( "lib/fonts" )

--jit.off()
--require('dbg')

-- Wrap every OpenGL call to test it for error
local function testGL( v )
   local r = gl.glGetError()
   if r ~= 0 then
      error( "OpenGL Error: "..tostring(r) .. " " .. ffi.string(glu.gluErrorString(r)) )
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
         testGL( fun( gl[key_prefix .. k:upper()], v ) )
      end
   end
end

local function bind_font( font )
   local tid = ffi.new( "GLuint[1]" )
   testGL( gl.glGenTextures( 1, tid ) )
   local tid = tid[0]
   testGL( gl.glBindTexture( gl.GL_TEXTURE_2D, tid ) )
   withGL{ gl.glPixelStorei, "GL_UNPACK_", SWAP_BYTES="FALSE", LSB_FIRST="FALSE",
           ROW_LENGTH=0, SKIP_ROWS=0, SKIP_PIXELS=0, ALIGNMENT=1 }
   withGL{ gl.glPixelTransferf, "GL_", ALPHA_SCALE=1, ALPHA_BIAS=0 }
   testGL( gl.glTexImage2D( gl.GL_TEXTURE_2D, 0, gl.GL_ALPHA, font.tw, font.th, 0,
                            gl.GL_ALPHA, gl.GL_UNSIGNED_BYTE, font.td ) )
   withGL{ function(p,v) gl.glTexParameterf( gl.GL_TEXTURE_2D, p, v ) end, "GL_TEXTURE_",
           WRAP_S="REPEAT", WRAP_T="REPEAT", MAG_FILTER="LINEAR", MIN_FILTER="LINEAR" }
   testGL( gl.glTexEnvi( gl.GL_TEXTURE_ENV, gl.GL_TEXTURE_ENV_MODE, gl.GL_MODULATE ) )
   return {
      tid = tid,
      font = font
   }
end

local function unbind_font( font )
   local tid = ffi.new( "GLuint[1]", font.tid )
   testGL( gl.glDeleteTextures(1, tid) )
end

local function build_text( font, lines, top, bottom )
   local fixed = false
   local lines = type(lines)=="string" and { lines } or lines
   local top = top or 1
   local bottom = bottom or #lines

   assert( 1 <= top and top <= bottom and bottom <= #lines,
	   "top="..tostring(top).." "..
	   "bottom="..tostring(bottom).." "..
	"lines="..tostring(#lines)
	)

   local chars = 0
   for y = top, bottom do
      chars = chars + #lines[ y ]
   end

   local v = ffi.new( "float[?]", chars * 12 )
   local uv = ffi.new( "float[?]", chars * 12 )
   local tid, font = font.tid, font.font
   local u0, v0, u1, v1, cw, ch = font.u0, font.v0, font.u1, font.v1, font.cw, font.ch
   local x0, c, w, h = 0, 0, 0, 0
   local y0 = (top - 1) * ch
   local ootw = 1 / font.tw
   ootw = ootw - ootw / 2
   for y = top, bottom do
      local x0, y1, line = x0, y0 + ch, lines[y]
      for x = 1, #line do
         local ch = line:byte(x)
         local u0, v0, u1, v1 = u0[ch], v0[ch], u1[ch], v1[ch]
	 local x1 = x0
	 if fixed then
	    x1 = x1 + 8
	    if cw[ch] <= 6 then
	       u0 = u0 - ootw*2
	       u1 = u1 + ootw*2
	    end
	 else
	    x1 = x1 + cw[ch]
	 end
         v[c +  0], v[c +  1], uv[c +  0], uv[c +  1] = x0, y0, u0, v0
         v[c +  2], v[c +  3], uv[c +  2], uv[c +  3] = x1, y0, u1, v0
         v[c +  4], v[c +  5], uv[c +  4], uv[c +  5] = x0, y1, u0, v1
         v[c +  6], v[c +  7], uv[c +  6], uv[c +  7] = x1, y0, u1, v0
         v[c +  8], v[c +  9], uv[c +  8], uv[c +  9] = x1, y1, u1, v1
         v[c + 10], v[c + 11], uv[c + 10], uv[c + 11] = x0, y1, u0, v1
         c = c + 12
         x0 = x1
      end
      w = max(w, x0)
      y0 = y1
   end
   h = max(h, y0)

   return {
      tid = tid,
      n_verts = chars * 6,
      uvs = uv,
      verts = v,
      w = w,
      h = h,
   }
end

local function draw_text( dc, x, y, selection )
   testGL( gl.glPushClientAttrib(    gl.GL_CLIENT_ALL_ATTRIB_BITS ) )
   testGL( gl.glPushAttrib(          gl.GL_ALL_ATTRIB_BITS ) )
   testGL( gl.glPushMatrix( ) )
   testGL( gl.glTranslated(       x, y, 0 ) )
   testGL( gl.glEnable(              gl.GL_BLEND ) )
   testGL( gl.glBlendFunc(           gl.GL_SRC_ALPHA, gl.GL_ONE_MINUS_SRC_ALPHA ) )
   testGL( gl.glEnable(              gl.GL_TEXTURE_2D ) )
   testGL( gl.glBindTexture(         gl.GL_TEXTURE_2D, dc.tid ) )
   testGL( gl.glVertexPointer(    2, gl.GL_FLOAT, 0, dc.verts ) )
   testGL( gl.glTexCoordPointer(  2, gl.GL_FLOAT, 0, dc.uvs ) )
   testGL( gl.glEnableClientState(   gl.GL_VERTEX_ARRAY ) )
   testGL( gl.glEnableClientState(   gl.GL_TEXTURE_COORD_ARRAY ) )
   if selection then
      local from = selection.from * 6
      local to   = selection.to   * 6
      if 0 <= from and from <= to and to <= dc.n_verts then
         assert( 0 <= from and from <= to and to <= dc.n_verts,
                 "from="..tostring(from)..
                 " to="..tostring(to)..
              " n_verts="..tostring(dc.n_verts))
         testGL( gl.glDrawArrays(       gl.GL_TRIANGLES, 0,  from ) )
         testGL( gl.glBlendFunc(        gl.GL_ONE_MINUS_SRC_ALPHA, gl.GL_SRC_ALPHA ) )
         testGL( gl.glDrawArrays(       gl.GL_TRIANGLES, from, to - from ) )
         testGL( gl.glBlendFunc(        gl.GL_SRC_ALPHA, gl.GL_ONE_MINUS_SRC_ALPHA ) )
         testGL( gl.glDrawArrays(       gl.GL_TRIANGLES, to, dc.n_verts - to ) )
      else
         testGL( gl.glDrawArrays(       gl.GL_TRIANGLES, 0, dc.n_verts ) )
      end
   else
      testGL( gl.glDrawArrays(       gl.GL_TRIANGLES, 0, dc.n_verts ) )
   end
   testGL( gl.glPopMatrix() )
   testGL( gl.glPopAttrib() )
   testGL( gl.glPopClientAttrib( ) )
end

local function read_text_file(n)
   local lines = {}
   for line in io.lines(n) do
      lines[#lines + 1] = line
   end
   return lines
end

local source = read_text_file( ... or (arg and arg[1]) or "ffi/OpenGL.lua" )

local state = {
   lines = {},
   top = 0,
   left = 0,
}

local function main()
   assert( glfw.glfwInit() )


   local desktop_mode = ffi.new( "GLFWvidmode[1]" )
   glfw.glfwGetDesktopMode( desktop_mode )
   local desktop_width, desktop_height = desktop_mode[0].width, desktop_mode[0].height
   local width, height = desktop_width * 0.9, desktop_height * 0.9

   local window = glfw.glfwOpenWindow( width, height, glfw.GLFW_WINDOWED, "Font Demo", nil )
   assert( window, "Failed to open GLFW window" )

   local function key_pressed(key)
      return glfw.glfwGetKey( window, glfw[ "GLFW_KEY_" .. key:upper() ] ) == glfw.GLFW_PRESS
   end

   glfw.glfwEnable( window, glfw.GLFW_STICKY_KEYS )
   glfw.glfwSetWindowPos( window, (desktop_width - width)/2, (desktop_height - height)/2 )
   glfw.glfwSwapInterval( 0 ) -- 0=nosync 1=60fps

   local font = bind_font( fonts[4] )
   local font2 = bind_font( fonts[1] )

   local mx, my = ffi.new( "int[1]" ), ffi.new( "int[1]" ) -- mouse x, y
   local ww, wh = ffi.new( "int[1]" ), ffi.new( "int[1]" ) -- window width, height
   local sx, sy = ffi.new( "int[1]" ), ffi.new( "int[1]" ) -- mouse scroll x, y
   local px, py, pdx, pdy = 0, 0, 0, 0
   local s1 = 10
   local s2 = 100

   while glfw.glfwIsWindow(window) and glfw.glfwGetKey(window, glfw.GLFW_KEY_ESCAPE) ~= glfw.GLFW_PRESS do
      glfw.glfwGetWindowSize(window, ww, wh)
      local ww, wh = ww[0], wh[0]

      glfw.glfwGetMousePos(window, mx, my)
      local mx, my = mx[0], my[0]

      glfw.glfwGetScrollOffset(window, sx, sy)
      local sx, sy = sx[0], sy[0]

      if key_pressed( "UP" ) then
--       py = py + font.font.ch
--       sy = sy + 1
         py = py + font.font.ch
      end

      if key_pressed( "DOWN" ) then
--       py = py - font.font.ch
--       sy = sy - 1
         py = py - font.font.ch
      end

      testGL( gl.glViewport(0, 0, ww, wh) )
      testGL( gl.glClearColor(0.4, 0.3, 0.2 + pdy/100.0, 0) )
--      if math.abs(pdy) < 10.5 then
	 testGL( gl.glClear(gl.GL_COLOR_BUFFER_BIT) )
  --    end

      testGL( gl.glMatrixMode(gl.GL_PROJECTION) )
      testGL( gl.glLoadIdentity() )

      testGL( gl.glOrtho(0, ww, wh, 0, -1, 1 ) )

      local top = max(1,min(#source,math.floor(-py / font.font.ch) + 1))
      local bottom = max(1,min(#source, top + math.floor( wh / font.font.ch )))
      dc = build_text( font, source, top, bottom )

      gl.glColor4ub( 130, 255, 255, 255 )
      draw_text( dc, px, py, { from = s1, to = s2 } )

      if false then
	 gl.glPushMatrix()
	 gl.glTranslated(ww - 256, 0, 0 )
	 gl.glScaled(256 / dc2.w, wh / dc2.h, 0)
	 draw_text( dc2, 0, 0, { from = s1, to = s2 } )
	 gl.glPopMatrix()
      end

      pdx = pdx * 0.915 + sx
      if sx * pdx < 0 then
         pdx = 0
      end
      px = px + pdx
      px = min(px, 0)

      pdy = pdy * 0.915 + sy
      if sy * pdy < 0 then
         pdy = 0
      end
      py = py + pdy
      py = min(py, 0)

      s1 = s1 + 2.5
      s2 = s2 + 3

      if s1 > dc.n_verts / 6 then
	 s1 = 0
	 s2 = 10
      end

      glfw.glfwSwapBuffers()
      glfw.glfwPollEvents()
   end
   glfw.glfwTerminate()

   print( "Verts: ", dc.n_verts )
end

main()

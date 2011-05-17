#!/usr/bin/env luajit

local shr, band = bit.rshift, bit.band

local ffi   = require( "ffi" )
local gl    = require( "ffi/OpenGL" )
local glfw  = require( "ffi/glfw" )
local fonts = require( "lib/fonts" )

-- Wrap every OpenGL call to test it for error
local function testGL( v )
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
         testGL( fun( gl[key_prefix .. k:upper()], v ) )
      end
   end
end

local function bind_font( font )
   local tid = ffi.new( "GLuint[1]" )
   testGL( gl.glGenTextures( 1, tid ) )
   tid = tid[0]
   testGL( gl.glBindTexture( gl.GL_TEXTURE_2D, tid ) )
   withGL{ gl.glPixelStorei, "GL_UNPACK_", SWAP_BYTES="FALSE", LSB_FIRST="FALSE", 
           ROW_LENGTH=0, SKIP_ROWS=0, SKIP_PIXELS=0, ALIGNMENT=1 }
   withGL{ gl.glPixelTransferf, "GL_", ALPHA_SCALE=1, ALPHA_BIAS=0, 
           RED_BIAS=1, GREEN_BIAS=1, BLUE_BIAS=1 }
   testGL( gl.glTexImage2D( gl.GL_TEXTURE_2D, 0, 2, font.tw, font.th, 0, 
                            gl.GL_ALPHA, gl.GL_UNSIGNED_BYTE, font.td ) )
   withGL{ function(p,v) gl.glTexParameterf( gl.GL_TEXTURE_2D, p, v ) end, "GL_TEXTURE_",
           WRAP_S="CLAMP", WRAP_T="CLAMP", MAG_FILTER="NEAREST", MIN_FILTER="NEAREST" }
   testGL( gl.glTexEnvi( gl.GL_TEXTURE_ENV, gl.GL_TEXTURE_ENV_MODE, gl.GL_MODULATE ) )
   return{
      tid = tid,
      font = font
   }
end

local function unbind_font( font )
   local tid = ffi.new( "GLuint[1]", font.tid )
   testGL( gl.glDeleteTextures(1, tid) )
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
      testGL( gl.glDrawArrays(          gl.GL_TRIANGLES, 0,    from ) )
      testGL( gl.glBlendFunc(           gl.GL_ONE_MINUS_SRC_ALPHA, gl.GL_SRC_ALPHA ) )
      testGL( gl.glDrawArrays(          gl.GL_TRIANGLES, from, to - from ) )
      testGL( gl.glBlendFunc(           gl.GL_SRC_ALPHA, gl.GL_ONE_MINUS_SRC_ALPHA ) )
      testGL( gl.glDrawArrays(          gl.GL_TRIANGLES, to,   dc.n_verts - to ) )
   else
      testGL( gl.glDrawArrays(          gl.GL_TRIANGLES, 0, dc.n_verts ) )
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

local source = read_text_file( ... or (arg and arg[1]) or "moar.lua" )

local function main()
   assert( glfw.glfwInit() )

   local desktop_mode = ffi.new( "GLFWvidmode[1]" )
   glfw.glfwGetDesktopMode( desktop_mode )
   local desktop_width, desktop_height = desktop_mode[0].width, desktop_mode[0].height
   local width, height = desktop_width * 0.9, desktop_height * 0.9

   local window = glfw.glfwOpenWindow( width, height, glfw.GLFW_WINDOWED, "Font Demo", nil )
   assert( window, "Failed to open GLFW window" )

   glfw.glfwSetWindowPos( window, (desktop_width - width)/2, (desktop_height - height)/2 )
   glfw.glfwSwapInterval( 1 ) -- 60fps

   local font = bind_font( fonts[4] )

   local mx, my = ffi.new( "int[1]" ), ffi.new( "int[1]" )
   local sw, sh = ffi.new( "int[1]" ), ffi.new( "int[1]" )
   local px, py = 0, 0
   local s1 = 10
   local s2 = 100
   while glfw.glfwIsWindow(window) and glfw.glfwGetKey(window, glfw.GLFW_KEY_ESCAPE) ~= glfw.GLFW_PRESS do
      glfw.glfwGetMousePos(window, mx, my)
      local mx, my = mx[0], my[0]

      glfw.glfwGetWindowSize(window, sw, sh)
      local sw, sh = sw[0], sh[0]

      testGL( gl.glViewport(0, 0, sw, sh) )
      testGL( gl.glClearColor(0.4, 0.3, 0.2, 0) )
      testGL( gl.glClear(gl.GL_COLOR_BUFFER_BIT) )

      testGL( gl.glMatrixMode(gl.GL_PROJECTION) )
      testGL( gl.glLoadIdentity() )
      
      testGL( gl.glOrtho(0, sw, sh, 0, -1, 1 ) )

      gl.glColor4ub( 130, 255, 255, 255 )
      draw_text( build_text( font, source ), px, py, { from = s1, to = s2 } )
      py = py - 1

      s1 = s1 + 2.5
      s2 = s2 + 3

      glfw.glfwSwapBuffers()
      glfw.glfwPollEvents()
   end
   glfw.glfwTerminate()
end

main()

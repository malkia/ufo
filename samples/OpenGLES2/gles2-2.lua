#!/usr/bin/env luajit

local ffi = require( "ffi" )
local egl = require( "ffi/egl" )
local gles2 = require( "ffi/gles2" )
local kd = require( "ffi/OpenKODE" )
local gl = gles2

local vs_src = [[
      varying mediump vec2  pos;
      attribute vec4        position;
      uniform vec4          offset;
      void main()
      {
	 gl_Position = position + offset;
	 pos = position.xy;
      }
]]

local fs_src = [[
      varying mediump vec2  pos;
      uniform mediump float phase;
      void  main()
      {
	 gl_FragColor = vec4( 1., 0.9, 0.7, 1.0 ) * cos( 30.*sqrt(pos.x*pos.x + 1.5*pos.y*pos.y)  + atan(pos.y,pos.x) - phase );
      }                                 
]]

--  some more formulas to play with...
--      cos( 20.*(pos.x*pos.x + pos.y*pos.y) - phase );
--      cos( 20.*sqrt(pos.x*pos.x + pos.y*pos.y) + atan(pos.y,pos.x) - phase );
--      cos( 30.*sqrt(pos.x*pos.x + 1.5*pos.y*pos.y - 1.8*pos.x*pos.y*pos.y)
--            + atan(pos.y,pos.x) - phase );


local dpy = egl.eglGetDisplay( egl.EGL_DEFAULT_DISPLAY )
print( 'display', dpy )
assert( dpy ~= nil )

local r = egl.eglInitialize( dpy, nil, nil )
assert( r == egl.EGL_TRUE, 'eglInitialize' )

local attr = ffi.new( "EGLint[1]", egl.EGL_NONE )
local cfg = ffi.new( "EGLConfig[128]" )
local n_cfg = ffi.new( "EGLint[1]", 0 )
local r = egl.eglChooseConfig( dpy, attr, cfg, 128, n_cfg )
assert( r == egl.EGL_TRUE )
n_cfg = n_cfg[0]
print( 'n_cfg=', n_cfg )
for i=0, n_cfg-1 do
   local value = ffi.new( "EGLint[1]" )
   for _,v in ipairs{
      "BUFFER_SIZE", "ALPHA_SIZE", "BLUE_SIZE", "GREEN_SIZE", "RED_SIZE",
      "DEPTH_SIZE", "STENCIL_SIZE", "CONFIG_CAVEAT", "CONFIG_ID", "LEVEL",
      "MAX_PBUFFER_HEIGHT", "MAX_PBUFFER_PIXELS", "MAX_PBUFFER_WIDTH",
      "NATIVE_RENDERABLE", "NATIVE_VISUAL_ID", "NATIVE_VISUAL_TYPE",
      "SAMPLES", "SAMPLE_BUFFERS", "SURFACE_TYPE", "TRANSPARENT_TYPE",
      "TRANSPARENT_BLUE_VALUE", "TRANSPARENT_GREEN_VALUE", "TRANSPARENT_RED_VALUE"
   } do
      egl.eglGetConfigAttrib( dpy, cfg[i], egl["EGL_" .. v:upper()], value )
      print( i, v, value[0] )
   end
end

cfg = cfg[0]

local kd_win = kd.kdCreateWindow( dpy, cfg,  nil )
print( 'kd_win', kd_win )

local kd_size = ffi.new( "KDint32[2]", 640, 480 )
local kd_pos = ffi.new( "KDint32[2]", 10, 10 )
local kd_visible = ffi.new( "KDboolean[1]", 1 )

kd.kdSetWindowPropertyiv( kd_win, kd.KD_WINDOWPROPERTY_SIZE, kd_size )
kd.kdSetWindowPropertybv( kd_win, kd.KD_WINDOWPROPERTY_VISIBILITY, kd_visible )
--kd.kdSetWindowPropertyiv( kd_win, kd.KD_WINDOWPROPERTY_SIZE, kd_size )

local win = ffi.new( "EGLNativeWindowType[1]" )
kd.kdRealizeWindow( kd_win, win )
win = win[0]
print( 'win', win )

local surf = egl.eglCreateWindowSurface ( dpy, cfg, win, nil )
print( 'surf', surf )

local ctx_attr = ffi.new( "EGLint[3]", egl.EGL_CONTEXT_CLIENT_VERSION, 2, egl.EGL_NONE )
local ctx = egl.eglCreateContext( dpy, cfg, nil, ctx_attr )
print( 'context', ctx )

local r = egl.eglMakeCurrent( dpy, surf, surf, ctx )
print( 'make current', r )

local function print_shader_info( shader )
   local length = ffi.new( "GLint[1]" )
   gl.glGetShaderiv( shader, gl.GL_INFO_LOG_LENGTH, length )
   local length = length[0]
   if length <= 0 then
      return
   end
   local buffer = ffi.new( "char[?]", length )
   gl.glGetShaderInfoLog( shader, length, nil, buffer )
   print( ffi.string(buffer) )
   local success = ffi.new( "GLint[1]" )
   gl.glGetShaderiv( shader, gl.GL_COMPILER_STATUS, success )
   local success = succes[0]
   print( 'success', success )
end

local function CHK(f)
   assert(gl.glGetError())
   return f
end

function load_shader( source, gl_shader_type )
   local chk = gl.glGetError()
   assert( gl_shader_type == gl.GL_VERTEX_SHADER or gl_shader_type == gl.GL_FRAGMENT_SHADER )
   local shader = CHK(gl.glCreateShader( gl_shader_type ))
   if shader == 0 then
      return nil
   end
   local text = ffi.new( "GLchar[?]", #source+1, source )
   local text_ptr = ffi.new( "const GLchar*[1]", text )
   local int = ffi.new( "GLint[1]", #source )
   CHK(gl.glShaderSource( shader, 1, text_ptr, int ))
   CHK(gl.glCompileShader( shader ))
   CHK(gl.glGetShaderiv( shader, gl.GL_INFO_LOG_LENGTH, int ))
   local info_log = ffi.new( "GLchar[?]", int[0] )
   CHK(gl.glGetShaderInfoLog( shader, int[0], int, info_log ))
   info_log = ffi.string( info_log, int[0] )
   CHK(gl.glGetShaderiv( shader, gl.GL_COMPILE_STATUS, int ))
   print( status, info_log )
   return shader
--   if status ~= gl.GL_TRUE then
--      return nil, status, info_log
--   end
   --assert(gl.glIsShader(shader) == gl.GL_TRUE)
   --return shader
end
 
local function load_shader2( src, type )
      local shader = gl.glCreateShader( type )
      local ptr = ffi.new( "char[?]", #src, src )
      local ptr2 = ffi.new( "const char*[1]", ptr )
      gl.glShaderSource( shader, 1, ptr2, nil )
      gl.glCompileShader ( shader );
      print_shader_info ( shader );
      return shader
end


local vs = load_shader( vs_src, gl.GL_VERTEX_SHADER )
print( 'vs', vs )

local fs = load_shader( fs_src, gl.GL_FRAGMENT_SHADER )
print( 'fs', fs )

local prog
local loc_position
local loc_phase   
local loc_offset  

if vs ~= nil and fs ~= nil then
   prog = gl.glCreateProgram()
   print( 'prog', prog )
   
   gl.glAttachShader( prog, vs )
   gl.glAttachShader( prog, fs )
   gl.glLinkProgram( prog )
   gl.glUseProgram( prog )
   
   loc_position = gl.glGetAttribLocation( prog, "position" )
   loc_phase    = gl.glGetAttribLocation( prog, "phase" )
   loc_offset   = gl.glGetAttribLocation( prog, "offset" )
   
   print( loc_position, loc_phase, loc_offset )
end

local ww, wh = 800, 480

local phase = 0
local update_pos = true 

local frames = 0

local norm_x, norm_y = 0, 0
local offset_x, offset_y = 0, 0
local p1_pos_x, p1_pos_y = 0, 0

while true do -- frames < 100 do
   frames = frames + 1

   gl.glViewport( 0, 0, ww, wh )
   gl.glClearColor( 0.08, 0.06, 0.07, 1)
   gl.glClear ( gl.GL_COLOR_BUFFER_BIT )
--   gl.glUniform1f( loc_phase, phase )
   phase =  math.fmod( phase + 0.5, 2 * 3.141 )
 
   if update_pos  then
      local old_offset_x  =  offset_x;
      local old_offset_y  =  offset_y;
      
      offset_x  =  norm_x - p1_pos_x;
      offset_y  =  norm_y - p1_pos_y;
 
      p1_pos_x  =  norm_x;
      p1_pos_y  =  norm_y;
 
      offset_x  =  offset_x + old_offset_x;
      offset_y  =  offset_y + old_offset_y;
 
      update_pos = false;
   end
 
--   gl.glUniform4f( loc_offset, offset_x , offset_y, 0.0 , 0.0 )
--   gl.glVertexAttribPointer( loc_position, 3, gl.GL_FLOAT, gl.GL_FALSE, 0, vertexArray )
--   gl.glEnableVertexAttribArray( loc_position )
--   gl.glDrawArrays( gl.GL_TRIANGLE_STRIP, 0, 5 )
 
   egl.eglSwapBuffers( dpy, surf )
end

egl.eglDestroyContext( dpy, ctx )
egl.eglDestroySurface( dpy, surf )
egl.eglTerminate( dpy )
 

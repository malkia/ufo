local ffi = require( "ffi" )
local sdl = require( "ffi/sdl" )
local cr  = require( "ffi/cairo" )
local gl  = require( "ffi/OpenGL" )
local shl, shr, bor, band, min, max = bit.lshift, bit.rshift, bit.bor, bit.band, math.min, math.max

local function handle( type, handlers )
   if handlers[type] then
      return handlers[type]()
   end
end

do
   local sw, sh, running = 640, 480, true
   local mx, my, mb, kb, km = 0, 0, {}, 0, 0
   local evt = ffi.new( "SDL_Event" )
   local screen = sdl.SDL_Init(0xFFFF)
   --   sdl.SDL_GL_SetAttribute( sdl.SDL_GL_DOUBLEBUFFER, 1 )
   evt.type, evt.resize.w, evt.resize.h = sdl.SDL_VIDEORESIZE, sw, sh
   sdl.SDL_PushEvent( evt )
   local surf = ffi.new( "cairo_surface_t*[1]" )
   local data = ffi.new( "char*[1]" )
   local ctx, ctx_surf, ctx_data = nil, nil, nil
   local frame = 0
   while running do
      while sdl.SDL_PollEvent( evt ) > 0 do
	 local ks, mm, bn = evt.key.keysym, evt.motion, evt.button.button
 	 handle(
	    evt.type, {
	       [sdl.SDL_MOUSEMOTION]     = function() mx, my   = mm.x, mm.y     end,
	       [sdl.SDL_MOUSEBUTTONDOWN] = function() mb[ bn ] = true           end,
	       [sdl.SDL_MOUSEBUTTONUP]   = function() mb[ bn ] = false          end,
	       [sdl.SDL_KEYDOWN]         = function() kb, km   = ks.sym, ks.mod end,
	       [sdl.SDL_KEYUP]           = function()
					      if kb == sdl.SDLK_ESCAPE then
						 running = false
					      end
					   end,
	       [sdl.SDL_VIDEORESIZE]=
		  function()
		     sw, sh = evt.resize.w, evt.resize.h
		     screen = sdl.SDL_SetVideoMode(
			sw, sh, 0, 
			bor(sdl.SDL_OPENGL, sdl.SDL_RESIZABLE)
		     )
		     ctx_data = ffi.new( "uint8_t[?]", 4 * sw * sh )
		     ctx_surf = cr.cairo_image_surface_create_for_data(
			ctx_data, cr.CAIRO_FORMAT_ARGB32, sw, sh, 4 * sw
		     )
		     assert( cr.cairo_surface_status( ctx_surf ) == cr.CAIRO_STATUS_SUCCESS )
		     ctx = cr.cairo_create( ctx_surf )
		     assert( cr.cairo_status( ctx ) == cr.CAIRO_STATUS_SUCCESS )
		  end,
	    })
      end
--      sdl.SDL_WM_SetCaption( tostring(frame), nil )
      gl.glViewport( 0, 0, sw, sh )
      gl.glClearColor( 0, 0, (frame/256)%1, 0 )
      gl.glClear(gl.GL_COLOR_BUFFER_BIT)
      sdl.SDL_GL_SwapBuffers()
      frame = frame + 1
   end
   sdl.SDL_Quit()
end

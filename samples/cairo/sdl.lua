local ffi = require( "ffi" )
local sdl = require( "ffi/SDL" )
local cr  = require( "ffi/cairo" )
local gl  = require( "ffi/OpenGL" )
local shl, shr, bor, band, min, max = bit.lshift, bit.rshift, bit.bor, bit.band, math.min, math.max

local function handle( type, handlers )
   if handlers[type] then
      return handlers[type]()
   end
end

do
   local cr_srf, cr_obj
   local sw, sh = 640, 480
   local mx, my, mb, kb, km = 0, 0, {}, 0, 0
   local running, evt = true, ffi.new( "SDL_Event" )
   local screen = sdl.SDL_Init(0xFFFF)
   evt.type, evt.resize.w, evt.resize.h = sdl.SDL_VIDEORESIZE, sw, sh
   sdl.SDL_PushEvent( evt )
   while running do
      while sdl.SDL_PollEvent( evt ) > 0 do
	 local ks, mm, bn = evt.key.keysym, evt.motion, evt.button.button
 	 handle (
	    evt.type, {
	       [sdl.SDL_MOUSEMOTION]     = function() mx, my   = mm.x, mm.y     end,
	       [sdl.SDL_MOUSEBUTTONDOWN] = function() mb[ bn ] = true           end,
	       [sdl.SDL_MOUSEBUTTONUP]   = function() mb[ bn ] = false          end,
	       [sdl.SDL_KEYDOWN]         = function() kb, km   = ks.sym, ks.mod end,
	       [sdl.SDL_KEYUP]           = function() running  = (kb ~= sdl.SDLK_ESCAPE) end,
	       [sdl.SDL_VIDEORESIZE]     =
		  function()
		     sw, sh = evt.resize.w, evt.resize.h
		     screen = sdl.SDL_SetVideoMode( sw, sh, 0, sdl.SDL_RESIZABLE )
		     cr_srf = ffi.gc(
			cr.cairo_image_surface_create( cr.CAIRO_FORMAT_ARGB32, sw, sh ),
			cr.cairo_surface_destroy
		     )
		     cr_ctx = ffi.gc(
			cr.cairo_create( cr_srf ),
			cr.cairo_destroy
		     )
		     sdl.SDL_WM_SetCaption(
			"Cairo testing... " .. tostring(cr_ctx) .. " " .. tostring(cr_srf), nil
		     )
		  end,
	    })
      end
      print( cr_ctx )
      cr.cairo_set_source_rgb(   cr_ctx, 0, 0, 0 )
      cr.cairo_select_font_face( cr_ctx, "Courier New", cr.CAIRO_FONT_SLANT_NORMAL, 0 )
      cr.cairo_set_font_size(    cr_ctx, 60 )
      cr.cairo_move_to(          cr_ctx, 10, 70 )
      cr.cairo_show_text(        cr_ctx, "Some text" )
--      cr.cairo_show_page(        cr_ctx )
      ffi.copy(
	 screen.pixels,
	 cr.cairo_image_surface_get_data( cr_srf ),
	 0 --sw * sh * 2 --sw * sh * 4
      )
      sdl.SDL_Flip( screen )
   end
   sdl.SDL_Quit()
end

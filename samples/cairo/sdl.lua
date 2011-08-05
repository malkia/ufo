local ffi = require( "ffi" )
local sdl = require( "ffi/SDL" )
local cr  = require( "ffi/cairo" )
local random = math.random

local function handle( type, handlers )
   if handlers[type] then
      return handlers[type]()
   end
end

local terminal = {
   lines = {},
   top   = 0,
   left  = 0,
   line  = 1,
   col   = 1,
   font_extents = ffi.new( "cairo_font_extents_t" )
}

function terminal:update( cr_ctx, terminal )
   cr.cairo_save( cr_ctx )
   cr.cairo_font_extents( cr_ctx, self.font_extents )
   local srf = cr.cairo_get_target( cr_ctx )
   cr.cairo_restore( cr_ctx )
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
	       [sdl.SDL_QUIT]            = function() running = false           end,
	       [sdl.SDL_MOUSEMOTION]     = function() mx, my   = mm.x, mm.y     end,
	       [sdl.SDL_MOUSEBUTTONDOWN] = function() mb[ bn ] = true           end,
	       [sdl.SDL_MOUSEBUTTONUP]   = function() mb[ bn ] = false          end,
	       [sdl.SDL_KEYDOWN]         = function() kb, km   = ks.sym, ks.mod end,
	       [sdl.SDL_KEYUP]           = function() running  = (kb ~= sdl.SDLK_ESCAPE) end,
	       [sdl.SDL_VIDEORESIZE]     =
		  function()
		     sw, sh = evt.resize.w, evt.resize.h
		     screen = sdl.SDL_SetVideoMode(
			sw, sh, 32,
			bit.bor(sdl.SDL_DOUBLEBUF, sdl.SDL_RESIZABLE)
		     )
		     cr_srf = ffi.gc(
			cr.cairo_image_surface_create( cr.CAIRO_FORMAT_ARGB32, sw, sh ),
			cr.cairo_surface_destroy
		     )
		     cr_ctx = ffi.gc(
			cr.cairo_create( cr_srf ),
			cr.cairo_destroy
		     )
		     sdl_srf = ffi.gc(
			sdl.SDL_CreateRGBSurfaceFrom(
			   cr.cairo_image_surface_get_data( cr_srf ),
			   sw, sh, 32, cr.cairo_format_stride_for_width( cr.CAIRO_FORMAT_ARGB32, sw ),
			    0,  0,  0,  0
			),
			SDL_FreeSurface
		     )
		     sdl.SDL_WM_SetCaption( "Cairo Testing", nil )
		  end,
	    })
      end

      cr.cairo_set_antialias(      cr_ctx, cr.CAIRO_ANTIALIAS_GRAY )
      cr.cairo_save(               cr_ctx )
      cr.cairo_set_operator(       cr_ctx, cr.CAIRO_OPERATOR_CLEAR )
      cr.cairo_paint(              cr_ctx )
      cr.cairo_restore(            cr_ctx )
      cr.cairo_set_source_rgba(    cr_ctx, random(), random(), random(), random() )
      cr.cairo_select_font_face(   cr_ctx, "Lucida Console", 0, 0 )
      cr.cairo_set_font_size(      cr_ctx, 20 )
      cr.cairo_move_to(            cr_ctx, mx, my )
      cr.cairo_show_text(          cr_ctx, "Some text" )
      cr.cairo_move_to(            cr_ctx, sw/2, sh/2 )
      for i=1,10 do
	 cr.cairo_set_line_width(  cr_ctx, random(i))
	 cr.cairo_set_source_rgba( cr_ctx, random(), random(), random(), random() )
	 cr.cairo_line_to(         cr_ctx, random(mx, my), random(sw-mx, sh-my))
      end
      cr.cairo_stroke(             cr_ctx )

      sdl.SDL_UpperBlit(           sdl_srf, nil, screen, nil )
      sdl.SDL_Flip(                screen )
   end
   sdl.SDL_Quit()
end

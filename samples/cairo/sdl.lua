local ffi = require( "ffi" )
local sdl = require( "ffi/SDL" )
local cr  = require( "ffi/cairo" )
local wm  = require( "lib/wm/sdl" )
local random = math.random

do
   local surf, ctx, sdl_surf

   function wm:resized()
      surf = ffi.gc(
	 cr.cairo_image_surface_create( cr.CAIRO_FORMAT_ARGB32, self.width, self.height ),
	 cr.cairo_surface_destroy
      )
      ctx = ffi.gc(
	 cr.cairo_create( surf ),
	 cr.cairo_destroy
      )
      sdl_surf = ffi.gc(
	 sdl.SDL_CreateRGBSurfaceFrom(
	    cr.cairo_image_surface_get_data( surf ),
	    self.width, self.height, 32,
	    cr.cairo_format_stride_for_width( cr.CAIRO_FORMAT_ARGB32, self.width ),
	    0,  0,  0,  0
	 ),
	 SDL_FreeSurface
      )
      sdl.SDL_WM_SetCaption( "Cairo Testing", nil )
   end

   function wm:key_pressed()
      if self.kb == 27 then
	 wm:exit()
      end
   end

   while wm:update() do
      cr.cairo_set_antialias(      ctx, cr.CAIRO_ANTIALIAS_GRAY )
      cr.cairo_save(               ctx )
      cr.cairo_set_operator(       ctx, cr.CAIRO_OPERATOR_CLEAR )
      cr.cairo_paint(              ctx )
      cr.cairo_restore(            ctx )
      cr.cairo_set_source_rgba(    ctx, random(), random(), random(), random() )
      cr.cairo_select_font_face(   ctx, "Lucida Console", 0, 0 )
      cr.cairo_set_font_size(      ctx, 20 )
      cr.cairo_move_to(            ctx, wm.mx, wm.my )
      cr.cairo_show_text(          ctx, "Some text" )
      cr.cairo_move_to(            ctx, wm.width/2, wm.height/2 )
      for i=1,10 do
	 cr.cairo_set_line_width(  ctx, random(i))
	 cr.cairo_set_source_rgba( ctx, random(), random(), random(), random() )
	 cr.cairo_line_to(         ctx, random(wm.mx, wm.my),
				   random(wm.width-wm.mx, wm.height-wm.my))
      end
      cr.cairo_stroke(             ctx )
      sdl.SDL_UpperBlit(           sdl_surf, nil, wm.window, nil )
   end
end

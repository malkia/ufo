-- http://cairographics.org/operators/
local ffi = require( "ffi" )
local sdl = require( "ffi/SDL" )
local cr  = require( "ffi/cairo" )
local wm  = require( "lib/wm/sdl" )

do
   local format, surf, ctx, sdl_surf = cr.CAIRO_FORMAT_ARGB32

   wm:init(1024,768)
   function wm:resized()
      surf = ffi.gc(
	 cr.cairo_image_surface_create( format, self.width, self.height ),
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
	    cr.cairo_format_stride_for_width( format, self.width ),
	    0,  0,  0,  0
	 ),
	 SDL_FreeSurface
      )
      sdl.SDL_WM_SetCaption( "Cairo Compositing Operators (Porter/Duff)", nil )
   end

   function wm:key_pressed()
      if self.kb == 27 then
	 wm:exit()
      end
   end

   local operator = 0
   local operators = {
      "clear",       "source",         "over",       "in",         "out",      "atop",
      "dest",        "dest_over",      "dest_in",    "dest_out",   "dest_atop", 
      "xor",         "add",            "saturate", 
      "multiply",    "screen",         "overlay",    "darken",     "lighten", 
      "color_dodge", "color_burn",     "hard_light", "soft_light",
      "difference",  "exclusion", 
      "hsl_hue",     "hsl_saturation", "hsl_color",  "hsl_luminosity"
   }

   while wm:update() do
      if wm.kb == 32 or wm.kb == sdl.SDLK_DOWN then
	 operator = (operator + 1) % #operators
      end
      if wm.kb == sdl.SDLK_UP then
	 operator = (operator - 1) % #operators
      end
      wm.kb = 0

      cr.cairo_identity_matrix( ctx )
      cr.cairo_scale( ctx, wm.width/200, wm.height/160 )
      cr.cairo_translate( ctx, 10, 10 )

      cr.cairo_save(               ctx )
      cr.cairo_set_source_rgba(    ctx, 0.5, 0.5, 0.5, 0.5 )
      cr.cairo_set_operator(       ctx, cr.CAIRO_OPERATOR_SOURCE )
      cr.cairo_paint(              ctx )
      cr.cairo_restore(            ctx )

      cr.cairo_save(               ctx )
      cr.cairo_select_font_face(   ctx, "Tahoma", 0, 0 )
      cr.cairo_set_font_size(      ctx, 16 )

      cr.cairo_rectangle( ctx, 0, 0, 120, 90 )
      cr.cairo_set_source_rgba( ctx, 0.7, 0, 0, 0.8 )
      cr.cairo_fill( ctx )

      local operator = operators[ operator % #operators + 1 ]
      local index = cr[ "CAIRO_OPERATOR_" .. operator:upper() ]

      cr.cairo_set_operator( ctx, index )

      cr.cairo_rectangle(       ctx, 40, 30, 120, 90 )
      cr.cairo_set_source_rgba( ctx, 0, 0, 0.9, 0.4  )
      cr.cairo_fill(            ctx )

      cr.cairo_restore( ctx )
      cr.cairo_move_to( ctx, -8, -2 )
      cr.cairo_set_source_rgba( ctx, 1, 1, 1, 1 )
      cr.cairo_show_text( ctx, string.format("%02d 0x%02X", index, index) .. " " .. operator )

      sdl.SDL_UpperBlit( sdl_surf, nil, wm.window, nil )
   end
end

local ffi = require( "ffi" )
local sdl = require( "ffi/sdl" )
local cr  = require( "ffi/cairo" )
local wm  = require( "lib/wm/sdl" )
local random = math.random

local lines = {{ x=0, y=0, solid = false }}

local function make_colors(n)
   n = n or 16
   local colors = {}
   for i=1, n do
      local r = random(0.1,0.9)
      local g = random(0.1,0.9)
      local b = random(0.1,0.9)
      local mag = r*r + g*g + b*b
      local oolen = 1 / math.sqrt(mag)
      r, g, b = r*oolen, g*oolen, b*oolen
      v = { random(), random(), random() }
      v[random(1,#v)] = 0.25
      v[random(1,#v)] = 0.75
      colors[#colors+1] = { r*v[1], g*v[1], b*v[2], 1 }
   end
   return colors
end

do
   local format, surf, ctx, sdl_surf = cr.CAIRO_FORMAT_ARGB32

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
      sdl.SDL_WM_SetCaption( "Cairo Testing", nil )
   end

   function wm:key_pressed()
      if self.kb == 27 then
	 wm:exit()
      end
   end

   local colors = make_colors()

   while wm:update(true) do
      cr.cairo_save(               ctx )
      cr.cairo_set_operator(       ctx, cr.CAIRO_OPERATOR_CLEAR )
      cr.cairo_paint(              ctx )
      cr.cairo_set_source_rgba(    ctx, 1, 1, 1, 1 )
      cr.cairo_restore(            ctx )

      cr.cairo_select_font_face(   ctx, "Terminal", 0, 0 )
      cr.cairo_set_font_size(      ctx, 16 )
      cr.cairo_move_to(            ctx, 0, 16 )
      cr.cairo_set_source_rgba(    ctx, 1, 1, 1, 1 )
      cr.cairo_show_text(          ctx, tostring( #lines ))

      cr.cairo_set_line_width(     ctx, 1+math.sqrt(math.max(1,wm.wheel/16)))

      local color = 0
      for i=1,#lines do
	 local point = lines[i]
	 if i > 1 and lines[i-1].solid then
	    cr.cairo_line_to(      ctx, point.x, point.y )
	 else
	    cr.cairo_move_to(      ctx, point.x, point.y )
	    cr.cairo_stroke(  ctx )
--	    cr.cairo_set_line_width( ctx, random()*3 + math.sqrt(math.max(1,wm.wheel/16)))
	    color = color + 1
	    local color = colors[ color % #colors + 1 ]
	    cr.cairo_set_source_rgba( ctx, color[1], color[2], color[3], color[4] )
	 end
      end
      cr.cairo_stroke(  ctx )

      if wm.mb[1] then
	 local dx = lines[ #lines ].x - wm.mx
	 local dy = lines[ #lines ].y - wm.my
	 if math.abs(dx) > 1 or math.abs(dy) > 1 then
	    lines[ #lines + 1 ] = { x = wm.mx, y = wm.my, solid=true, color = random() }
	 end
      elseif lines[ #lines ].solid then
	 lines[ #lines + 1 ] = { x=wm.mx, y=wm.my, solid=false, color = random() }
      end

      if wm.mb[3] then
	 lines = {{ x=wm.mx, y = wm.my, solid=true }}
	 colors = make_colors()
      end

      sdl.SDL_UpperBlit( sdl_surf, nil, wm.window, nil )
   end
end

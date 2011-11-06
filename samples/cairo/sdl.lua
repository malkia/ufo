local ffi = require( "ffi" )
local sdl = require( "ffi/sdl" )
local cr  = require( "ffi/cairo" )
local wm  = require( "lib/wm/sdl" )
local random, floor, pi = math.random, math.floor, math.pi

local lines = {{ x=0, y=0, solid = false }}

local gfx = {}

-- From the cairo cookbook
-- http://cairographics.org/cookbook/roundedrectangles/
function gfx:round_rect_a(x,y,width,height,radius)
   local radius = radius or 5 -- an approximate curvature radius
   local half_radius = radius * 0.5
   local double_radius = radius + radius
   local x0, y0 = x, y -- + half_radius, y + half_radius
   local x1, y1 = x0+width, y0+height
   local ctx = gfx.ctx

   if width < double_radius then 
      if height < double_radius then
	 cr.cairo_move_to(  ctx, x0, (y0 + y1) * 0.5 )
	 cr.cairo_curve_to( ctx, x0, y0, x0, y0, (x0 + x1) * 0.5, y0 )
	 cr.cairo_curve_to( ctx, x1, y0, x1, y0, x1, (y0 + y1) * 0.5 )
	 cr.cairo_curve_to( ctx, x1, y1, x1, y1, (x1 + x0) * 0.5, y1 )
	 cr.cairo_curve_to( ctx, x0, y1, x0, y1, x0, (y0 + y1) * 0.5 )
      else 
	 cr.cairo_move_to(  ctx, x0, y0 + radius )
	 cr.cairo_curve_to( ctx, x0 ,y0, x0, y0, (x0 + x1)/2, y0 )
	 cr.cairo_curve_to( ctx, x1, y0, x1, y0, x1, y0 + radius )
	 cr.cairo_line_to(  ctx, x1, y1 - radius )
	 cr.cairo_curve_to( ctx, x1, y1, x1, y1, (x1 + x0)/2, y1 )
	 cr.cairo_curve_to( ctx, x0, y1, x0, y1, x0, y1- radius )
      end
   else
      if height < double_radius then
	 cr.cairo_move_to(  ctx, x0, (y0 + y1)/2 )
	 cr.cairo_curve_to( ctx, x0 , y0, x0 , y0, x0 + radius, y0 )
	 cr.cairo_line_to(  ctx, x1 - radius, y0 )
	 cr.cairo_curve_to( ctx, x1, y0, x1, y0, x1, (y0 + y1)/2 )
	 cr.cairo_curve_to( ctx, x1, y1, x1, y1, x1 - radius, y1 )
	 cr.cairo_line_to(  ctx, x0 + radius, y1 )
	 cr.cairo_curve_to( ctx, x0, y1, x0, y1, x0, (y0 + y1)/2 )
      else
	 cr.cairo_move_to(  ctx, x0, y0 + radius)
	 cr.cairo_curve_to( ctx, x0 , y0, x0 , y0, x0 + radius, y0)
	 cr.cairo_line_to(  ctx, x1 - radius, y0)
	 cr.cairo_curve_to( ctx, x1, y0, x1, y0, x1, y0 + radius)
	 cr.cairo_line_to(  ctx, x1, y1 - radius)
	 cr.cairo_curve_to( ctx, x1, y1, x1, y1, x1 - radius, y1)
	 cr.cairo_line_to(  ctx, x0 + radius, y1)
	 cr.cairo_curve_to( ctx, x0, y1, x0, y1, x0, y1- radius)
      end
   end
end

function gfx:round_rect_b(x,y,w,h,radius_x,radius_y)
   -- http://graphics.stanford.edu/courses/cs248-98-fall/Final/q1.html
   local ARC_TO_BEZIER = 0.55228475
   local radius_x = radius_x or 5
   local radius_y = radius_y or 5

   if radius_x > w - radius_x then
      radius_x = w * 0.5
   end

   if radius_y > h - radius_y then
      radius_y = h * 0.5
   end

   -- approximate (quite close) the arc using a bezier curve
   local c1 = ARC_TO_BEZIER * radius_x
   local c2 = ARC_TO_BEZIER * radius_y
   local ctx = gfx.ctx

   cr.cairo_move_to(      ctx, x + radius_x, y )
   cr.cairo_rel_line_to(  ctx, w - 2 * radius_x, 0.0 )
   cr.cairo_rel_curve_to( ctx, c1, 0.0, radius_x, c2, radius_x, radius_y )
   cr.cairo_rel_line_to(  ctx, 0, h - 2 * radius_y )
   cr.cairo_rel_curve_to( ctx, 0, c2, c1 - radius_x, radius_y, -radius_x, radius_y )
   cr.cairo_rel_line_to(  ctx, -w + 2 * radius_x, 0 )
   cr.cairo_rel_curve_to( ctx, -c1, 0, -radius_x, -c2, -radius_x, -radius_y )
   cr.cairo_rel_line_to(  ctx,   0, -h + 2 * radius_y )
   cr.cairo_rel_curve_to( ctx,   0, -c2, radius_x - c1, -radius_y, radius_x, -radius_y )
end

function gfx:round_rect_c(x, y, w, h, r)
   local r = r or 5
   local ctx = self.ctx
   cr.cairo_move_to(  ctx, x  +r, y                            )                  
   cr.cairo_line_to(  ctx, x+w-r, y                            )                
   cr.cairo_curve_to( ctx, x+w,   y,    x+w, y,   x+w,   y  +r ) 
   cr.cairo_line_to(  ctx, x+w,   y+h-r                        )           
   cr.cairo_curve_to( ctx, x+w,   y+h,  x+w, y+h, x+w-r, y+h   )
   cr.cairo_line_to(  ctx, x  +r, y+h                          )                   
   cr.cairo_curve_to( ctx, x,     y+h,  x,   y+h, x,     y+h-r )      
   cr.cairo_line_to(  ctx, x,     y  +r                        )                     
   cr.cairo_curve_to( ctx, x,     y,    x,   y,   x  +r, y     )            
end

function gfx:round_rect_d(x, y, w, h, r)
   local r = r or 5
   local half_pi = pi * 0.5
   local ctx = gfx.ctx
   cr.cairo_arc( ctx, x     + r, y     + r, r, 2*half_pi, 3*half_pi )
   cr.cairo_arc( ctx, x + w - r, y     + r, r, 3*half_pi, 4*half_pi )
   cr.cairo_arc( ctx, x + w - r, y + h - r, r, 0*half_pi, 1*half_pi )
   cr.cairo_arc( ctx, x     + r, y + h - r, r, 1*half_pi, 2*half_pi )
end

-- items is meta structure
function gfx:list_box(x, y, w, h, items)
   local ctx = gfx.ctx
   local eh = 24 -- element height
   local ev = floor( h / eh ) -- elements visible
   local top = items.top or 1
   local bottom = items.bottom or #items
   local current = items.current or 1

   -- Make the rectangle path
   cr.cairo_new_path( ctx )
   cr.cairo_rectangle( ctx, x, y, w, h )
   cr.cairo_close_path( ctx )

   -- Fill it first, but preserve the path
   cr.cairo_set_source_rgb( ctx, 0.125, 0.25, 1 ) -- listbox background color
   cr.cairo_fill_preserve( ctx )

   -- Next stroke it, and preserve the path
   cr.cairo_set_source_rgb( ctx, 1, 1, 0 ) -- listbox "wire" color
   cr.cairo_stroke_preserve( ctx )

   -- Now set the clip, do not keep the path
   cr.cairo_clip( ctx )
   for i=1, ev do
	 local y = y + (i - top) * eh
	 local current = (i == current)
	 if current then
	    cr.cairo_new_path(       ctx )
	    cr.cairo_move_to(        ctx,  x,  y )
	    cr.cairo_rel_line_to(    ctx,  w,  0 )
	    cr.cairo_rel_line_to(    ctx,  0, eh )
	    cr.cairo_rel_line_to(    ctx, -w,  0 )
	    cr.cairo_close_path(     ctx )
	    cr.cairo_set_source_rgb( ctx, 0.75, 0, 0.5 )
	    cr.cairo_fill_preserve(  ctx )
	    cr.cairo_set_source_rgb( ctx, 0.75, 1, 0.5 )
	    cr.cairo_stroke(         ctx )
	 end
	 cr.cairo_move_to(        ctx, x + 8, y + eh * 0.8 )
	 cr.cairo_set_source_rgb( ctx, current and 1 or 0, 1, selected and 1 or 0 )
	 cr.cairo_show_text(      ctx, items[i] )
   end
   cr.cairo_reset_clip( ctx )
end

local items = {
   "First Item",
   "Secod Item",
   "Third Item",
   "Fourth Item",
   "Fifth Item",
   "Third Item 1",
   "Fourth Item 2",
   "Fifth Item 3",
   "Third Item 4",
   "Fourth Item 5",
   "Fifth Item 6",
   "Third Item 7",
   "Fourth Item 8",
   "Fifth Item 9",
   selected = { 3, 5 },
   current = 2,
}

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
      sdl.SDL_WM_SetCaption( "Cairo Testing", nil )

      gfx.ctx = ctx
      gfx.surf = surf
   end

   function wm:key_pressed()
      if self.kb == 27 then
	 wm:exit()
      end
   end

   local colors = make_colors()

   local frame = 0 

   while wm:update(false) do
      cr.cairo_save(               ctx )
      cr.cairo_set_operator(       ctx, cr.CAIRO_OPERATOR_CLEAR )
      cr.cairo_paint(              ctx )
      cr.cairo_set_source_rgba(    ctx, 1, 1, 1, 1 )
      cr.cairo_restore(            ctx )

      cr.cairo_select_font_face(   ctx, "Tahoma", 0, 0 )
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
      
      local bw, bh = 32 + 16 + frame,32 + frame
      local cols, rows = floor(wm.width / bw) + 1, floor(wm.height / bh) + 1
      cols, rows = 4, 4
      for i=0, cols*rows - 1 do
	 local col, row = floor(i / rows), (i % rows)
	 local x, y = col * bw, row * bh
	 local inset = 10
	 local method = (i % 4 + 1) --random(1,4)
	 cr.cairo_set_source_rgba(    ctx, 1, 1, 1, 1 )

	 cr.cairo_new_path( gfx.ctx )
	 gfx["round_rect_"..string.char(32+64+method)](gfx, x+inset, y+inset, bw-inset, bh-inset, bh / 3 )
	 cr.cairo_close_path( gfx.ctx )
	 if i % 3 ~= 0 then
	    cr.cairo_stroke( gfx.ctx )
	 else
	    local color = colors[ i % #colors + 1 ]
	    cr.cairo_set_source_rgba( ctx, color[1], color[2], color[3], color[4] )
	    cr.cairo_fill( gfx.ctx )
	    cr.cairo_new_path( gfx.ctx )
	    gfx["round_rect_"..string.char(32+64+method)](gfx, x+inset, y+inset, bw-inset, bh-inset, bh / 3 )
	    cr.cairo_close_path( gfx.ctx )
	    cr.cairo_set_source_rgba(    ctx, 1, 1, 1, 1 )
	    cr.cairo_stroke( gfx.ctx )
	 end

	 local current = items.current - 1

	 if wm.kb == 0x40000052 then
	    items.current = (current - 1) % #items + 1
	 elseif wm.kb == 0x40000051 then
	    items.current = (current + 1) % #items + 1
	 end
	 wm.kb = 0

	 gfx:list_box( 10, wm.height/2, 100, 200, items )
	 
	 cr.cairo_move_to(            ctx, x + 22, y + bh * 0.8 )
	 local p = i %8 + 2
	 cr.cairo_set_font_size(      ctx, (bh * 0.5) )
	 cr.cairo_show_text(          ctx, "Aa" )
      end

      sdl.SDL_UpperBlit( sdl_surf, nil, wm.window, nil )

--      frame = frame + 0.1 -- + 0.025
   end
end

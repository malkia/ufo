local ffi = require( "ffi" )
local sdl = require( "ffi/SDL" )
local cr  = require( "ffi/cairo" )
local wm  = require( "lib/wm/sdl" )
local random, floor = math.random, math.floor

local lines = {{ x=0, y=0, solid = false }}

local gfx = {}

-- From the cairo cookbook
-- http://cairographics.org/cookbook/roundedrectangles/
function gfx:round_rect_a(x,y,width,height,radius)
   local radius = radius or 5 -- an approximate curvature radius
   local half_radius = radius * 0.5
   local double_radius = radius + radius
   local x0, y0 = x + half_radius, y + half_radius
   local rect_width  = width - radius
   local rect_height = height - radius
   local ctx = gfx.ctx

   cr.cairo_save(ctx)
   -- cr.set_line_width (0.04)
   -- self.snippet_normalize(cr, width, height)

   local x1, y1 = x0+rect_width, y0+rect_height

   -- if rect_width==0 or rect_height==0
   --    return
   -- end

   if rect_width < double_radius then 
      if rect_height < double_radius then
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
      if rect_height < double_radius then
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
   cr.cairo_close_path(ctx)
   cr.cairo_restore(ctx)   
end

function gfx:round_rect_b(x,y,w,h,radius_x,radius_y)
   -- http://graphics.stanford.edu/courses/cs248-98-fall/Final/q1.html
   local ARC_TO_BEZIER = 0.55228475
   local radius_x = radius_x or 5
   local radius_y = radius_y or 5

   if radius_x > w - radius_x then
      radius_x = w / 2
   end

   if radius_y > h - radius_y then
      radius_y = h / 2
   end

   -- approximate (quite close) the arc using a bezier curve
   local c1 = ARC_TO_BEZIER * radius_x
   local c2 = ARC_TO_BEZIER * radius_y
   local ctx = gfx.ctx

   cr.cairo_save( ctx )
   cr.cairo_new_path(     ctx )
   cr.cairo_move_to(      ctx, x + radius_x, y )
   cr.cairo_rel_line_to(  ctx, w - 2 * radius_x, 0.0 )
   cr.cairo_rel_curve_to( ctx, c1, 0.0, radius_x, c2, radius_x, radius_y )
   cr.cairo_rel_line_to(  ctx, 0, h - 2 * radius_y )
   cr.cairo_rel_curve_to( ctx, 0, c2, c1 - radius_x, radius_y, -radius_x, radius_y )
   cr.cairo_rel_line_to(  ctx, -w + 2 * radius_x, 0 )
   cr.cairo_rel_curve_to( ctx, -c1, 0, -radius_x, -c2, -radius_x, -radius_y )
   cr.cairo_rel_line_to(  ctx, 0, -h + 2 * radius_y )
   cr.cairo_rel_curve_to( ctx, 0, -c2, radius_x - c1, -radius_y, radius_x, -radius_y )
   cr.cairo_close_path(   ctx  )
   cr.cairo_restore( ctx )
end

function gfx:round_rect_d(x, y, w, h, radius)
   local radius = radius or 1000
   local half_pi = math.pi * 0.5
   local a, b, c, d = x, x + w, y, y + h
   local ctx = gfx.ctx
   cr.cairo_new_path( ctx )
   cr.cairo_arc( ctx, a + radius, c + radius, radius, 2*half_pi, 3*half_pi)
   cr.cairo_arc( ctx, b - radius, c + radius, radius, 3*half_pi, 4*half_pi)
   cr.cairo_arc( ctx, b - radius, d - radius, radius, 0*half_pi, 1*half_pi)
   cr.cairo_arc( ctx, a + radius, d - radius, radius, 1*half_pi, 2*half_pi)
   cr.cairo_close_path( ctx )
   cr.cairo_stroke( ctx )
end

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

      cr.cairo_select_font_face(   ctx, "", 0, 0 )
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
      
      local bw, bh = 128 + 16 + frame*4,32 + frame
      local cols, rows = floor(wm.width / bw) + 1, floor(wm.height / bh) + 1
      for i=0, cols*rows - 1 do
	 local col, row = floor(i / rows), (i % rows)
	 local x, y = col * bw, row * bh
	 local inset = 10
	 gfx:round_rect_d( x+inset, y+inset, bw-inset, bh-inset, bh / 3 )
	 cr.cairo_move_to(            ctx, x + 20, y + bh * 0.75 )
	 cr.cairo_set_source_rgba(    ctx, 1, 1, 1, 1 )
	 local p = i %8 + 2
	 cr.cairo_set_font_size(      ctx, bh * 0.5 )
	 cr.cairo_show_text(          ctx, "AaBbCc DdEeFf" )
      end

      sdl.SDL_UpperBlit( sdl_surf, nil, wm.window, nil )

      frame = frame + 0.025
   end
end

local random = math.random

local ffi = require( "ffi" )
local cr = require( "ffi/cairo" )
local world = require( "samples/cairo/world-map-data" )

local function CHK(ctx)
   local error = cr.cairo_status(ctx)
   if error ~= 0 then
      print( 'cairo error: ', error )
   end
end

local WIDTH, HEIGHT = 800, 400
local data = ffi.new( "uint8_t[?]", WIDTH*HEIGHT*4 )
local tests = { "pdf", "svg", "png" }

local function test1(ctx)
   cr.cairo_set_source_rgba(      ctx, 0, 0.5, 1, 1 );                             CHK(ctx)
   cr.cairo_select_font_face(     ctx, "Verdana", cr.CAIRO_FONT_SLANT_NORMAL, 0 ); CHK(ctx)
   cr.cairo_set_font_size(        ctx, 20 );                                       CHK(ctx)
   cr.cairo_set_line_width(       ctx, 10 );                                       CHK(ctx)
   cr.cairo_move_to(              ctx, 320, 240 );                                 CHK(ctx)
   for i=1,10 do
      cr.cairo_set_source_rgba(   ctx, random(), random(), random(), random() );   CHK(ctx)
      cr.cairo_line_to(           ctx, random(40,600), random(80,400) );           CHK(ctx)
      cr.cairo_show_text(         ctx, tostring(i));                               CHK(ctx)
   end
   cr.cairo_stroke(               ctx  );                                          CHK(ctx)
   cr.cairo_show_page(            ctx  );                                          CHK(ctx)
end

local function test2( ctx, fill, stroke )
   cr.cairo_set_line_width( ctx, 0.2 );                                     CHK(ctx)
   cr.cairo_set_source_rgb( ctx, 0.68, 0.85, 0.90 );                        CHK(ctx)
   cr.cairo_rectangle(      ctx, 0, 0, WIDTH, HEIGHT );                     CHK(ctx)
   cr.cairo_fill(           ctx  );                                         CHK(ctx)
   local cx = ffi.new("double[1]")
   local cy = ffi.new("double[1]")
   local switch = {
      new_path    = function(x,y)
		       if fill then
			  cr.cairo_set_source_rgb( ctx, 0.75, 0.75, 0.75 ); CHK(ctx)
			  cr.cairo_fill_preserve(  ctx  );                  CHK(ctx)
		       end
		       if stroke then
			  cr.cairo_set_source_rgb( ctx, 0.50, 0.50, 0.50 ); CHK(ctx)
			  cr.cairo_stroke(         ctx  );                  CHK(ctx)
		       end
		       cr.cairo_new_path(          ctx  );                  CHK(ctx)
		       cr.cairo_move_to(           ctx, x, y );             CHK(ctx)
		    end,
      ["end"]     = function(x,y,switch)
		       switch.new_path( x, y );                             CHK(ctx)
		       return true
		    end,
      move_to     = function(x,y)
		       cr.cairo_close_path( ctx );                          CHK(ctx)
		       cr.cairo_move_to(    ctx, x, y );                    CHK(ctx)
		    end,
      line_to     = function(x,y)
		       cr.cairo_line_to(    ctx, x, y );                    CHK(ctx)
		    end,
      hline_to    = function(x,y)
		       cr.cairo_get_current_point( ctx, cx, cy );           CHK(ctx)
		       cr.cairo_line_to(           ctx, x,  cy[0] );        CHK(ctx)
		    end,
      vline_to    = function(x,y)
		       cr.cairo_get_current_point( ctx, cx, cy );           CHK(ctx)
		       cr.cairo_line_to(           ctx, cx[0], y );         CHK(ctx)
		    end,
      rel_line_to = function(x,y)
		       cr.cairo_rel_line_to( ctx, x, y );                   CHK(ctx)
		    end,
   }
   for _, cmd in ipairs(world) do
      if switch[ cmd[1] ]( cmd[2], cmd[3], switch ) then
	 return
      end
   end
   cr.cairo_new_path( ctx );                                                CHK(ctx)
end

for _, ext in ipairs( tests ) do
   local sf
   if ext == "png" then
      sf = cr.cairo_image_surface_create_for_data( data, cr.CAIRO_FORMAT_ARGB32, WIDTH, HEIGHT, WIDTH*4 );
   else
      sf = cr[ "cairo_" .. ext .. "_surface_create" ]( "world-map." .. ext, WIDTH, HEIGHT )
   end
   local ctx = cr.cairo_create( sf ); CHK(ctx)

--   test1(ctx)
   test2(ctx,true)
   test2(ctx,false,true)
   test2(ctx,true,true)

   if ext == "png" then
      cr.cairo_surface_write_to_png( sf, "world-map." .. ext ); CHK(ctx)
   end
   cr.cairo_destroy( ctx );
   cr.cairo_surface_destroy( sf );

   print( 'created world-map.' .. ext )
end

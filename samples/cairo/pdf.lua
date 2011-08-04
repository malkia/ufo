local random = math.random

local ffi = require( "ffi" )
local cr = require( "ffi/cairo" )

local function CHK(cx)
   print( cr.cairo_status(cx) )
end

print( cr.cairo_version() )

local data = ffi.new( "uint8_t[?]", 640*480*4 )

--local sf = cr.cairo_pdf_surface_create( "TEST.PDF", 566.9, 793.7 ) -- 200x280 mm hCairo
--local sf = cr.cairo_svg_surface_create( "TEST.SVG", 566.9, 793.7 ) -- 200x280 mm hCairo
local sf = cr.cairo_image_surface_create_for_data( data, cr.CAIRO_FORMAT_ARGB32, 640, 480, 640*4 ) -- 200x280 mm hCairo
print( sf, cr.cairo_image_surface_get_data( sf ), data )

for i=0, 4 do
   print(i, cr.cairo_format_stride_for_width(i, 33))
end

--if true then return end
local cx = cr.cairo_create(               sf ); CHK(cx)
           cr.cairo_set_source_rgba(      cx, 0, 0.5, 1, 1 ); CHK(cx)
	   cr.cairo_select_font_face(     cx, "Verdana", cr.CAIRO_FONT_SLANT_NORMAL, 0 ); CHK(cx)
	   cr.cairo_set_font_size(        cx, 20 ); CHK(cx)
	   cr.cairo_set_line_width(       cx, 10 ); CHK(cx)
	   cr.cairo_move_to(              cx, 320, 240 ); CHK(cx)
	   for i=1,10 do
	      cr.cairo_set_source_rgba(   cx, random(), random(), random(), random() ); CHK(cx)
	      cr.cairo_line_to(           cx, random(40,600), random(80,400) ); CHK(cx)
--	      cr.cairo_show_text(         cx, tostring(i))
	   end
	   cr.cairo_stroke(               cx ); CHK(cx)
	   cr.cairo_show_page(            cx ); CHK(cx)
--	   cr.cairo_surface_write_to_png( sf, "TEST.PNG" ); CHK(cx)
	   cr.cairo_destroy(              cx );
	   cr.cairo_surface_destroy(      sf );

local cr = require( "ffi/cairo" )
--local sf = cr.cairo_pdf_surface_create( "TEST.PDF", 566.9, 793.7 ) -- 200x280 mm hCairo
local sf = cr.cairo_svg_surface_create( "TEST.SVG", 566.9, 793.7 ) -- 200x280 mm hCairo
--local sf = cr.cairo_image_surface_create( cr.CAIRO_FORMAT_ARGB32, 640, 480 ) -- 200x280 mm hCairo
local cx = cr.cairo_create(               sf )
           cr.cairo_set_source_rgb(       cx, 0, 0, 0 )
	   cr.cairo_select_font_face(     cx, "Courier New", cr.CAIRO_FONT_SLANT_NORMAL, 0 )
	   cr.cairo_set_font_size(        cx, 60 )
	   cr.cairo_move_to(              cx, 10, 70 )
	   cr.cairo_show_text(            cx, "Some text" )
	   cr.cairo_show_page(            cx )
	   cr.cairo_destroy(              cx )
--	   cr.cairo_surface_write_to_png( sf, "TEST.PNG" )
	   cr.cairo_surface_destroy(      sf )

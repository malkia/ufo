local random = math.random

local ffi = require( "ffi" )
local cr = require( "ffi/cairo" )

local function CHK(cx)
   print( cr.cairo_status(cx) )
end

print( cr.cairo_version() )

local data = ffi.new( "uint8_t[?]", 640*480*4 )
local tests = { "pdf", "svg", "png" }

for _, ext in ipairs( tests ) do
   local sf
   if ext == "png" then
      sf = cr.cairo_image_surface_create_for_data( data, cr.CAIRO_FORMAT_ARGB32, 640, 480, 640*4 )
   else
      sf = cr[ "cairo_" .. ext .. "_surface_create" ]( "test." .. ext, 566.9, 793.7 )
   end
   local cx = cr.cairo_create(    sf ); CHK(cx)
   cr.cairo_set_source_rgba(      cx, 0, 0.5, 1, 1 ); CHK(cx)
   cr.cairo_select_font_face(     cx, "Verdana", cr.CAIRO_FONT_SLANT_NORMAL, 0 ); CHK(cx)
   cr.cairo_set_font_size(        cx, 20 ); CHK(cx)
   cr.cairo_set_line_width(       cx, 10 ); CHK(cx)
   cr.cairo_move_to(              cx, 320, 240 ); CHK(cx)
   for i=1,10 do
      cr.cairo_set_source_rgba(   cx, random(), random(), random(), random() ); CHK(cx)
      cr.cairo_line_to(           cx, random(40,600), random(80,400) ); CHK(cx)
      cr.cairo_show_text(         cx, tostring(i))
   end
   cr.cairo_stroke(               cx ); CHK(cx)
   cr.cairo_show_page(            cx ); CHK(cx)
   if ext == "png" then
      cr.cairo_surface_write_to_png( sf, "test." .. ext ); CHK(cx)
   end
   cr.cairo_destroy(              cx );
   cr.cairo_surface_destroy(      sf );
end

local sdl = require( "ffi/SDL" )
local cr = require( "ffi/cairo" )
local wm = require( "lib/wm/sdl" )

local function resized(self)
   local format = cr.CAIRO_FORMAT_ARGB32
   local surface = {
      cr.cairo_image_surface_create( format, self.width, self.height ),
      cr.cairo_surface_destroy
   )
   local context = ffi.gc(
      cr.cairo_create( surface ),
      cr.cairo_destroy
   )
   local sdl_surface = ffi.gc(
      sdl.SDL_CreateRGBSurfaceFrom(
	 cr.cairo_image_surface_get_data( surface ),
	 self.width, self.height, 32,
	 cr.cairo_format_stride_for_width( format, self.width ),
	 0,  0,  0,  0
      ),
      sdl.SDL_FreeSurface
   )
   local cairo = {
      sdl_surface = sdl_surface,
      context = context,
      surface = surface,
   }
   wm.cairo = cairo
end

return wm
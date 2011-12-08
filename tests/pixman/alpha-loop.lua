local ffi = require( "ffi" )
local pm = require( "ffi/pixman" )

local WIDTH, HEIGHT = 400, 200

local function make_random_bytes( size )
   local bytes = ffi.new( "uint8_t[?]", size )
   for i=0, size-1 do
      bytes[i] = math.random(0,255)
   end
   return bytes
end

local alpha = make_random_bytes( WIDTH * HEIGHT )
local src   = ffi.cast( "uint32_t*", make_random_bytes( WIDTH * HEIGHT * 4 ))
local dest  = ffi.cast( "uint32_t*", make_random_bytes( WIDTH * HEIGHT * 4 ))

local a = pm.pixman_image_create_bits( pm.PIXMAN_a8, WIDTH, HEIGHT, ffi.cast( "uint32_t*", alpha ), WIDTH )
local d = pm.pixman_image_create_bits( pm.PIXMAN_a8r8g8b8, WIDTH, HEIGHT, dest, WIDTH * 4 )
local s = pm.pixman_image_create_bits( pm.PIXMAN_a2r10g10b10, WIDTH, HEIGHT, src, WIDTH * 4 )

pm.pixman_image_set_alpha_map( s, a, 0, 0 )
pm.pixman_image_set_alpha_map( a, s, 0, 0 )
pm.pixman_image_composite( pm.PIXMAN_OP_SRC, s, NULL, d, 0, 0, 0, 0, 0, 0, WIDTH, HEIGHT ) 
pm.pixman_image_unref( s )

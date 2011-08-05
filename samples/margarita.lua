local ffi = require( "ffi" )
local wm = require( "lib/wm/sdl" )
local cos, sin, abs, sqrt, atan2, pi = math.cos, math.sin, math.abs, math.sqrt, math.atan2, math.pi

-- http://playingwithmathematica.com/2011/06/17/friday-fun-6/#more-413
local function margarita_shader( x, y )
   local z = sqrt( x*x + y*y ) - 3.5 * atan2(y, x) + sin(x) + cos(y)
   if z % (3.1415926535898 * 7) < 1.5707963267949 then
      return 0xFF0000
   end
   if z % 3.1415926535898 < 1.5707963267949 then
      return 0
   end
   return 0xFFFFFF
end

local uint32ptr = ffi.typeof( "uint32_t*" )
local function render( screen )
    local pixels_u32 = ffi.cast( uint32ptr, screen.pixels )
    local width, height, pitch = screen.w, screen.h, screen.pitch / 4
    local halfw, halfh = width/2, height/2
    local oow, ooh = 1/width, 1/height
    for i = 0, height-1 do
       for j = 0, width-1 do
	  pixels_u32[ j + i*pitch ] = margarita_shader( (j-halfw)*oow*40, (halfh-i)*ooh*40 )
       end
    end
end

wm:init(512,512)
while wm:update() do
   render( wm.window )
   if wm.kb == 27 then
      wm:exit()
   end
end

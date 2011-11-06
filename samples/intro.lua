local ffi = require( "ffi" )
local sdl = require( "ffi/sdl" )
local wm = require( "lib/wm/sdl" )
local uint32ptr = ffi.typeof( "uint32_t*" )
local cos, sin, abs, sqrt, band, bor, bxor, shl, shr, rol, ror = math.cos, math.sin, math.abs, math.sqrt, bit.band, bit.bor, bit.bxor, bit.lshift, bit.rshift, bit.rol, bit.ror

local function intro_shader(x,y,tick,cos,sin)
   local xx, yy, xy = x*x, y*y, x*y
   return bxor(band(tick*xy,tick*yy,tick*xx),xx+y*tick+xx*cos-yy*sin,yy+x*tick+xx*sin+yy*cos)
end

local function render( screen, tick )
    local pixels_u32 = ffi.cast( uint32ptr, screen.pixels )
    local width, height, pitch = screen.w, screen.h, screen.pitch / 4
    local halfw, halfh = width/2, height/2
    local oow, ooh = 1/width, 1/height
    local cos, sin = cos(tick/128), sin(tick/128)
    for i = 0, height-1 do
       for j = 0, width-1 do
	  pixels_u32[ j + i*pitch ] = intro_shader(j-halfw, i-halfh,tick,cos,sin)
       end
    end
end

do
   local prev_time, curr_time, fps = nil, 0, 0, 0, 0

   local ticks_base, ticks = 256 * 128, 0, 0
   local bounce_mode, bounce_range, bounce_delta, bounce_step = false, 1024, 0, 1

   while wm:update() do
      local event = wm.event
      local sym, mod = event.key.keysym.sym, event.key.keysym.mod
      if wm.kb == 13 then
	 sdl.SDL_WM_ToggleFullScreen( wm.window )
      end

      if wm.kb == 27 then
	 wm:exit()
	 break
      end

      if wm.kb == 32 then
	 bounce_mode = not bounce_mode
	 ticks_base = ticks + ticks_base
      end

      if wm.kb == ("o"):byte() then
	 ticks_base = ticks_base - 100
      end

      if wm.kb == ("p"):byte() then
	 ticks_base = ticks_base + 100
      end

      if ticks_base > 256 * 256 * 256 then
	 ticks_base = 0
      end

      if bounce_mode then
	 if abs( bounce_delta ) > bounce_range then
	    bounce_step = -bounce_step
	 end
	 bounce_delta = bounce_delta + bounce_step
	 ticks = ticks_base + bounce_delta
      else
	 ticks = sdl.SDL_GetTicks()
      end

      -- Render the screen, and flip it
      render( wm.window, ticks + ticks_base )

      -- Calculate the frame rate
      prev_time, curr_time = curr_time, os.clock()
      local diff = curr_time - prev_time + 0.00001
      local real_fps = 1/diff
      if abs( fps - real_fps ) * 10 > real_fps then
	 fps = real_fps
      end
      fps = fps*0.99 + 0.01*real_fps
	 
      -- Update the window caption with statistics
      sdl.SDL_WM_SetCaption( string.format("%d %s %dx%d | %.2f fps | %.2f mps", ticks_base, tostring(bounce_mode), wm.window.w, wm.window.h, fps, fps * (wm.window.w * wm.window.h) / (1024*1024)), nil )
   end
   sdl.SDL_Quit()
end


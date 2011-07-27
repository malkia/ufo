local ffi = require( "ffi" )
local sdl = require( "ffi/SDL" )
local pn = require( "lib/perlin" )
local uint32ptr = ffi.typeof( "uint32_t*" )
local cos, sin, abs, sqrt, band, bor, bxor, shl, shr, rol, ror, random, floor = math.cos, math.sin, math.abs, math.sqrt, bit.band, bit.bor, bit.bxor, bit.lshift, bit.rshift, bit.rol, bit.ror, math.random, math.floor

local function render( screen, tick )
    local pixels_u32 = ffi.cast( uint32ptr, screen.pixels )
    local width, height, pitch = screen.w, screen.h, screen.pitch / 4
    local halfw, halfh = width/2, height/2
    local cos, sin = cos(tick/128), sin(tick/128)
    local ooh = 1/height
    local oow = 1/width
    local ox, oy = tick/8192, 0
    for i = 0, height-1 do
       for j = 0, width-1 do
	  local y, x = i - halfh, j - halfw
	  local xx, yy, xy = x*x, y*y, x*y
--	  pixels_u32[ j + i*pitch ] = (
--	     bxor(band(tick*xy,tick*yy,tick*xx),xx+y*tick+xx*cos-yy*sin,yy+x*tick+xx*sin+yy*cos)
--	  )
	  local r = floor(pn.perlin2(i*oow+ox,j*ooh,1,1.0+tick*0.00001,4)*256)
	  local g = floor(pn.perlin2(i*oow+ox,j*ooh,1,1.1+tick*0.00002,3)*256)
	  local b = floor(pn.perlin2(i*oow+ox,j*ooh,1,1.2+tick*0.00003,2)*256)
	  pixels_u32[ j + i*pitch ] = r+g*256+b*65536
       end
    end
end

do
   local screen, prev_time, curr_time, fps = nil, 0, 0, 0, 0
   local fullscreen = false

   local ticks_base, ticks = 256 * 128, 0, 0
   local bounce_mode, bounce_range, bounce_delta, bounce_step = false, 1024, 0, 1

   local event = ffi.new( "SDL_Event" )
   event.type, event.resize.w, event.resize.h = sdl.SDL_VIDEORESIZE, 512, 512
   sdl.SDL_PushEvent( event )

   screen = sdl.SDL_SetVideoMode( event.resize.w, event.resize.h, 32, sdl.SDL_RESIZABLE )

   sdl.SDL_EnableKeyRepeat(0, 0)

   while event.type ~= sdl.SDL_QUIT do
      if sdl.SDL_PollEvent( event ) > 0 then
	 -- Handle resizing, which itself reinitializes the screen
	 if event.type == sdl.SDL_VIDEORESIZE then
	    screen = sdl.SDL_SetVideoMode( event.resize.w, event.resize.h, 32, sdl.SDL_RESIZABLE )
	 end
	 -- Handle keyboard events. If ESCAPE is pressed send SDL_QUIT message
	 local sym, mod = event.key.keysym.sym, event.key.keysym.mod
	 if event.type == sdl.SDL_KEYUP then
	    if sym == sdl.SDLK_ESCAPE then
	       event.type = sdl.SDL_QUIT
	       sdl.SDL_PushEvent( event )
	    end
	    if sym == sdl.SDLK_RETURN and band( mod, sdl.KMOD_ALT ) then
	       sdl.SDL_WM_ToggleFullScreen( screen )
	    end
	    if sym == sdl.SDLK_SPACE then
	       bounce_mode = not bounce_mode
	       ticks_base = ticks + ticks_base
	    end
	 end
	 if event.type == sdl.SDL_KEYDOWN and event.key.state == sdl.SDL_PRESSED then
	    if sym == sdl.SDLK_LEFT then
	       ticks_base = ticks_base - 100
	    end
	    if sym == sdl.SDLK_RIGHT then
	       ticks_base = ticks_base + 100
	    end
	 end
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
      render( screen, ticks + ticks_base )
      sdl.SDL_Flip( screen )

      -- Calculate the frame rate
      prev_time, curr_time = curr_time, os.clock()
      local diff = curr_time - prev_time + 0.00001
      local real_fps = 1/diff
      if abs( fps - real_fps ) * 10 > real_fps then
	 fps = real_fps
      end
      fps = fps*0.99 + 0.01*real_fps
	 
      -- Update the window caption with statistics
      sdl.SDL_WM_SetCaption( string.format("%d %s %dx%d | %.2f fps | %.2f mps", ticks_base, tostring(bounce_mode), screen.w, screen.h, fps, fps * (screen.w * screen.h) / (1024*1024)), nil )
   end
   sdl.SDL_Quit()
end


local ffi = require( "ffi" )
local sdl = require( "ffi/SDL" )
local uint32ptr = ffi.typeof( "uint32_t*" )
local cos, sin, abs, sqrt, band, bor, bxor, shl, shr, rol, ror = math.cos, math.sin, math.abs, math.sqrt, bit.band, bit.bor, bit.bxor, bit.lshift, bit.rshift, bit.rol, bit.ror

--jit.off()

local function intro_shader(x,y,tick,cos,sin)
   local xx, yy, xy = x*x, y*y, x*y
   return bxor(band(tick*xy,tick*yy,tick*xx),xx+y*tick+xx*cos-yy*sin,yy+x*tick+xx*sin+yy*cos)
end

local function fmod(v, m)
   if v < 0 then
      return m - math.fmod(-v,m)
   end
   return math.fmod(v, m)
end

-- http://playingwithmathematica.com/2011/06/17/friday-fun-6/#more-413
local function margarita_shader( x, y, tick, cos, sin )
   local z = math.sqrt( x*x + y*y ) - 3.5 * math.atan2(y, x) + math.sin(x) + math.cos(y)
   local half_pi = math.pi * 0.5
   if fmod(z, math.pi * 7) < half_pi then
      return 0xFF0000
   end
   if fmod(z, math.pi) < half_pi then
      return 0
   end
   return 0xFFFFFF
end

local function render( screen, tick )
    local pixels_u32 = ffi.cast( uint32ptr, screen.pixels )
    local width, height, pitch = screen.w, screen.h, screen.pitch / 4
    local halfw, halfh = width/2, height/2
    local oow, ooh = 1/width, 1/height
    local cos, sin = cos(tick/128), sin(tick/128)
    for i = 0, height-1 do
       for j = 0, width-1 do
--	  pixels_u32[ j + i*pitch ] = intro_shader(j-halfw, i-halfh,tick,cos,sin)
	  pixels_u32[ j + i*pitch ] = margarita_shader( (j-halfw)*oow*40, (halfh-i)*ooh*40, tick, cos, sin )
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


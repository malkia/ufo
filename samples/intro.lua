local ffi = require( "ffi" )
local sdl = require( "ffi/SDL" )
local uint32ptr = ffi.typeof( "uint32_t*" )
local cos, sin, abs, sqrt, band, bor, bxor, shl, shr, rol, ror = math.cos, math.sin, math.abs, math.sqrt, bit.band, bit.bor, bit.bxor, bit.lshift, bit.rshift, bit.rol, bit.ror

local function render( screen, tick )
    local pixels_u32 = ffi.cast( uint32ptr, screen.pixels )
    local width, height = screen.w, screen.h
    local halfw, halfh = width/2, height/2
    local cos, sin = cos(tick/128), sin(tick/128)
    for i = 0, height-1 do
       for j = 0, width-1 do
	  local y, x = i - halfh, j - halfw
	  local xx, yy, xy = x*x, y*y, x*y
	  pixels_u32[ j + i*width ] = (
	     bxor(band(tick*xy,tick*yy,tick*xx),xx+y*tick+xx*cos-yy*sin,yy+x*tick+xx*sin+yy*cos)
	  )
       end
    end
end

do
   local start = 256 * 128
   local screen, prev_time, curr_time, fps = nil, 0, 0, 0, 0
   local event = ffi.new( "SDL_Event" )
   event.type, event.resize.w, event.resize.h = sdl.SDL_VIDEORESIZE, 512, 512
   while event.type ~= sdl.SDL_QUIT do
      sdl.SDL_PollEvent( event )

      -- Handle resizing, which itself reinitializes the screen
      if event.type == sdl.SDL_VIDEORESIZE then
	 screen = sdl.SDL_SetVideoMode( event.resize.w, event.resize.h, 32, sdl.SDL_RESIZABLE )
      end

      -- Handle keyboard events. If ESCAPE is pressed send SDL_QUIT message
      if event.type == sdl.SDL_KEYUP and event.key.keysym.sym == sdl.SDLK_ESCAPE then
	 event.type = sdl.SDL_QUIT
	 sdl.SDL_PushEvent( event )
      end

      -- Render the screen, and flip it
      render( screen, sdl.SDL_GetTicks() + start )
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
      sdl.SDL_WM_SetCaption( string.format("%dx%d | %.2f fps | %.2f mps", screen.w, screen.h, fps, fps * (screen.w * screen.h) / (1024*1024)), nil )
   end
   sdl.SDL_Quit()
end


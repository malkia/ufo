local ffi = require( "ffi" )
local sdl = require( "ffi/SDL" )
local uint32ptr = ffi.typeof( "uint32_t*" )
local band, bor, bxor = bit.band, bit.bor, bit.bxor

local function render( screen, tick )
    local pixels_u32 = ffi.cast( uint32ptr, screen.pixels )
    local width, height = screen.w, screen.h
    local halfw, halfh = width/2, height/2
    for i = 0, height-1 do
       for j = 0, width-1 do
	  local y, x = i - halfh, j - halfw
	  pixels_u32[ j + i*width ] = bxor(band(tick*x*y,tick*y*y,tick*x*x),x*x+y*tick,y*y+x*tick)
       end
    end
    sdl.SDL_UpdateRect( screen, 0, 0, width, height )
end

do
   local start = 256 * 128
   local screen = sdl.SDL_SetVideoMode( 512, 512, 32, sdl.SDL_RESIZABLE )
   local event = ffi.new( "SDL_Event" )
   local overtime, prev_time, curr_time, fps = 0, 0, 0, 0
   while event.type ~= sdl.SDL_QUIT do
      sdl.SDL_PollEvent( event )
      if event.type == sdl.SDL_KEYUP and event.key.keysym.sym == sdl.SDLK_ESCAPE then
	 event.type = sdl.SDL_QUIT
	 sdl.SDL_PushEvent( event )
      end
      if event.type == sdl.SDL_VIDEORESIZE then
	 screen = sdl.SDL_SetVideoMode( event.resize.w, event.resize.h, 32, sdl.SDL_RESIZABLE )
      end

      render( screen, sdl.SDL_GetTicks() + start )

      prev_time, curr_time = curr_time, os.clock()
      local curr_fps = 1 / (curr_time - prev_time + 0.00001)
      local spd = (curr_time - prev_time) * 5
      fps = fps * (1-spd) + curr_fps * spd
      sdl.SDL_WM_SetCaption( string.format("%dx%d - %.2f fps - %.2f mps", screen.w, screen.h, fps, fps * (screen.w * screen.h) / (1024*1024)), nil )
   end
   sdl.SDL_Quit()
end


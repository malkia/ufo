local ffi = require( "ffi" )
local sdl = require( "ffi/SDL" )

local screen = sdl.SDL_SetVideoMode( 640, 480, 32, 0 )
local event = ffi.new( "SDL_Event" )
local rect = ffi.new( "SDL_Rect" )

local function drawrect( x, y, w, h, color )
   rect.x, rect.y, rect.w, rect.h = x, y, w, h
   sdl.SDL_FillRect( screen, rect, color )
end

local function render()
   drawrect(0,0,640,480,0)
   drawrect(64,48,64,48,0xff)
   sdl.SDL_UpdateRect(screen, 0, 0, 640, 480)
   sdl.SDL_Delay(10); 
end

while true do
   local shouldExit = false
   while sdl.SDL_PollEvent( event ) ~= 0 do
      if event.type == sdl.SDL_QUIT
      or event.type == sdl.SDL_KEYUP and event.key.keysym.sym == sdl.SDLK_ESCAPE then
	 shouldExit = true
      end
   end
   if shouldExit then
      break
   end
   render()
end

sdl.SDL_Quit()

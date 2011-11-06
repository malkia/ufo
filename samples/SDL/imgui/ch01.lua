-- Reference: http://sol.gfxile.net/imgui/ch01.html
--  Based on: http://sol.gfxile.net/imgui/ch01.cpp

local ffi = require( "ffi" )
local sdl = require( "ffi/sdl" )

local screen = sdl.SDL_SetVideoMode( 640, 480, 32, 0 )
local event, rect = ffi.new( "SDL_Event" ), ffi.new( "SDL_Rect" )

local should_exit = false

local function draw_rect( x, y, w, h, color )
   rect.x, rect.y, rect.w, rect.h = x, y, w, h
   sdl.SDL_FillRect( screen, rect, color )
end

local function render()
   draw_rect(  0,  0, 640, 480,    0 )
   draw_rect( 64, 48,  64,  48, 0xff )
   sdl.SDL_UpdateRect( screen, 0, 0, 640, 480 )
   sdl.SDL_Delay( 10 ) 
end

while not should_exit do
   while sdl.SDL_PollEvent( event ) ~= 0 do
      local evt, key = event.type, event.key.keysym.sym
      if evt == sdl.SDL_QUIT or (evt == sdl.SDL_KEYUP and key == sdl.SDLK_ESCAPE) then
	 should_exit = true
      end
   end
   render()
end

sdl.SDL_Quit()

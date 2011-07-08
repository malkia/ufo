local ffi = require( "ffi" )
local sdl = require( "ffi/SDL" )
local shl = bit.lshift

local screen = sdl.SDL_SetVideoMode( 640, 480, 32, 0 )
local event = ffi.new( "SDL_Event" )
local rect = ffi.new( "SDL_Rect" )

local uistate = { 
   mousex = 0, 
   mousey = 0, 
   mousedown = false, 
   hotitem = 0, 
   activeitem = 0 
}

local function drawrect( x, y, w, h, color )
   rect.x, rect.y, rect.w, rect.h = x, y, w, h
   sdl.SDL_FillRect( screen, rect, color )
end

local function render()
   drawrect(0,0,640,480,0)
   drawrect(uistate.mousex - 32, uistate.mousey - 24, 64, 48, shl(0xFF, (uistate.mousedown and 1 or 0) * 8))
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

      if event.type == sdl.SDL_MOUSEMOTION then
	 uistate.mousex, uistate.mousey = event.motion.x, event.motion.y
      end

      if event.type == sdl.SDL_MOUSEBUTTONDOWN and event.button.button == 1 then
	 uistate.mousedown = true
      end

      if event.type == sdl.SDL_MOUSEBUTTONUP and event.button.button == 1 then
	 uistate.mousedown = false
      end
   end
   if shouldExit then
      break
   end
   render()
end

sdl.SDL_Quit()

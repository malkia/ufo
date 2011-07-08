-- Reference: http://sol.gfxile.net/imgui/ch02.html
--  Based on: http://sol.gfxile.net/imgui/ch02.cpp

local ffi = require( "ffi" )
local sdl = require( "ffi/SDL" )
local shl = bit.lshift

local screen = sdl.SDL_SetVideoMode( 640, 480, 32, 0 )
local event, rect = ffi.new( "SDL_Event" ), ffi.new( "SDL_Rect" )

local should_exit = false

local ui_state = { 
   mouse_down = false, 
   mouse_x = 0, mouse_y = 0, 
   hot_item = 0, active_item = 0 
}

local function draw_rect( x, y, w, h, color )
   rect.x, rect.y, rect.w, rect.h = x, y, w, h
   sdl.SDL_FillRect( screen, rect, color )
end

local function render()
   draw_rect(  0,  0, 640, 480,  0 )
   draw_rect( ui_state.mouse_x - 32,
	      ui_state.mouse_y - 24,
	      64, 48, shl( 0xFF, (ui_state.mouse_down and 1 or 0) * 8) )
   sdl.SDL_UpdateRect( screen, 0, 0, 640, 480 )
   sdl.SDL_Delay( 10 ) 
end

while not should_exit do
   while sdl.SDL_PollEvent( event ) ~= 0 do
      local evt, key, motion, button = event.type, event.key.keysym.sym, event.motion, event.button.button
      if evt == sdl.SDL_QUIT or (evt == sdl.SDL_KEYUP and key == sdl.SDLK_ESCAPE) then
	 should_exit = true
      end
      if evt == sdl.SDL_MOUSEMOTION then
	 ui_state.mouse_x, ui_state.mouse_y = motion.x, motion.y
      end
      if evt == sdl.SDL_MOUSEBUTTONDOWN and button == 1 then
	 ui_state.mouse_down = true
      end
      if evt == sdl.SDL_MOUSEBUTTONUP and button == 1 then
	 ui_state.mouse_down = false
      end
   end
   render()
end

sdl.SDL_Quit()



















































-- Reference: http://sol.gfxile.net/imgui/ch05.html
--  Based on: http://sol.gfxile.net/imgui/ch05.cpp

local ffi = require( "ffi" )
local sdl = require( "ffi/sdl" )
local shl, shr, bor, band, min, max = bit.lshift, bit.rshift, bit.bor, bit.band, math.min, math.max

local screen = sdl.SDL_SetVideoMode( 640, 480, 32, 0 )
local event, rect = ffi.new( "SDL_Event" ), ffi.new( "SDL_Rect" )

local should_exit = false

local ui_state = { 
   mouse_down = false, 
   mouse_x = 0, mouse_y = 0, 
   hot_item = 0, active_item = 0 
}

local function CURRENT_LINE()
   return debug.getinfo(2, "l").currentline
end

local function GEN_ID()
   return CURRENT_LINE()
end

local function draw_rect( x, y, w, h, color )
   rect.x, rect.y, rect.w, rect.h = x, y, w, h
   sdl.SDL_FillRect( screen, rect, color )
end

local function region_hit( x, y, w, h )
   return ( ui_state.mouse_x >= x and
	    ui_state.mouse_y >= y and
	    ui_state.mouse_x <= x + w and
	    ui_state.mouse_y <= y + h )
end

local function button( id, x, y )
   if region_hit( x, y, 64, 48 ) then
      ui_state.hot_item = id
      if ui_state.active_item == 0 and ui_state.mouse_down then
	 ui_state.active_item = id
      end
   end

   draw_rect( x+8, y+8, 64, 48, 0 )

   if ui_state.hot_item == id then
      if ui_state.active_item == id then
	 draw_rect( x+2, y+2, 64, 48, 0xffffff )
      else
	 draw_rect(   x,   y, 64, 48, 0xffffff )
      end
   else
      draw_rect( x, y, 64, 48, 0xaaaaaa )
   end

   return ( not ui_state.mouse_down
	    and ui_state.hot_item == id
	    and ui_state.active_item == id )
end

local function slider( id, x, y, max_value, value )
   local ypos = (256 - 16) * value / max_value

   if region_hit( x+8, y+8, 16, 255 ) then
      ui_state.hot_item = id
      if ui_state.active_item == 0 and ui_state.mouse_down then
	 ui_state.active_item = id
      end
   end

   draw_rect( x, y, 32, 256+16, 0x777777 )
  
   if ui_state.active_item == id or ui_state.hot_item == id then
      draw_rect( x+8, y+8 + ypos, 16, 16, 0xffffff )
   else
      draw_rect( x+8, y+8 + ypos, 16, 16, 0xaaaaaa )
   end
   
   if ui_state.active_item == id then
      local mouse_pos = ui_state.mouse_y - (y + 8)
      mouse_pos = max( mouse_pos, 0 )
      mouse_pos = min( mouse_pos, 255 )
      local v = mouse_pos * max_value / 255
      if v ~= value then
	 return true, v
      end
   end

   return false, value
end

local function imgui_prepare()
   ui_state.hot_item = 0
end

local function imgui_finish()
  if not ui_state.mouse_down then
     ui_state.active_item = 0
  elseif ui_state.active_item == 0 then
     ui_state.active_item = -1
  end
end

local bg_color = 0x77
local function render()
   draw_rect( 0, 0, 640, 480, bg_color )

   imgui_prepare() do
      button( GEN_ID(), 50, 50 )
      
      button( GEN_ID(), 150, 50 )
      
      if button( GEN_ID(), 50, 150 ) then
	 bg_color = bor( sdl.SDL_GetTicks() * 0xc0cac01a, 0x77 )
      end
      
      if button( GEN_ID(), 150, 150 ) then
	 should_exit = true
      end

      local changed, slider_value = slider( GEN_ID(), 500, 40, 255, band( bg_color, 0xFF ) )
      if changed then
	 bg_color = bor( band( bg_color, 0xffff00 ), slider_value )
      end

      local changed, slider_value = slider( GEN_ID(), 550, 40, 63, band( shr( bg_color, 10 ), 0x3F ) )
      if changed then
	 bg_color = bor( band( bg_color, 0xff00ff ), shl( slider_value, 10 ) )
      end
      
      local changed, slider_value = slider( GEN_ID(), 600, 40, 15, band( shr( bg_color, 20 ), 0xF ) )
      if changed then
	 bg_color = bor( band( bg_color, 0x00ffff), shl( slider_value, 20 ) )
      end
   end imgui_finish()
   
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

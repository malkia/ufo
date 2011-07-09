-- Reference: http://sol.gfxile.net/imgui/ch06.html
--  Based on: http://sol.gfxile.net/imgui/ch06.cpp

local ffi = require( "ffi" )
local sdl = require( "ffi/SDL" )
local shl, shr, bor, band, min, max = bit.lshift, bit.rshift, bit.bor, bit.band, math.min, math.max

local screen = sdl.SDL_SetVideoMode( 640, 480, 32, 0 )
local event, rect, rect2 = ffi.new( "SDL_Event" ), ffi.new( "SDL_Rect" ), ffi.new( "SDL_Rect" )

sdl.SDL_EnableKeyRepeat( sdl.SDL_DEFAULT_REPEAT_DELAY, sdl.SDL_DEFAULT_REPEAT_INTERVAL )
sdl.SDL_EnableUNICODE(1)

local function load_font( name )
   local file = sdl.SDL_RWFromFile(name, "rb")
   local temp = sdl.SDL_LoadBMP_RW(file, 1)
   local font = sdl.SDL_ConvertSurface( temp, screen.format, sdl.SDL_SWSURFACE )
   sdl.SDL_FreeSurface( temp )
   sdl.SDL_SetColorKey( font, sdl.SDL_SRCCOLORKEY, 0 )
   return font
end

local font = load_font( "font14x24.bmp" )

local should_exit = false

local ui_state = { 
   mouse_down = false, 
   mouse_x = 0, mouse_y = 0, 
   hot_item = 0, active_item = 0,
   kbd_item = 0, key_entered = 0,  key_mod = false, 
   last_widget = 0
}

local function CURRENT_LINE()
   return debug.getinfo(2, "l").currentline
end

local function GEN_ID()
   return CURRENT_LINE()
end

local function draw_charcode( charcode, x, y )
   rect.x,   rect.y,  rect.w,  rect.h = 0, (charcode - 32) * 24, 14, 24
   rect2.x, rect2.y, rect2.w, rect2.h = x, y, 14, 24
   -- sdl.SDL_BlitSurface( font, rect, screen, rect2 )
   sdl.SDL_UpperBlit( font, rect, screen, rect2 )
end

local function draw_string( s, x, y )
   for i=1, #s do
      draw_charcode( s:byte(i), x, y )
      x = x + 14
   end
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

   if ui_state.kbd_item == 0 then
      ui_state.kbd_item = id
   end
   
   if ui_state.kbd_item == id then
      draw_rect( x-6, y-6, 84, 68, 0xff0000 )
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
   
   if ui_state.kbd_item == id then
      if ui_state.key_entered == sdl.SDLK_TAB then
	 ui_state.kbd_item = 0
	 if band( ui_state.key_mod, sdl.KMOD_SHIFT ) then
	    ui_state.kbd_item = ui_state.last_widget
	 end
	 ui_state.key_entered = 0
      elseif ui_state.key_entered == sdl.SDLK_RETURN then
	 return true
      end
   end
   
   ui_state.last_widget = id;
   
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

   if ui_state.kbd_item == 0 then
      ui_state.kbd_item = id;
   end

   if ui_state.kbd_item == id then
      draw_rect( x-4, y-4, 40, 280, 0xff0000 )
   end

   draw_rect( x, y, 32, 256+16, 0x777777 )
  
   if ui_state.active_item == id or ui_state.hot_item == id then
      draw_rect( x+8, y+8 + ypos, 16, 16, 0xffffff )
   else
      draw_rect( x+8, y+8 + ypos, 16, 16, 0xaaaaaa )
   end

   if ui_state.kbd_item == id then
      if ui_state.key_entered == sdl.SDLK_TAB then
	 ui_state.kbd_item = 0
	 if band( ui_state.key_mod, sdl.KMOD_SHIFT ) then
	    ui_state.kbd_item = ui_state.last_widget;
	 end
	 ui_state.key_entered = 0;
      elseif ui_state.key_entered == sdl.SDLK_UP then
	 if value > 0 then
	    value = value - 1
	    return true, value
	 end
      elseif ui_state.key_entered == sdl.SDLK_DOWN then
	 if value < max_value then
	    value = value + 1
	    return true, value
	 end
      end
   end

   ui_state.last_widget = id
   
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
   
   if ui_state.key_entered == SDLK_TAB then
      ui_state.kbditem = 0
   end
   ui_state.key_entered = 0
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

   draw_string( "Test1238919283891289319823123", 10, 10 )
   
   sdl.SDL_UpdateRect( screen, 0, 0, 640, 480 )
   sdl.SDL_Delay( 10 )
end

while not should_exit do
   while sdl.SDL_PollEvent( event ) ~= 0 do
      local evt, key, mod = event.type, event.key.keysym.sym, event.key.keysym.mod
      local motion, button = event.motion, event.button.button
      if evt == sdl.SDL_QUIT then
	 should_exit = true
      elseif evt == sdl.SDL_MOUSEMOTION then
	 ui_state.mouse_x, ui_state.mouse_y = motion.x, motion.y
      elseif evt == sdl.SDL_MOUSEBUTTONDOWN and button == 1 then
	 ui_state.mouse_down = true
      elseif evt == sdl.SDL_MOUSEBUTTONUP and button == 1 then
	 ui_state.mouse_down = false
      elseif evt == sdl.SDL_KEYDOWN then
	 ui_state.key_entered = key
	 ui_state.key_mod = mod
      elseif evt == sdl.SDL_KEYUP then
	 if key == sdl.SDLK_ESCAPE then
	    should_exit = true
	 end
      end
   end
   render()
end

sdl.SDL_Quit()

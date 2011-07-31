-- Small Text Editor

local ffi = require( "ffi" )
local sdl = require( "ffi/SDL" )
local shl, shr, bor, band, min, max = bit.lshift, bit.rshift, bit.bor, bit.band, math.min, math.max

local sw, sh = 768, 512

local screen = sdl.SDL_SetVideoMode( sw, sh, 32, 0 )
local event, rect, rect2 = ffi.new( "SDL_Event" ), ffi.new( "SDL_Rect" ), ffi.new( "SDL_Rect" )

sdl.SDL_EnableKeyRepeat( sdl.SDL_DEFAULT_REPEAT_DELAY, sdl.SDL_DEFAULT_REPEAT_INTERVAL )
sdl.SDL_EnableUNICODE(1)

local function read_text_file(n)
   local lines = {}
   for line in io.lines(n) do
      lines[ #lines + 1 ] = line
   end
   return lines
end

local source = debug.getinfo(1,"S").source
if source:sub(1,1)=="@" then
   print(source)
   source = read_text_file( source:sub(2) )
end

local function require_font( name )
   local font = require( "samples/SDL/imgui/" .. name )
   local data = ffi.new( "uint8_t[?]", #font, font )
   local temp = sdl.SDL_LoadBMP_RW( sdl.SDL_RWFromConstMem(data, ffi.sizeof(data)), 1 )
   local font = sdl.SDL_ConvertSurface( temp, screen.format, sdl.SDL_SWSURFACE )
   sdl.SDL_FreeSurface( temp )
   sdl.SDL_SetColorKey( font, sdl.SDL_SRCCOLORKEY, 0 )
   return font
end

local fw, fh = 7, 12
--local fw, fh = 14, 24
local font = require_font( "font"..tostring(fw).."x"..tostring(fh) )

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
   rect.x,   rect.y,  rect.w,  rect.h = 0, (charcode - 32) * fh, fw, fh
   rect2.x, rect2.y, rect2.w, rect2.h = x, y, fw, fh
   -- sdl.SDL_BlitSurface( font, rect, screen, rect2 )
   sdl.SDL_UpperBlit( font, rect, screen, rect2 )
end

local function draw_string( s, x, y )
   for i=1, #s do
      draw_charcode( s:byte(i), x, y )
      x = x + fw
   end
end

local function clamp(v,minimum,maximum)
   return max(minimum, min(maximum, v))
end

local function draw_text( x, y, lines, top, count )
   if type(lines)=="string" then
      lines = { lines }
   end
   top = clamp(top or 1, 1, #lines)
   local bottom = top + count
   bottom = clamp(bottom or #lines, top, #lines)
   for i = top, bottom do
      draw_string( lines[i], x, y )
      y = y + fh
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

local function slider( id, x, y, w, h, max_value, value )
   local ypos = (h - 16*2) * value / max_value

   if region_hit( x+8, y+8, 16, h-16 ) then
      ui_state.hot_item = id
      if ui_state.active_item == 0 and ui_state.mouse_down then
	 ui_state.active_item = id
      end
   end

   if ui_state.kbd_item == 0 then
      ui_state.kbd_item = id;
   end

   if ui_state.kbd_item == id then
      draw_rect( x-4, y-4, 40, sh, 0xff0000 )
   end

   draw_rect( x, y, 32, h, 0x777777 )
  
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

local some_y = -1
local function render()
   draw_rect( 0, 0, sw, sh, 0 )

   draw_text( 10, (some_y -1) % fh - fh, source, math.floor(-some_y / fh), math.floor(sh / fh)+1 )
--   print(some_y%24, math.floor(-some_y/24))
   some_y = some_y - 1

   imgui_prepare() 
   do
      local changed, slider_value = slider( GEN_ID(), sw - 32, 0, 32, sh, #source, -some_y / fh)
      if changed then
	 some_y = clamp(slider_value, 1, #source) * fh
      end
   end
   imgui_finish()

--   draw_string( "Test1238919283891289319823123", 10, 10 )
   
   sdl.SDL_Flip(screen)
--   sdl.SDL_Delay( 16 )
end

local function handle( event, handlers )
   if handlers[event] then
      return handlers[event]()
   end
end

do
   evt = ffi.new( "SDL_Event" )
   evt.type = sdl.SDL_VIDEORESIZE
   evt.resize.w, evt.resize.h = sw, sh
   sdl.SDL_PushEvent( evt )
   while evt.type ~= sdl.SDL_QUIT do
      while sdl.SDL_PollEvent( event ) ~= 0 do
	 local evt, key, mod = event.type, event.key.keysym.sym, event.key.keysym.mod
	 local motion, button = event.motion, event.button.button
	 
	 handle(
	    evt, {
	       [sdl.SDL_QUIT]=
	       function()
		  should_exit = true
	       end,
	       
	       [sdl.SDL_MOUSEMOTION]=
	       function()
		  ui_state.mouse_x = motion.x
		  ui_state.mouse_y = motion.y
	       end,
	       
	       [sdl.SDL_MOUSEBUTTONDOWN]=
	       function()
		  if button == 1 then
		     ui_state.mouse_down = true
		  end
	       end,
	       
	       [sdl.SDL_MOUSEBUTTONUP]=
	       function()
		  if button == 1 then
		     ui_state.mouse_down = false
		  end
	       end,
	       
	       [sdl.SDL_KEYDOWN]=
	       function()
		  ui_state.key_entered = key
		  ui_state.key_mod = mod
	       end,
	       
	       [sdl.SDL_KEYUP]=
	       function()
		  if key == sdl.SDLK_ESCAPE then
		     should_exit = true
		  end
	       end,
	    }
	 )
      end
      render()
   end
end

sdl.SDL_Quit()

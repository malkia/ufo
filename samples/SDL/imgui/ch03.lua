local ffi = require( "ffi" )
local sdl = require( "ffi/SDL" )
local shl, bor = bit.lshift, bit.bor

local shouldExit = false
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

local function regionhit( x, y, w, h )
   return ( x >= uistate.mousex and
	    y >= uistate.mousey and
	    x + w <= uistate.mousex and
	    y + h <= uistate.mousey )
end

local function button(id, x, y)
   if regionhit( x, y, 64, 48 ) then
      uistate.hotitem = id
      if uistate.activeitem == 00 and uistate.mousedown then
	 uistate.activeitem = id
      end
   end
   drawrect(x+8, y+8, 64, 48, 0);
   if uistate.hotitem == id then
      if uistate.activeitem == id then
	 drawrect(x+2, y+2, 64, 48, 0xffffff);
      else
	 drawrect(x, y, 64, 48, 0xffffff);
      end
  else
     drawrect(x, y, 64, 48, 0xaaaaaa);
  end

  return ( not uistate.mousedown
	   and uistate.hotitem == id
	   and uistate.activeitem == id )
end

local function imgui_prepare()
   uistate.hotitem = 0
end

local function imgui_finish()
  if not uistate.mousedown then
     uistate.activeitem = 0
  elseif uistate.activeitem == 0 then
     uistate.activeitem = -1
  end
end

local bgcolor = 0x77
local function render()
   drawrect( 0, 0, 640, 480, bgcolor )
   imgui_prepare()
   button( 2, 50, 50 )
   button( 2, 150, 50 )
   if button( 3, 50, 150 ) then
      bgcolor = bor(sdl.SDL_GetTicks() * 0xc0cac01a, 0x77)
   end

   if button(4,150,150) then
      shouldExit = true
   end
   
   imgui_finish()
   
   sdl.SDL_UpdateRect(screen, 0, 0, 640, 480)
   sdl.SDL_Delay(10)
end

while true do
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

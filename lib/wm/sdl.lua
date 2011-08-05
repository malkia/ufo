local wm = {}

local ffi = require( "ffi" )
local sdl = require( "ffi/SDL" )

function wm:init(width, height)
   sdl.SDL_Init(0xFFFF)
   self.width = width or self.width or 640
   self.height = height or self.height or 480
   self.window = sdl.SDL_SetVideoMode(
      self.width, self.height, 32,
      bit.bor( sdl.SDL_DOUBLEBUF, sdl.SDL_RESIZABLE )
   )
   self.event = ffi.new( "SDL_Event" )
   self.event.type, self.event.resize.w, self.event.resize.h = sdl.SDL_VIDEORESIZE, self.width, self.height
   sdl.SDL_PushEvent( self.event )
   self.mx, self.my, self.mb = 0, 0, {}
   self.kb, self.km = 0, 0
end

function wm:exit()
   self.event.type = sdl.SDL_QUIT
   sdl.SDL_PushEvent(self.event)
end

local function handle( type, handlers )
   if handlers[type] then
      handlers[type]()
   end
end

function wm:update()
   if self.window == nil then
      self:init()
   end
   while sdl.SDL_PollEvent( self.event ) ~= 0 do
      local ks, mm, bn = self.event.key.keysym, self.event.motion, self.event.button.button
      handle(
	 self.event.type, {
	    [sdl.SDL_QUIT] =
	       function()
		  if wm.exiting then
		     wm:exiting()
		  end
		  sdl.SDL_Quit()
		  if wm.exited then
		     wm:exited()
		  end
		  for k,_ in pairs(self) do
		     self[k] = nil
		  end
		  self.update = function() return false end
		  return false
	       end,
	    [sdl.SDL_MOUSEMOTION]     = function() self.mx, self.my = mm.x, mm.y     end,
	    [sdl.SDL_MOUSEBUTTONDOWN] = function() self.mb[ bn ] = true              end,
	    [sdl.SDL_MOUSEBUTTONUP]   = function() self.mb[ bn ] = false             end,
	    [sdl.SDL_KEYDOWN] =
	       function()
		  self.kb, self.km = ks.sym, ks.mod
		  if self.key_pressed then
		     self:key_pressed()
		  end
	       end,
	    [sdl.SDL_VIDEORESIZE] =
	       function()
		  self.width, self.height = self.event.resize.w, self.event.resize.h
		  if self.resizing then
		     self:resizing()
		  end
		  self.window = sdl.SDL_SetVideoMode(
		     self.width, self.height, 32,
		     bit.bor(sdl.SDL_DOUBLEBUF, sdl.SDL_RESIZABLE)
		  )
		  if self.resized then
		     self:resized()
		  end
		  return true
	       end,

      })
   end
   sdl.SDL_Flip( self.window )
   return true
end

if ... then 
   return wm
end

do
   function wm:resizing()
      print( 'Resizing to', self.width, self.height )
   end
   function wm:resized()
      print( 'Resized to', self.width, self.height )
   end
   function wm:exiting()
      print( 'Exiting' )
   end
   function wm:exited()
      print( 'Exited' )
   end
   function wm:key_pressed()
      print( 'Key pressed', wm.kb )
      if wm.kb == 27 then
	 wm:exit()
      end
   end
   while wm:update() do
      if wm.kb == 32 then
	 -- polling exit
	 wm:exit()
      end
   end
end

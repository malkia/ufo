local ffi = require( "ffi" )
local sdl = require( "ffi/sdl" )

local function handle(type, handlers)
   local handler = handlers[type]
   if handler then
      return true, handler()
   end
end

local function notify(object, event_handler, ...)
   local func = object[ event_handler ]
   if func then
      return true, func(object, ...)
   end
end

local function update(self, wait_for_events)
   if self.window == nil then
      self:init()
   end
   while (wait_for_events and sdl.SDL_WaitEvent or sdl.SDL_PollEvent)( self.event ) ~= 0 do
      wait_for_events = false
      local ks, mm, bn = self.event.key.keysym, self.event.motion, self.event.button.button
      local handled_any, result = handle(
	 self.event.type, {
	    [sdl.SDL_QUIT] =
	    function()
	       notify(self, "exiting")
	       sdl.SDL_Quit()
	       self.window = nil
	       notify(self, "exited")
	       self.update = function() return false end
	       return false
	    end,
	    [sdl.SDL_MOUSEMOTION] =
	    function()
	       self.mx, self.my = mm.x, mm.y
	       notify(self, "mouse_moved")
	    end,
	    [sdl.SDL_MOUSEWHEEL]      = function() self.wheel = self.wheel + self.event.wheel.y end,
	    [sdl.SDL_MOUSEBUTTONDOWN] = function() self.mb[ bn ] = true end,
	    [sdl.SDL_MOUSEBUTTONUP]   = function() self.mb[ bn ] = false end,
	    [sdl.SDL_KEYDOWN] =
	    function()
	       self.kb, self.km = ks.sym, ks.mod
	       notify(self, "key_pressed")
	    end,
	    [sdl.SDL_VIDEORESIZE] =
	    function()
	       self.width, self.height = self.event.resize.w, self.event.resize.h
	       notify(self, "resizing")
	       self.window = sdl.SDL_SetVideoMode(
		  self.width, self.height, 32,
		  bit.bor(sdl.SDL_DOUBLEBUF*0, sdl.SDL_RESIZABLE)
	       )
	       notify(self, "resized")
	    end,
      })
   end
   sdl.SDL_Flip( self.window )
   return true
end

local function init(self, width, height)
   assert(self.window == nil)
   sdl.SDL_Init(0xFFFF)
   self.width = width or self.width or 640
   self.height = height or self.height or 480
   self.window = sdl.SDL_SetVideoMode(
      self.width, self.height, 32,
      bit.bor( sdl.SDL_DOUBLEBUF*0, sdl.SDL_RESIZABLE )
   )
   assert(NULL ~= self.window, ffi.string(sdl.SDL_GetError()))
   self.event = ffi.new( "SDL_Event" )
   self.event.type, self.event.resize.w, self.event.resize.h = sdl.SDL_VIDEORESIZE, self.width, self.height
   sdl.SDL_PushEvent( self.event )
   self.mx, self.my, self.mb = 0, 0, {}
   self.kb, self.km = 0, 0
   self.wheel = 0
   self.idle = true
   self.update = self.update or update
end

local function exit(self)
   self.event.type = sdl.SDL_QUIT
   sdl.SDL_PushEvent(self.event)
end

local function new()
   return {
      new = new,
      init = init,
      update = update,
      exit = exit,
   }
end

if ... then 
   return new()
end

---- STANDALONE TESTING ----

-- mocking require, making sure argument (module to be loaded) is ignored
require = function() return new() end

-- Test1
do
   local wm = require( "lib/wm/lua....but-it-does-not-matter-we-are-testing-this-here" )
   function wm:resizing()
      print( 'Resizing to', self.width, self.height )
   end
   function wm:resized()
      print( 'Resized to', self.width, self.height )
   end
   function wm:exiting()
      assert(self.window)
      print( 'Exiting' )
   end
   function wm:exited()
      assert(self.window == nil)
      print( 'Exited' )
   end
   function wm:key_pressed()
      print( 'Key pressed', wm.kb )
      if wm.kb == 27 then
	 wm:exit()
      end
   end
   local frame = 0
   assert(wm.window == nil)
   while wm:update(true) do
      if wm.kb == 32 then
	 -- polling exit
	 wm:exit()
      end
      if wm.kb == 50 then
      end
      if frame > 10 then
	 wm:exit()
      end
      frame = frame + 1
   end
   assert(wm.window == nil)
end

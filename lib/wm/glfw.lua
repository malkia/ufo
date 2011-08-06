local ffi  = require( "ffi" )
local glfw = require( "ffi/glfw" )
local moo  = require( "lib/moo" )

local int1, int2 = ffi.new( "int" ), ffi.new( "int" )
local notify = moo.notify

local function update(self)
   if self.window == nil then
      self:init()
   end
   assert(self.window)

   if not glfw.glfwIsWindow(self.window) then
      notify(self, "exiting")
      self.window = false
      notify(self, "exited")
      self.update = function() return false end
      return false
   end

   glfw.SwapBuffers()
   glfw.PollEvents()

   -- Polling mouse
   glfw.glfwGetMousePos(window, int1, int2)
   local mx, my = int1[0], int2[0]
   if self.mx ~= mx or self.my ~= my then
      self.mx, self.my = mx, my
      notify(self, "mouse_moved")
   end
   
   -- Detecting window size changes
   glfw.glfwGetWindowSize(window, int1, int2)
   local width, height = int1[0], int2[0]
   if self.width ~= width or self.height ~= height then
      self.width, self.height = width, height
      notify(self, "resized")
   end

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
      self.window = glfw.glfwOpenWindow(
	 self.width, self.height,
	 glfw.GLFW_WINDOWED, "", nil
      )
      notify(self, "resized")
   end,

   return true
end

local function init(self, width, height)
   assert(self.window == nil)
   assert(glfw.glfwInit())
   self.width = width or self.width or 640
   self.height = height or self.height or 480
   self.mx, self.my, self.mb = 0, 0, {}
   self.kb, self.km = 0, 0
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

-- mocking require, making sure argument (module to be loaded) is ignored
require = function() new() end

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
   while wm:update() do
      if wm.kb == 32 then
	 -- polling exit
	 wm:exit()
      end
      if wm.kb == 50 then
      end
      if frame > 100 then
	 wm:exit()
      end
      frame = frame + 1
   end
   assert(wm.window == nil)
end


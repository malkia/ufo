-- flame.lua
-- by David Hollander
-- http://github.com/davidhollander <dhllndr@gmail.com>
-- MIT License

-- Implementation of Scott Drave's flame algorithm in LuaJIT and SDL
-- http://en.wikipedia.org/wiki/Fractal_flame

-- FFI
--
local ffi = require( "ffi" )
local sdl = require( "ffi/sdl" )
local uint32ptr = ffi.typeof( "uint32_t*" )

ffi.cdef[[
void Sleep(int ms);
int poll(struct pollfd *fds, unsigned long nfds, int timeout);
]]
local sleep
if ffi.os == "Windows" then
  function sleep(s)
    ffi.C.Sleep(s*1000)
  end
else
  function sleep(s)
    ffi.C.poll(nil, 0, s*1000)
  end
end

-- HELPERS
--
local bit = require'bit'
local blshift, brshift = bit.lshift, bit.rshift
local ti, tc = table.insert, table.concat
local rand, min, max, abs, floor = math.random, math.min, math.max, math.abs, math.floor
local sin, cos, rad = math.sin, math.cos, math.rad
math.randomseed(os.time())

function color(r,g,b)
  return blshift(r,16)+blshift(g,8)+b
end
local white = color(255,255,255)

-- FLAME
--
local function r(x,y) return (x^2+y^2)^.5 end
local V = {
  function(x,y) return x, y end,
  function(x,y) return sin(x), sin(y) end,
  function(x,y)
    local r2=x^2+y^2
    return x/r2, y/r2 end,
  function(x,y)
    local r2=x^2+y^2
    local co, si = cos(r2),sin(r2)
    return x*si-y*co, x*co+y*si
  end,
  --[[function(x,y)
    return (x-y)*(x+y)/(x^2+y^2)^.5, 2*x*y
  end]]
}
local function weights()
  local t={}
  local sum=0
  for i=1,#V do
    local x = rand()
    ti(t, x)
    sum=sum+x
  end
  for i, x in ipairs(t) do t[i]=x/sum end
  return t
end

local function addfn(fnlist)
  local a, b, c, d, e, f = rand(), rand(), rand(-.2,.2), rand(), rand(), rand(-.2,.2)
  local w = weights()
  ti(fnlist, function(x, y)
    local x2, y2=0, 0
    for i, v in ipairs(V) do
      local xi, yi = v(x*a+y*b+c, x*d+y*e+f)
      x2=x2+w[i]*xi; y2=y2+w[i]*yi
    end
    return x2, y2
  end)
end

function flame(w, h, n)
  local flamefns={}
  local history={}
  for i=1,10 do addfn(flamefns) end
    local x, y = rand(), rand()
  for i=1,20 do
    local fn = flamefns[math.random(#flamefns)]
    x, y = fn(x, y)
  end
  for i=1,n do
    local fn = flamefns[math.random(#flamefns)]
    x, y = fn(x, y)
    --xf, yf = flamefns[#flamefns](x, y)
    if abs(x)<1 and abs(y)<1 then
      local xf = floor((x+1)/2*(w-1))
      local yf = floor((y+1)/2*(h-1))
      history[yf]=history[yf] or {}
      history[yf][xf]=history[yf][xf] and history[yf][xf]+1 or 1
    end
  end
  return history
end

-- RENDER
--
function render(w, h, n)
  local history = flame(w, h, n)
  local event = ffi.new( "SDL_Event" )
  event.type = sdl.SDL_VIDEORESIZE
  event.resize.w, event.resize.h = w, h
  local screen = sdl.SDL_SetVideoMode(event.resize.w,event.resize.h,32,sdl.SDL_RESIZABLE)
  sdl.SDL_PushEvent(event)
  local p = screen.pitch/4
  local pixels_u32 = ffi.cast( uint32ptr, screen.pixels )
  for y, row in pairs(history) do
    for x, count in pairs(row) do
      local b = math.log(count)*50+20
      pixels_u32[y+x*p] = min(color(b,b,b), white)
    end
  end
  sdl.SDL_Flip( screen )
end

-- DEMO
--
print ""
print "flame.lua by David Hollander"
print "Implementation of Scott Drave's flame algorithm in LuaJIT and SDL"
print "http://en.wikipedia.org/wiki/Fractal_flame"
print ""
while true do
  print(512, 512, 10e6)
  local c = os.clock()
  render(512, 512, 10e6)
  print('time', os.clock()-c)
end

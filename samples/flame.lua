-- flame.lua
-- by David Hollander
-- http://github.com/davidhollander <dhllndr@gmail.com>
-- MIT License

-- Implementation of Scott Drave's flame algorithm in LuaJIT and SDL
-- http://en.wikipedia.org/wiki/Fractal_flame

-- FFI
--
local ffi = require( "ffi" )
local sdl = require( "ffi/SDL" )
local uint32ptr = ffi.typeof( "uint32_t*" )

-- HELPERS
--
local bit = require'bit'
local blshift, brshift = bit.lshift, bit.rshift
local ti, tc = table.insert, table.concat
local rand, min, max, abs, floor = math.random, math.min, math.max, math.abs, math.floor
local sin, cos, rad = math.sin, math.cos, math.rad
math.randomseed(os.time())

local function color(r,g,b)
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

local count2log = {}
for i=0,1000 do count2log[i]=math.log(i) end

local history = ffi.new( "uint8_t[?]", 512 * 512 * 2 )

function flame(w, h, n)
  local flamefns={}
  ffi.fill( history, ffi.sizeof(history) )
  for i=1,10 do addfn(flamefns) end
    local x, y = rand(), rand()
  for i=1,20 do
    local fn = flamefns[math.random(#flamefns)]
    x, y = fn(x, y)
 end
 print('1')
  for i=1,n do
    local fn = flamefns[math.random(#flamefns)]
    x, y = fn(x, y)
    x, y = x*0.5 + 0.5, y*0.5 + 0.5
    x, y = min(0,max(x,1)), min(0,max(y,1))
    x, y = x*w, y*h
    history[y*w+x]=history[y*w+x] + 1
 end
 print('2')
end

-- RENDER
--
function render(screen, w, h, n)
  flame(w, h, n)
  local p = screen.pitch/4
  local pixels_u32 = ffi.cast( uint32ptr, screen.pixels )
  for y = 0, h-1 do
    for x = 0, w-1 do
       local v = history[ y*w + x ]
       local b = v + 20 --math.log(v)*50+20
       pixels_u32[y*p+x] = b --min(color(b,b,b), white)
    end
  end
  sdl.SDL_Flip( screen )
end

-- DEMO
--
local w, h = 512, 512
local event = ffi.new( "SDL_Event" )
event.type = sdl.SDL_VIDEORESIZE
event.resize.w, event.resize.h = w, h
local screen = sdl.SDL_SetVideoMode(event.resize.w,event.resize.h,32,sdl.SDL_RESIZABLE)
sdl.SDL_PushEvent(event)

print ""
print "flame.lua by David Hollander"
print "Implementation of Scott Drave's flame algorithm in LuaJIT and SDL"
print "http://en.wikipedia.org/wiki/Fractal_flame"
print ""
while true do
--   print(w, h, 500 )10e6)
  local c = os.clock()
  render(screen, w, h, 10e6/10)
  print('time', os.clock()-c)
  sdl.SDL_PumpEvents()
end

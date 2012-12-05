--jit.off()

-- http://jsfiddle.net/uzMPU/

--require("lib/strict")

local ffi = require( "ffi" )
local sdl = require( "ffi/sdl" )
local wm = require( "lib/wm/sdl" )
local uint32ptr = ffi.typeof( "uint32_t*" )
local modf,fmod,pi, cos, sin, abs, sqrt, band, bor, bxor, shl, shr, rol, ror, random, floor, ceil = 
math.modf,math.fmod, math.pi, math.cos, math.sin, math.abs, math.sqrt, bit.band, bit.bor, bit.bxor, bit.lshift, bit.rshift, bit.rol, bit.ror, math.random, math.floor, math.ceil

local map = ffi.new("uint8_t[?]", 64 * 64 * 64)
local texmap = ffi.new("uint32_t[?]", 16 * 16 * 16 * 3)

local function mod(x,y)
   return fmod(x,y)
end

local function rand(x)
   return math.random(x)-1
end

local function init()
   for i=1, 15 do
      local br = 255 - rand(96)
      for y=0, 16*3-1 do
	 for x=0,15 do
	    local color = 0x966C4A
	    if i == 4 then color = 0x7F7F7F end
	    if i ~= 4 or rand(3) == 0 then br = 255 - rand(96) end
	    if i == 1 and y < band(shr(x*x*3 + x*81,2),3) + 18 then
	       color = 0x6AAA40
	    elseif i == 1 and y < band(shr(x*x*3 + x*81,2),3) + 19 then
	       br = br * 2 / 3
	    end

	    if i == 7 then
	       color = 0x675231
	       if x > 0 and x < 15 and ((y>0 and y<15) or (y>32 and y<47)) then
		  color = 0xBC9862
		  local xd = x - 7
		  local yd = band(y,15) - 7
		  if xd < 0  then xd = 1 - xd end
		  if yd < 0  then yd = 1 - yd end
		  if yd > xd then xd =     yd end
		  br = 196 - rand(32) + mod(xd,3)*32
	       elseif rand(2)==0 then
		  br = br * (150 - band(x,1) * 100) / 100
	       end
	    end
	       
	    if i == 5 then
	       color = 0xB53A15
	       if mod(x + shr(y,2)*4, 8) == 0 or mod(y,4) == 0 then
		  color = 0xBCAFA5
	       end
	    end

	    if i == 9 then
	       color = 0x4040ff
	    end

	    local brr = br
	    if y >= 32 then brr = brr / 2 end
	    
	    if i == 8 then
	       color = 0x50D937
	       if rand(2)==0 then
		  color = 0
		  brr = 255
	       end
	    end
	    
	    texmap[x + y * 16 + i * 256 * 3] = bor(
	       shl(band(shr(color,16), 255) * brr/255, 16),
	       shl(band(shr(color,8), 255) * brr/255, 8),
	       band(color,255) * brr/255)
	 end
      end
   end

   for x=0, 63 do
      for y=0, 63 do
	 for z=0, 63 do
	    local i = bor(shl(z,12), shl(y, 6), x)
	    local yd = (y - 32.5) * 0.4
	    local zd = (z - 32.5) * 0.4
	    map[i] = rand(16)
	    if random() > sqrt(sqrt(yd * yd + zd * zd)) - 0.8 then
	       map[i] = 0
	    end
	 end
      end
   end
end

local function renderMinecraft(screen, time)
   local pixels = ffi.cast( uint32ptr, screen.pixels )
   local w, h, pitch = screen.w, screen.h, screen.pitch / 4

   local xRot = sin(mod(time,10000) / 10000 * pi * 2) * 0.4 + pi / 2
   local yRot = cos(mod(time,10000) / 10000 * pi * 2) * 0.4
   local yCos = cos(yRot)
   local ySin = sin(yRot)
   local xCos = cos(xRot)
   local xSin = sin(xRot)

   local ox = 32.5 + mod(time,10000) / 10000 * 64
   local oy = 32
   local oz = 32

   for x=0, w-1 do
      local ___xd = (x - w / 2) / h
      for y=0, h-1 do
	 local __yd = (y - h / 2) / h
	 local __zd = 1

	 local ___zd = __zd * yCos + __yd * ySin
	 local _yd = __yd * yCos - __zd * ySin

	 local _xd = ___xd * xCos + ___zd * xSin
	 local _zd = ___zd * xCos - ___xd * xSin

	 local col = 0
	 local br = 255
	 local ddist = 0

	 local closest = 32
	 for d=0,2 do
	    local dimLength = _xd
	    if d == 1 then dimLength = _yd end
	    if d == 2 then dimLength = _zd end

	    local ll = 1 / abs(dimLength)
	    local xd = _xd * ll
	    local yd = _yd * ll
	    local zd = _zd * ll

	    local initial = ox%1
	    if d == 1 then initial = oy%1 end
	    if d == 2 then initial = oz%1 end
	    if dimLength > 0 then initial = 1 - initial end

	    local dist = ll * initial
	    
	    local xp = ox + xd * initial
	    local yp = oy + yd * initial
	    local zp = oz + zd * initial

	    if dimLength < 0 then
	       if d == 0 then xp = xp - 1 end
	       if d == 1 then yp = yp - 1 end
	       if d == 2 then zp = zp - 1 end
	    end

	    while dist < closest do
	       local xp1, yp1, zp1 = modf(xp), modf(yp), modf(zp)
	       local tex = map[bor(shl(band(zp1,63),12), shl(band(yp1,63),6), band(xp1,63))]
	       if tex > 0 then
		  local u = band((xp + zp) * 16, 15)
		  local v = band(yp * 16, 15) + 16
		  if d == 1 then
		     u = band(xp * 16, 15)
		     v = band(zp * 16, 15)
		     if yd < 0 then v = v + 32 end
		  end

		  local cc = texmap[u + v * 16 + tex * 256 * 3]
		  if cc > 0 then
		     col = cc
		     ddist = 255 - modf(dist / 32 * 255)
		     br = 255 - ((d + 2) % 3) * 50;
		     closest = dist
		  end
	       end
	       xp = xp + xd
	       yp = yp + yd
	       zp = zp + zd
	       dist = dist + ll
	    end
	 end

	 pixels[x + y * pitch] = --col
	 bor(
	    shl(band(shr(col,16), 0xff) * br*ddist/(255*255), 16),
	    shl(band(shr(col,8),  0xff) * br*ddist/(255*255), 8),
	    band(col,255) * br*ddist/(255*255))
      end
   end
end


do
   init();

   local prev_time, curr_time, fps = nil, 0, 0, 0, 0

   local ticks_base, ticks = 0, 0, 0 --256 * 128, 0, 0
   local bounce_mode, bounce_range, bounce_delta, bounce_step = false, 1024, 0, 1

   wm.width, wm.height = 212 * 2, 120 * 2

   while wm:update() do
      local event = wm.event
      local sym, mod = event.key.keysym.sym, event.key.keysym.mod
      if wm.kb == 13 then
	 sdl.SDL_WM_ToggleFullScreen( wm.window )
      end

      if wm.kb == 27 then
	 wm:exit()
	 break
      end

      if wm.kb == 32 then
	 bounce_mode = not bounce_mode
	 ticks_base = ticks + ticks_base
      end

      if wm.kb == ("o"):byte() then
	 ticks_base = ticks_base - 100
      end

      if wm.kb == ("p"):byte() then
	 ticks_base = ticks_base + 100
      end

      if ticks_base > 256 * 256 * 256 then
	 ticks_base = 0
      end

      if bounce_mode then
	 if abs( bounce_delta ) > bounce_range then
	    bounce_step = -bounce_step
	 end
	 bounce_delta = bounce_delta + bounce_step
	 ticks = ticks_base + bounce_delta
      else
	 ticks = sdl.SDL_GetTicks()
      end

      -- Render the screen, and flip it
      renderMinecraft( wm.window, ticks + ticks_base )

      -- Calculate the frame rate
      prev_time, curr_time = curr_time, os.clock()
      local diff = curr_time - prev_time + 0.00001
      local real_fps = 1/diff
      if abs( fps - real_fps ) * 10 > real_fps then
	 fps = real_fps
      end
      fps = fps*0.99 + 0.01*real_fps
	 
      -- Update the window caption with statistics
      sdl.SDL_WM_SetCaption( string.format("%d %s %dx%d | %.2f fps | %.2f mps", ticks_base, tostring(bounce_mode), wm.window.w, wm.window.h, fps, fps * (wm.window.w * wm.window.h) / (1024*1024)), nil )
   end
   sdl.SDL_Quit()
end


local ffi = require( "ffi" )

local sqrt, random, floor, band, min, max = math.sqrt, math.random, math.floor, bit.band, math.min, math.max

local function v2normself(v)
   local oos = 1 / sqrt( v[0]*v[0] + v[1]*v[1] )
   v[0], v[1] = v[0]*oos, v[1]*oos
end

local function v3normself(v)
   local oos = 1 / sqrt( v[0]*v[0] + v[1]*v[1] + v[2]*v[2] )
   v[0], v[1], v[2] = v[0]*oos, v[1]*oos, v[2]*oos
end

local function perlin_init(B)
   local p  = ffi.new( "uint8_t[?]",       B + B + 2 )
   local g1 = ffi.new( "double[?]",    B + B + 2 )
   local g2 = ffi.new( "double[?]", (B + B + 2)*2 )
   local g3 = ffi.new( "double[?][3]", B + B + 2 )

   for i = 0, B-1 do
      p[i] = i
      g1[i] = random()*2-1
      local x = random()*2-1
      local y = random()*2-1
      local n = sqrt(x*x + y*y)
      g2[i*2],g2[i*2+1] = x/n, y/n
      for j = 0, 2 do
	 g3[i][j] = random()*2-1
      end
      v3normself( g3[i] )
   end

   for i = B-1, 0 do
      local j = random(0, B-1)
      p[i], p[j] = p[j], p[i]
   end

   for i = 0, B+1 do
      p[B+i] = p[i]
      g1[B+i] = g1[i]
      for j = 0, 1 do
	 g2[(B+i)*2+0] = g2[i*2+0]
	 g2[(B+i)*2+1] = g2[i*2+1]
      end
      for j = 0, 2 do
	 g3[B+i][j] = g3[i][j]
      end
   end

   return p, g1, g2, g3
end

local p, g1, g2, g3 = perlin_init(256)

local function s_curve(t)
   return t*t*(3 - 2*t)
end

local function setup(t)
   local ft = floor( t )
   local b0 = band(255, ft)
   local r0 = t - ft
   local b1 = band(255, b0 + 1)
   local r1 = r0 - 1
   return b0, b1, r0, r1
end

local function setup2(t)
   local ft = floor( t )
   local b0 = band(255, ft)
   return b0, band(255, b0 + 1), t - ft
end

local function at3(q,rx,ry,rz)
   return rx*q[0] + ry*q[1] + rz*q[2]
end

local function noise1( arg )
   local bx0, bx1, rx0, rx1 = setup( arg )
   local sx = s_curve( rx0 )
   local u = rx0 * g1[ p[bx0] ]
   local v = rx1 * g1[ p[bx1] ]
   return lerp( sx, u, v )
end

local function lerp(t, a, b)
   return a + t * (b - a)
end

local function noise2( arg0, arg1 )
   local g2 = g2
   local bx0, bx1, rx = setup2( arg0 )
   local by0, by1, ry = setup2( arg1 )
   local   i,   j = p[    bx0],   p[    bx1]
   local b00, b10 = p[i + by0]*2, p[j + by0]*2
   local b01, b11 = p[i + by1]*2, p[j + by1]*2
   local sx = rx*rx*(3-2*rx)
   local a = lerp(
      sx,
       rx   *g2[b00] + ry*g2[b00+1],
      (rx-1)*g2[b10] + ry*g2[b10+1]
   )
   local b = lerp(
      sx,
       rx   *g2[b01] + (ry-1)*g2[b01+1],
      (rx-1)*g2[b11] + (ry-1)*g2[b11+1]
   )
   return lerp( ry*ry*(3-2*ry), a, b )
end

local function noise3( arg0, arg1, arg2 )
   local bx0, bx1, rx0, rx1 = setup( arg0 )
   local by0, by1, ry0, ry1 = setup( arg1 )
   local bz0, bz1, rz0, rz1 = setup( arg2 )
   local i, j = p[ bx0 ], p[ bx1 ]
   local b00, b10 = p[ i + by0 ], p[ j + by0 ]
   local b01, b11 = p[ i + by1 ], p[ j + by1 ]
   local t, sy, sz = s_curve( rx0 ), s_curve( ry0 ), s_curve( rz0 )
   local u = at3( g3[b00 + bz0], rx0, ry0, rz0 )
   local v = at3( g3[b10 + bz0], rx1, ry0, rz0 )
   local a = lerp(  t, u, v )
   local u = at3( g3[b01 + bz0], rx0, ry1, rz0 )
   local v = at3( g3[b11 + bz0], rx1, ry1, rz0 )
   local b = lerp(  t, u, v )
   local c = lerp( sy, a, b )
   local u = at3( g3[b00 + bz1], rx0, ry0, rz1 )
   local v = at3( g3[b10 + bz1], rx1, ry0, rz1 )
   local a = lerp(  t, u, v )
   local u = at3( g3[b01 + bz1], rx0, ry1, rz1 )
   local v = at3( g3[b11 + bz1], rx1, ry1, rz1 )
   local b = lerp(  t, u, v )
   local d = lerp( sy, a, b )
   return    lerp( sz, c, d )
end

-- --- My harmonic summing functions - PDB --------------------------*/

-- In what follows "alpha" is the weight when the sum is formed.
-- Typically it is 2, As this approaches 1 the function is noisier.
-- "beta" is the harmonic scaling/spacing, typically 2.

local function perlin1( x, alpha, beta, n )
   local sum, scale = 0, 1
   for i = 0, n - 1 do
      sum = sum + noise1( x ) / scale
      scale = scale * alpha
      x = x * beta
   end
   return sum
end

local function perlin2( x, y, alpha, beta, n )
   local sum, ooscale = 0, 1
   local ooalpha = 0.5 -- 1 / alpha
   for i = 0, n - 1 do
      sum = sum + noise2( x, y ) * ooscale
      x,y,ooscale = x*beta, y*beta, ooscale*ooalpha
   end
   return sum
end

local function perlin3( x, y, z, alpha, beta, n )
   local sum, scale = 0, 1
   for i = 0, n - 1 do
      sum = sum + noise3( x, y, z ) / scale
      scale = scale * alpha
      x, y, z = x*beta, y*beta, z*beta
   end
   return sum
end

if false then
   for x = 0, 100 do
      for y = 0, 100 do
	 local v = floor(perlin2(random(),random(),1,1,100))
	 v = max(0,min(v, 100-32))+32
	 io.write(string.format("%c",v))
      end
      io.write('\n')
   end
end

return {
   noise1  = noise1,
   noise2  = noise2,
   noise3  = noise3,
   perlin1 = perlin1,
   perlin2 = perlin2,
   perlin3 = perlin3,
}

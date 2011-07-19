local ffi  = require( "ffi" )
local sqrt = math.sqrt
local new = ffi.typeof( "double[3]" )

local function eq(a, b)
   return a[0]==b[0] and a[1]==b[1] and a[2]==b[2]
end

local function mag(a)
   return a[0]*a[0] + a[1]*a[1] + a[2]*a[2]
end

local function len(a)
   return sqrt(mag(a))
end

local function dot(a, b)
   return a[0]*b[0] + a[1]*b[1] + a[2]*b[2]
end

---- NEG ----
local function neg(r, a)
   r[0], r[1], r[2] = -a[0], -a[1], -a[2]
   return r
end
local function negself(a)
   a[0], a[1], a[2] = -a[0], -a[1], -a[2]
   return a
end
local function negnew(a)
   return neg(new(), a)
end

---- ADD ----
local function add(r, a, b)
   r[0], r[1], r[2] = a[0]+b[0], a[1]+b[1], a[2]+b[2]
   return r
end
local function addself(a, b)
   a[0], a[1], a[2] = a[0]+b[0], a[1]+b[1], a[2]+b[2]
   return a
end
local function addnew(a, b)
   return add(new(), a, b)
end

---- SUB ----
local function sub(r, a, b)
   r[0], r[1], r[2] = a[0]-b[0], a[1]-b[1], a[2]-b[2]
   return r
end
local function subself(a, b)
   a[0], a[1], a[2] = a[0]-b[0], a[1]-b[1], a[2]-b[2]
   return a
end
local function subnew(a, b)
   return sub(new(), a, b)
end

---- MUL ----
local function mul(r, a, b)
   r[0], r[1], r[2] = a[0]*b[0], a[1]*b[1], a[2]*b[2]
   return r
end
local function mulself(a, b)
   a[0], a[1], a[2] = a[0]*b[0], a[1]*b[1], a[2]*b[2]
   return a
end
local function mulnew(a, b)
   return mul(new(), a, b)
end

---- SCALE ----
local function scale(r, a, k)
   r[0], r[1], r[2] = a[0]*k, a[1]*k, a[2]*k
   return r
end
local function scaleself(a, k)
   a[0], a[1], a[2] = a[0]*k, a[1]*k, a[2]*k
   return a
end
local function scalenew(a, k)
   return scale(new(), a, k)
end

--- NORM ----
local function norm(r, a)
   local im = 1 / len(a)
   r[0], r[1], r[2] = a[0]*im, a[1]*im, a[2]*im
   return r
end
local function normself(a)
   local im = 1 / len(a)
   a[0], a[1], a[2] = a[0]*im, a[1]*im, a[2]*im
   return a
end
local function normnew(a)
   return norm(new(),a)
end

---- CROSS ----
local function cross(r, a, b)
   r[0], r[1], r[2] = a[1]*b[2] - a[2]*b[1], a[2]*b[0] - a[0]*b[2], a[0]*b[1] - a[1]*b[0]
   return r
end
local function crossself(a, b)
   a[0], a[1], a[2] = a[1]*b[2] - a[2]*b[1], a[2]*b[0] - a[0]*b[2], a[0]*b[1] - a[1]*b[0]
   return r
end
local function crossnew(a, b)
   return cross(new(), a, b)
end

---- DIR ----
local function dir(r, a, b)
   return norm(sub(r, a, b))
end
local function dirself(a, b)
   return normself(subself(a, b))
end
local function dirnew(a, b)
   return dir(new(), a, b)
end

local function str(v)
   return tostring(v[0])..", "..tostring(v[1])..", "..tostring(v[2])
end

if not ... then
   local v = new(1,2,3)
   local n = negself(v)
end

return {
   new   = new, 
   mag   = mag, 
   len   = len, 
   dot   = dot, 
   neg   = neg,   negself   = negself,   negnew   = negnew,
   add   = add,   addself   = addself,   addnew   = addnew,
   sub   = sub,   subself   = subself,   subnew   = subnew,
   scale = scale, scaleself = scaleself, scalenew = scalenew,
   norm  = norm,  normself  = normself,  normnew  = normnew,
   cross = cross, crossself = crossself, crossnew = crossnew,
   dir   = dir,   dirself   = dirself,   dirnew   = dirnew,
   tostring = tostring_,
}


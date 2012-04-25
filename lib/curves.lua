-- Translation directly of the awesome C# iTween Project

local curves = {}
local min, max, pi, sin, cos, pow, sqrt = math.min, math.max, math.pi, math.sin, math.cos, math.pow, math.sqrt
local two_over_pi = 2 / pi

local function punch( amplitude, value )
   local s = 9
   if value == 0 then
      return 0
   end
   if value == 1 then
      return 0
   end
   local period = 0.3
   s = period / (2 * pi) * math.asin(0)
   return amplitude * pow(2, -10 * value) * sin((value * 1 - s) * (2 * pi) / period)
end
	
function curves.linear( from, to, value )
   return (1 - value) * from + value * to
end
	
function curves.clerp( from, to, value )
   to = to - from
   if to < -180 then
      return from + (360 + to) * value
   end
   if to >  180 then
      return from - (360 - to) * value
   end
   return from + to * value
end

function curves.spring( from, to, value )
   value = max( min( value, 1 ), 0 )
   value = (sin( value * pi * (0.2 + 2.5 * value * value * value)) * 
	    pow(1 - value, 2.2) + value) * (1 + (1.2 * (1 - value)))
   return from + (to - from) * value
end

function curves.easeInQuad( from, to, value )
   return (to - from) * value * value + from
end

function curves.easeOutQuad( from, to, value )
   return (from - to) * value * (value - 2) + from
end

function curves.easeInOutQuad( from, to, value )
   value = value + value
   to = to - from
   if value < 1 then
      return 0.5 * to * value * value + from
   end
   value = value - 1
   return -0.5 * to * (value * (value - 2) - 1) + from
end

function curves.easeInCubic( from, to, value )
   return (to - from) * value * value * value + from
end

function curves.easeOutCubic( from, to, value )
   value = value - 1
   return (to - from) * (value * value * value + 1) + from
end

function curves.easeInOutCubic( from, to, value )
   value = value + value
   to = to - from
   if value < 1 then
      return 0.5 * to * value * value * value + from
   end
   value = value - 2
   return 0.5 * to * (value * value * value + 2) + from
end

function curves.easeInQuart( from, to, value )
   return (to - from) * value * value * value * value + from
end

function curves.easeOutQuart( from, to, value )
   return (from - to) * (value * value * value * value - 1) + from
end

function curves.easeInOutQuart(from, to, value)
   value = value + value
   to = to - from;
   if value < 1 then
      return 0.5 * to * value * value * value * value + from;
   end
   value = value - 2
   return -0.5 * to * (value * value * value * value - 2) + from;
end

function curves.easeInQuint( from, to, value )
   return (to - from) * value * value * value * value * value + from;
end

function curves.easeOutQuint(from, to, value)
   value = value - 1
   return (to - from) * (value * value * value * value * value + 1) + from;
end

function curves.easeInOutQuint(from, to, value)
   value = value + value
   to = to - from
   if value < 1 then
      return 0.5 * to * value * value * value * value * value + from
   end
   value = value - 2
   return 0.5 * to * (value * value * value * value * value + 2) + from
end

function curves.easeInSine( from, to, value )
   return (from - to) * cos( value * two_over_pi ) + to
end

function curves.easeOutSine( from, to, value )
   return (to - from) * sin( value * two_over_pi ) + from
end

function curves.easeInOutSine( from, to, value )
   return 0.5 * (from - to) * (cos( value * pi) - 1) + from
end

function curves.easeInExpo( from, to, value )
   return (to - from) * pow(2, 10 * (value - 1)) + from
end

function curves.easeOutExpo( from, to, value )
   return (to - from) * (1 - (pow(2, -10 * value))) + from
end

function curves.easeInOutExpo( from, to, value )
   value = value + value
   if value < 1 then
      return 0.5 * (to-from) * pow(2, 10 * (value - 1)) + from
   end
   return 0.5 * (to-from) * (2 - pow(2, 10 * (1 - value))) + from
end

function curves.easeInCirc( from, to, value )
   return (from - to) * (sqrt(1 - value * value) - 1) + from
end

function curves.easeOutCirc( from, to, value )
   value = value - 1
   return (to - from) * sqrt( 1 - value * value ) + from
end

function curves.easeInOutCirc(from, to, value)
   value = value + value
   to = to - from
   if value < 1 then
      return -0.5 * to * (sqrt(1 - value * value) - 1) + from
   end
   value = value - 2
   return 0.5 * to * (sqrt(1 - value * value) + 1) + from
end

function curves.easeInBounce(from, to, value)
   return to - curves.easeOutBounce( 0, to - from, 1 - value )
end

function curves.easeOutBounce(from, to, value)
   to = to - from
   if value < (1 / 2.75) then
      return to * (7.5625 * value * value) + from;
   end
   if value < (1.5 / 2.75) then
      value = value - (1.5 / 2.75)
      return to * (7.5625 * value * value + 0.75) + from
   end
   if value < (2.5 / 2.75) then
      value = value - (2.25 / 2.75)
      return to * (7.5625 * value * value + 0.9375) + from
   end
   value = value - (2.625 / 2.75)
   return to * (7.5625 * value * value + 0.984375) + from
end

function curves.easeInOutBounce( from, to, value )
   if value < 0.5 then
      return curves.easeInBounce( 0, to-from, value + value ) * 0.5 + from
   end
   return curves.easeOutBounce( 0, to-from, value + value - 0.5) * 0.5 + (to-from)*0.5 + from
end

function curves.easeInBack( from, to, value )
   return (to-from) * value * value * (1.70158 * value + value - 1.70158) + from
end

function curves.easeOutBack( from, to, value )
   value = value - 1
   return (to-from) * (value * value * (1.70158 * value + value + 1.70158) + 1) + from
end

--[[
	function curves.easeInOutBack(from, to, value){
		s = 1.70158f;
		to -= from;
		value /= .5f;
		if ((value) < 1){
			s *= (1.525f);
			return to / 2 * (value * value * (((s) + 1) * value - s)) + from;
		}
		value -= 2;
		s *= (1.525f);
		return to / 2 * ((value) * value * (((s) + 1) * value + s) + 2) + from;
	}

	function curves.punch(amplitude, value){
		s = 9;
		if (value == 0){
			return 0;
		}
		if (value == 1){
			return 0;
		}
		period = 1 * 0.3f;
		s = period / (2 * Mathf.PI) * Mathf.Asin(0);
		return (amplitude * Mathf.Pow(2, -10 * value) * Mathf.Sin((value * 1 - s) * (2 * Mathf.PI) / period));
    }
	
	/* GFX47 MOD FROM */
	function curves.easeInElastic(from, to, value){
		to -= from;
		
		d = 1f;
		p = d * .3f;
		s = 0;
		a = 0;
		
		if (value == 0) return from;
		
		if ((value /= d) == 1) return from + to;
		
		if (a == 0f || a < Mathf.Abs(to)){
			a = to;
			s = p / 4;
			}else{
			s = p / (2 * Mathf.PI) * Mathf.Asin(to / a);
		}
		
		return -(a * Mathf.Pow(2, 10 * (value-=1)) * Mathf.Sin((value * d - s) * (2 * Mathf.PI) / p)) + from;
	}		
	/* GFX47 MOD TO */

	/* GFX47 MOD FROM */
	//function curves.elastic(from, to, value){
	function curves.easeOutElastic(from, to, value){
	/* GFX47 MOD TO */
		//Thank you to rafael.marteleto for fixing this as a port over from Pedro's UnityTween
		to -= from;
		
		d = 1f;
		p = d * .3f;
		s = 0;
		a = 0;
		
		if (value == 0) return from;
		
		if ((value /= d) == 1) return from + to;
		
		if (a == 0f || a < Mathf.Abs(to)){
			a = to;
			s = p / 4;
			}else{
			s = p / (2 * Mathf.PI) * Mathf.Asin(to / a);
		}
		
		return (a * Mathf.Pow(2, -10 * value) * Mathf.Sin((value * d - s) * (2 * Mathf.PI) / p) + to + from);
	}		
	
	/* GFX47 MOD FROM */
	function curves.easeInOutElastic(from, to, value){
		to -= from;
		
		d = 1f;
		p = d * .3f;
		s = 0;
		a = 0;
		
		if (value == 0) return from;
		
		if ((value /= d/2) == 2) return from + to;
		
		if (a == 0f || a < Mathf.Abs(to)){
			a = to;
			s = p / 4;
			}else{
			s = p / (2 * Mathf.PI) * Mathf.Asin(to / a);
		}
		
		if (value < 1) return -0.5f * (a * Mathf.Pow(2, 10 * (value-=1)) * Mathf.Sin((value * d - s) * (2 * Mathf.PI) / p)) + from;
		return a * Mathf.Pow(2, -10 * (value-=1)) * Mathf.Sin((value * d - s) * (2 * Mathf.PI) / p) * 0.5f + to + from;
	}		
	/* GFX47 MOD TO */
	
--]]



if true then
   local c = ".:"
   local w, h = 64, 32
   for k,v in pairs(curves) do
      print()
      print(k)
      for y=h-1, 0, -1 do
	 local l = {}
	 for x=0, w-1 do
	    local v = v(0, 1, x / w) * h
	    if v - 1 > y then
	       l[#l+1] = '='
	    elseif v - 0.5 > y then 
	       l[#l+1] = "'"
	    elseif v > y then 
	       l[#l+1] = ':'
	    elseif v + 0.5 > y then
	       l[#l+1] = '.'
	    else
	       l[#l+1] = '-'
	    end
	 end
	 print(table.concat(l))
      end
   end
end

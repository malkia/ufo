local function r_menu1()
   return "menu"
end

local function r_menu2()
   return "menu"
end

local function r(type,...)
   return function() return type end
end

local function r_menu(t)
   return r'menu', t
end

local function r_button(...)
   return r('button',...)
end

-- Unordered resource table
local t = {
   [ r_menu1 ] = {
      "(Apple)", {},
      "Aquamacs", {},
      "File", {},
      "Edit", {},
      "Options", {},
      "Tools", {},
      "Lua", {},
      "Window", {},
      "Help", {},
   },
   [ r_menu2 ] = {
      "Blah",
      "Gah",
      "Dah",
   },
   [ r'menu' ] = {
      "Gosho",
   },
   [ r'menu' ] = {
      "Bosho",
   },
   [ function() return "menu" end ] = {
      "Tosho",
   },
   r_menu { 
      "Kotooshu",
   },
}

for k,v in pairs(t) do
   print(k,v)
--   print(k, k(), v[1])
end

-- No order in here
local form = {
   [ r'button' ] = {
      x = 10, y = 20,
   },
   [ r'button' ] = {
      x = 10, y = 20,
   },
   [ r_button() ] = {
      x = 10, y = 20,
   },
   [ r_button() ] = {
      x = 10, y = 20,
   },
   [ r_button() ] = {
      x = 10, y = 20,
   },
   [ r_button(10,20) ] = {
      x = 10, y = 20,
   },
   [ r_button{ 10, 20 } ] = {
      x = 10, y = 20,
   },
   [ r_button{ 10, 20 } ] = {},
   [ r_button { 
	 x = 10, 
	 y = 20 
   } ] = {},
   [r( 'button',{ 
	 x = 10, 
	 y = 20 
  })] = {},
}

for k,v in pairs(form) do
   print(k,k(),v)
end

-- local r = require( "lib/ui/r" )

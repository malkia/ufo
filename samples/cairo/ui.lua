local ffi = require( "ffi" )
local sdl = require( "ffi/sdl" )
local wm  = require( "lib/wm/sdl" )
local random, floor, pi = math.random, math.floor, math.pi

local lines = {{ x=0, y=0, solid = false }}

-- Preallocate certain ffi structures, to prevent allocations
local gfx = {}
local ui = {}

local function gencode()
   local constructors = {
      "image_surface_create",
      "create",
   }
   local context_functions = {
      "move_to", "line_to", "curve_to", "rel_move_to", "rel_line_to", "rel_curve_to",
      "arc", "new_path", "rectangle", "close_path", "set_source_rgb", "set_source_rgba",
      "fill_preserve", "stroke_preserve", "stroke", "set_line_width", "show_text", "clip",
      "reset_clip", "text_extents", "save", "restore", "set_font_size", "set_operator",
      "paint", "select_font_face", "surface_destroy", "destroy"
   }
   local surface_functions = {
   }
   local c = { "return {\n" }
   for _,n in ipairs(constructors) do
      assert( c[#c+1] == nil )
      c[#c+1]='["'..n..'"]=function(self,...)return self.library.cairo_' .. n .. "(...)end,\n"
   end
   for _,n in ipairs(context_functions) do
      assert( c[#c+1] == nil )
      c[#c+1]='["'..n..'"]=function(self,...)return self.library.cairo_' .. n .. "(self.context,...)end,\n"
   end
   for _,n in ipairs(surface_functions) do
      assert( c[#c+1] == nil )
      c[#c+1]='["'..n..'"]=function(self,...)return self.library.cairo_' .. n .. "(self.surface,...)end,\n"
   end
   c[#c+1] = "}\n"
   return table.concat(c)
end

local function fillconstants(m)
   local constants = {
      "FORMAT_RGB24", "OPERATOR_SOURCE",
   }
   for _,n in ipairs(constants) do
      assert( m[n] == nil )
      m[n] = m.library["CAIRO_" .. n]
   end
end

--print(gencode())

local cairo = loadstring(gencode())()
cairo.library = require( "ffi/cairo" )
fillconstants(cairo)
cairo.context = {}
cairo.surface = {}

-- From the cairo cookbook
-- http://cairographics.org/cookbook/roundedrectangles/
function gfx:round_rect_a(x,y,width,height,radius)
   local radius = radius or 5 -- an approximate curvature radius
   local half_radius = radius * 0.5
   local double_radius = radius + radius
   local x0, y0 = x, y -- + half_radius, y + half_radius
   local x1, y1 = x0+width, y0+height

   if width < double_radius then 
      if height < double_radius then
	 cairo:move_to(  x0, (y0 + y1) * 0.5 )
	 cairo:curve_to( x0, y0, x0, y0, (x0 + x1) * 0.5, y0 )
	 cairo:curve_to( x1, y0, x1, y0, x1, (y0 + y1) * 0.5 )
	 cairo:curve_to( x1, y1, x1, y1, (x1 + x0) * 0.5, y1 )
	 cairo:curve_to( x0, y1, x0, y1, x0, (y0 + y1) * 0.5 )
      else 
	 cairo:move_to(  x0, y0 + radius )
	 cairo:curve_to( x0 ,y0, x0, y0, (x0 + x1)/2, y0 )
	 cairo:curve_to( x1, y0, x1, y0, x1, y0 + radius )
	 cairo:line_to(  x1, y1 - radius )
	 cairo:curve_to( x1, y1, x1, y1, (x1 + x0)/2, y1 )
	 cairo:curve_to( x0, y1, x0, y1, x0, y1- radius )
      end
   else
      if height < double_radius then
	 cairo:move_to(  x0, (y0 + y1)/2 )
	 cairo:curve_to( x0 , y0, x0, y0, x0 + radius, y0 )
	 cairo:line_to(  x1 - radius, y0 )
	 cairo:curve_to( x1, y0, x1, y0, x1, (y0 + y1)/2 )
	 cairo:curve_to( x1, y1, x1, y1, x1 - radius, y1 )
	 cairo:line_to(  x0 + radius, y1 )
	 cairo:curve_to( x0, y1, x0, y1, x0, (y0 + y1)/2 )
      else
	 cairo:move_to(  x0, y0 + radius)
	 cairo:curve_to( x0 , y0, x0 , y0, x0 + radius, y0)
	 cairo:line_to(  x1 - radius, y0)
	 cairo:curve_to( x1, y0, x1, y0, x1, y0 + radius)
	 cairo:line_to(  x1, y1 - radius)
	 cairo:curve_to( x1, y1, x1, y1, x1 - radius, y1)
	 cairo:line_to(  x0 + radius, y1)
	 cairo:curve_to( x0, y1, x0, y1, x0, y1- radius)
      end
   end
end

function gfx:round_rect_b(x,y,w,h,radius_x,radius_y)
   -- http://graphics.stanford.edu/courses/cs248-98-fall/Final/q1.html
   local ARC_TO_BEZIER = 0.55228475
   local radius_x = radius_x or 5
   local radius_y = radius_y or 5

   if radius_x > w - radius_x then
      radius_x = w * 0.5
   end

   if radius_y > h - radius_y then
      radius_y = h * 0.5
   end

   -- approximate (quite close) the arc using a bezier curve
   local c1 = ARC_TO_BEZIER * radius_x
   local c2 = ARC_TO_BEZIER * radius_y

   cairo:move_to(      x + radius_x, y )
   cairo:rel_line_to(  w - 2 * radius_x, 0.0 )
   cairo:rel_curve_to( c1, 0.0, radius_x, c2, radius_x, radius_y )
   cairo:rel_line_to(  0, h - 2 * radius_y )
   cairo:rel_curve_to( 0, c2, c1 - radius_x, radius_y, -radius_x, radius_y )
   cairo:rel_line_to(  -w + 2 * radius_x, 0 )
   cairo:rel_curve_to( -c1, 0, -radius_x, -c2, -radius_x, -radius_y )
   cairo:rel_line_to(  0, -h + 2 * radius_y )
   cairo:rel_curve_to( 0, -c2, radius_x - c1, -radius_y, radius_x, -radius_y )
end

function gfx:round_rect_c(x, y, w, h, r)
   local r = r or 5
   cairo:move_to(  x  +r, y                            )                  
   cairo:line_to(  x+w-r, y                            )                
   cairo:curve_to( x+w,   y,    x+w, y,   x+w,   y  +r ) 
   cairo:line_to(  x+w,   y+h-r                        )           
   cairo:curve_to( x+w,   y+h,  x+w, y+h, x+w-r, y+h   )
   cairo:line_to(  x  +r, y+h                          )                   
   cairo:curve_to( x,     y+h,  x,   y+h, x,     y+h-r )      
   cairo:line_to(  x,     y  +r                        )                     
   cairo:curve_to( x,     y,    x,   y,   x  +r, y     )            
end

function gfx:round_rect_d(x, y, w, h, r)
   local r, half_pi = r or 5, pi * 0.5
   cairo:new_path()
   cairo:arc( x  +r, y  +r, r, 2*half_pi, 3*half_pi )
   cairo:arc( x+w-r, y  +r, r, 3*half_pi, 4*half_pi )
   cairo:arc( x+w-r, y+h-r, r, 0*half_pi, 1*half_pi )
   cairo:arc( x  +r, y+h-r, r, 1*half_pi, 2*half_pi )
end

local function take_string( table_or_string, table_key )
   local s = table_or_string or "<nil>"
   local t, k = type(s), table_key or 1
   if t == "string" then
      return s
   elseif t == "number" or t == "boolean" then
      return tostring(s)
   elseif t == "table" then
      -- The name is either the first element: [1], or .name, or .id
      return take_string( s[k] or s.label or s.text or s.name or s.id )
   elseif t == "function" then
      return take_string( s(k), table_key )
   else
      -- userdata
      -- thread
      -- luajit has more I think
      --   cdata
      --
      return "<"..t..">"
   end
end

-- items is meta structure
function gfx:list_box(items, x, y, w, h)
   local eh = 24 -- element height
   local h = h or eh * #items
   local ev = floor( h / eh ) -- elements visible
   local h = ev * eh
   local top = items.top or 1
   local bottom = items.bottom or #items
   local current = items.current or 1

   if top < current - ev + 1 then
      top = current - ev + 1
   end

   bottom = math.min(#items, top + ev - 1)

   items.top, items.bottom = top, bottom

   -- Make the rectangle path
   cairo:rectangle( x, y, w, h )

   -- Fill it first, but preserve the path
   cairo:set_source_rgb( 1, 1, 1 ) -- listbox background color
   cairo:fill_preserve()

   -- Next stroke it, and preserve the path
   cairo:set_source_rgb( 0, 0, 0 ) -- listbox "wire" color
   cairo:set_line_width( 0.25 )
   cairo:stroke_preserve()

   -- Now set the clip, do not keep the path
   cairo:clip()
   for i=top, bottom do
      local y = y + (i - top) * eh
      local current = (i == current)
      if current then
	 cairo:move_to(      x,  y )
	 cairo:rel_line_to(  w,  0 )
	 cairo:rel_line_to(  0, eh )
	 cairo:rel_line_to( -w,  0 )

	 -- background
	 cairo:set_source_rgb( 0, 0, 1 )
	 cairo:fill_preserve()
	 -- wiring
	 cairo:set_source_rgb( 1, 1, 1 )
	 cairo:stroke()
      end
      cairo:move_to(        x + 8, y + eh * 0.8 )
      cairo:set_source_rgb( current and 1 or 0, current and 1 or 0, current and 1 or 0 )
      cairo:show_text(      take_string( items[i] ) )
   end
   cairo:reset_clip()
end

local gfx_text_extents = ffi.new( "cairo_text_extents_t" )
function gfx:text_extents( text )
   cairo:text_extents( text, gfx_text_extents )
   return gfx_text_extents
end

function gfx:main_menu(items, x, y, w, h)
   local eh = 24 -- element height
   local ev = floor( h / eh ) -- elements visible
   local h = ev * eh
   local current = items.current or 1

   local hgap = 8
   local vgap = 5
   local width = 0
   local height = 0
   for i=1, #items do
      local item = take_string( items[i] )
      local te = gfx:text_extents( item )
      width = width + te.width + hgap*2
      height = math.max(height, te.height)
   end

   -- Make the rectangle path
   cairo:rectangle( x, y, width, height + vgap*2 )

   -- Fill it first, but preserve the path
   cairo:set_source_rgb( 1, 1, 1 ) -- listbox background color
   cairo:fill_preserve( )

   -- Next stroke it, and preserve the path
   cairo:set_source_rgb( 0, 0, 0 ) -- listbox "wire" color
   cairo:set_line_width( 0.25 )
   cairo:stroke_preserve()

   -- Now set the clip, do not keep the path
   cairo:clip()
   local cx = hgap
   for i=1, #items do
      local iw = gfx:text_extents( take_string(items[i]) ).width + hgap*2
      local y = 0
      local current = (i == current)
      local opened = items.opened
      if current then
	 if items.opened then
	 else
	    cairo:move_to( cx-hgap,  y )
	    cairo:rel_line_to(  iw,  0 )
	    cairo:rel_line_to(   0,  height + vgap*2 )
	    cairo:rel_line_to( -iw,  0 )

	    -- background
	    cairo:set_source_rgb( 0, 0, 1 )
	    cairo:fill_preserve()
	    -- wiring
	    cairo:set_source_rgb( 1, 1, 1 )
	    cairo:stroke()
	 end
      end
      cairo:move_to( cx, y + height*1.2  )
      if current and not opened then
	 cairo:set_source_rgb( 1, 1, 1 )
      else
	 if current and opened then
	    cairo:set_source_rgb( 0.5, 0.5, 0.5 )
	 else
	    cairo:set_source_rgb( 0, 0, 0 )
	 end
      end
      local item = take_string( items[i] )
      cairo:show_text( item )
      if current and opened then
	 local items = items[i]
	 if type(items)=="function" then
	    items = items()
	 end
	 local items = items[2]
	 if items then
	    cairo:save()
	    cairo:reset_clip()
	    gfx:list_box( items, cx, y + height+hgap, 100 )
	    cairo:restore()
	 end
      end
      cx = cx + iw
   end
   cairo:reset_clip()
end

function ui:list_box(state)
   -- Draws a list_box
end

local items = {
   "First Item",
   "Secod Item",
   "Third Item",
   "Fourth Item",
   "Fifth Item",
   "Third Item 1",
   "Fourth Item 2",
   "Fifth Item 3",
   "Third Item 4",
   "Fourth Item 5",
   "Fifth Item 6",
   "Third Item 7",
   "Fourth Item 8",
   "Fifth Item 9",
   selected = { 3, 5 },
   current = 2,
}

-- Table is a magic construct :)
-- The menu would be defined in it
-- All "array" elements define order of display
-- All "dictionary" elements define actions

local edit_menu = { 
   "Edit", { 
      "Undo", { 
	 "Cut" 
      },
      "Paste", { 
	 "Paste from Kill Menu", { 
	    "Clip1",
	    "Clip2",
	    "Clip3" 
	 },
      },
   },
}

local edit_menu2 = { 
   "Edit", { 
      "Undo2", { 
	 "Cut2" 
      },
      "Paste2", { 
	 "Paste2 from Kill Menu", { 
	    "Clip4",
	    "Clip5",
	    "Clip6" 
	 },
      },
   },
}

local which_edit_menu

local test_menu = {
   "(Apple)", {
      "About This Mac", function() end,
      "Software Update...", function() end,
      "App Store...", function() end,
      "", {},
   },
   "File", {
      
   },
   "Edit", {
   },
   "Options", {
      "Line Wrapping", {
      },
      { true, "Smart Word Spacing in Text Modes" },
      "", {},
      ""
   },
}

--[[
  lua types: 
    nil, boolean, number, string, function, userdata, thread, and table
  First item
    if function, then eval it, and put result back here
    if string then that's the textual contents
    if number
    if boolean
  Second item

  First item -- Visual representation
    nil      -> ? bad idea to rely on it
    boolean  -> ? Maybe way to display checked menu items?
    number   -> ? 
    string   -> The text of the item
    function -> Evals the function, then feedback the result back to "First item"
    userdata -> ?
    thread   -> Like function, but actually resumes the thread coroutine, and expects value to be yielded back to "First item"
    table    -> Special cases - like Check boxed item, or image item, builtin-slider, etc... Maybe widget or whole OO style widgets
    cdata    -> ?

  Second item -- Action to be taken
    nil      -> ? bad idea to rely on it
    boolean  -> ? Maybe not active, or disabled or it could be a way to specify checked menu items
    number   -> This can keep some kind of number identifier - like 513
    string   -> This can keep some kind of string identifier - like "ID_MENU_ITEM_BLAH123"
    function -> Action to be taken when pressed
    userdata -> ?
    thread   -> Like function, but actually resumes the thread coroutine with the action. Could be the only way to implement interactive dialogs in the menu, like in OSX Help ->Search
    table    -> Sub-items are listed here
    cdata    -> ?
--]]

-- Menu is defined in pairs of 2
-- First item is the textual representation
--       If it's a string, then it's the text itself
--       If it's a function, then the function returns the representation
--       If it's a table, number, userdata, etc. - undefined for now
-- Second item is either menu expansion or function
--       If it's a table, then it's an expansion
--       Otherwise if it's a function then it acts on it's value.

local main_menu = {
   {
      "File", {
	 { "Visit New File | C-x C-f" },
	 { "Open File...", "Test" },
      },
   },
   function()
      which_edit_menu = not(which_edit_menu)
      return which_edit_menu and edit_menu or edit_menu2
   end,
   { 
      "Options", {
	 "Line Wrapping",
	 "Smart Word Spacing",
	 "-------------",
	 "Show Tabs",
	 "Show Buffers in new",
	 "----"
      },
   },
   { 
      "Buffers", { 
	 { name1 = "One" },
	 { name = "Two" },
	 { label = "Treeh" }
      },
   },
   { "Tools" },
   { "Lua" },
   { 
      "Help", {
	 function() return "Search [|   ]" end,
	 "Help on Word",
	 "Documentation",
	 "About",
      },
   },
   {
      function() return os.date( "%X" ) end,
      {
	 function() return os.date( "%A" ) end,
	 function() return os.date( "%d %b %Y" ) end,
      }
   },
   current = 3,
}

local function make_colors(n)
   n = n or 16
   local colors = {}
   for i=1, n do
      local r = random(0.1,0.9)
      local g = random(0.1,0.9)
      local b = random(0.1,0.9)
      local mag = r*r + g*g + b*b
      local oolen = 1 / math.sqrt(mag)
      r, g, b = r*oolen, g*oolen, b*oolen
      v = { random(), random(), random() }
      v[random(1,#v)] = 1 --0.50
      v[random(1,#v)] = 1 --0.75
      colors[#colors+1] = { r*v[1], g*v[1], b*v[2], 1 }
   end
   return colors
end

local key2cmd = {
   --sdl.SDLK_UP    = "up",
   --sdl.SDLK_DOWN  = "down",
   --sdl.SDLK_LEFT  = "left",
   --sdl.SDLK_RIGHT = "right",
   --sdl.SDLK_SPACE = "select",
   --sdl.SDLK_ENTER = "accept",
}

do
   local sdl_surface

   function wm:resized()
      local format = cairo.FORMAT_RGB24
      cairo.surface = ffi.gc(
	 cairo:image_surface_create( format, self.width, self.height ),
	 cairo.library.cairo_surface_destroy 
      )
      cairo.context = ffi.gc(
	 cairo:create( cairo.surface ),
	 cairo.library.cairo_destroy
      )
      sdl_surface = ffi.gc(
	 sdl.SDL_CreateRGBSurfaceFrom(
	    cairo.library.cairo_image_surface_get_data( cairo.surface ),
	    self.width, self.height, 32,
	    cairo.library.cairo_format_stride_for_width( format, self.width ),
	    0, 0, 0, 0
	 ),
	 sdl.SDL_FreeSurface
      )
      sdl.SDL_WM_SetCaption( "GUI Demo", nil )
   end

   function wm:key_pressed()
      if self.kb == 27 then
	 wm:exit()
      end
   end

   local colors = make_colors()

   local frame = 0 

   while wm:update(false) do
      cairo:save()
      cairo:set_operator( cairo.OPERATOR_SOURCE )
      cairo:set_source_rgba( 1, 0.75, 0.15, 1 )
      cairo:paint()
      cairo:restore()

      cairo:select_font_face( "Tahoma", 0, 0 )
      cairo:set_font_size( 16 )
      cairo:move_to( wm.width - 50, wm.height - 16 )
      cairo:set_source_rgba( 1, 1, 1, 1 )
      cairo:show_text( tostring( #lines ))

      cairo:set_line_width( 1+math.sqrt(math.max(1,wm.wheel/16)))

      local color = 0
      for i=1,#lines do
	 local point = lines[i]
	 if i > 1 and lines[i-1].solid then
	    cairo:line_to( point.x, point.y )
	 else
	    cairo:move_to( point.x, point.y )
	    cairo:stroke()
--	    cairo:set_line_width( random()*3 + math.sqrt(math.max(1,wm.wheel/16)))
	    color = color + 1
	    local color = colors[ color % #colors + 1 ]
	    cairo:set_source_rgba( color[1], color[2], color[3], color[4] )
	 end
      end
      cairo:stroke()

      if wm.mb[1] then
	 local dx = lines[ #lines ].x - wm.mx
	 local dy = lines[ #lines ].y - wm.my
	 if math.abs(dx) > 1 or math.abs(dy) > 1 then
	    lines[ #lines + 1 ] = { x = wm.mx, y = wm.my, solid=true, color = random() }
	 end
      elseif lines[ #lines ].solid then
	 lines[ #lines + 1 ] = { x=wm.mx, y=wm.my, solid=false, color = random() }
      end

      if wm.mb[3] then
	 lines = {{ x=wm.mx, y = wm.my, solid=true }}
	 colors = make_colors()
      end

      cairo:set_line_width( 0.5 )

      local bw, bh = 128 + 16 + frame,32 + frame
      local cols, rows = floor(wm.width / bw) + 1, floor(wm.height / bh) + 1
      cols, rows = 4, 4
      for i=0, cols*rows - 1 do
	 local col, row = floor(i / rows), (i % rows)
	 local x, y = col * bw, row * bh + 50
	 local inset = 10
	 local method = (i % 4 + 1) --random(1,4)
	 cairo:set_source_rgba( 1, 1, 1, 1 )

	 gfx["round_rect_"..string.char(32+64+method)](gfx, x+inset, y+inset, bw-inset, bh-inset, bh / 3 )

	 local a, b, c, d = random(#colors), random(#colors),random(#colors),random(#colors)
	 if i ~= os.time() % (cols*rows) then
	    cairo:set_source_rgba( 1, 1, 1, 1 )
	 else
	    cairo:set_source_rgba( 0.25, 0.5, 1, 1 )
	 end

	 cairo:fill_preserve()
	 cairo:set_source_rgba( 0, 0, 0, 1 )
	 cairo:stroke()
	 cairo:move_to( x + 22, y + bh * 0.8 )
	 cairo:set_font_size( bh * 0.5 )
	 cairo:show_text( "Aa" )
      end

      local current = items.current - 1
      
      if     wm.kb == sdl.SDLK_UP     then items.current = (current - 1) % #items + 1
      elseif wm.kb == sdl.SDLK_DOWN   then items.current = (current + 1) % #items + 1
      elseif wm.kb == sdl.SDLK_LEFT   then main_menu.current = (main_menu.current - 2) % #main_menu + 1
      elseif wm.kb == sdl.SDLK_RIGHT  then main_menu.current = main_menu.current % #main_menu + 1
      elseif wm.kb == sdl.SDLK_RETURN then main_menu.opened = not main_menu.opened end
      wm.kb = 0
      
      gfx:list_box( items, 10, wm.height/2-50, 100, 200 )
      gfx:list_box( items, 170, wm.height/2-25, 175, 300 )
      gfx:main_menu( main_menu, 0, 0, wm.width, 100 )
      
      sdl.SDL_UpperBlit( sdl_surface, nil, wm.window, nil )
   end
end



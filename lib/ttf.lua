local ffi = require( "ffi" )
local floor, ceil = math.floor, math.ceil
local shl, shr, band, bor = bit.lshift, bit.rshift, bit.band, bit.bor

ffi.cdef[[
      enum {
	 TTF_VMOVE               = 1,
	 TTF_VLINE               = 2,
	 TTF_VCURVE              = 3,
	 TTF_MACSTYLE_DONTCARE   = 0,
	 TTF_MACSTYLE_BOLD       = 1,
	 TTF_MACSTYLE_ITALIC     = 2,
	 TTF_MACSTYLE_UNDERSCORE = 4,
 	 TTF_MACSTYLE_NONE       = 8,
	 TTF_PLATFORM_UNICODE    = 0,
	 TTF_PLATFORM_MAC        = 1,
	 TTF_PLATFORM_ISO        = 2,
	 TTF_PLATFORM_MICROSOFT  = 3,
	 TTF_UNICODE_EID_UNICODE_1_0      = 0,
	 TTF_UNICODE_EID_UNICODE_1_1      = 1,
	 TTF_UNICODE_EID_ISO_10646        = 2,
	 TTF_UNICODE_EID_UNICODE_2_0_BMP  = 3,
	 TTF_UNICODE_EID_UNICODE_2_0_FULL = 4,
	 TTF_MICROSOFT_EID_SYMBOL         = 0,
	 TTF_MICROSOFT_EID_UNICODE_BMP    = 1,
	 TTF_MICROSOFT_EID_SHIFTJIS       = 2,
	 TTF_MICROSOFT_EID_UNICODE_FULL   = 10,
      };

enum { // encodingID for STBTT_PLATFORM_ID_MAC; same as Script Manager codes
   STBTT_MAC_EID_ROMAN        =0,   STBTT_MAC_EID_ARABIC       =4,
   STBTT_MAC_EID_JAPANESE     =1,   STBTT_MAC_EID_HEBREW       =5,
   STBTT_MAC_EID_CHINESE_TRAD =2,   STBTT_MAC_EID_GREEK        =6,
   STBTT_MAC_EID_KOREAN       =3,   STBTT_MAC_EID_RUSSIAN      =7,
};

enum { // languageID for STBTT_PLATFORM_ID_MICROSOFT; same as LCID...
       // problematic because there are e.g. 16 english LCIDs and 16 arabic LCIDs
   STBTT_MS_LANG_ENGLISH     =0x0409,   STBTT_MS_LANG_ITALIAN     =0x0410,
   STBTT_MS_LANG_CHINESE     =0x0804,   STBTT_MS_LANG_JAPANESE    =0x0411,
   STBTT_MS_LANG_DUTCH       =0x0413,   STBTT_MS_LANG_KOREAN      =0x0412,
   STBTT_MS_LANG_FRENCH      =0x040c,   STBTT_MS_LANG_RUSSIAN     =0x0419,
   STBTT_MS_LANG_GERMAN      =0x0407,   STBTT_MS_LANG_SPANISH     =0x0409,
   STBTT_MS_LANG_HEBREW      =0x040d,   STBTT_MS_LANG_SWEDISH     =0x041D,
};

enum { // languageID for STBTT_PLATFORM_ID_MAC
   STBTT_MAC_LANG_ENGLISH      =0 ,   STBTT_MAC_LANG_JAPANESE     =11,
   STBTT_MAC_LANG_ARABIC       =12,   STBTT_MAC_LANG_KOREAN       =23,
   STBTT_MAC_LANG_DUTCH        =4 ,   STBTT_MAC_LANG_RUSSIAN      =32,
   STBTT_MAC_LANG_FRENCH       =1 ,   STBTT_MAC_LANG_SPANISH      =6 ,
   STBTT_MAC_LANG_GERMAN       =2 ,   STBTT_MAC_LANG_SWEDISH      =5 ,
   STBTT_MAC_LANG_HEBREW       =10,   STBTT_MAC_LANG_CHINESE_SIMPLIFIED =33,
   STBTT_MAC_LANG_ITALIAN      =3 ,   STBTT_MAC_LANG_CHINESE_TRAD =19,
};



      typedef struct _ttf_bakedchar {
	 uint16_t x0, y0, x1, y1;
	 float    xoff, yoff, xadvance;
      } ttf_bakedchar;
      
      typedef struct _ttf_aligned_quad {
	 float x0, y0, s0, t0;
	 float x1, y1, s1, t1;
      } ttf_aligned_quad;

      typedef struct _ttf_fontinfo {
	 void*    userdata;
	 uint8_t* data;
	 uint32_t fontstart;
	 uint32_t n_glyphs; 
	 uint32_t loca, head, glyf, hhea, hmtx;
	 uint32_t index_map;
	 uint32_t index_to_loc_format;
      } ttf_fontinfo;

      typedef struct _ttf_vertex {
	 int16_t x, y, cx, cy;
	 uint8_t type, padding;
      } ttf_vertex;
      
      typedef struct _ttf_bitmap {
	 int w, h, stride;
	 uint8_t* pixels;
      } ttf_bitmap;

      typedef struct _ttf_edge {
	 float x0,y0, x1,y1;
	 int invert;
      } ttf_edge;

      typedef struct _ttf_active_edge {
	 int x,dx;
	 float ey;
	 struct _ttf_active_edge* next;
	 int valid;
      } ttf_active_edge;
]]

local m = {}

local function read_uint16( ptr )
   local data8 = ffi.cast( "uint8_t*", ptr )
   return bor( shl( ptr[0], 8 ),  ptr[1] )
end

local function read_uint32( ptr )
   local data8 = ffi.cast( "uint8_t*", ptr )
   return bor( shl( ptr[0], 24 ),  shl( ptr[1], 16 ), shl( ptr[2], 8 ), ptr[3] )
end

local function tag( font, id )
end

function m.isfont( font )
   return true;
end

local function find_table( data8, fontstart, tag )
   local n_tables = read_uint16( data + fontstart + 4 )
   local tabledir = fontstart + 12
   for i = 0, n_tables - 1 do
      local loc = tabledir + 16 * i
      if tag( data + loc, tag ) then
	 return read_uint32( data + loc + 8 )
      end
   end
   return nil
end

local function index_to_offset( fontcol, index )
   if isfont( fontcol ) then
      if index == 0 then
	 return 0
      end
      return nil
   end

   if tag( fontcol, "ttcf" ) then
      if read_uint32( fontcol + 4 ) == 0x00010000 or read_uint32( fontcol + 4 ) == 0x00020000 then
	 local n = read_uint32( fontcol + 8 )
	 if index >= n then
	    return nil
	 end
	 return read_uint32( fontcol + 12 + index * 14 )
      end
   end

   return nil
end

local function initfont( info, data, fontstart )
   info.data = data
   info.fontstart = fontstart
   
   for _, v in ipairs{ "cmap", "loca", "head", "glyf", "hhea", "hmtx" } do
      local offs = find_table( data, fontstart, v )
      if not offs then
	 return nil
      end
      info[ v ] = offs
   end

   local t = find_table( data, fontstart, "maxp" )
   if t then
      info.n_glyphs = read_uint16( data + t + 4 )
   else
      info.n_glyphs = 0xFFFF
   end

   local n_tables = read_uint16( data + cmap + 2 )
   local index_map 
   for i = 0, n_tables - 1 do
      local offs = cmap + 4 + 8 * i
      local plat = read_uint16( data, offs )
      if plat == C.TTF_PLATFORM_MICROSOFT then
	 local eid = read_uint16( data, offs + 2 )
	 if eid == C.TTF_MS_EID_UNICODE_BMP or
	    eid == C.TTF_MS_EID_UNICODE_FULL then
	    info.index_map = cmap + read_uint32( data, offs + 4 )
	 end
      end
   end

   if not index_map then
      return nil
   end

   info.index_map = index_map
   info.index_to_loc_format = read_uint16( data, info.head + 50 )

   return true
end

local function find_glyph_index( info, unicode_codepoint )
   local data = info.data
   local index_map = info.index_map
   local format = read_uint16( data, index_map )
   if format == 0 then
      local bytes = read_uint16( data, index_map + 2 )
      if unicode_codepoint < bytes - 6 then
	 return read_uint8( data, index_map + 6 + unicode_codepoint )
      end
   elseif format == 6 then
      local first, count = read_uint16( data, index_map + 6 ), read_uint16( data, index_map + 8 )
      if unicode_codepoint >= first and
	 unicode_codepoint < first + count then
	 return read_uint16( data, index_map + 10 + (unicode_codepoint - first) * 2 )
      end
   elseif format == 4 then
      if unicode_codepoint > 0xFFFF then
	 return nil
      end

      local segment_count  = shr( read_uint16( data, index_map + 6 ), 1 )
      local search_range   = shr( read_uint16( data, index_map + 8 ), 1 )
      local entry_selector =      read_uint16( data, index_map + 10 )
      local range_shift    = shr( read_uint16( data, index_map + 12 ), 1 )
      local item, offset, start, endx
      local end_count      = index_map + 14
      local search         = end_count

      if unicode_codepoint >= read_uint16( data, search + range_shift * 2 ) then
	 search = search + range_shift * 2
      end

      search = search - 2
      while entry_selector do
	 search_range = shr( search_range, 1 )
	 local start, endx = read_uint16( data, search + 2 + segment_count  * 2 + 2 ), read_uint16( data, search + 2 )
	 local start, endx = read_uint16( data, search + 2 + segment_count  * 2 + 2 + search_range * 2 ), read_uint16( data, search + 2 + search_range * 2 )
	 if unicode_codepoint > endx then
	    search = search + search_range * 2
	 end
	 entry_selector = entry_selector - 1
      end
      search = search + 2

      local item = shr( search - end_count, 1 )
      local start, endx = read_uint16( data, index_map + 14 + segment_count * 2 + 2 + 2 * item ), read_uint16( data, index_map + 14 + 2 + 2 * item )

      if unicode_codepoint < start then
	 return nil
      end

      local offset = read_uint16( data, index_map + 14 + segment_count * 6 + 2 + 2 * item )
      if offset == 0 then
         return unicode_codepoint + read_uint16( data, index_map + 14 + segcount*4 + 2 + 2*item )
      end

      return read_uint16( data, offset + (unicode_codepoint-start)*2 + index_map + 14 + segcount*6 + 2 + 2*item )

   elseif format == 12 then
      --todo
   end
   return nil
end


local function get_glyph_offset( info, index )
   if index >= info.n_glyphs or
      info.index_to_loc_format >= 2 then
      return nil
   end

   local g1, g2

   if info.index_to_loc_format == 0 then
      g1 = info.glyph + read_uint16( data, info.loca + index * 2 ) * 2
      g2 = info.glyph + 10 
   else
      
   end

   if g1 == g2 then
      return nil
   end
     
   return info.glyph + g1
end

local function get_glyph_box( info, index )
   local g = get_glyph_offset( info, index )
   if not g then
      return nil
   end
   return read_uint16( data, g + 2 ), read_uint16( data, g + 4 ), read_uint16( data, g + 6 ), read_uint16( data, g + 8 )
end

local function get_glyph_shape( info, index )
   local g = get_glyph_offset( info, index )
   if not g then return nil end
   
   local n_contours = read_uint16( data, g )
   if n_contours > 0 then
      
   end
end

local function matches( fontcol, offs, name, flags )
   if not isfont( fontcol
end

local function find_matching_font( fontcol, name, flags )
   local i = 0
   while true do
      local offs = index_to_offset( fontcol, i )
      if offs < 0 or matches( fontcol, offs, name, flags ) then
	 return offs
      end
      i = i + 1
   end
end


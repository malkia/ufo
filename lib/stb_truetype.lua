-- Translation to LuaJIT of stb_truetype.h - v0.3 - public domain - 2009 Sean Barrett / RAD Game Tools
-- Translated by Dimiter "malkia" Stanev, malkia@gmail.com

local m = {}

function m.stbtt_InitFont( info, data2, fontstart )
   stbtt_uint8 *data = (stbtt_uint8 *) data2;
   stbtt_uint32 cmap, t;
   stbtt_int32 i,numTables;

   info->data = data;
   info->fontstart = fontstart;

   local cmap = stbtt__find_table(data, fontstart, "cmap");
   info->loca = stbtt__find_table(data, fontstart, "loca");
   info->head = stbtt__find_table(data, fontstart, "head");
   info->glyf = stbtt__find_table(data, fontstart, "glyf");
   info->hhea = stbtt__find_table(data, fontstart, "hhea");
   info->hmtx = stbtt__find_table(data, fontstart, "hmtx");
   if (!cmap || !info->loca || !info->head || !info->glyf || !info->hhea || !info->hmtx)
      return 0;

   t = stbtt__find_table(data, fontstart, "maxp");
   if (t)
      info->numGlyphs = ttUSHORT(data+t+4);
   else
      info->numGlyphs = 0xffff;

   // find a cmap encoding table we understand *now* to avoid searching
   // later. (todo: could make this installable)
   // the same regardless of glyph.
   numTables = ttUSHORT(data + cmap + 2);
   info->index_map = 0;
   for (i=0; i < numTables; ++i) {
      stbtt_uint32 encoding_record = cmap + 4 + 8 * i;
      // find an encoding we understand:
      switch(ttUSHORT(data+encoding_record)) {
         case STBTT_PLATFORM_ID_MICROSOFT:
            switch (ttUSHORT(data+encoding_record+2)) {
               case STBTT_MS_EID_UNICODE_BMP:
               case STBTT_MS_EID_UNICODE_FULL:
                  // MS/Unicode
                  info->index_map = cmap + ttULONG(data+encoding_record+4);
                  break;
            }
            break;
      }
   }
   if (info->index_map == 0)
      return 0;

   info->indexToLocFormat = ttUSHORT(data+info->head + 50);
   return 1;
}

-- testing...

local ffi = require('ffi')
ffi.cdef[[
      typedef struct FILE* FILE;

      enum {
	 FZ_STORE_UNLIMITED,
	 FZ_STORE_DEFAULT = 256 << 20,
      };

      enum {
	 FZ_LOCK_ALLOC,
	 FZ_LOCK_FILE,
	 FZ_LOCK_FREETYPE,
	 FZ_LOCK_GLYPHCACHE,
	 FZ_LOCK_MAX
      };

      typedef enum fz_link_kind {
	 FZ_LINK_NONE,
	 FZ_LINK_GOTO,
	 FZ_LINK_URI,
	 FZ_LINK_LAUNCH,
	 FZ_LINK_NAMED,
	 FZ_LINK_GOTOR,
      } fz_link_kind;
      
      enum {
	 fz_link_flag_l_valid   =  1, /* lt.x is valid */
	 fz_link_flag_t_valid   =  2, /* lt.y is valid */
	 fz_link_flag_r_valid   =  4, /* rb.x is valid */
	 fz_link_flag_b_valid   =  8, /* rb.y is valid */
	 fz_link_flag_fit_h     = 16, /* Fit horizontally */
	 fz_link_flag_fit_v     = 32, /* Fit vertically */
	 fz_link_flag_r_is_zoom = 64, /* rb.x is actually a zoom figure */
      };

      enum {
	 FZ_META_UNKNOWN_KEY = -1,
	 FZ_META_OK,
	 FZ_META_FORMAT_INFO,
	 FZ_META_CRYPT_INFO,
	 FZ_META_HAS_PERMISSION,
	 FZ_META_INFO,
      };

      enum {
	 FZ_PERMISSION_PRINT,
	 FZ_PERMISSION_CHANGE,
	 FZ_PERMISSION_COPY,
	 FZ_PERMISSION_NOTES,
      };

      typedef struct fz_error_context fz_error_context;
      typedef struct fz_warn_context  fz_warn_context;
      typedef struct fz_font_context  fz_font_context;
      typedef struct fz_aa_context    fz_aa_context;
      typedef struct fz_store         fz_store;
      typedef struct fz_glyph_cache   fz_glyph_cache;
      typedef struct fz_buffer        fz_buffer;
      typedef struct fz_stream        fz_stream;
      typedef struct fz_colorspace    fz_colorspace;
      typedef struct fz_pixmap        fz_pixmap;
      typedef struct fz_bitmap        fz_bitmap;
      typedef struct fz_image         fz_image;
      typedef struct fz_halftone      fz_halftone;
      typedef struct fz_font          fz_font;
      typedef struct fz_device        fz_device;
      typedef struct fz_display_list  fz_display_list;
      typedef struct fz_link          fz_link;
      typedef struct fz_link_dest     fz_link_dest;
      typedef struct fz_outline       fz_outline;
      typedef struct fz_document      fz_document;
      typedef struct fz_page          fz_page;

      typedef struct fz_alloc_context {
	 void*          user;
	 void*       (* malloc)(  void*,        unsigned int );
	 void*       (* realloc)( void*, void*, unsigned int );
	 void        (* free)(    void*, void*  );
      } fz_alloc_context;

      /*
      typedef struct fz_error_context {
	 int            top;
	 struct {
	    int         code;
	    jmp_buf     buffer;
	 }              stack[256];
	 char           message[256];
      } fz_error_context;
      */

      typedef struct fz_locks_context {
	 void *user;
	 void (*lock)(void *user, int lock);
	 void (*unlock)(void *user, int lock);
      } fz_locks_context;

      typedef struct fz_context
      {
	 fz_alloc_context* alloc;
	 fz_locks_context* locks;
	 fz_error_context* error;
	 fz_warn_context*  warn;
	 fz_font_context*  font;
	 fz_aa_context*    aa;
	 fz_store*         store;
	 fz_glyph_cache*   glyph_cache;
      } fz_context;

      typedef struct fz_point
      {
	 float x, y;
      } fz_point;

      typedef struct fz_rect
      {
	 float x0, y0;
	 float x1, y1;
      } fz_rect;

      typedef struct fz_bbox
      {
	 int x0, y0;
	 int x1, y1;
      } fz_bbox;

      typedef struct fz_matrix
      {
	 float a, b, c, d, e, f;
      } fz_matrix;

      
      typedef struct fz_text_style {
	 struct fz_text_style* next;
	 int                   id;
	 fz_font*              font;
	 float                 size;
	 int                   wmode;
	 int                   script;
	 /*        etc...      */
      } fz_text_style;

      typedef struct fz_text_sheet {
	 int            maxid;
	 fz_text_style* style;
      } fz_text_sheet;

      typedef struct fz_text_char {
	 fz_rect        bbox;
	 int            c;
      } fz_text_char;

      typedef struct fz_text_span fz_text_span;
      typedef struct fz_text_line {
	 fz_rect        bbox;
	 int            len, cap;
	 fz_text_span*  spans;
      } fz_text_line;

      typedef struct fz_text_block {
	 fz_rect        bbox;
	 int            len, cap;
	 fz_text_line*  lines;
      } fz_text_block;

      typedef struct fz_text_page {
	 fz_rect        mediabox;
	 int len,       cap;
	 fz_text_block* blocks;
      } fz_text_page;

      typedef struct fz_text_span {
	 fz_rect        bbox;
	 int            len, cap;
	 fz_text_char*  text;
	 fz_text_style* style;
      } fz_text_span;

      typedef struct fz_cookie {
	 int            abort;
	 int            progress;
	 int            progress_max; // -1 for unknown
      } fz_cookie;

      typedef struct fz_link_dest {
	 fz_link_kind kind;
	 union {
	    struct {
	       int      page;
	       int      flags;
	       fz_point lt;
	       fz_point rb;
	       char*    file_spec;
	       int      new_window;
	    } gotor;
	    struct {
	       char*    uri;
	       int      is_map;
	    } uri;
	    struct {
	       char*    file_spec;
	       int      new_window;
	    } launch;
	    struct {
	       char*    named;
	    } named;
	 } ld;
      } fz_link_dest;

      typedef struct fz_link {
	 int            refs;
	 fz_rect        rect;
	 fz_link_dest   dest;
	 fz_link*       next;
      } fz_link;

      typedef struct fz_outline {
	 char*          title;
	 fz_link_dest   dest;
	 fz_outline*    next;
	 fz_outline*    down;
      } fz_outline;

      extern int             fz_optind;
      extern char*           fz_optarg;
      extern const fz_rect   fz_unit_rect;
      extern const fz_bbox   fz_unit_bbox;
      extern const fz_rect   fz_empty_rect;
      extern const fz_bbox   fz_empty_bbox;
      extern const fz_rect   fz_infinite_rect;
      extern const fz_bbox   fz_infinite_bbox;
      extern const fz_matrix fz_identity;
      extern fz_colorspace*  fz_device_gray;
      extern fz_colorspace*  fz_device_rgb;
      extern fz_colorspace*  fz_device_bgr;
      extern fz_colorspace*  fz_device_cmyk;

      void        fz_var_imp(         void* );
      void        fz_push_try(        fz_error_context* ex );
      void        fz_throw(           fz_context*, char *fmt, ... );
      void        fz_rethrow(         fz_context*  );
      void        fz_warn(            fz_context*, char *fmt, ... );
      void        fz_flush_warnings(  fz_context*  );
      fz_context* fz_new_context(     fz_alloc_context*, fz_locks_context*, unsigned int max_store );
      fz_context* fz_clone_context(   fz_context*  );
      void        fz_free_context(    fz_context*  );
      int         fz_aa_level(        fz_context*  );
      void        fz_set_aa_level(    fz_context*, int bits );
      void*       fz_malloc(          fz_context*, unsigned int size );
      void*       fz_calloc(          fz_context*, unsigned int count, unsigned int size );
      void*       fz_malloc_array(    fz_context*, unsigned int count, unsigned int size );
      void*       fz_resize_array(    fz_context*, void *p, unsigned int count, unsigned int size );
      char*       fz_strdup(          fz_context*, char *s );
      void        fz_free(            fz_context*, void *p );
      void*       fz_malloc_no_throw( fz_context *ctx, unsigned int size );
      void*       fz_calloc_no_throw( fz_context *ctx, unsigned int count, unsigned int size );
      void*       fz_malloc_array_no_throw( fz_context *ctx, unsigned int count, unsigned int size);
      void*       fz_resize_array_no_throw( fz_context *ctx, void *p, unsigned int count, unsigned int size );
      char*       fz_strdup_no_throw(    fz_context *ctx, char *s );
      char*       fz_strsep(             char **stringp, const char *delim );
      int         fz_strlcpy(            char *dst, const char *src, int n );
      int         fz_strlcat(            char *dst, const char *src, int n );
      int         fz_chartorune(         int *rune, char *str );
      int         fz_runetochar(         char *str, int rune );
      int         fz_runelen(            int rune );
      int         fz_getopt(             int nargc, char * const *nargv, const char *ostr );
      fz_matrix        fz_concat(             fz_matrix left, fz_matrix right );
      fz_matrix        fz_scale(              float sx, float sy );
      fz_matrix        fz_shear(              float sx, float sy );
      fz_matrix        fz_rotate(             float degrees );
      fz_matrix        fz_translate(          float tx, float ty );
      fz_matrix        fz_invert_matrix(      fz_matrix );
      int              fz_is_rectilinear(     fz_matrix );
      float            fz_matrix_expansion(   fz_matrix );
      fz_bbox          fz_bbox_covering_rect( fz_rect );
      fz_bbox          fz_round_rect(         fz_rect );
      fz_rect          fz_intersect_rect(     fz_rect a, fz_rect b );
      fz_bbox          fz_intersect_bbox(     fz_bbox a, fz_bbox b );
      fz_rect          fz_union_rect(         fz_rect a, fz_rect b );
      fz_bbox          fz_union_bbox(         fz_bbox a, fz_bbox b );
      fz_point         fz_transform_point(    fz_matrix transform, fz_point point  );
      fz_point         fz_transform_vector(   fz_matrix transform, fz_point vector );
      fz_rect          fz_transform_rect(     fz_matrix transform, fz_rect  rect   );
      fz_bbox          fz_transform_bbox(     fz_matrix transform, fz_bbox  bbox   );
      fz_buffer*       fz_keep_buffer(        fz_context*, fz_buffer* );
      void             fz_drop_buffer(        fz_context*, fz_buffer* );
      int              fz_buffer_storage(     fz_context*, fz_buffer *, unsigned char **data );
      fz_stream*       fz_open_file(          fz_context*, const char*    filename );
      fz_stream*       fz_open_file_w(        fz_context*, const wchar_t* filename );
      fz_stream*       fz_open_fd(            fz_context*, int file );
      fz_stream*       fz_open_memory(        fz_context*, unsigned char*, int len );
      fz_stream*       fz_open_buffer(        fz_context*, fz_buffer* );
      void             fz_close(              fz_stream* );
      int              fz_tell(               fz_stream* );
      void             fz_seek(               fz_stream*, int offset, int whence );
      int              fz_read(               fz_stream*, unsigned char* data, int len );
      fz_buffer*       fz_read_all(           fz_stream*, int initial );
      fz_bitmap*       fz_keep_bitmap(        fz_context*, fz_bitmap* );
      void             fz_drop_bitmap(        fz_context*, fz_bitmap* );
      fz_colorspace*   fz_find_device_colorspace( fz_context*, char* );
      fz_bbox          fz_pixmap_bbox(        fz_context*, fz_pixmap* );
      int              fz_pixmap_width(       fz_context*, fz_pixmap* );
      int              fz_pixmap_height(      fz_context*, fz_pixmap* );
      fz_pixmap*       fz_new_pixmap(         fz_context*, fz_colorspace*, int w, int h );
      fz_pixmap*       fz_new_pixmap_with_bbox( fz_context*, fz_colorspace*, fz_bbox );
      fz_pixmap*       fz_new_pixmap_with_data( fz_context*, fz_colorspace*, int w, int h, unsigned char *samples );
      fz_pixmap*       fz_new_pixmap_with_bbox_and_data( fz_context*, fz_colorspace*, fz_bbox bbox, uint8_t* samples );
      fz_pixmap*       fz_keep_pixmap(               fz_context*, fz_pixmap*  );
      void             fz_drop_pixmap(               fz_context*, fz_pixmap*  );
      fz_colorspace*   fz_pixmap_colorspace(         fz_context*, fz_pixmap*  );
      int              fz_pixmap_components(         fz_context*, fz_pixmap*  );
      uint8_t*         fz_pixmap_samples(            fz_context*, fz_pixmap*  );
      void             fz_clear_pixmap_with_value(   fz_context*, fz_pixmap*, int value );
      void             fz_clear_pixmap(              fz_context*, fz_pixmap*  );
      void             fz_invert_pixmap(             fz_context*, fz_pixmap*  );
      void             fz_invert_pixmap_rect(        fz_pixmap*,  fz_bbox     rect );
      void             fz_gamma_pixmap(              fz_context*, fz_pixmap*, float gamma);
      void             fz_unmultiply_pixmap(         fz_context*, fz_pixmap*  );
      void             fz_convert_pixmap(            fz_context*, fz_pixmap*  dst,  fz_pixmap* src);
      void             fz_write_pixmap(              fz_context*, fz_pixmap*, char* filename, int rgb );
      void             fz_write_pnm(                 fz_context*, fz_pixmap*, char* filename  );
      void             fz_write_pam(                 fz_context*, fz_pixmap*, char* filename, int savealpha);
      void             fz_write_png(                 fz_context*, fz_pixmap*, char* filename, int savealpha);
      void             fz_write_pbm(                 fz_context*, fz_bitmap*, char* filename  );
      void             fz_md5_pixmap(                fz_pixmap*, uint8_t digest[16] );
      fz_pixmap*       fz_image_to_pixmap(           fz_context*, fz_image* , int w, int h);
      void             fz_drop_image(                fz_context*, fz_image* );
      fz_image*        fz_keep_image(                fz_context*, fz_image* );
      fz_bitmap*       fz_halftone_pixmap(           fz_context*, fz_pixmap*, fz_halftone* );
      void             fz_free_device(               fz_device*  );
      fz_device*       fz_new_trace_device(          fz_context* );
      fz_device*       fz_new_bbox_device(           fz_context*, fz_bbox*  bboxp );
      fz_device*       fz_new_draw_device(           fz_context*, fz_pixmap* dest );
      fz_device*       fz_new_draw_device_with_bbox( fz_context*, fz_pixmap* dest, fz_bbox clip );
      fz_device*       fz_new_text_device(       fz_context*, fz_text_sheet*, fz_text_page* );
      fz_text_sheet*   fz_new_text_sheet(        fz_context*  );
      void             fz_free_text_sheet(       fz_context*, fz_text_sheet* );
      fz_text_page*    fz_new_text_page(         fz_context*, fz_rect mediabox );
      void             fz_free_text_page(        fz_context*, fz_text_page* );
      void             fz_print_text_sheet(      fz_context*, FILE*, fz_text_sheet* );
      void             fz_print_text_page_html(  fz_context*, FILE*, fz_text_page*  );
      void             fz_print_text_page_xml(   fz_context*, FILE*, fz_text_page*  );
      void             fz_print_text_page(       fz_context*, FILE*, fz_text_page*  );
      fz_display_list* fz_new_display_list(      fz_context* );
      fz_device*       fz_new_list_device(       fz_context*, fz_display_list* );
      void             fz_run_display_list(      fz_display_list*, fz_device*, fz_matrix ctm,
						 fz_bbox area, fz_cookie * );
      void             fz_free_display_list(     fz_context*,  fz_display_list* );
      fz_link*         fz_new_link(              fz_context*,  fz_rect bbox, fz_link_dest dest);
      fz_link*         fz_keep_link(             fz_context*,  fz_link *link);
      void             fz_drop_link(             fz_context*,  fz_link *link);
      void             fz_free_link_dest(        fz_context*,  fz_link_dest *dest);
      void             fz_print_outline_xml(     fz_context*,  FILE *out, fz_outline *outline);
      void             fz_print_outline(         fz_context*,  FILE *out, fz_outline *outline);
      void             fz_free_outline(          fz_context*,  fz_outline *outline);
      fz_document*     fz_open_document(         fz_context*,  char *filename);
      void             fz_close_document(        fz_document*  );
      int              fz_needs_password(        fz_document*  );
      int              fz_authenticate_password( fz_document*, char *password);
      fz_outline*      fz_load_outline(          fz_document*  );
      int              fz_count_pages(           fz_document*  );
      fz_page*         fz_load_page(             fz_document*, int pagen );
      fz_link*         fz_load_links(            fz_document*, fz_page*  );
      fz_rect          fz_bound_page(            fz_document*, fz_page*  );
      void             fz_run_page(              fz_document*, fz_page*, fz_device*, fz_matrix t, fz_cookie* );
      void             fz_free_page(             fz_document*, fz_page*  );
      int              fz_meta(                  fz_document*, int key, void* ptr, int size );
      void             fz_write(                 fz_document*, char* filename, fz_write_options* );
]]

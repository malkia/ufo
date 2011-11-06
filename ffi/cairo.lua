local ffi = require( "ffi" )

local libs = ffi_cairo_libs or {
   Windows = { x86 = "bin/Windows/x86/cairo.dll", x64 = "bin/Windows/x64/cairo.dll" },
   OSX     = { x86 = "bin/OSX/cairo.dylib", x64 = "bin/OSX/cairo.dylib" },
   Linux   = { x86 = "cairo", x64 = "cairo", arm = "cairo" },
}

local cr = ffi.load( ffi_cairo_lib or libs[ ffi.os ][ ffi.arch ] or "cairo" )

CAIRO_MIME_TYPE_JPEG = "image/jpeg"
CAIRO_MIME_TYPE_PNG  = "image/png"
CAIRO_MIME_TYPE_JP2  = "image/jp2"
CAIRO_MIME_TYPE_URI  = "text/x-uri"

-- #define CAIRO_FONT_TYPE_ATSUI CAIRO_FONT_TYPE_QUARTZ

ffi.cdef [[
      typedef int                        cairo_bool_t;
      typedef struct _cairo              cairo_t;
      typedef struct _cairo_surface      cairo_surface_t;
      typedef struct _cairo_device       cairo_device_t;
      typedef struct _cairo_pattern      cairo_pattern_t;
      typedef struct _cairo_scaled_font  cairo_scaled_font_t;
      typedef struct _cairo_font_face    cairo_font_face_t;
      typedef struct _cairo_font_options cairo_font_options_t;
      typedef struct _cairo_region       cairo_region_t;
      
      typedef enum _cairo_status {
	 CAIRO_STATUS_SUCCESS,
	 CAIRO_STATUS_NO_MEMORY,
	 CAIRO_STATUS_INVALID_RESTORE,
	 CAIRO_STATUS_INVALID_POP_GROUP,
	 CAIRO_STATUS_NO_CURRENT_POINT,
	 CAIRO_STATUS_INVALID_MATRIX,
	 CAIRO_STATUS_INVALID_STATUS,
	 CAIRO_STATUS_NULL_POINTER,
	 CAIRO_STATUS_INVALID_STRING,
	 CAIRO_STATUS_INVALID_PATH_DATA,
	 CAIRO_STATUS_READ_ERROR,
	 CAIRO_STATUS_WRITE_ERROR,
	 CAIRO_STATUS_SURFACE_FINISHED,
	 CAIRO_STATUS_SURFACE_TYPE_MISMATCH,
	 CAIRO_STATUS_PATTERN_TYPE_MISMATCH,
	 CAIRO_STATUS_INVALID_CONTENT,
	 CAIRO_STATUS_INVALID_FORMAT,
	 CAIRO_STATUS_INVALID_VISUAL,
	 CAIRO_STATUS_FILE_NOT_FOUND,
	 CAIRO_STATUS_INVALID_DASH,
	 CAIRO_STATUS_INVALID_DSC_COMMENT,
	 CAIRO_STATUS_INVALID_INDEX,
	 CAIRO_STATUS_CLIP_NOT_REPRESENTABLE,
	 CAIRO_STATUS_TEMP_FILE_ERROR,
	 CAIRO_STATUS_INVALID_STRIDE,
	 CAIRO_STATUS_FONT_TYPE_MISMATCH,
	 CAIRO_STATUS_USER_FONT_IMMUTABLE,
	 CAIRO_STATUS_USER_FONT_ERROR,
	 CAIRO_STATUS_NEGATIVE_COUNT,
	 CAIRO_STATUS_INVALID_CLUSTERS,
	 CAIRO_STATUS_INVALID_SLANT,
	 CAIRO_STATUS_INVALID_WEIGHT,
	 CAIRO_STATUS_INVALID_SIZE,
	 CAIRO_STATUS_USER_FONT_NOT_IMPLEMENTED,
	 CAIRO_STATUS_DEVICE_TYPE_MISMATCH,
	 CAIRO_STATUS_DEVICE_ERROR,
	 CAIRO_STATUS_LAST_STATUS
      } cairo_status_t;

      typedef enum _cairo_content {
	 CAIRO_CONTENT_COLOR		= 0x1000,
	 CAIRO_CONTENT_ALPHA		= 0x2000,
	 CAIRO_CONTENT_COLOR_ALPHA	= 0x3000
      } cairo_content_t;

      typedef enum _cairo_operator {
	 CAIRO_OPERATOR_CLEAR,

	 CAIRO_OPERATOR_SOURCE,
	 CAIRO_OPERATOR_OVER,
	 CAIRO_OPERATOR_IN,
	 CAIRO_OPERATOR_OUT,
	 CAIRO_OPERATOR_ATOP,
	 
	 CAIRO_OPERATOR_DEST,
	 CAIRO_OPERATOR_DEST_OVER,
	 CAIRO_OPERATOR_DEST_IN,
	 CAIRO_OPERATOR_DEST_OUT,
	 CAIRO_OPERATOR_DEST_ATOP,
	 
	 CAIRO_OPERATOR_XOR,
	 CAIRO_OPERATOR_ADD,
	 CAIRO_OPERATOR_SATURATE,
	 
	 CAIRO_OPERATOR_MULTIPLY,
	 CAIRO_OPERATOR_SCREEN,
	 CAIRO_OPERATOR_OVERLAY,
	 CAIRO_OPERATOR_DARKEN,
	 CAIRO_OPERATOR_LIGHTEN,
	 CAIRO_OPERATOR_COLOR_DODGE,
	 CAIRO_OPERATOR_COLOR_BURN,
	 CAIRO_OPERATOR_HARD_LIGHT,
	 CAIRO_OPERATOR_SOFT_LIGHT,
	 CAIRO_OPERATOR_DIFFERENCE,
	 CAIRO_OPERATOR_EXCLUSION,
	 CAIRO_OPERATOR_HSL_HUE,
	 CAIRO_OPERATOR_HSL_SATURATION,
	 CAIRO_OPERATOR_HSL_COLOR,
	 CAIRO_OPERATOR_HSL_LUMINOSITY
      } cairo_operator_t;

      typedef enum _cairo_antialias {
	 CAIRO_ANTIALIAS_DEFAULT,
	 CAIRO_ANTIALIAS_NONE,
	 CAIRO_ANTIALIAS_GRAY,
	 CAIRO_ANTIALIAS_SUBPIXEL
      } cairo_antialias_t;

      typedef enum _cairo_fill_rule {
	 CAIRO_FILL_RULE_WINDING,
	 CAIRO_FILL_RULE_EVEN_ODD
      } cairo_fill_rule_t;

      typedef enum _cairo_line_cap {
	 CAIRO_LINE_CAP_BUTT,
	 CAIRO_LINE_CAP_ROUND,
	 CAIRO_LINE_CAP_SQUARE
      } cairo_line_cap_t;

      typedef enum _cairo_line_join {
	 CAIRO_LINE_JOIN_MITER,
	 CAIRO_LINE_JOIN_ROUND,
	 CAIRO_LINE_JOIN_BEVEL
      } cairo_line_join_t;

      typedef enum _cairo_font_slant {
	 CAIRO_FONT_SLANT_NORMAL,
	 CAIRO_FONT_SLANT_ITALIC,
	 CAIRO_FONT_SLANT_OBLIQUE
      } cairo_font_slant_t;

      typedef enum _cairo_font_weight {
	 CAIRO_FONT_WEIGHT_NORMAL,
	 CAIRO_FONT_WEIGHT_BOLD
      } cairo_font_weight_t;

      typedef enum _cairo_subpixel_order {
	 CAIRO_SUBPIXEL_ORDER_DEFAULT,
	 CAIRO_SUBPIXEL_ORDER_RGB,
	 CAIRO_SUBPIXEL_ORDER_BGR,
	 CAIRO_SUBPIXEL_ORDER_VRGB,
	 CAIRO_SUBPIXEL_ORDER_VBGR
      } cairo_subpixel_order_t;

      typedef enum _cairo_hint_style {
	 CAIRO_HINT_STYLE_DEFAULT,
	 CAIRO_HINT_STYLE_NONE,
	 CAIRO_HINT_STYLE_SLIGHT,
	 CAIRO_HINT_STYLE_MEDIUM,
	 CAIRO_HINT_STYLE_FULL
      } cairo_hint_style_t;

      typedef enum _cairo_hint_metrics {
	 CAIRO_HINT_METRICS_DEFAULT,
	 CAIRO_HINT_METRICS_OFF,
	 CAIRO_HINT_METRICS_ON
      } cairo_hint_metrics_t;

      typedef enum _cairo_font_type {
	 CAIRO_FONT_TYPE_TOY,
	 CAIRO_FONT_TYPE_FT,
	 CAIRO_FONT_TYPE_WIN32,
	 CAIRO_FONT_TYPE_QUARTZ,
	 CAIRO_FONT_TYPE_USER
      } cairo_font_type_t;

      typedef enum _cairo_path_data_type {
	 CAIRO_PATH_MOVE_TO,
	 CAIRO_PATH_LINE_TO,
	 CAIRO_PATH_CURVE_TO,
	 CAIRO_PATH_CLOSE_PATH
      } cairo_path_data_type_t;

      typedef enum _cairo_device_type {
	 CAIRO_DEVICE_TYPE_DRM,
	 CAIRO_DEVICE_TYPE_GL,
	 CAIRO_DEVICE_TYPE_SCRIPT,
	 CAIRO_DEVICE_TYPE_XCB,
	 CAIRO_DEVICE_TYPE_XLIB,
	 CAIRO_DEVICE_TYPE_XML
      } cairo_device_type_t;

      typedef enum _cairo_surface_type {
	 CAIRO_SURFACE_TYPE_IMAGE,
	 CAIRO_SURFACE_TYPE_PDF,
	 CAIRO_SURFACE_TYPE_PS,
	 CAIRO_SURFACE_TYPE_XLIB,
	 CAIRO_SURFACE_TYPE_XCB,
	 CAIRO_SURFACE_TYPE_GLITZ,
	 CAIRO_SURFACE_TYPE_QUARTZ,
	 CAIRO_SURFACE_TYPE_WIN32,
	 CAIRO_SURFACE_TYPE_BEOS,
	 CAIRO_SURFACE_TYPE_DIRECTFB,
	 CAIRO_SURFACE_TYPE_SVG,
	 CAIRO_SURFACE_TYPE_OS2,
	 CAIRO_SURFACE_TYPE_WIN32_PRINTING,
	 CAIRO_SURFACE_TYPE_QUARTZ_IMAGE,
	 CAIRO_SURFACE_TYPE_SCRIPT,
	 CAIRO_SURFACE_TYPE_QT,
	 CAIRO_SURFACE_TYPE_RECORDING,
	 CAIRO_SURFACE_TYPE_VG,
	 CAIRO_SURFACE_TYPE_GL,
	 CAIRO_SURFACE_TYPE_DRM,
	 CAIRO_SURFACE_TYPE_TEE,
	 CAIRO_SURFACE_TYPE_XML,
	 CAIRO_SURFACE_TYPE_SKIA,
	 CAIRO_SURFACE_TYPE_SUBSURFACE
      } cairo_surface_type_t;

      typedef enum _cairo_format {
	 CAIRO_FORMAT_INVALID   = -1,
	 CAIRO_FORMAT_ARGB32    = 0,
	 CAIRO_FORMAT_RGB24     = 1,
	 CAIRO_FORMAT_A8        = 2,
	 CAIRO_FORMAT_A1        = 3,
	 CAIRO_FORMAT_RGB16_565 = 4
      } cairo_format_t;
      
      typedef enum _cairo_pattern_type {
	 CAIRO_PATTERN_TYPE_SOLID,
	 CAIRO_PATTERN_TYPE_SURFACE,
	 CAIRO_PATTERN_TYPE_LINEAR,
	 CAIRO_PATTERN_TYPE_RADIAL
      } cairo_pattern_type_t;

      typedef enum _cairo_text_cluster_flags {
	 CAIRO_TEXT_CLUSTER_FLAG_BACKWARD = 0x00000001
      } cairo_text_cluster_flags_t;

      typedef enum _cairo_extend {
	 CAIRO_EXTEND_NONE,
	 CAIRO_EXTEND_REPEAT,
	 CAIRO_EXTEND_REFLECT,
	 CAIRO_EXTEND_PAD
      } cairo_extend_t;

      typedef enum _cairo_filter {
	 CAIRO_FILTER_FAST,
	 CAIRO_FILTER_GOOD,
	 CAIRO_FILTER_BEST,
	 CAIRO_FILTER_NEAREST,
	 CAIRO_FILTER_BILINEAR,
	 CAIRO_FILTER_GAUSSIAN
      } cairo_filter_t;

      typedef enum _cairo_region_overlap {
	 CAIRO_REGION_OVERLAP_IN,		
	 CAIRO_REGION_OVERLAP_OUT,		
	 CAIRO_REGION_OVERLAP_PART		
      } cairo_region_overlap_t;

      typedef struct _cairo_matrix {
	 double xx; double yx;
	 double xy; double yy;
	 double x0; double y0;
      } cairo_matrix_t;
      
      typedef struct _cairo_user_data_key {
	 int unused;
      } cairo_user_data_key_t;

      typedef struct _cairo_rectangle {
	 double x, y, width, height;
      } cairo_rectangle_t;
      
      typedef struct _cairo_rectangle_list {
	 cairo_status_t     status;
	 cairo_rectangle_t *rectangles;
	 int                num_rectangles;
      } cairo_rectangle_list_t;
      
      typedef struct {
	 unsigned long        index;
	 double               x;
	 double               y;
      } cairo_glyph_t;

      typedef struct {
	 int        num_bytes;
	 int        num_glyphs;
      } cairo_text_cluster_t;

      typedef struct {
	 double x_bearing;
	 double y_bearing;
	 double width;
	 double height;
	 double x_advance;
	 double y_advance;
      } cairo_text_extents_t;

      typedef struct {
	 double ascent;
	 double descent;
	 double height;
	 double max_x_advance;
	 double max_y_advance;
      } cairo_font_extents_t;

      typedef union _cairo_path_data_t {
	 struct {
	    cairo_path_data_type_t type;
	    int length;
	 } header;
	 struct {
	    double x, y;
	 } point;
      } cairo_path_data_t;
      
      typedef struct cairo_path {
	 cairo_status_t     status;
	 cairo_path_data_t* data;
	 int                num_data;
      } cairo_path_t;

      typedef struct _cairo_rectangle_int {
	 int x, y;
	 int width, height;
      } cairo_rectangle_int_t;
          
      typedef void           ( *cairo_destroy_func_t )
                             (  void* data );

      typedef cairo_status_t ( *cairo_write_func_t )
                             (  void* closure, const unsigned char* data, unsigned int length );

      typedef cairo_status_t (* cairo_read_func_t ) 
                             (  void* closure, unsigned char* data, unsigned int length );

      typedef cairo_status_t ( *cairo_user_scaled_font_init_func_t )
                             (  cairo_scaled_font_t* scaled_font, 
                                cairo_t* cr, cairo_font_extents_t* extents );

      typedef cairo_status_t ( *cairo_user_scaled_font_render_glyph_func_t) 
                             (  cairo_scaled_font_t* scaled_font, unsigned long glyph,
			        cairo_t*, cairo_text_extents_t*  );
      
      typedef cairo_status_t ( *cairo_user_scaled_font_text_to_glyphs_func_t )
                             (  cairo_scaled_font_t*, const char* utf8, int utf8_len,
			        cairo_glyph_t**             glyphs,   int* n_glyphs,
			        cairo_text_cluster_t**      clusters, int* n_clusters,
			        cairo_text_cluster_flags_t* cluster_flags );
      
      typedef cairo_status_t ( *cairo_user_scaled_font_unicode_to_glyph_func_t )
                             (  cairo_scaled_font_t* scaled_font, unsigned long unicode,
                                unsigned long* glyph_index );

int                     cairo_version(                    void );
const char*             cairo_version_string(             void );

cairo_t*                cairo_create(                     cairo_surface_t* target );

cairo_t*                cairo_reference(                  cairo_t*  );
void                    cairo_destroy(                    cairo_t*  );
unsigned int            cairo_get_reference_count(        cairo_t*  );
void *                  cairo_get_user_data(              cairo_t*, const cairo_user_data_key_t* key );
cairo_status_t          cairo_set_user_data(              cairo_t*, const cairo_user_data_key_t* key, void* user_data, cairo_destroy_func_t destroy );
void                    cairo_save(                       cairo_t*  );
void                    cairo_restore(                    cairo_t*  );
void                    cairo_push_group(                 cairo_t*  );
void                    cairo_push_group_with_content(    cairo_t*, cairo_content_t content );
cairo_pattern_t*        cairo_pop_group(                  cairo_t*  );
void                    cairo_pop_group_to_source(        cairo_t*  );
void                    cairo_set_operator(               cairo_t*, cairo_operator_t op );
void                    cairo_set_source(                 cairo_t*, cairo_pattern_t* source );
void                    cairo_set_source_rgb(             cairo_t*, double red, double green, double blue );
void                    cairo_set_source_rgba(            cairo_t*, double red, double green, double blue, double alpha );
void                    cairo_set_source_surface(         cairo_t*, cairo_surface_t *surface, double x, double	y );
void                    cairo_set_tolerance(              cairo_t*, double tolerance );
void                    cairo_set_antialias(              cairo_t*, cairo_antialias_t antialias );
void                    cairo_set_fill_rule(              cairo_t*, cairo_fill_rule_t fill_rule );
void                    cairo_set_line_width(             cairo_t*, double width );
void                    cairo_set_line_cap(               cairo_t*, cairo_line_cap_t line_cap );
void                    cairo_set_line_join(              cairo_t*, cairo_line_join_t line_join );
void                    cairo_set_dash(                   cairo_t*, const double *dashes, int num_dashes, double offset );
void                    cairo_set_miter_limit(            cairo_t*, double limit );
void                    cairo_translate(                  cairo_t*, double tx, double ty );
void                    cairo_scale(                      cairo_t*, double sx, double sy );
void                    cairo_rotate(                     cairo_t*, double angle );
void                    cairo_transform(                  cairo_t*, const cairo_matrix_t *matrix );
void                    cairo_set_matrix(                 cairo_t*, const cairo_matrix_t *matrix );
void                    cairo_identity_matrix(            cairo_t*  );
void                    cairo_user_to_device(             cairo_t*, double*  x, double*  y );
void                    cairo_user_to_device_distance(    cairo_t*, double* dx, double* dy );
void                    cairo_device_to_user(             cairo_t*, double*  x, double*  y );
void                    cairo_device_to_user_distance(    cairo_t*, double* dx, double* dy );
void                    cairo_new_path(                   cairo_t*  );
void                    cairo_move_to(                    cairo_t*, double x, double y );
void                    cairo_new_sub_path(               cairo_t*  );
void                    cairo_line_to(                    cairo_t*, double x, double y );
void                    cairo_curve_to(                   cairo_t*, double x1, double y1, double x2, double y2, double x3, double y3 );
void                    cairo_arc(                        cairo_t*, double xc, double yc, double radius, double angle1, double angle2 );
void                    cairo_arc_negative(               cairo_t*, double xc, double yc, double radius, double angle1, double angle2 );
void                    cairo_arc_to(                     cairo_t*, double x1, double y1, double x2, double y2, double radius );
void                    cairo_rel_move_to(                cairo_t*, double dx, double dy );
void                    cairo_rel_line_to(                cairo_t*, double dx, double dy );
void                    cairo_rel_curve_to(               cairo_t*, double dx1, double dy1, double dx2, double dy2, double dx3, double dy3 );
void                    cairo_rectangle(                  cairo_t*, double x, double y, double width, double height );
void                    cairo_stroke_to_path(             cairo_t*  );
void                    cairo_close_path(                 cairo_t*  );
void                    cairo_path_extents(               cairo_t*, double *x1, double *y1, double *x2, double *y2 );
void                    cairo_paint(                      cairo_t*  );
void                    cairo_paint_with_alpha(           cairo_t*, double alpha );
void                    cairo_mask(                       cairo_t*, cairo_pattern_t *pattern );
void                    cairo_mask_surface(               cairo_t*, cairo_surface_t *surface, double surface_x, double surface_y );
void                    cairo_stroke(                     cairo_t*  );
void                    cairo_stroke_preserve(            cairo_t*  );
void                    cairo_fill(                       cairo_t*  );
void                    cairo_fill_preserve(              cairo_t*  );
void                    cairo_copy_page(                  cairo_t*  );
void                    cairo_show_page(                  cairo_t*  );
cairo_bool_t            cairo_in_stroke(                  cairo_t*, double x, double y );
cairo_bool_t            cairo_in_fill(                    cairo_t*, double x, double y );
cairo_bool_t            cairo_in_clip(                    cairo_t*, double x, double y );
void                    cairo_stroke_extents(             cairo_t*, double *x1, double *y1, double *x2, double *y2 );
void                    cairo_fill_extents(               cairo_t*, double *x1, double *y1, double *x2, double *y2 );
void                    cairo_reset_clip(                 cairo_t*  );
void                    cairo_clip(                       cairo_t*  );
void                    cairo_clip_preserve(              cairo_t*  );
void                    cairo_clip_extents(               cairo_t*, double *x1, double *y1, double *x2, double *y2 );
cairo_rectangle_list_t* cairo_copy_clip_rectangle_list(   cairo_t*  );

void                    cairo_rectangle_list_destroy(     cairo_rectangle_list_t *rectangle_list );
cairo_glyph_t*          cairo_glyph_allocate(             int num_glyphs );
void                    cairo_glyph_free(                 cairo_glyph_t *glyphs );
cairo_text_cluster_t*   cairo_text_cluster_allocate(      int num_clusters );
void                    cairo_text_cluster_free(          cairo_text_cluster_t *clusters );
cairo_font_options_t*   cairo_font_options_create(        void );
cairo_font_options_t*   cairo_font_options_copy(          const cairo_font_options_t *original );
void                    cairo_font_options_destroy(             cairo_font_options_t *options );
cairo_status_t          cairo_font_options_status(              cairo_font_options_t *options );
void                    cairo_font_options_merge(               cairo_font_options_t *options, const cairo_font_options_t *other );
cairo_bool_t            cairo_font_options_equal(         const cairo_font_options_t *options, const cairo_font_options_t *other );
unsigned long           cairo_font_options_hash(          const cairo_font_options_t *options );
void                    cairo_font_options_set_antialias(            cairo_font_options_t *options, cairo_antialias_t  antialias);
cairo_antialias_t       cairo_font_options_get_antialias(      const cairo_font_options_t *options );
void                    cairo_font_options_set_subpixel_order(       cairo_font_options_t *options, cairo_subpixel_order_t  subpixel_order);
cairo_subpixel_order_t  cairo_font_options_get_subpixel_order( const cairo_font_options_t *options);
void                    cairo_font_options_set_hint_style(           cairo_font_options_t *options, cairo_hint_style_t hint_style );
cairo_hint_style_t      cairo_font_options_get_hint_style(     const cairo_font_options_t *options );
void                    cairo_font_options_set_hint_metrics(         cairo_font_options_t *options, cairo_hint_metrics_t hint_metrics );
cairo_hint_metrics_t    cairo_font_options_get_hint_metrics(   const cairo_font_options_t *options );
void                    cairo_select_font_face(                cairo_t*, const char *family, cairo_font_slant_t slant, cairo_font_weight_t  weight);
void                    cairo_set_font_size(                   cairo_t*, double size );
void                    cairo_set_font_matrix(                 cairo_t*, const cairo_matrix_t *matrix );
void                    cairo_get_font_matrix(                 cairo_t*,       cairo_matrix_t *matrix );
void                    cairo_set_font_options(                cairo_t*, const cairo_font_options_t *options );
void                    cairo_get_font_options(                cairo_t*,       cairo_font_options_t *options );
void                    cairo_set_font_face(                   cairo_t*,       cairo_font_face_t *font_face);
cairo_font_face_t*      cairo_get_font_face(                   cairo_t* );      
void                    cairo_set_scaled_font(                 cairo_t*, const cairo_scaled_font_t *scaled_font);
cairo_scaled_font_t*    cairo_get_scaled_font(                 cairo_t* );
void                    cairo_show_text(                       cairo_t*, const char *utf8 );
void                    cairo_show_glyphs(                     cairo_t*, const cairo_glyph_t *glyphs, int num_glyphs );
void                    cairo_show_text_glyphs(                cairo_t*, const char *utf8, int utf8_len, 
                                                                            const cairo_glyph_t *glyphs, int num_glyphs, 
                                                                            const cairo_text_cluster_t *clusters, int num_clusters,
                                                                            cairo_text_cluster_flags_t  cluster_flags );
void                    cairo_text_path(                       cairo_t*, const char *utf8 );
void                    cairo_glyph_path(                      cairo_t*, const cairo_glyph_t *glyphs, int num_glyphs );
void                    cairo_text_extents(                    cairo_t*, const char *utf8, cairo_text_extents_t *extents );
void                    cairo_glyph_extents(                   cairo_t*, const cairo_glyph_t *glyphs, int num_glyphs, cairo_text_extents_t *extents );
void                    cairo_font_extents(                    cairo_t*, cairo_font_extents_t *extents );

cairo_font_face_t*      cairo_font_face_reference(             cairo_font_face_t*   font_face );
void                    cairo_font_face_destroy(               cairo_font_face_t*   font_face );
unsigned int            cairo_font_face_get_reference_count(   cairo_font_face_t*   font_face );
cairo_status_t          cairo_font_face_status(                cairo_font_face_t*   font_face );
cairo_font_type_t       cairo_font_face_get_type(              cairo_font_face_t*   font_face );
void*                   cairo_font_face_get_user_data(         cairo_font_face_t*   font_face, const cairo_user_data_key_t* key );
cairo_status_t          cairo_font_face_set_user_data(         cairo_font_face_t*   font_face, const cairo_user_data_key_t* key, void *user_data, cairo_destroy_func_t destroy );
cairo_scaled_font_t*    cairo_scaled_font_create(              cairo_font_face_t*   font_face, const cairo_matrix_t *font_matrix, const cairo_matrix_t *ctm, const cairo_font_options_t *options );
cairo_scaled_font_t*    cairo_scaled_font_reference(           cairo_scaled_font_t* scaled_font );
void                    cairo_scaled_font_destroy(             cairo_scaled_font_t* scaled_font );
unsigned int            cairo_scaled_font_get_reference_count( cairo_scaled_font_t* scaled_font );
cairo_status_t          cairo_scaled_font_status(              cairo_scaled_font_t* scaled_font );
cairo_font_type_t       cairo_scaled_font_get_type(            cairo_scaled_font_t* scaled_font );
void*                   cairo_scaled_font_get_user_data(       cairo_scaled_font_t* scaled_font, const cairo_user_data_key_t* key );
cairo_status_t          cairo_scaled_font_set_user_data(       cairo_scaled_font_t* scaled_font, const cairo_user_data_key_t* key, void* user_data, cairo_destroy_func_t destroy );
void                    cairo_scaled_font_extents(             cairo_scaled_font_t* scaled_font,       cairo_font_extents_t* extents );
void                    cairo_scaled_font_text_extents(        cairo_scaled_font_t* scaled_font, const char* utf8, cairo_text_extents_t* extents );
void                    cairo_scaled_font_glyph_extents(       cairo_scaled_font_t* scaled_font, const cairo_glyph_t* glyphs, int num_glyphs, cairo_text_extents_t* extents );
cairo_status_t          cairo_scaled_font_text_to_glyphs(      cairo_scaled_font_t* scaled_font, double x, double y, 
                                                                                    const char* utf8,                int  utf8_len, 
                                                                                    cairo_glyph_t**        glyphs,   int* num_glyphs,
			                                                            cairo_text_cluster_t** clusters, int* num_clusters,
                                                                                    cairo_text_cluster_flags_t* cluster_flags );
cairo_font_face_t*     cairo_scaled_font_get_font_face(       cairo_scaled_font_t* scaled_font );
void                   cairo_scaled_font_get_font_matrix(     cairo_scaled_font_t* scaled_font, cairo_matrix_t* font_matrix );
void                   cairo_scaled_font_get_ctm(             cairo_scaled_font_t* scaled_font, cairo_matrix_t* ctm );
void                   cairo_scaled_font_get_scale_matrix(    cairo_scaled_font_t* scaled_font, cairo_matrix_t* scale_matrix );
void                   cairo_scaled_font_get_font_options(    cairo_scaled_font_t* scaled_font, cairo_font_options_t* options );
cairo_font_face_t*     cairo_toy_font_face_create(            const char* family,  cairo_font_slant_t slant, cairo_font_weight_t weight );
const char*            cairo_toy_font_face_get_family(        cairo_font_face_t*   font_face );
cairo_font_slant_t     cairo_toy_font_face_get_slant(         cairo_font_face_t*   font_face );
cairo_font_weight_t    cairo_toy_font_face_get_weight(        cairo_font_face_t*   font_face );
cairo_font_face_t*     cairo_user_font_face_create(           void );
void                   cairo_user_font_face_set_init_func(    cairo_font_face_t* font_face, cairo_user_scaled_font_init_func_t init_func );
void              cairo_user_font_face_set_render_glyph_func( cairo_font_face_t*, cairo_user_scaled_font_render_glyph_func_t );
void            cairo_user_font_face_set_text_to_glyphs_func( cairo_font_face_t*, cairo_user_scaled_font_text_to_glyphs_func_t );
void          cairo_user_font_face_set_unicode_to_glyph_func( cairo_font_face_t*, cairo_user_scaled_font_unicode_to_glyph_func_t );

cairo_user_scaled_font_init_func_t             cairo_user_font_face_get_init_func(             cairo_font_face_t* );
cairo_user_scaled_font_render_glyph_func_t     cairo_user_font_face_get_render_glyph_func(     cairo_font_face_t* );
cairo_user_scaled_font_text_to_glyphs_func_t   cairo_user_font_face_get_text_to_glyphs_func(   cairo_font_face_t* );
cairo_user_scaled_font_unicode_to_glyph_func_t cairo_user_font_face_get_unicode_to_glyph_func( cairo_font_face_t* );

cairo_operator_t       cairo_get_operator(                    cairo_t* cr );
cairo_pattern_t*       cairo_get_source(                      cairo_t* cr );
double                 cairo_get_tolerance(                   cairo_t* cr );
cairo_antialias_t      cairo_get_antialias(                   cairo_t* cr );
cairo_bool_t           cairo_has_current_point(               cairo_t* cr );
void                   cairo_get_current_point(               cairo_t* cr, double* x, double* y );
cairo_fill_rule_t      cairo_get_fill_rule(                   cairo_t* cr );
double                 cairo_get_line_width(                  cairo_t* cr );
cairo_line_cap_t       cairo_get_line_cap(                    cairo_t* cr );
cairo_line_join_t      cairo_get_line_join(                   cairo_t* cr );
double                 cairo_get_miter_limit(                 cairo_t* cr );
int                    cairo_get_dash_count(                  cairo_t* cr );
void                   cairo_get_dash(                        cairo_t* cr, double *dashes, double *offset );
void                   cairo_get_matrix(                      cairo_t* cr, cairo_matrix_t* matrix );
cairo_surface_t*       cairo_get_target(                      cairo_t* cr );
cairo_surface_t*       cairo_get_group_target(                cairo_t* cr );
cairo_path_t*          cairo_copy_path(                       cairo_t* cr );
cairo_path_t*          cairo_copy_path_flat(                  cairo_t* cr );
void                   cairo_append_path(                     cairo_t* cr, const cairo_path_t* path );
void                   cairo_path_destroy(                    cairo_path_t* path );
cairo_status_t         cairo_status(                          cairo_t* cr );
const char*            cairo_status_to_string(                cairo_status_t status );

cairo_device_t*        cairo_device_reference(                cairo_device_t*  );
cairo_device_type_t    cairo_device_get_type(                 cairo_device_t*  );
cairo_status_t         cairo_device_status(                   cairo_device_t*  );
cairo_status_t         cairo_device_acquire(                  cairo_device_t*  );
void                   cairo_device_release(                  cairo_device_t*  );
void                   cairo_device_flush(                    cairo_device_t*  );
void                   cairo_device_finish(                   cairo_device_t*  );
void                   cairo_device_destroy(                  cairo_device_t*  );
unsigned int           cairo_device_get_reference_count(      cairo_device_t*  );
void*                  cairo_device_get_user_data(            cairo_device_t*, const cairo_user_data_key_t* key );
cairo_status_t         cairo_device_set_user_data(            cairo_device_t*, const cairo_user_data_key_t*, void* user_data, cairo_destroy_func_t );

cairo_surface_t*       cairo_surface_create_similar(          cairo_surface_t*  other, cairo_content_t content, int w, int h );
cairo_surface_t*       cairo_surface_create_for_rectangle(    cairo_surface_t*  target, double x, double y, double w, double h );
cairo_surface_t*       cairo_surface_reference(               cairo_surface_t*  );
void                   cairo_surface_finish(                  cairo_surface_t*  );
void                   cairo_surface_destroy(                 cairo_surface_t*  );
cairo_device_t*        cairo_surface_get_device(              cairo_surface_t*  );
unsigned int           cairo_surface_get_reference_count(     cairo_surface_t*  );
cairo_status_t         cairo_surface_status(                  cairo_surface_t*  );
cairo_surface_type_t   cairo_surface_get_type(                cairo_surface_t*  );
cairo_content_t        cairo_surface_get_content(             cairo_surface_t*  );
cairo_status_t         cairo_surface_write_to_png(            cairo_surface_t*, const char* filename );
cairo_status_t         cairo_surface_write_to_png_stream(     cairo_surface_t*, cairo_write_func_t write_func, void* closure);
void*                  cairo_surface_get_user_data(           cairo_surface_t*, const cairo_user_data_key_t* key );
cairo_status_t         cairo_surface_set_user_data(           cairo_surface_t*, const cairo_user_data_key_t*, void* user_data, cairo_destroy_func_t );
void                   cairo_surface_get_mime_data(           cairo_surface_t*, const char* mime_type, const unsigned char** data, unsigned long* length );
cairo_status_t         cairo_surface_set_mime_data(           cairo_surface_t*, const char* mime_type,
							                        const unsigned char* data,    unsigned long length,
							                        cairo_destroy_func_t destroy, void*         closure);
void                   cairo_surface_get_font_options(        cairo_surface_t*, cairo_font_options_t *options);
void                   cairo_surface_flush(                   cairo_surface_t*  );
void                   cairo_surface_mark_dirty(              cairo_surface_t*  );
void                   cairo_surface_mark_dirty_rectangle(    cairo_surface_t*, int x, int y, int width, int height);
void                   cairo_surface_set_device_offset(       cairo_surface_t*, double x_offset, double y_offset);
void                   cairo_surface_get_device_offset(       cairo_surface_t*, double *x_offset, double *y_offset);
void                   cairo_surface_set_fallback_resolution( cairo_surface_t*, double  x_pixels_per_inch, double  y_pixels_per_inch );
void                   cairo_surface_get_fallback_resolution( cairo_surface_t*, double* x_pixels_per_inch, double* y_pixels_per_inch );
void                   cairo_surface_copy_page(               cairo_surface_t* surface);
void                   cairo_surface_show_page(               cairo_surface_t* surface);
cairo_bool_t           cairo_surface_has_show_text_glyphs(    cairo_surface_t* surface );

int                    cairo_format_stride_for_width(         cairo_format_t format, int width );

cairo_surface_t*       cairo_image_surface_create(            cairo_format_t format, int width, int height );
cairo_surface_t*       cairo_image_surface_create_for_data(   unsigned char* data, cairo_format_t format, int width, int height, int stride );
unsigned char*         cairo_image_surface_get_data(          cairo_surface_t* surface );
cairo_format_t         cairo_image_surface_get_format(        cairo_surface_t* surface );
int                    cairo_image_surface_get_width(         cairo_surface_t* surface );
int                    cairo_image_surface_get_height(        cairo_surface_t* surface );
int                    cairo_image_surface_get_stride(        cairo_surface_t* surface );
cairo_surface_t*       cairo_image_surface_create_from_png(   const char* filename );
cairo_surface_t*       cairo_image_surface_create_from_png_stream( cairo_read_func_t read_func, void* closure );

cairo_surface_t*       cairo_recording_surface_create(        cairo_content_t content, const cairo_rectangle_t *extents);
void                   cairo_recording_surface_ink_extents(   cairo_surface_t *surface, double *x0, double *y0, double *width, double *height);

cairo_pattern_t*       cairo_pattern_create_rgb(              double R, double G, double B );
cairo_pattern_t*       cairo_pattern_create_rgba(             double R, double G, double B, double A );
cairo_pattern_t*       cairo_pattern_create_linear(           double  x0, double  y0, double      x1, double  y1 );
cairo_pattern_t*       cairo_pattern_create_radial(           double cx0, double cy0, double radius0, double cx1, double cy1, double radius1 );
cairo_pattern_t*       cairo_pattern_create_for_surface(      cairo_surface_t* surface );
cairo_pattern_t*       cairo_pattern_reference(               cairo_pattern_t*  );
void                   cairo_pattern_destroy(                 cairo_pattern_t*  );
unsigned int           cairo_pattern_get_reference_count(     cairo_pattern_t*  );
cairo_status_t         cairo_pattern_status(                  cairo_pattern_t*  );
void*                  cairo_pattern_get_user_data(           cairo_pattern_t*, const cairo_user_data_key_t*  );
cairo_status_t         cairo_pattern_set_user_data(           cairo_pattern_t*, const cairo_user_data_key_t*, void* user_data, cairo_destroy_func_t );
cairo_pattern_type_t   cairo_pattern_get_type(                cairo_pattern_t*  );
void                   cairo_pattern_add_color_stop_rgb(      cairo_pattern_t*, double offset, double R, double G, double B );
void                   cairo_pattern_add_color_stop_rgba(     cairo_pattern_t*, double offset, double R, double G, double B, double A );
void                   cairo_pattern_set_matrix(              cairo_pattern_t*, const cairo_matrix_t *matrix );
void                   cairo_pattern_get_matrix(              cairo_pattern_t*,       cairo_matrix_t  *matrix);
void                   cairo_pattern_set_extend(              cairo_pattern_t*, cairo_extend_t extend);
cairo_extend_t         cairo_pattern_get_extend(              cairo_pattern_t*  );
void                   cairo_pattern_set_filter(              cairo_pattern_t*, cairo_filter_t filter);
cairo_filter_t         cairo_pattern_get_filter(              cairo_pattern_t*  );
cairo_status_t         cairo_pattern_get_rgba(                cairo_pattern_t*, double *R, double *G, double *B, double *A );
cairo_status_t         cairo_pattern_get_surface(             cairo_pattern_t*, cairo_surface_t **surface);
cairo_status_t         cairo_pattern_get_color_stop_rgba(     cairo_pattern_t*, int index, double* offset, double* R, double* G, double* B, double* A);
cairo_status_t         cairo_pattern_get_color_stop_count(    cairo_pattern_t*, int* count);
cairo_status_t         cairo_pattern_get_linear_points(       cairo_pattern_t*, double *x0, double *y0, double *x1, double *y1);
cairo_status_t         cairo_pattern_get_radial_circles(      cairo_pattern_t*, double *x0, double *y0, double *r0, double *x1, double *y1, double *r1);

void                   cairo_matrix_init(                     cairo_matrix_t*, double xx, double yx, double xy, double yy, double x0, double y0 );
void                   cairo_matrix_init_identity(            cairo_matrix_t*);
void                   cairo_matrix_init_translate(           cairo_matrix_t*, double tx, double ty);
void                   cairo_matrix_init_scale(               cairo_matrix_t*, double sx, double sy);
void                   cairo_matrix_init_rotate(              cairo_matrix_t*, double radians);
void                   cairo_matrix_translate(                cairo_matrix_t*, double tx, double ty);
void                   cairo_matrix_scale(                    cairo_matrix_t*, double sx, double sy);
void                   cairo_matrix_rotate(                   cairo_matrix_t*, double radians);
cairo_status_t         cairo_matrix_invert(                   cairo_matrix_t*  );
void                   cairo_matrix_multiply(                 cairo_matrix_t*, const cairo_matrix_t *a, const cairo_matrix_t *b);
void                   cairo_matrix_transform_distance( const cairo_matrix_t*, double* dx, double* dy );
void                   cairo_matrix_transform_point(    const cairo_matrix_t*, double*  x, double*  y );

cairo_region_t*        cairo_region_create(                   void );
cairo_region_t*        cairo_region_create_rectangle(   const cairo_rectangle_int_t *rectangle);
cairo_region_t*        cairo_region_create_rectangles(  const cairo_rectangle_int_t *rects, int count );
cairo_region_t*        cairo_region_copy(               const cairo_region_t* original);
cairo_region_t*        cairo_region_reference(                cairo_region_t* region);
void                   cairo_region_destroy(                  cairo_region_t* region);
cairo_bool_t           cairo_region_equal(              const cairo_region_t* a, const cairo_region_t* b );
cairo_status_t         cairo_region_status(             const cairo_region_t* region);
void                   cairo_region_get_extents(        const cairo_region_t* region, cairo_rectangle_int_t *extents );
int                    cairo_region_num_rectangles(     const cairo_region_t* region );
void                   cairo_region_get_rectangle(      const cairo_region_t* region, int nth, cairo_rectangle_int_t* rectangle );
cairo_bool_t           cairo_region_is_empty(           const cairo_region_t* region );
cairo_region_overlap_t cairo_region_contains_rectangle( const cairo_region_t* region, const cairo_rectangle_int_t *rectangle );
cairo_bool_t           cairo_region_contains_point(     const cairo_region_t* region, int  x, int  y );
void                   cairo_region_translate(                cairo_region_t* region, int dx, int dy );
cairo_status_t         cairo_region_subtract(                 cairo_region_t* dst, const cairo_region_t *other);
cairo_status_t         cairo_region_subtract_rectangle(       cairo_region_t* dst, const cairo_rectangle_int_t* rectangle );
cairo_status_t         cairo_region_intersect(                cairo_region_t* dst, const cairo_region_t*        other );
cairo_status_t         cairo_region_intersect_rectangle(      cairo_region_t* dst, const cairo_rectangle_int_t* rectangle );
cairo_status_t         cairo_region_union(                    cairo_region_t* dst, const cairo_region_t*        other );
cairo_status_t         cairo_region_union_rectangle(          cairo_region_t* dst, const cairo_rectangle_int_t* rectangle );
cairo_status_t         cairo_region_xor(                      cairo_region_t* dst, const cairo_region_t*        other );
cairo_status_t         cairo_region_xor_rectangle(            cairo_region_t* dst, const cairo_rectangle_int_t* rectangle );

void                   cairo_debug_reset_static_data(         void );


typedef struct _cairo_script_interpreter cairo_script_interpreter_t;

typedef void             (* csi_destroy_func_t)(        void* closure, void *ptr );
typedef cairo_surface_t* (* csi_surface_create_func_t)( void* closure, cairo_content_t content, double width, double height, long uid );
typedef cairo_t*         (* csi_context_create_func_t)( void* closure, cairo_surface_t* surface );
typedef void             (* csi_show_page_func_t)(      void* closure, cairo_t* cr );
typedef void             (* csi_copy_page_func_t)(      void* closure, cairo_t* cr );

typedef struct _cairo_script_interpreter_hooks {
   void *closure;
   csi_surface_create_func_t surface_create;
   csi_destroy_func_t surface_destroy;
   csi_context_create_func_t context_create;
   csi_destroy_func_t context_destroy;
   csi_show_page_func_t show_page;
   csi_copy_page_func_t copy_page;
} cairo_script_interpreter_hooks_t;

typedef struct FILE_ *FILE;

cairo_script_interpreter_t* cairo_script_interpreter_create(           void );
void                        cairo_script_interpreter_install_hooks(    cairo_script_interpreter_t*, const cairo_script_interpreter_hooks_t* hooks );
cairo_status_t              cairo_script_interpreter_run(              cairo_script_interpreter_t*, const char *filename );
cairo_status_t              cairo_script_interpreter_feed_stream(      cairo_script_interpreter_t*, FILE* stream );
cairo_status_t              cairo_script_interpreter_feed_string(      cairo_script_interpreter_t*, const char *line, int len );
unsigned int                cairo_script_interpreter_get_line_number(  cairo_script_interpreter_t*  );
cairo_script_interpreter_t* cairo_script_interpreter_reference(        cairo_script_interpreter_t*  );
cairo_status_t              cairo_script_interpreter_finish(           cairo_script_interpreter_t*  );
cairo_status_t              cairo_script_interpreter_destroy(          cairo_script_interpreter_t*  );
cairo_status_t              cairo_script_interpreter_translate_stream( FILE* stream, cairo_write_func_t write_func, void *closure );

typedef void* GType;

GType cairo_gobject_context_get_type(            void );
GType cairo_gobject_device_get_type(             void );
GType cairo_gobject_pattern_get_type(            void );
GType cairo_gobject_surface_get_type(            void );
GType cairo_gobject_rectangle_get_type(          void );
GType cairo_gobject_scaled_font_get_type(        void );
GType cairo_gobject_font_face_get_type(          void );
GType cairo_gobject_font_options_get_type(       void );
GType cairo_gobject_rectangle_int_get_type(      void );
GType cairo_gobject_region_get_type(             void );
GType cairo_gobject_status_get_type(             void );
GType cairo_gobject_content_get_type(            void );
GType cairo_gobject_operator_get_type(           void );
GType cairo_gobject_antialias_get_type(          void );
GType cairo_gobject_fill_rule_get_type(          void );
GType cairo_gobject_line_cap_get_type(           void );
GType cairo_gobject_line_join_get_type(          void );
GType cairo_gobject_text_cluster_flags_get_type( void );
GType cairo_gobject_font_slant_get_type(         void );
GType cairo_gobject_font_weight_get_type(        void );
GType cairo_gobject_subpixel_order_get_type(     void );
GType cairo_gobject_hint_style_get_type(         void );
GType cairo_gobject_hint_metrics_get_type(       void );
GType cairo_gobject_font_type_get_type(          void );
GType cairo_gobject_path_data_type_get_type(     void );
GType cairo_gobject_device_type_get_type(        void );
GType cairo_gobject_surface_type_get_type(       void );
GType cairo_gobject_format_get_type(             void );
GType cairo_gobject_pattern_type_get_type(       void );
GType cairo_gobject_extend_get_type(             void );
GType cairo_gobject_filter_get_type(             void );
GType cairo_gobject_region_overlap_get_type(     void );

typedef enum _cairo_svg_version {
  CAIRO_SVG_VERSION_1_1,
  CAIRO_SVG_VERSION_1_2
} cairo_svg_version_t;

cairo_surface_t* cairo_svg_surface_create(              const char* filename,
 			                                double width_in_points, double height_in_points );
cairo_surface_t* cairo_svg_surface_create_for_stream(   cairo_write_func_t write_func, void* closure,
				                        double width_in_points, double height_in_points );
void             cairo_svg_surface_restrict_to_version( cairo_surface_t*, cairo_svg_version_t version );
void             cairo_svg_get_versions(                cairo_svg_version_t const**, int* n_versions );
const char*      cairo_svg_version_to_string(           cairo_svg_version_t version );

typedef enum _cairo_pdf_version {
  CAIRO_PDF_VERSION_1_4,
  CAIRO_PDF_VERSION_1_5
} cairo_pdf_version_t;

cairo_surface_t* cairo_pdf_surface_create(              const char* filename, 
                                                        double width_in_points, double height_in_points );
cairo_surface_t* cairo_pdf_surface_create_for_stream(   cairo_write_func_t write_func, void* closure, 
                                                        double width_in_points, double height_in_points );
void             cairo_pdf_surface_restrict_to_version( cairo_surface_t*, cairo_pdf_version_t version );
void             cairo_pdf_get_versions(                cairo_pdf_version_t const**, int* n_versions );
const char*      cairo_pdf_version_to_string(           cairo_pdf_version_t version );
void             cairo_pdf_surface_set_size(            cairo_surface_t* surface, 
                                                        double width_in_points, double height_in_points );
typedef enum _cairo_ps_level {
  CAIRO_PS_LEVEL_2,
  CAIRO_PS_LEVEL_3
} cairo_ps_level_t;

cairo_surface_t* cairo_ps_surface_create(               const char* filename,
			                                double width_in_points, double height_in_points );
cairo_surface_t* cairo_ps_surface_create_for_stream(    cairo_write_func_t write_func, void *closure,
			                                double width_in_points, double height_in_points );
void             cairo_ps_surface_restrict_to_level(    cairo_surface_t*, cairo_ps_level_t level );
void             cairo_ps_get_levels(                   cairo_ps_level_t const** levels, int* n_levels );
const char*      cairo_ps_level_to_string(              cairo_ps_level_t level );
void             cairo_ps_surface_set_eps(              cairo_surface_t*, cairo_bool_t eps );
cairo_bool_t     cairo_ps_surface_get_eps(              cairo_surface_t*  );
void             cairo_ps_surface_set_size(             cairo_surface_t*,
			                                double width_in_points, double height_in_points );
void             cairo_ps_surface_dsc_comment(          cairo_surface_t*, const char* comment );
void             cairo_ps_surface_dsc_begin_setup(      cairo_surface_t*  );
void             cairo_ps_surface_dsc_begin_page_setup( cairo_surface_t*  );

cairo_surface_t* cairo_tee_surface_create(              cairo_surface_t* master );
void             cairo_tee_surface_add(                 cairo_surface_t*, cairo_surface_t* target );
void             cairo_tee_surface_remove(              cairo_surface_t*, cairo_surface_t* target );
cairo_surface_t* cairo_tee_surface_index(               cairo_surface_t*, int index );

cairo_device_t*  cairo_xml_create(                      const char* filename );
cairo_device_t*  cairo_xml_create_for_stream(           cairo_write_func_t write_func, void* closure );
cairo_surface_t* cairo_xml_surface_create(              cairo_device_t* xml, cairo_content_t content,
                                                        double width, double height );
cairo_status_t   cairo_xml_for_recording_surface(       cairo_device_t* xml, cairo_surface_t* surface );

typedef enum {
  CAIRO_SCRIPT_MODE_BINARY,
  CAIRO_SCRIPT_MODE_ASCII
} cairo_script_mode_t;

cairo_device_t*  cairo_script_create(                    const char *filename );
cairo_device_t*  cairo_script_create_for_stream(         cairo_write_func_t write_func, void *closure );
void             cairo_script_write_comment(             cairo_device_t* scr, const char *comment, int len );
void             cairo_script_set_mode(                  cairo_device_t* scr, cairo_script_mode_t mode );
cairo_script_mode_t cairo_script_get_mode(               cairo_device_t* scr  );
cairo_surface_t* cairo_script_surface_create(            cairo_device_t* scr, cairo_content_t content, 
                                                         double width, double height);
cairo_surface_t* cairo_script_surface_create_for_target( cairo_device_t* scr, cairo_surface_t* target );
cairo_status_t   cairo_script_from_recording_surface(    cairo_device_t* scr, cairo_surface_t* rec_surf );







typedef struct _cairo_vg_context cairo_vg_context_t;
typedef struct __GLXcontextRec *GLXContext;
typedef struct _XDisplay Display;
typedef struct FT_Face_ *FT_Face;
typedef struct FcPattern_ *FcPattern;

typedef void* Window;
typedef void* HGLRC;
typedef void* HDC;
typedef void* EGLDisplay;
typedef void* EGLContext;
typedef void* EGLSurface;
typedef void* LOGFONTW;
typedef void* HFONT;
typedef void* VGImage;
typedef void* VGImageFormat;
typedef void* BView;
typedef void* BBitmap;
typedef void* IDirectFB;
typedef void* IDirectFBSurface;
typedef void* HPS;
typedef void* HWND;
typedef void* PRECTL;
typedef void* QPainter;
typedef void* QImage;
typedef void* CGContextRef;
typedef void* CGFontRef;
typedef void* ATSUFontID;
typedef void* xcb_connection_t;
typedef void* xcb_drawable_t;
typedef void* xcb_visualtype_t;
typedef void* xcb_screen_t;
typedef void* xcb_pixmap_t;
typedef void* xcb_render_pictforminfo_t;
typedef void* Drawable;
typedef void* Visual;
typedef void* Pixmap;
typedef void* Screen;
typedef void* XRenderPictFormat;

cairo_surface_t*    cairo_gl_surface_create(                cairo_device_t*, cairo_content_t, int w, int h );
cairo_surface_t*    cairo_gl_surface_create_for_texture(    cairo_device_t*, cairo_content_t,
                                                            unsigned int texture, int width, int height );
void                cairo_gl_surface_set_size(              cairo_surface_t*, int w, int h );
int                 cairo_gl_surface_get_width(             cairo_surface_t* );
int                 cairo_gl_surface_get_height(            cairo_surface_t* );
void                cairo_gl_surface_swapbuffers(           cairo_surface_t* );


cairo_device_t*     cairo_glx_device_create(                Display *dpy, GLXContext gl_ctx );
Display*            cairo_glx_device_get_display(           cairo_device_t* );
GLXContext          cairo_glx_device_get_context(           cairo_device_t* );
cairo_surface_t*    cairo_gl_surface_create_for_window(     cairo_device_t*, Window win, int w, int h );


cairo_device_t*     cairo_wgl_device_create(                HGLRC rc );
HGLRC               cairo_wgl_device_get_context(           cairo_device_t* );
cairo_surface_t*    cairo_gl_surface_create_for_dc(         cairo_device_t*, HDC dc, int w, int h );


cairo_device_t*     cairo_egl_device_create(                EGLDisplay dpy,  EGLContext egl );
cairo_surface_t*    cairo_gl_surface_create_for_egl(        cairo_device_t*, EGLSurface, int w, int h );


cairo_surface_t*    cairo_win32_surface_create(             HDC hdc );
cairo_surface_t*    cairo_win32_printing_surface_create(    HDC hdc );
cairo_surface_t*    cairo_win32_surface_create_with_ddb(    HDC hdc, cairo_format_t, int w, int h );
cairo_surface_t*    cairo_win32_surface_create_with_dib(             cairo_format_t, int w, int h );
HDC                 cairo_win32_surface_get_dc(             cairo_surface_t* );
cairo_surface_t*    cairo_win32_surface_get_image(          cairo_surface_t* surface );


cairo_font_face_t*  cairo_win32_font_face_create_for_logfontw(       LOGFONTW* );
cairo_font_face_t*  cairo_win32_font_face_create_for_hfont(                     HFONT );
cairo_font_face_t*  cairo_win32_font_face_create_for_logfontw_hfont( LOGFONTW*, HFONT );
cairo_status_t      cairo_win32_scaled_font_select_font(             cairo_scaled_font_t*, HDC hdc );
void                cairo_win32_scaled_font_done_font(               cairo_scaled_font_t*  );
double              cairo_win32_scaled_font_get_metrics_factor(      cairo_scaled_font_t*  );
void                cairo_win32_scaled_font_get_logical_to_device(   cairo_scaled_font_t*, cairo_matrix_t* );
void                cairo_win32_scaled_font_get_device_to_logical(   cairo_scaled_font_t*, cairo_matrix_t* );


cairo_vg_context_t* cairo_vg_context_create_for_glx(   Display*, GLXContext );
cairo_vg_context_t* cairo_vg_context_create_for_egl(   EGLDisplay, EGLContext );
cairo_status_t      cairo_vg_context_status(           cairo_vg_context_t* );
void                cairo_vg_context_destroy(          cairo_vg_context_t* );
cairo_surface_t*    cairo_vg_surface_create(           cairo_vg_context_t*, cairo_content_t, int w, int h );
cairo_surface_t*    cairo_vg_surface_create_for_image( cairo_vg_context_t*, VGImage, VGImageFormat, int, int );
VGImage             cairo_vg_surface_get_image(        cairo_surface_t* );
VGImageFormat       cairo_vg_surface_get_format(       cairo_surface_t* );
int                 cairo_vg_surface_get_height(       cairo_surface_t* );
int                 cairo_vg_surface_get_width(        cairo_surface_t* );


cairo_font_face_t*  cairo_ft_font_face_create_for_ft_face( FT_Face face, int load_flags );
FT_Face             cairo_ft_scaled_font_lock_face(        cairo_scaled_font_t* scaled_font );
void                cairo_ft_scaled_font_unlock_face(      cairo_scaled_font_t* scaled_font );
cairo_font_face_t*  cairo_ft_font_face_create_for_pattern( FcPattern *pattern );
void                cairo_ft_font_options_substitute(      const cairo_font_options_t*, FcPattern* pattern );


cairo_surface_t*    cairo_beos_surface_create(             BView*  );
cairo_surface_t*    cairo_beos_surface_create_for_bitmap(  BView*, BBitmap* );


cairo_surface_t*    cairo_directfb_surface_create(         IDirectFB *dfb, IDirectFBSurface *surface );


cairo_surface_t*    cairo_skia_surface_create(             cairo_format_t, int w, int h );
cairo_surface_t*    cairo_skia_surface_create_for_data(    unsigned char*,cairo_format_t,int w,int h,int skip);
unsigned char*      cairo_skia_surface_get_data(           cairo_surface_t* );
cairo_format_t      cairo_skia_surface_get_format(         cairo_surface_t* );
int                 cairo_skia_surface_get_width(          cairo_surface_t* );
int                 cairo_skia_surface_get_height(         cairo_surface_t* );
int                 cairo_skia_surface_get_stride(         cairo_surface_t* );
cairo_surface_t*    cairo_skia_surface_get_image(          cairo_surface_t* );


void                cairo_os2_init(                        );
void                cairo_os2_fini(                        );
cairo_surface_t*    cairo_os2_surface_create(              HPS hps_client_window, int w, int h );
cairo_surface_t*    cairo_os2_surface_create_for_window(   HWND hwnd_client_window,int w, int h );
void                cairo_os2_surface_set_hwnd(            cairo_surface_t*, HWND hwnd_client_window );
int                 cairo_os2_surface_set_size(            cairo_surface_t*, int w, int h, int timeout );
void                cairo_os2_surface_refresh_window(      cairo_surface_t*, HPS paint, PRECTL paint_rect );
void                cairo_os2_surface_set_manual_window_refresh( cairo_surface_t*, cairo_bool_t manual );
cairo_bool_t        cairo_os2_surface_get_manual_window_refresh( cairo_surface_t*  );
cairo_status_t      cairo_os2_surface_get_hps(             cairo_surface_t*, HPS* hps );
cairo_status_t      cairo_os2_surface_set_hps(             cairo_surface_t*, HPS hps );
 

cairo_surface_t*    cairo_qt_surface_create(               QPainter* );
cairo_surface_t*    cairo_qt_surface_create_with_qimage(   cairo_format_t,   int w, int h );
cairo_surface_t*    cairo_qt_surface_create_with_qpixmap(  cairo_content_t,  int w, int h );
QPainter*           cairo_qt_surface_get_qpainter(         cairo_surface_t*  );
cairo_surface_t*    cairo_surface_map_image(               cairo_surface_t*  );
void                cairo_surface_unmap_image(             cairo_surface_t*, cairo_surface_t* );
cairo_surface_t*    cairo_qt_surface_get_image(            cairo_surface_t*  );
QImage*             cairo_qt_surface_get_qimage(           cairo_surface_t*  );


cairo_surface_t*    cairo_quartz_surface_create(                    cairo_format_t format, int w, int h );
cairo_surface_t*    cairo_quartz_surface_create_for_cg_context(     CGContextRef cgContext, int w, int h );
CGContextRef        cairo_quartz_surface_get_cg_context(            cairo_surface_t* );
cairo_font_face_t*  cairo_quartz_font_face_create_for_cgfont(       CGFontRef  font );
cairo_font_face_t*  cairo_quartz_font_face_create_for_atsu_font_id( ATSUFontID font_id );
cairo_surface_t*    cairo_quartz_image_surface_create(              cairo_surface_t* image_surface );
cairo_surface_t*    cairo_quartz_image_surface_get_image(           cairo_surface_t* surface );


cairo_device_t*     cairo_drm_device_get(                           struct udev_device* device );
cairo_device_t*     cairo_drm_device_get_for_fd(                    int fd );
cairo_device_t*     cairo_drm_device_default(                       );
int                 cairo_drm_device_get_fd(                        cairo_device_t* );
void                cairo_drm_device_throttle(                      cairo_device_t* );
cairo_surface_t*    cairo_drm_surface_create(                       cairo_device_t*, cairo_format_t,
                                                                    int w, int h ); 
cairo_surface_t*    cairo_drm_surface_create_for_name(              cairo_device_t*, unsigned int name,
	                                                            cairo_format_t, int w, int h, int stride );
cairo_surface_t*    cairo_drm_surface_create_from_cacheable_image(  cairo_device_t*,  cairo_surface_t* );
cairo_status_t      cairo_drm_surface_enable_scan_out(              cairo_surface_t*  );
unsigned int        cairo_drm_surface_get_handle(                   cairo_surface_t*  );
unsigned int        cairo_drm_surface_get_name(                     cairo_surface_t*  );
cairo_format_t      cairo_drm_surface_get_format(                   cairo_surface_t*  );
int                 cairo_drm_surface_get_width(                    cairo_surface_t*  );
int                 cairo_drm_surface_get_height(                   cairo_surface_t*  );
int                 cairo_drm_surface_get_stride(                   cairo_surface_t*  );
cairo_surface_t*    cairo_drm_surface_map_to_image(                 cairo_surface_t*  );
void                cairo_drm_surface_unmap(                        cairo_surface_t*, cairo_surface_t* );


cairo_surface_t*    cairo_xcb_surface_create(                       xcb_connection_t*, xcb_drawable_t, 
                                                                    xcb_visualtype_t*, int w, int h );
cairo_surface_t*    cairo_xcb_surface_create_for_bitmap(            xcb_connection_t*, xcb_screen_t*,
	 			                                    xcb_pixmap_t,      int w, int h );
cairo_surface_t*    cairo_xcb_surface_create_with_xrender_format(   xcb_connection_t*, xcb_screen_t*,
		  	    		                            xcb_drawable_t, xcb_render_pictforminfo_t*,
                                                                    int width, int height );
void                cairo_xcb_surface_set_size(                     cairo_surface_t*, int w, int h );
xcb_connection_t*   cairo_xcb_device_get_connection(                cairo_device_t* );
void                cairo_xcb_device_debug_cap_xshm_version(        cairo_device_t*, int major, int minor );
void                cairo_xcb_device_debug_cap_xrender_version(     cairo_device_t*, int major, int minor );
void                cairo_xcb_device_debug_set_precision(           cairo_device_t*, int precision );
int                 cairo_xcb_device_debug_get_precision(           cairo_device_t* );


cairo_surface_t*    cairo_xlib_surface_create(                      Display*, Drawable, Visual, int w, int h );
cairo_surface_t*    cairo_xlib_surface_create_for_bitmap(           Display*, Pixmap, Screen*,  int w, int h );
void                cairo_xlib_surface_set_size(                    cairo_surface_t*, int w, int h );
void                cairo_xlib_surface_set_drawable(                cairo_surface_t*, Drawable, int w, int h );
Display*            cairo_xlib_surface_get_display(                 cairo_surface_t*  );
Drawable            cairo_xlib_surface_get_drawable(                cairo_surface_t*  );
Screen*             cairo_xlib_surface_get_screen(                  cairo_surface_t*  );
Visual*             cairo_xlib_surface_get_visual(                  cairo_surface_t*  );
int                 cairo_xlib_surface_get_depth(                   cairo_surface_t*  );
int                 cairo_xlib_surface_get_width(                   cairo_surface_t*  );
int                 cairo_xlib_surface_get_height(                  cairo_surface_t*  );
cairo_surface_t*    cairo_xlib_surface_create_with_xrender_format(  Display*, Drawable, Screen *,
                                                                    XRenderPictFormat*, int w, int h );
XRenderPictFormat*  cairo_xlib_surface_get_xrender_format(          cairo_surface_t* );
void                cairo_xlib_device_debug_set_precision(          cairo_device_t*,  int precision);
int                 cairo_xlib_device_debug_get_precision(          cairo_device_t*   );

]]

return cr


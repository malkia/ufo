local ffi = require('ffi')
local mupdf = require('ffi/mu/fitz')

ffi.cdef[[
      enum
      {
	 PDF_PERM_PRINT = 1 << 2,
	 PDF_PERM_CHANGE = 1 << 3,
	 PDF_PERM_COPY = 1 << 4,
	 PDF_PERM_NOTES = 1 << 5,
	 PDF_PERM_FILL_FORM = 1 << 8,
	 PDF_PERM_ACCESSIBILITY = 1 << 9,
	 PDF_PERM_ASSEMBLE = 1 << 10,
	 PDF_PERM_HIGH_RES_PRINT = 1 << 11,
	 PDF_DEFAULT_PERM_FLAGS = 0xfffc
      };
      
      typedef struct pdf_document_s pdf_document;
      typedef struct pdf_obj_s pdf_obj;
      typedef struct pdf_page_s pdf_page;
      
      pdf_obj*      pdf_new_null(                  fz_context*);
      pdf_obj*      pdf_new_bool(                  fz_context*, int b);
      pdf_obj*      pdf_new_int(                   fz_context*, int i);
      pdf_obj*      pdf_new_real(                  fz_context*, float f);
      pdf_obj*       fz_new_name(                  fz_context*, char *str);
      pdf_obj*      pdf_new_string(                fz_context*, char *str, int len);
      pdf_obj*      pdf_new_indirect(              fz_context*, int num, int gen, void *doc);
      pdf_obj*      pdf_new_ref(                   pdf_document* xref, pdf_obj* obj );
      pdf_obj*      pdf_new_array(                 fz_context*, int initialcap);
      pdf_obj*      pdf_new_dict(                  fz_context*, int initialcap);
      pdf_obj*      pdf_copy_array(                fz_context*, pdf_obj* array);
      pdf_obj*      pdf_copy_dict(                 fz_context*, pdf_obj* dict);
      pdf_obj*      pdf_keep_obj(                  pdf_obj* );
      void          pdf_drop_obj(                  pdf_obj* );
      int           pdf_is_null(                   pdf_obj* );
      int           pdf_is_bool(                   pdf_obj* );
      int           pdf_is_int(                    pdf_obj* );
      int           pdf_is_real(                   pdf_obj* );
      int           pdf_is_name(                   pdf_obj* );
      int           pdf_is_string(                 pdf_obj* );
      int           pdf_is_array(                  pdf_obj* );
      int           pdf_is_dict(                   pdf_obj* );
      int           pdf_is_indirect(               pdf_obj* );
      int           pdf_is_stream(                 pdf_document*, int num, int gen);
      int           pdf_objcmp(                    pdf_obj* a, pdf_obj* b);
      int           pdf_dict_marked(               pdf_obj* );
      int           pdf_dict_mark(                 pdf_obj* );
      void          pdf_dict_unmark(               pdf_obj* );
      int           pdf_to_bool(                   pdf_obj* );
      int           pdf_to_int(                    pdf_obj* );
      float         pdf_to_real(                   pdf_obj* );
      char*         pdf_to_name(                   pdf_obj* );
      char*         pdf_to_str_buf(                pdf_obj* );
      pdf_obj*      pdf_to_dict(                   pdf_obj* );
      int           pdf_to_str_len(                pdf_obj* );
      int           pdf_to_num(                    pdf_obj* );
      int           pdf_to_gen(                    pdf_obj* );
      int           pdf_array_len(                 pdf_obj* array  );
      pdf_obj*      pdf_array_get(                 pdf_obj* array, int i  );
      void          pdf_array_put(                 pdf_obj* array, int i, pdf_obj* );
      void          pdf_array_push(                pdf_obj* array, pdf_obj* );
      void          pdf_array_insert(              pdf_obj* array, pdf_obj* );
      int           pdf_array_contains(            pdf_obj* array, pdf_obj* );
      int           pdf_dict_len(                  pdf_obj* dict);
      pdf_obj*      pdf_dict_get_key(              pdf_obj* dict, int idx);
      pdf_obj*      pdf_dict_get_val(              pdf_obj* dict, int idx);
      pdf_obj*      pdf_dict_get(                  pdf_obj* dict, pdf_obj* key);
      pdf_obj*      pdf_dict_gets(                 pdf_obj* dict, char *key);
      pdf_obj*      pdf_dict_getsa(                pdf_obj* dict, char *key, char *abbrev);
      void           fz_dict_put(                  pdf_obj* dict, pdf_obj* key, pdf_obj* val);
      void          pdf_dict_puts(                 pdf_obj* dict, char *key, pdf_obj* val);
      void          pdf_dict_del(                  pdf_obj* dict, pdf_obj* key);
      void          pdf_dict_dels(                 pdf_obj* dict, char *key);
      void          pdf_sort_dict(                 pdf_obj* dict);
      int           pdf_fprint_obj(                FILE*, pdf_obj*, int tight );
      void          pdf_print_obj(                 pdf_obj*);
      void          pdf_print_ref(                 pdf_obj*);
      char*         pdf_to_utf8(                    fz_context*, pdf_obj* src );
      uint16_t*     pdf_to_ucs2(                    fz_context*, pdf_obj* src );
      pdf_obj*      pdf_to_utf8_name(               fz_context*, pdf_obj* src );
      char*         pdf_from_ucs2(                  fz_context*, uint16_t *str);
      fz_rect       pdf_to_rect(                    fz_context*, pdf_obj* array);
      fz_matrix     pdf_to_matrix(                  fz_context*, pdf_obj* array);
      int           pdf_count_objects(             pdf_document*);
      pdf_obj*      pdf_resolve_indirect(          pdf_obj* ref);
      pdf_obj*      pdf_load_object(               pdf_document*, int num, int gen);
      void          pdf_update_object(             pdf_document*, int num, int gen, pdf_obj* newobj);
      fz_buffer*    pdf_load_raw_stream(           pdf_document*, int num, int gen);
      fz_buffer*    pdf_load_stream(               pdf_document*, int num, int gen);
      fz_stream*    pdf_open_raw_stream(           pdf_document*, int num, int gen);
      fz_stream*    pdf_open_stream(               pdf_document*, int num, int gen);
      fz_image*     pdf_load_image(                pdf_document*, pdf_obj*);
      fz_outline*   pdf_load_outline(              pdf_document*);
      pdf_document* pdf_open_document(              fz_context*, const char *filename);
      pdf_document* pdf_open_document_with_stream(  fz_stream *file);
      void          pdf_close_document(            pdf_document*);
      int           pdf_needs_password(            pdf_document*);
      int           pdf_authenticate_password(     pdf_document*, char *pw);
      int           pdf_has_permission(            pdf_document*, int p);
      int           pdf_lookup_page_number(        pdf_document*, pdf_obj* pageobj);
      int           pdf_count_pages(               pdf_document*);
      pdf_page*     pdf_load_page(                 pdf_document*, int number);
      fz_link*      pdf_load_links(                pdf_document*, pdf_page*);
      fz_rect       pdf_bound_page(                pdf_document*, pdf_page*);
      void          pdf_free_page(                 pdf_document*, pdf_page*);
      void          pdf_run_page(                  pdf_document*, pdf_page*, fz_device*, fz_matrix ctm, fz_cookie* );
      void          pdf_run_page_with_usage(       pdf_document*, pdf_page*, fz_device*, fz_matrix ctm, char *event, fz_cookie* );
]]
                                        
local ffi = require( "ffi" )
local expat = ffi.load( "expat" )

ffi.cdef[[
struct XML_ParserStruct;
typedef struct XML_ParserStruct *XML_Parser;

enum {
   XML_MAJOR_VERSION = 2,
   XML_MINOR_VERSION = 0,
   XML_MICRO_VERSION = 1
};

typedef enum {
  XML_STATUS_ERROR     = 0,
  XML_STATUS_OK        = 1,
  XML_STATUS_SUSPENDED = 2,
} XML_Status;

typedef enum {
  XML_ERROR_NONE,
  XML_ERROR_NO_MEMORY,
  XML_ERROR_SYNTAX,
  XML_ERROR_NO_ELEMENTS,
  XML_ERROR_INVALID_TOKEN,
  XML_ERROR_UNCLOSED_TOKEN,
  XML_ERROR_PARTIAL_CHAR,
  XML_ERROR_TAG_MISMATCH,
  XML_ERROR_DUPLICATE_ATTRIBUTE,
  XML_ERROR_JUNK_AFTER_DOC_ELEMENT,
  XML_ERROR_PARAM_ENTITY_REF,
  XML_ERROR_UNDEFINED_ENTITY,
  XML_ERROR_RECURSIVE_ENTITY_REF,
  XML_ERROR_ASYNC_ENTITY,
  XML_ERROR_BAD_CHAR_REF,
  XML_ERROR_BINARY_ENTITY_REF,
  XML_ERROR_ATTRIBUTE_EXTERNAL_ENTITY_REF,
  XML_ERROR_MISPLACED_XML_PI,
  XML_ERROR_UNKNOWN_ENCODING,
  XML_ERROR_INCORRECT_ENCODING,
  XML_ERROR_UNCLOSED_CDATA_SECTION,
  XML_ERROR_EXTERNAL_ENTITY_HANDLING,
  XML_ERROR_NOT_STANDALONE,
  XML_ERROR_UNEXPECTED_STATE,
  XML_ERROR_ENTITY_DECLARED_IN_PE,
  XML_ERROR_FEATURE_REQUIRES_XML_DTD,
  XML_ERROR_CANT_CHANGE_FEATURE_ONCE_PARSING,
  XML_ERROR_UNBOUND_PREFIX,
  XML_ERROR_UNDECLARING_PREFIX,
  XML_ERROR_INCOMPLETE_PE,
  XML_ERROR_XML_DECL,
  XML_ERROR_TEXT_DECL,
  XML_ERROR_PUBLICID,
  XML_ERROR_SUSPENDED,
  XML_ERROR_NOT_SUSPENDED,
  XML_ERROR_ABORTED,
  XML_ERROR_FINISHED,
  XML_ERROR_SUSPEND_PE,
  XML_ERROR_RESERVED_PREFIX_XML,
  XML_ERROR_RESERVED_PREFIX_XMLNS,
  XML_ERROR_RESERVED_NAMESPACE_URI
} XML_Error;

typedef enum {
  XML_CTYPE_EMPTY = 1,
  XML_CTYPE_ANY,
  XML_CTYPE_MIXED,
  XML_CTYPE_NAME,
  XML_CTYPE_CHOICE,
  XML_CTYPE_SEQ
} XML_Content_Type;

typedef enum {
  XML_CQUANT_NONE,
  XML_CQUANT_OPT,
  XML_CQUANT_REP,
  XML_CQUANT_PLUS
} XML_Content_Quant;

typedef enum {
  XML_INITIALIZED,
  XML_PARSING,
  XML_FINISHED,
  XML_SUSPENDED
} XML_Parsing;

typedef enum {
  XML_FEATURE_END,
  XML_FEATURE_UNICODE,
  XML_FEATURE_UNICODE_WCHAR_T,
  XML_FEATURE_DTD,
  XML_FEATURE_CONTEXT_BYTES,
  XML_FEATURE_MIN_SIZE,
  XML_FEATURE_SIZEOF_XML_CHAR,
  XML_FEATURE_SIZEOF_XML_LCHAR,
  XML_FEATURE_NS,
  XML_FEATURE_LARGE_SIZE
} XML_FeatureEnum;

typedef enum {
  XML_PARAM_ENTITY_PARSING_NEVER,
  XML_PARAM_ENTITY_PARSING_UNLESS_STANDALONE,
  XML_PARAM_ENTITY_PARSING_ALWAYS
} XML_ParamEntityParsing;

typedef struct XML_Memory_Handling_Suite {
  void *(*malloc_fcn)(size_t size);
  void *(*realloc_fcn)(void *ptr, size_t size);
  void (*free_fcn)(void *ptr);
} XML_Memory_Handling_Suite;

typedef struct XML_Content {
  XML_Content_Type    type;
  XML_Content_Quant   quant;
  char*               name;
  unsigned int        numchildren;
  struct XML_Content* children;
} XML_Content;

typedef struct XML_Encoding {
  int     map[ 256 ];
  void*   data;
  int  (* convert )( void *data, const char *s );
  void (* release )( void *data );
} XML_Encoding;

typedef struct XML_ParsingStatus {
  XML_Parsing   parsing;
  unsigned char finalBuffer;
} XML_ParsingStatus;

typedef struct XML_Expat_Version {
  int major;
  int minor;
  int micro;
} XML_Expat_Version;

typedef struct {
  enum XML_FeatureEnum feature;
  const char*          name;
  long int             value;
} XML_Feature;

typedef void    (* XML_ElementDeclHandler            )( void *udata, const char* name, XML_Content *model);
typedef void    (* XML_AttlistDeclHandler            )( void *udata, const char* elname, const char  *attname, const char  *att_type, const char  *dflt, int isrequired );
typedef void    (* XML_XmlDeclHandler                )( void *udata, const char* version, const char *encoding, int standalone );
typedef void    (* XML_StartElementHandler           )( void *udata, const char* name, const char **atts);
typedef void    (* XML_EndElementHandler             )( void *udata, const char* name);
typedef void    (* XML_CharacterDataHandler          )( void *udata, const char* s, int len );
typedef void    (* XML_ProcessingInstructionHandler  )( void *udata, const char* target, const char *data );
typedef void    (* XML_CommentHandler                )( void *udata, const char* data );
typedef void    (* XML_StartCdataSectionHandler      )( void *udata  );
typedef void    (* XML_EndCdataSectionHandler        )( void *udata  );
typedef void    (* XML_DefaultHandler                )( void *udata, const char *s,      int len);
typedef void    (* XML_StartDoctypeDeclHandler       )( void *udata, const char *doctypeName, const char *sysid, const char *pubid, int has_internal_subset );
typedef void    (* XML_EndDoctypeDeclHandler         )( void *udata  );
typedef void    (* XML_EntityDeclHandler             )( void *udata, const char *entName, int is_param_entity, const char *val, int val_len, const char *base, const char *sysId, const char *pubId, const char *notationName);
typedef void    (* XML_UnparsedEntityDeclHandler     )( void *udata, const char *entityName, const char *base, const char *systemId, const char *publicId, const char *notationName );
typedef void    (* XML_NotationDeclHandler           )( void *udata, const char *notationName, const char *base, const char *systemId, const char *publicId);
typedef void    (* XML_StartNamespaceDeclHandler     )( void *udata, const char *prefix, const char *uri );
typedef void    (* XML_EndNamespaceDeclHandler       )( void *udata, const char *prefix);
typedef int     (* XML_NotStandaloneHandler          )( void *udata  );
typedef void    (* XML_SkippedEntityHandler          )( void *udata, const char *entityName, int is_parameter_entity );
typedef int     (* XML_UnknownEncodingHandler        )( void *encodingHandlerData, const char *name, XML_Encoding *info );
typedef int     (* XML_ExternalEntityRefHandler      )( XML_Parser, const char *context, const char *base, const char *systemId, const char *publicId );

XML_Parser         XML_ParserCreate(                    const char *encoding);
XML_Parser         XML_ParserCreateNS(                  const char *encoding, char namespaceSeparator );
XML_Parser         XML_ParserCreate_MM(                 const char *encoding, const XML_Memory_Handling_Suite*, const char* namespaceSeparator );

unsigned char      XML_ParserReset(                     XML_Parser, const char *encoding );

void               XML_SetElementDeclHandler(           XML_Parser, XML_ElementDeclHandler );
void               XML_SetAttlistDeclHandler(           XML_Parser, XML_AttlistDeclHandler );
void               XML_SetXmlDeclHandler(               XML_Parser, XML_XmlDeclHandler );
void               XML_SetEntityDeclHandler(            XML_Parser, XML_EntityDeclHandler );
void               XML_SetElementHandler(               XML_Parser, XML_StartElementHandler, XML_EndElementHandler );
void               XML_SetStartElementHandler(          XML_Parser, XML_StartElementHandler );
void               XML_SetEndElementHandler(            XML_Parser, XML_EndElementHandler );
void               XML_SetCharacterDataHandler(         XML_Parser, XML_CharacterDataHandler );
void               XML_SetProcessingInstructionHandler( XML_Parser, XML_ProcessingInstructionHandler );
void               XML_SetCommentHandler(               XML_Parser, XML_CommentHandler );
void               XML_SetCdataSectionHandler(          XML_Parser, XML_StartCdataSectionHandler, XML_EndCdataSectionHandler end);
void               XML_SetStartCdataSectionHandler(     XML_Parser, XML_StartCdataSectionHandler );
void               XML_SetEndCdataSectionHandler(       XML_Parser, XML_EndCdataSectionHandler );
void               XML_SetDefaultHandler(               XML_Parser, XML_DefaultHandler );
void               XML_SetDefaultHandlerExpand(         XML_Parser, XML_DefaultHandler );
void               XML_SetDoctypeDeclHandler(           XML_Parser, XML_StartDoctypeDeclHandler, XML_EndDoctypeDeclHandler end);
void               XML_SetStartDoctypeDeclHandler(      XML_Parser, XML_StartDoctypeDeclHandler );
void               XML_SetEndDoctypeDeclHandler(        XML_Parser, XML_EndDoctypeDeclHandler );
void               XML_SetUnparsedEntityDeclHandler(    XML_Parser, XML_UnparsedEntityDeclHandler handler);
void               XML_SetNotationDeclHandler(          XML_Parser, XML_NotationDeclHandler );
void               XML_SetNamespaceDeclHandler(         XML_Parser, XML_StartNamespaceDeclHandler, XML_EndNamespaceDeclHandler );
void               XML_SetStartNamespaceDeclHandler(    XML_Parser, XML_StartNamespaceDeclHandler );
void               XML_SetEndNamespaceDeclHandler(      XML_Parser, XML_EndNamespaceDeclHandler );
void               XML_SetNotStandaloneHandler(         XML_Parser, XML_NotStandaloneHandler );
void               XML_SetExternalEntityRefHandler(     XML_Parser, XML_ExternalEntityRefHandler );
void               XML_SetExternalEntityRefHandlerArg(  XML_Parser, void *arg );
void               XML_SetSkippedEntityHandler(         XML_Parser, XML_SkippedEntityHandler );
void               XML_SetUnknownEncodingHandler(       XML_Parser, XML_UnknownEncodingHandler, void *data );
void               XML_SetUserData(                     XML_Parser, void *userData );
XML_Status         XML_SetEncoding(                     XML_Parser, const char *encoding );
XML_Status         XML_SetBase(                         XML_Parser, const char *base );
const char*        XML_GetBase(                         XML_Parser  );

void               XML_DefaultCurrent(                  XML_Parser  );
void               XML_SetReturnNSTriplet(              XML_Parser, int do_nst );
void               XML_UseParserAsHandlerArg(           XML_Parser  );
XML_Error          XML_UseForeignDTD(                   XML_Parser, unsigned char useDTD );
int                XML_GetSpecifiedAttributeCount(      XML_Parser  );
int                XML_GetIdAttributeIndex(             XML_Parser  );
XML_Status         XML_Parse(                           XML_Parser, const char *s, int len, int isFinal );
void*              XML_GetBuffer(                       XML_Parser, int len  );
XML_Status         XML_ParseBuffer(                     XML_Parser, int len, int isFinal    );
XML_Status         XML_StopParser(                      XML_Parser, unsigned char resumable );
XML_Status         XML_ResumeParser(                    XML_Parser  );
void               XML_GetParsingStatus(                XML_Parser, XML_ParsingStatus *status);
XML_Parser         XML_ExternalEntityParserCreate(      XML_Parser, const char *context, const char *encoding );
int                XML_SetParamEntityParsing(           XML_Parser, XML_ParamEntityParsing );
XML_Error          XML_GetErrorCode(                    XML_Parser  );
int                XML_GetCurrentLineNumber(            XML_Parser  );
int                XML_GetCurrentColumnNumber(          XML_Parser  );
long               XML_GetCurrentByteIndex(             XML_Parser  );
int                XML_GetCurrentByteCount(             XML_Parser  );
const char*        XML_GetInputContext(                 XML_Parser, int *offset, int *size );
void               XML_FreeContentModel(                XML_Parser, XML_Content *model );
void*              XML_MemMalloc(                       XML_Parser, size_t size );
void*              XML_MemRealloc(                      XML_Parser, void *ptr, size_t size );
void               XML_MemFree(                         XML_Parser, void *ptr );
void               XML_ParserFree(                      XML_Parser );
const char*        XML_ErrorString(                     XML_Error );
const char*        XML_ExpatVersion(                    );
XML_Expat_Version  XML_ExpatVersionInfo(                );
const XML_Feature* XML_GetFeatureList(                  );
]]

return expat

ffi.cdef[[
      typedef int aiBool;
      
      enum {
	 AI_FALSE = 0,
	 AI_TRUE = 1,
	 AI_STRING_MAXLEN = 1024,
      };

      typedef enum _aiReturn {
	 AI_RETURN_SUCCESS = 0,
	 AI_RETURN_FAILURE = -1,
	 AI_RETURN_OUTOFMEMORY = -3,
      } aiReturn;

      typedef enum _aiOrigin {
	 AI_ORIGIN_SET = 0,
	 AI_ORIGIN_CUR = 1,
	 AI_ORIGIN_END = 2,
      } aiOrigin;

      typedef enum _aiDefaultLogStream {
	 AI_DEFAULT_LOG_STREAM_FILE = 1,
	 AI_DEFAULT_LOG_STREAM_STDOUT = 2,
	 AI_DEFAULT_LOG_STREAM_STDERR = 4,
	 AI_DEFAULT_LOG_STREAM_DEBUGGER = 8,
      } aiDefaultLogStream;

      typedef struct _aiVector2D {
	 float x, y;
      } aiVector2D;

      typedef struct _aiVector3D {
	 float x, y, z;
      } aiVector3D;

      typedef struct _aiColor3D {
	 float r, g, b;
      } aiColor3D;

      typedef struct _aiColor4D {
	 float r, g, b, a;
      } aiColor4D;

      typedef struct _aiPlane {
	 float a, b, c, d;
      } aiPlane;

      typedef struct _aiRay {
	 aiVector3D pos, dir;
      } aiRay;

      typedef struct _aiString {
	 size_t length;
	 char data[ AI_STRING_MAXLEN ];
      } aiString;
      
      typedef struct _aiMemoryInfo {
	 unsigned int textures;
	 unsigned int materials;
	 unsigned int meshes;
	 unsigned int nodes;
	 unsigned int animations;
	 unsigned int cameras;
	 unsigned int lights;
	 unsigned int total;
      } aiMemoryInfo;

      typedef struct _aiExportFormatDesc {
	 const char* id; 
	 const char* description;
	 const char* fileExtension;
      } aiExportFormatDesc;

      typedef struct _aiExportDataBlob {
	 size_t                    size;
	 void*                     data;
	 aiString                  name;
	 struct _aiExportDataBlob* next;
      } aiExportDataBlob;

      typedef void (* aiLogStreamCallback )( const char* message, char* user );
      
      struct aiLogStream
      {
	 aiLogStreamCallback callback;
	 char* user;
      };

      const aiScene* aiImportFile(                 const char* pFile, unsigned int pFlags );
      const aiScene* aiImportFileEx(               const char* pFile, unsigned int pFlags, aiFileIO* pFS );
      const aiScene* aiImportFileFromMemory(       const char* pBuffer, unsigned int pLength, unsigned int pFlags, const char* pHint );
      const aiScene* aiApplyPostProcessing(        const aiScene* pScene, unsigned int pFlags );
      aiLogStream    aiGetPredefinedLogStream(     aiDefaultLogStream pStreams, const char* file );
      void           aiAttachLogStream(            const aiLogStream* stream );
      void           aiEnableVerboseLogging(       aiBool d );
      aiReturn       aiDetachLogStream(            aiLogStream* stream );
      void           aiDetachAllLogStreams(        void );
      void           aiReleaseImport(              const aiScene* pScene );
      const char*    aiGetErrorString(             void );
      aiBool         aiIsExtensionSupported(       const char* szExtension );
      void           aiGetExtensionList(           aiString* szOut );
      void           aiGetMemoryRequirements(      const aiScene* pIn, aiMemoryInfo* in );
      void           aiSetImportPropertyInteger(   const char* szName, int value );
      void           aiSetImportPropertyFloat(     const char* szName, float value );
      void           aiSetImportPropertyString(    const char* szName, aiString* st );
      void           aiCreateQuaternionFromMatrix( aiQuaternion* quat, aiMatrix3x3* mat );
      void           aiDecomposeMatrix(            const aiMatrix4x4* mat, aiVector3D* scaling, aiQuaternion* rotation, aiVector3D* position );
      void           aiTransposeMatrix4(           aiMatrix4x4* mat );
      void           aiTransposeMatrix3(           aiMatrix3x3* mat );
      void           aiTransformVecByMatrix3(      aiVector3D* vec, aiMatrix3x3* mat );
      void           aiTransformVecByMatrix4(      aiVector3D* vec, aiMatrix4x4* mat );


      size_t                    aiGetExportFormatCount(void);
      const aiExportFormatDesc* aiGetExportFormatDescription( size_t pIndex);
ASSIMP_API aiReturn aiExportScene( const C_STRUCT aiScene* pScene, const char* pFormatId, const char* pFileName);
ASSIMP_API aiReturn aiExportSceneEx( const C_STRUCT aiScene* pScene, const char* pFormatId, const char* pFileName, C_STRUCT aiFileIO* pIO );
ASSIMP_API const C_STRUCT aiExportDataBlob* aiExportSceneToBlob( const C_STRUCT aiScene* pScene, const char* pFormatId );
ASSIMP_API C_STRUCT void aiReleaseExportData( const C_STRUCT aiExportDataBlob* pData );
      


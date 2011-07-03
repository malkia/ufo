local ffi  = require( "ffi" )

local libs = ffi_dbghelp_libs or {
   Windows = { x86 = "dbghelp.dll", x64 = "dbghelpdll" },
}

local lib  = ffi_dbghelp_lib or libs[ ffi.os ][ ffi.arch ]

local dh   = ffi.load( lib )

ffi.cdef[[
  typedef struct {
    unsigned SizeOfStruct;
    unsigned TypeIndex;
    uint64_t Reserved[2];
    unsigned Index;
    unsigned Size;
    uint64_t ModBase;
    unsigned Flags;
    uint64_t Value;
    uint64_t Address;
    unsigned Register;
    unsigned Scope;
    unsigned Tag;
    unsigned NameLen;
    unsigned MaxNameLen;
    char     Name[];
  } SYMBOL_INFO;
  int SymInitialize( void* process, const char* userSearchPath, int fInvadeProcess);
  int SymNext(       void* process, SYMBOL_INFO*  symbolInfo );
  int SymPrev(       void* process, SYMBOL_INFO*  symbolInfo );
  int SymNextW(      void* process, SYMBOL_INFOW* symbolInfo );
  int SymPrevW(      void* process, SYMBOL_INFOW* symbolInfo );
  unsigned GetLastError();
]]

return dh
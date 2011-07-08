#include <stdio.h>

extern
#ifdef _WIN32
__declspec(dllexport)
#endif
int luaopen_ufo(void* L) {
  printf( "\nUFO\n" );
  return 1;
}


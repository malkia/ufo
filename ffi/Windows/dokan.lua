--  Dokan : user-mode file system library for Windows
--
--  Copyright (C) 2008 Hiroki Asakawa info@dokan-dev.net
--
--  http://dokan-dev.net/en
--
-- This program is free software; you can redistribute it and/or modify it under
-- the terms of the GNU Lesser General Public License as published by the Free
-- Software Foundation; either version 3 of the License, or (at your option) any
-- later version.
-- 
-- This program is distributed in the hope that it will be useful, but WITHOUT ANY
-- WARRANTY; without even the implied warranty of MERCHANTABILITY or FITNESS
-- FOR A PARTICULAR PURPOSE. See the GNU General Public License for more details.
-- 
-- You should have received a copy of the GNU Lesser General Public License along
-- with this program. If not, see <http://www.gnu.org/licenses/>.

-- DOKAN_DRIVER_NAME = L"dokan.sys"

ffi.cdef[[
enum {
   DOKAN_SUCCESS              =   0,
   DOKAN_ERROR                =  -1,
   DOKAN_DRIVE_LETTER_ERROR   =  -2,
   DOKAN_DRIVER_INSTALL_ERROR =	 -3,
   DOKAN_START_ERROR          =  -4,
   DOKAN_MOUNT_ERROR          =  -5,
   DOKAN_MOUNT_POINT_ERROR    =  -6,
   DOKAN_VERSION              = 600,
   DOKAN_OPTION_DEBUG         =   1,
   DOKAN_OPTION_STDERR        =   2,
   DOKAN_OPTION_ALT_STREAM    =   4,
   DOKAN_OPTION_KEEP_ALIVE    =   8,
   DOKAN_OPTION_NETWORK       =  16,
   DOKAN_OPTION_REMOVABLE     =  32,
};

typedef struct DOKAN_OPTIONS {
   uint16_t Version;
   uint16_t ThreadCount;
   uint32_t Options;
   uint64_t GlobalContext;
   wchar_t* MountPoint;
} DOKAN_OPTIONS, *PDOKAN_OPTIONS;

typedef struct DOKAN_FILE_INFO {
   uint64_t Context;
   uint64_t DokanContext;
   DOKAN_OPTIONS* Options;
   uint32_t ProcessId;
   uint8_t  IsDirectory;
   uint8_t  DeleteOnClose;
   uint8_t  PagingIo;
   uint8_t  SynchronousIo;
   uint8_t  Nocache;
   uint8_t  WriteToEndOfFile;
} DOKAN_FILE_INFO;

typedef int (__stdcall *DOKAN_FILL_FIND_DATA)( PWIN32_FIND_DATAW, PDOKAN_FILE_INFO );

typedef struct DOKAN_OPERATIONS {
   int (__stdcall *CreateFile)(           wchar_t* FileName, uint32_t DesiredAccess, uint32_t ShareMode, uint32 CreationDisposition, uint32_t FlagsAndAttributes, DOKAN_FILE_INFO* );
   int (__stdcall *OpenDirectory)(        wchar_t* FileName,                                                                                                      DOKAN_FILE_INFO* );
   int (__stdcall *CreateDirectory)(      wchar_t* FileName,                                                                                                      DOKAN_FILE_INFO* );
   int (__stdcall *Cleanup)(              wchar_t* FileName,                                                                                                      DOKAN_FILE_INFO* );
   int (__stdcall *CloseFile)(            wchar_t* FileName,                                                                                                      DOKAN_FILE_INFO* );
   int (__stdcall *ReadFile)(             wchar_t* FileName, void* Buffer, uint32_t NumberOfBytesToRead,  uint32_t* NumberOfBytesRead,    uint64_t Offset,        DOKAN_FILE_INFO* );
   int (__stdcall *WriteFile)(            wchar_t* FileName, void* Buffer, uint32_t NumberOfBytesToWrite, uint32_t* NumberOfBytesWritten, uint64_t Offset,        DOKAN_FILE_INFO* );
   int (__stdcall *FlushFileBuffers)(     wchar_t* FileName,                                                                                                      DOKAN_FILE_INFO* );
   int (__stdcall *GetFileInformation)(   wchar_t* FileName, void* /*LPBY_HANDLE_FILE_INFORMATION*/ Buffer,                                                       DOKAN_FILE_INFO* );
   int (__stdcall *FindFiles)(            wchar_t* PathName,                         DOKAN_FILL_FIND_DATA callback,                                               DOKAN_FILE_INFO* );
   int (__stdcall *FindFilesWithPattern)( wchar_t* PathName, wchar_t* SearchPattern, DOKAN_FILL_FIND_DATA callback,                                               DOKAN_FILE_INFO* );
   int (__stdcall *SetFileAttributes)(    wchar_t* FileName, uint32_t Attributes,                                                                                 DOKAN_FILE_INFO* );
   int (__stdcall *SetFileTime)(          wchar_t* FileName, const FILETIME* CreationTime, CONST FILETIME* LastAccessTime, const FILETIME* LastWriteTime,         DOKAN_FILE_INFO* );
   int (__stdcall *DeleteFile)(		  wchar_t* FileName,                                                                                                      DOKAN_FILE_INFO* );
   int (__stdcall *DeleteDirectory)(      wchar_t* FileName,                                                                                                      DOKAN_FILE_INFO* );
   int (__stdcall *MoveFile)(             wchar_t* OldName,  wchar_t* NewName, BOOL ReplaceExisting,                                                              DOKAN_FILE_INFO* );
   int (__stdcall *SetEndOfFile)(         wchar_t* FileName, uint64_t Length,                                                                                     DOKAN_FILE_INFO* );
   int (__stdcall *SetAllocationSize)(    wchar_t* FileName, uint64_t Length,                                                                                     DOKAN_FILE_INFO* );
   int (__stdcall *LockFile)(             wchar_t* FileName, uint64_t ByteOffset, uint64_t Length,                                                                DOKAN_FILE_INFO* );
   int (__stdcall *UnlockFile)(           wchar_t* FileName, uint64_t ByteOffset, uint64_t Length,                                                                DOKAN_FILE_INFO* );
   int (__stdcall *GetDiskFreeSpace)(     wchar_t* FileName, uint64_t* FreeBytesAvailable, uint64_t* TotalNumberOfBytes, uint64_t* TotalNumberOfFreeBytes,        DOKAN_FILE_INFO* );
   int (__stdcall *GetVolumeInformation)( wchar_t* VolName,  uint32_t VolNameSize, uint32_t* VolSerNum, uint32_t* MaxComponentLen, uint32_t* FileSysFlags,
					  wchar_t* FileSysName, uint32_t FileSysNameSize,                                                                         DOKAN_FILE_INFO* );
   int (__stdcall *Unmount)(                                                                                                                                      DOKAN_FILE_INFO* );
   int (__stdcall *GetFileSecurity)(      wchar_t* FileName, void* SECURITY_INFORMATION, void* SECURITY_DESCRIPTOR, uint32_t LengthOfSecurityDescriptorBuffer, uint32_t* LengthNeeded, DOKAN_FILE_INFO* );
   int (__stdcall *SetFileSecurity)(	  wchar_t* FileName, void* SECURITY_INFORMATION, void* SECURITY_DESCRIPTOR, uint32_t LengthOfSecurityDescriptorBuffer,                         DOKAN_FILE_INFO* );
} DOKAN_OPERATIONS;

int    DOKANAPI DokanMain(               DOKAN_OPTIONS* Options, DOKAN_OPERATIONS* Operations );
BOOL   DOKANAPI DokanUnmount(            wchar_t DriveLetter );
BOOL   DOKANAPI DokanRemoveMountPoint(   wchar_t* MountPoint );
BOOL   DOKANAPI DokanIsNameInExpression( wchar_t* Expression, wchar_t* FileName, BOOL IgnoreCase );
ULONG  DOKANAPI DokanVersion(            );
ULONG  DOKANAPI DokanDriverVersion(      );
BOOL   DOKANAPI DokanResetTimeout(       ULONG Timeout, DOKAN_FILE_INFO* FileInfo );
HANDLE DOKANAPI DokanOpenRequestorToken( DOKAN_FILE_INFO* FileInfo );
]]

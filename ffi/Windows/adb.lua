local ffi = require( "ffi" )

assert( ffi.os == "Windows" and ffi.arch == "x86",
	"Android ADB requires Windows/x86" );

ffi.cdef[[
   typedef void* ADB_HANDLE;

   typedef struct ADB_GUID {
     uint32_t Data1;
     uint16_t Data2;
     uint16_t Data3;
     uint8_t  Data4[8];
   } ADB_GUID;

   typedef struct ADB_OVERLAPPED {
     uint32_t* Internal;
     uint32_t* InternalHigh;
     union {
       struct {
        uint32_t Offset;
        uint32_t OffsetHigh;
       };
       void* Pointer;
     };
     ADB_HANDLE hEvent;
   } ADB_OVERLAPPED;

   typedef struct ADB_USB_DEVICE_DESCRIPTOR {
     uint8_t  bLength;
     uint8_t  bDescriptorType;
     uint16_t bcdUSB;
     uint8_t  bDeviceClass;
     uint8_t  bDeviceSubClass;
     uint8_t  bDeviceProtocol;
     uint8_t  bMaxPacketSize0;
     uint16_t idVendor;
     uint16_t idProduct;
     uint16_t bcdDevice;
     uint8_t  iManufacturer;
     uint8_t  iProduct;
     uint8_t  iSerialNumber;
     uint8_t  bNumConfigurations;
   } ADB_USB_DEVICE_DESCRIPTOR;

   typedef struct ADB_USB_CONFIGURATION_DESCRIPTOR {
     uint8_t  bLength;
     uint8_t  bDescriptorType;
     uint16_t wTotalLength;
     uint8_t  bNumInterfaces;
     uint8_t  bConfigurationValue;
     uint8_t  iConfiguration;
     uint8_t  bmAttributes;
     uint8_t  MaxPower;
   } ADB_USB_CONFIGURATION_DESCRIPTOR;

   typedef struct _USB_INTERFACE_DESCRIPTOR {
     uint8_t bLength;
     uint8_t bDescriptorType;
     uint8_t bInterfaceNumber;
     uint8_t bAlternateSetting;
     uint8_t bNumEndpoints;
     uint8_t bInterfaceClass;
     uint8_t bInterfaceSubClass;
     uint8_t bInterfaceProtocol;
     uint8_t iInterface;
   } ADB_USB_INTERFACE_DESCRIPTOR;

   typedef void* ADB;

   enum {
     ADB_QUERY_BULK_WRITE_ENDPOINT_INDEX   = 0xFC,
     ADB_QUERY_BULK_READ_ENDPOINT_INDEX    = 0xFE,
   
     ADB_DEVICE_VENDOR_ID                  = 0x0BB4,
     ADB_DEVICE_SINGLE_PRODUCT_ID          = 0x0C01,
     ADB_DEVICE_COMPOSITE_PRODUCT_ID       = 0x0C02,
     ADB_DEVICE_MAGIC_COMPOSITE_PRODUCT_ID = 0x0C03,
   
     ADB_DEVICE_INTERFACE_ID               = 0x01,
     ADB_DEVICE_EMULATOR_VENDOR_ID         = 0x18D1,
     ADB_DEVICE_EMULATOR_PROD_ID           = 0xDDDD,
   };

   typedef enum AdbEndpointType {
     AdbEndpointTypeInvalid,
     AdbEndpointTypeControl,
     AdbEndpointTypeIsochronous,
     AdbEndpointTypeBulk,
     AdbEndpointTypeInterrupt,
   } AdbEndpointType;

   typedef enum AdbOpenAccessType {
     AdbOpenAccessTypeReadWrite,
     AdbOpenAccessTypeRead,
     AdbOpenAccessTypeWrite,
     AdbOpenAccessTypeQueryInfo,
   } AdbOpenAccessType;
   
   typedef enum AdbOpenSharingMode {
     AdbOpenSharingModeReadWrite,
     AdbOpenSharingModeRead,
     AdbOpenSharingModeWrite,
     AdbOpenSharingModeExclusive,
   } AdbOpenSharingMode;

   typedef struct    AdbEndpointInformation {
     uint32_t        max_packet_size;
     uint32_t        max_transfer_size;
     AdbEndpointType endpoint_type;
     uint8_t         endpoint_address;
     uint8_t         polling_interval;
     uint8_t         setting_index;
   } AdbEndpointInformation;

   typedef struct AdbInterfaceInfo {
     ADB_GUID     class_id;
     uint32_t     flags;
     wchar_t      device_name[?];
   } AdbInterfaceInfo;

   ADB AdbEnumInterfaces(                ADB_GUID class_id, int exclude_not_present,
                                                  int exclude_removed, int active_only );
   int AdbNextInterface(                 ADB, AdbInterfaceInfo* info, uint32_t* size );
   int AdbResetInterfaceEnum(            ADB  );
   ADB AdbCreateInterfaceByName(   const wchar_t* interface_name );
   ADB AdbCreateInterface(               ADB_GUID class_id, uint16_t vendor_id,
                                                  uint16_t product_id, uint8_t interface_id );
   int AdbGetInterfaceName(              ADB, void* buf, uint32_t* bufsize, int ansi );
   int AdbGetSerialNumber(               ADB, void* buf, uint32_t* bufsize, int ansi );
   int AdbGetUsbDeviceDescriptor(        ADB, ADB_USB_DEVICE_DESCRIPTOR* );
   int AdbGetUsbConfigurationDescriptor( ADB, ADB_USB_CONFIGURATION_DESCRIPTOR* );
   int AdbGetUsbInterfaceDescriptor(     ADB, ADB_USB_INTERFACE_DESCRIPTOR* );
   int AdbGetEndpointInformation(        ADB, uint8_t endpoint_index,
                                              AdbEndpointInformation* info );
   int AdbGetDefaultBulkReadEndpointInformation(  ADB, AdbEndpointInformation* info );
   int AdbGetDefaultBulkWriteEndpointInformation( ADB, AdbEndpointInformation* info );
   ADB AdbOpenEndpoint(                  ADB, uint8_t endpoint_index,
                                              AdbOpenAccessType, AdbOpenSharingMode );
   ADB AdbOpenDefaultBulkReadEndpoint(   ADB, AdbOpenAccessType, AdbOpenSharingMode );
   ADB AdbOpenDefaultBulkWriteEndpoint(  ADB, AdbOpenAccessType, AdbOpenSharingMode );
   ADB AdbGetEndpointInterface(          ADB  );
   int AdbQueryInformationEndpoint(      ADB, AdbEndpointInformation* info );
   ADB AdbReadEndpointAsync(             ADB, void* buf, uint32_t bytes_to_read, 
                                              uint32_t* bytes_read, uint32_t time_out,
                                              ADB_HANDLE event_handle );
   ADB AdbWriteEndpointAsync(            ADB, void* buf, uint32_t bytes_to_write,
                                              uint32_t* bytes_written, uint32_t time_out,
                                              ADB_HANDLE event_handle );
   int AdbReadEndpointSync(              ADB, void* buf, uint32_t bytes_to_read, 
                                              uint32_t* bytes_read, uint32_t time_out );
   int AdbWriteEndpointSync(             ADB, void* buf, uint32_t bytes_to_write,
                                              uint32_t* bytes_written, uint32_t time_out );
   int AdbGetOvelappedIoResult(          ADB, ADB_OVERLAPPED* overlapped,
                                              uint32_t* bytes_transferred, int wait );
   int AdbHasOvelappedIoComplated(       ADB  adb_io_completion );
   int AdbCloseHandle(                   ADB  );

   static const size_t test1 = 0;
]]

ADB_USB_CLASS_ID = ffi.new(
   "ADB_GUID",
   0xf72fe0d4, 0xcbcb, 0x407d, {0x88, 0x14, 0x9e, 0xd6, 0x73, 0xd0, 0xdd, 0x6b}
)

local lib = ffi.load( "bin/Windows/x86/AdbWinApi.dll" )

if ... then
   return lib
end

print( ffi.test2 )

--- testing
print()

local adb = lib --require( "ffi/Windows/adb" )
local ADB = ffi.gc( adb.AdbEnumInterfaces( ADB_USB_CLASS_ID, 1, 1, 1), adb.AdbCloseHandle )
--print( ADB )
local count = ffi.new( "uint32_t[1]", 1024 )

local interface_info = ffi.new( "AdbInterfaceInfo", 1024 )
local interface_size = ffi.new( "uint32_t[1]", ffi.sizeof( interface_info ))

while adb.AdbNextInterface( ADB, interface_info, interface_size ) == 1 do
   local name = {}
   for i = 0,255 do
      local char = interface_info.device_name[i]
      if char == 0 then
	 break
      end
      name[#name+1] = string.char(char)
   end
   print(table.concat(name))
--   print(interface_info.flags)
end

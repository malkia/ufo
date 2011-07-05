IOS_DIR=/Developer/Platforms/iPhoneOS.platform/
SIM_DIR=/Developer/Platforms/iPhoneSimulator.platform/
IOS_SDK_VER="4.3"
IOS_MIN_VER="3.0"
IOS_OUT_DIR="ios"

build_target () {
    local platform=$1
    local sdk=$2
    local arch=$3
    local triple=$4
    local builddir=$5

    mkdir -p "${builddir}"
    pushd "${builddir}"
    export CC="${platform}"/Developer/usr/bin/gcc-4.2
    export CFLAGS="-arch ${arch} -isysroot ${sdk} -miphoneos-version-min=${IOS_MIN_VER}"
    ../configure --host=${triple} && make
    popd
}

# Build all targets
build_target "${IOS_DIR}" "${PLATFORM_IOS}/Developer/SDKs/iPhoneOS${SDK_IOS_VERSION}.sdk/" armv6 arm-apple-darwin10 armv6-ios
build_target "${IOS_DIR}" "${PLATFORM_IOS}/Developer/SDKs/iPhoneOS${SDK_IOS_VERSION}.sdk/" armv7 arm-apple-darwin10 armv7-ios
build_target "${SIM_DIR}" "${PLATFORM_IOS_SIM}/Developer/SDKs/iPhoneSimulator${SDK_IOS_VERSION}.sdk/" i386 i386-apple-darwin10 i386-ios-sim

# Create universal output directories
mkdir -p "${OUTPUT_DIR}"
mkdir -p "${OUTPUT_DIR}/include"
mkdir -p "${OUTPUT_DIR}/include/armv6"
mkdir -p "${OUTPUT_DIR}/include/armv7"
mkdir -p "${OUTPUT_DIR}/include/i386"

# Create the universal binary
lipo -create armv6-ios/.libs/libffi.a armv7-ios/.libs/libffi.a i386-ios-sim/.libs/libffi.a -output "${OUTPUT_DIR}/libffi.a"


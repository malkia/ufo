set -e
ROOT=../../../libzmq
pushd $ROOT
git clean -fdx

DEV=/Developer/Platforms/iPhoneOS.platform/Developer
SDK=$DEV/SDKs/iPhoneOS5.0.sdk
BIN=$DEV/usr/bin
HOST=arm-apple-darwin10

# I - iOS
# S - Simulator

DEVI=/Developer/Platforms/iPhoneOS.platform/Developer
DEVS=/Developer/Platforms/iPhoneSimulator.platform/Developer
SDKI=$DEVI/SDKs/iPhoneOS5.0.sdk
SDKS=$DEVS/SDKs/iPhoneSimulator5.0.sdk
BINI=$DEVI/usr/bin
BINS=$DEVS/usr/bin

FLAGS="-isysroot $SDK"
ARMV6="-march=armv6 -mcpu=arm1176jzf-s -mfpu=vfp"
ARMV7="-march=armv7 -mcpu=cortex-a8 -mtune=cortex-a8 -mfpu=neon"
ARCH=$ARMV6

./autogen.sh
./configure CPP="cpp" CXXCPP="cpp" CXX=$BIN/$HOST-llvm-g++-4.2 CC=$BIN/$HOST-llvm-gcc-4.2 LD=$BIN/ld CFLAGS="-O $ARCH $FLAGS" CXXFLAGS="-O $ARCH $FLAGS" --host=$HOST LDFLAGS="$FLAGS" AR=$BIN/ar AS=$BIN/as LIBTOOL=$BIN/libtool STRIP=$BIN/strip RANLIB=$BIN/ranlib
make -j


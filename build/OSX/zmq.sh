pushd ${0%/*}
LIBZMQ=../../../libzmq
pushd $LIBZMQ

# http://www.cybergarage.org/twiki/bin/view/Main/IPhoneDevTips

#ISDK=/Developer/Platforms/iPhoneOS.platform/Developer
#ISDKVER=iPhoneOS4.3.sdk
#ISDKP=$ISDK/usr/bin/
#FLAGS="-arch arvm6 -arch armv7 -miphoneos-version-min=3.0 -isysroot ${ISDK}/SDKs/${ISDKVER}"

#make clean
#./configure --host=arm-apple-darwin --enable-static=no --enable-shared=yes CC=$ISDKP/arm-apple-darwin10-gcc-4.2.1 CFLAGS="-pipe -std=c99 -Wno-trigraphs -fpascal-strings -O0 -Wreturn-type -Wunused-variable -fmessage-length=0 -fvisibility=hidden -miphoneos-version-min=3.1.2 -gdwarf-2 -mthumb -I/Library/iPhone/include -isysroot ${ISDK}/SDKs/${ISDKVER} -mdynamic-no-pic" CPP=$ISDKP/cpp AR=$ISDKP/ar AS=$ISDKP/as LIBTOOL=$ISDKP/libtool STRIP=$ISDKP/strip RANLIB=$ISDKP/ranlib

#make -j8
#file src/.libs/libzmq.1.dylib

#exit

FLAGS="-arch i386 -arch x86_64 -mmacosx-version-min=10.4"
CXX="g++ $FLAGS"
CC="gcc $FLAGS"
make clean
./configure CXX="$CXX" CC="$CC" CPP=/usr/bin/cpp CXXCPP=/usr/bin/cpp #--with-pgm
make -j

git log -1 >> src/.libs/libzmq.1.dylib

popd
mv $LIBZMQ/src/.libs/libzmq.1.dylib ../../bin/OSX/libzmq.dylib
install_name_tool -id @rpath/libzmq.dylib ../../bin/OSX/libzmq.dylib
popd

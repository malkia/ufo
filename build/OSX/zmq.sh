set -e
reldir=$(dirname $0)
pushd $reldir 1>/dev/null 2&>1 && absdir=$(pwd) && popd 1>/dev/null 2&>1

pushd ${0%/*}
LIBZMQ=../../../libzmq
pushd $LIBZMQ
git clean -fdx

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

FLAGS="-arch i386 -arch x86_64 -mmacosx-version-min=10.5"
CXX="clang++ $FLAGS"
CC="clang $FLAGS"
CPP="clang -E"
CXXCPP="clang++ -E"

#make clean
./autogen.sh
export OpenPGM_CFLAGS=-I../../openpgm/pgm/include
export OpenPGM_LIBS="-L../../openpgm/pgm/ -lpgm"
./configure CXX="$CXX" CC="$CC" CPP="$CPP" CXXCPP="$CXXCPP" --with-system-pgm
make -j V=1

git log -1 >> src/.libs/libzmq.3.dylib

popd
mv $LIBZMQ/src/.libs/libzmq.3.dylib ../../bin/OSX/zmq.dylib
install_name_tool -id @loader_path/zmq.dylib ../../bin/OSX/zmq.dylib
install_name_tool -change /usr/local/lib/libpgm-5.2.0.dylib @loader_path/pgm.dylib ../../bin/OSX/zmq.dylib
popd


set -e
reldir=$(dirname $0)
pushd $reldir 1>/dev/null 2&>1 && absdir=$(pwd) && popd 1>/dev/null 2&>1

pushd $absdir
DEPO=../../../openpgm/pgm
pushd $DEPO
. $absdir/../bin/clean-svn
./bootstrap.sh
./configure CFLAGS="-arch i386 -arch x86_64 -mmacosx-version-min=10.5 -D__APPLE_USE_RFC_3542=1" --disable-dependency-tracking
make -j

#git log -1 >> .libs/libpgm-5.2.0.dylib

popd
cp $DEPO/.libs/libpgm-5.2.0.dylib ../../bin/OSX/pgm.dylib
install_name_tool -id @loader_path/pgm.dylib ../../bin/OSX/pgm.dylib
popd


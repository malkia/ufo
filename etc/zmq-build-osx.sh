export LIBZMQ=../../libzmq
export FLAGS="-arch i386 -arch x86_64 -mmacosx-version-min=10.4"
export CXX="g++ $FLAGS"
export CC="gcc $FLAGS"

echo LIBZMQ=$LIBZMQ FLAGS=$FLAGS

pushd $LIBZMQ
make clean
./configure CXX="$CXX" CC="$CC" CPP=/usr/bin/cpp CXXCPP=/usr/bin/cpp
make -j8
git log -1 >> src/.libs/libzmq.1.dylib
popd

mv $LIBZMQ/src/.libs/libzmq.1.dylib ../bin/zmq.dylib


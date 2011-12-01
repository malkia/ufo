set -e

ROOT=../../../libzmq
pushd $ROOT && git clean -fdx && ./autogen.sh && ./configure CXX="g++ -m32" && make -j && popd && cp $ROOT/src/.libs/libzmq.so.3.0.0 ../../bin/Linux/x86/zmq.so
pushd $ROOT && git clean -fdx && ./autogen.sh && ./configure CXX="g++ -m64" && make -j && popd && cp $ROOT/src/.libs/libzmq.so.3.0.0 ../../bin/Linux/x64/zmq.so


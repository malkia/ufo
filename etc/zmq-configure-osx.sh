make clean
./configure CXX="g++ -arch i386 -arch x86_64" CC="gcc -arch i386 -arch x86_64" CPP=/usr/bin/cpp CXXCPP=/usr/bin/cpp
make -j8
cp ./src/.libs/libzmq.dylib ../ufo/bin/zmq.dylib
git log -1 >> ../ufo/bin/zmq.dylib

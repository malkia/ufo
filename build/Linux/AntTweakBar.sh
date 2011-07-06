ROOT=../../../AntTweakBar
make -C $ROOT/src clean
make -C $ROOT/src CXX="g++ -m32" LINK="g++ -m32" LIBS=-lGL -j
cp $ROOT/lib/libAntTweakBar.so ../../bin/Linux/x86
make -C $ROOT/src clean
make -C $ROOT/src CXX="g++ -m64" LINK="g++ -m64" LIBS=-lGL -j 
cp $ROOT/lib/libAntTweakBar.so ../../bin/Linux/x64

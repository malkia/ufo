LUAJIT=../../luajit
echo LUAJIT=$LUAJIT

pushd $LUAJIT/src

make clean
make "CC=gcc -m32" amalg
mv luajit       luajit32.tmp
mv libluajit.so luajit32.dylib.tmp

make clean
make "CC=gcc -m64" amalg
mv luajit       luajit64.tmp
mv libluajit.so luajit64.dylib.tmp

lipo -create -arch i386 luajit32.tmp       -arch x86_64 luajit64.tmp       -output luajit
lipo -create -arch i386 luajit32.dylib.tmp -arch x86_64 luajit64.dylib.tmp -output luajit.dylib

rm luajit*.tmp

git log -1 >> luajit
git log -1 >> luajit.dylib

popd

mv $LUAJIT/src/luajit ..
mv $LUAJIT/src/luajit.dylib ../bin


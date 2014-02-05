#!/bin/sh

rm -rf kernel.zip
rm -rf ramdisk.gz
find -name "*~" -exec rm -rf {} \;
find -name ".DS_Store" -exec rm -rf {} \; 

build () {
    cd boot.img-ramdisk
    find . | cpio -o -H newc | gzip > ../ramdisk.gz
    cd ..
    ./mkbootimg-$1 --kernel zImage --ramdisk ramdisk.gz -o boot.img
}

if [ -e ~/.bash_profile ]; then
    build darwin
else
    build linux
fi

mv -v boot.img out/
cd out
zip -r kernel.zip META-INF boot.img
mv -v kernel.zip ../
cd ..
adb push kernel.zip /sdcard/.

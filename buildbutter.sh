#!/bin/bash

echo 'Cleaning...'
make clean
echo 'Making config...'
make butter_n1_defconfig
echo 'Building zImage...'
make -j4

cp arch/arm/boot/zImage mkboot/

cd mkboot
echo "Making Boot.img..."
./img.sh

echo 'Moving modules and boot.img...'
cd ..
rm -rfv out/ButterKernel/system/lib/modules/*
find -name '*.ko' -exec cp -v {} out/ButterKernel/system/lib/modules \;
cp mkboot/boot.img out/ButterKernel

echo 'Zipping...'
cd out/ButterKernel
zip -r ButterKernel.zip cleaner META-INF system boot.img

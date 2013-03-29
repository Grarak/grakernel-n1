#!/bin/bash

cp arch/arm/boot/zImage mkboot/
cd mkboot
./img.sh

cd ..
cp mkboot/boot.img out/ButterKernel/

rm -rfv out/ButterKernel/system/lib/modules/*
find -name '*.ko' -exec cp -v {} out/ButterKernel/system/lib/modules \;

cd out/ButterKernel
zip -r ButterKernel.zip cleaner META-INF system boot.img

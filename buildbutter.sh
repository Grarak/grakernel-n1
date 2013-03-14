#!/bin/bash

echo 'Cleaning...'
make clean
echo 'Making config...'
make butter_i9103_defconfig
echo 'Building zImage...'
make -j4

cp arch/arm/boot/zImage mkboot/

cd mkboot
echo "Making Boot.img..."
./img.sh

echo 'Moving modules and boot.img...'
cd ..
cp drivers/scsi/scsi_wait_scan.ko out/ButterKernel/system/lib/modules
cp drivers/misc/fm_si4709/Si4709_driver.ko out/ButterKernel/system/lib/modules
cp drivers/net/wireless/bcmdhd/dhd.ko out/ButterKernel/system/lib/modules
cp mkboot/boot.img out/ButterKernel

echo 'Zipping...'
cd out/ButterKernel
zip -r ButterKernel.zip cleaner META-INF system boot.img

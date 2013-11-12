#!/bin/bash

rm -rf kernel.zip
rm -rf ramdisk.gz
find -name "*~" -exec rm -rf {} \;
find -name ".DS_Store" -exec rm -rf {} \;

ramdiskfolder=aosp42

build () {
    cd $ramdiskfolder
    find . | cpio -o -H newc | gzip > ../ramdisk.gz
    cd ..
    ./mkbootimg-$1 --kernel zImage --ramdisk ramdisk.gz --cmdline "mem=511M@0M secmem=1M@511M mem=512M@512M vmalloc=256M fota_boot=false tegra_fbmem=800K@0x18012000 video=tegrafb console=ram usbcore.old_scheme_first=1 lp0_vec=8192@0x1819E000 emmc_checksum_done=true emmc_checksum_pass=true tegraboot=sdmmc gpt" -o boot.img
}

echo "> AOSP 4.2 [0]"
echo "  AOSP 4.3 [1]"

read ramdisk

if [ "$ramdisk" == "0" ]; then
	ramdiskfolder=aosp42
else
	ramdiskfolder=aosp43
fi

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

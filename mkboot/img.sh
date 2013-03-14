echo "making ramdisk"
cd boot.img-ramdisk
chmod 750 init* charger
chmod 644 default.prop
chmod 640 fstab.n1
chmod 644 ueventd*
cd ..
./mkbootfs boot.img-ramdisk | gzip > ramdisk.gz
./mkbootimg --kernel zImage --ramdisk ramdisk.gz -o boot.img --base 10000000 

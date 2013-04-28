echo "making ramdisk"
./mkbootfs boot.img-ramdisk | gzip > ramdisk.gz
./mkbootimg --kernel zImage --ramdisk ramdisk.gz -o boot.img --base 10000000 

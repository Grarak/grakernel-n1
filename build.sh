#!/bin/bash

# Colorize and add text parameters
red=$(tput setaf 1) # red
cya=$(tput setaf 6) # cyan

txtbld=$(tput bold) # Bold

bldred=${txtbld}$(tput setaf 1) # red
bldcya=${txtbld}$(tput setaf 6) # cyan

txtrst=$(tput sgr0) # Reset

version=1.0

DATE_START=$(date +"%s")

##########################################################################
echo -e "${bldcya}Do you want to clean up? ${txtrst} [N/y]"
read cleanup

if [ "$cleanup" == "y" ]; then
        echo -e "Complete Clean? [N/y]"
        read cleanoption

        if [ "$cleanoption" == "n" ] || [ "$cleanoption" == "N" ]; then
                echo -e "${bldcya}make clean ${txtrst}"
        	make clean
        fi

        if [ "$cleanoption" == "y" ]; then
                echo -e "${bldcya}make clean mrproper ${txtrst}"
	        make clean mrproper
        fi
fi
###########################################################################
[ -e .version ] && rm -f .version

echo -e "${bldcya}Do you want to edit the kernel version? ${txtrst} [N/y]"
read kernelversion

if [ "$kernelversion" == "y" ]; then
        echo -e "${bldcya}What version has your kernel? ${txtrst}"
        echo "${bldred}NUMBERS ONLY! ${txtrst}"
        read number
 
        echo $number >> .version
fi
###########################################################################

make tegra_n1_defconfig

###########################################################################
echo -e "${bldcya}Build kernel ${txtrst}"
echo -e "> 1. i9103";
echo -e "  2. i927";
read variant

if [ "$variant" == "1" ]; then
	cp arch/arm/configs/gk_i9103_defconfig .config
else
	cp arch/arm/configs/gk_i927_defconfig .config
fi
sed -i s/CONFIG_LOCALVERSION=\".*\"/CONFIG_LOCALVERSION=\"-GraKernel_${version}\"/ .config

###########################################################################
echo -e "${bldcya}This could take a while .... ${txtrst}"

nice -n 10 make modules -j4 ARCH=arm
nice -n 10 make -j4 ARCH=arm

###########################################################################
if [ -e arch/arm/boot/zImage ]; then
	cp -vf arch/arm/boot/zImage ramdisk/
	rm -f ramdisk/boot.img-ramdisk/lib/modules/*.ko
	find -name "*.ko" -exec cp -vf {} ramdisk/boot.img-ramdisk/lib/modules/ \;

	cd ramdisk

	./build.sh

	echo -e "${bldcya}Finished!! ${txtrst}"
	DATE_END=$(date +"%s")
	DIFF=$(($DATE_END - $DATE_START))
	echo "Build completed in $(($DIFF / 60)) minute(s) and $(($DIFF % 60)) seconds."
	date '+%a, %d %b %Y %H:%M:%S'
else
	echo "${bldred}KERNEL DID NOT BUILD! ${txtrst}"
fi

exit 0
############################################################################

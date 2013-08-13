#!/bin/bash

# Colorize and add text parameters
red=$(tput setaf 1) # red
cya=$(tput setaf 6) # cyan

txtbld=$(tput bold) # Bold

bldred=${txtbld}$(tput setaf 1) # red
bldcya=${txtbld}$(tput setaf 6) # cyan

txtrst=$(tput sgr0) # Reset

gkversion=alpha
tcf=/Volumes/kernel/toolchain/

DATE_START=$(date +"%s")

echo -e "${bldcya} Select Toolchain ${txtrst}"
echo -e "  1: Google 4.6"
echo -e "  2: Google 4.7"
echo -e "> 3: Linaro 4.8 13.07 by Christopher83"
read toolchain

if [ "$toolchain" == "1" ]; then
        export CROSS_COMPILE=${tcf}arm-eabi-4.6/bin/arm-eabi-
fi

if [ "$toolchain" == "2" ]; then
        export CROSS_COMPILE=${tcf}arm-eabi-4.7/bin/arm-eabi-
fi

if [ "$toolchain" == "2" ]; then
        export CROSS_COMPILE=${tcf}linaro-optimized-4.8-13.07/bin/arm-unknown-linux-gnueabi-
fi

echo -e "${bldcya} Cleaning .... ${txtrst}"

##########################################################################
echo -e "Do you want to clean up? [N/y]"
read cleanup

if [ "$cleanup" == "y" ]; then
        echo -e "Complete Clean? [N/y]"
        read cleanoption

        if [ "$cleanoption" == "n" ] || [ "$cleanoption" == "N" ]; then
                echo -e "${bldcya} make clean ${txtrst}"
        	make clean
        fi

        if [ "$cleanoption" == "y" ]; then
                echo -e "${bldcya} make clean mrproper ${txtrst}"
	        make clean mrproper
        fi
fi
###########################################################################

###########################################################################
if [ -e .version ]; then
	rm .version
fi

echo -e "${bldcya} Do you want to edit the kernel version? ${txtrst} [N/y]"
read kernelversion

if [ "$kernelversion" == "y" ]; then
        echo -e "${bldcya} What version has your kernel? ${txtrst}"
        echo "${bldred} NUMBERS ONLY! ${txtrst}"
        read version
 
        echo $version >> .version
fi
###########################################################################

make tegra_n1_defconfig

###########################################################################
echo -e "${bldcya} Build kernel ${txtrst}"
cp arch/arm/configs/gk_i9103_defconfig .config
sed -i s/CONFIG_LOCALVERSION=\".*\"/CONFIG_LOCALVERSION=\"-GraKernel_${gkversion}_selinux_4.3.+\"/ .config

###########################################################################
echo -e "${bldcya} This could take a while .... ${txtrst}"
make -j4

###########################################################################
if [ -e arch/arm/boot/zImage ]; then

        echo -e "${bldcya} Building boot.img .... ${txtrst}"

        cp arch/arm/boot/zImage mkboot/.
        cd mkboot
        ./img.sh
        cd ..
        cp mkboot/boot.img out/GraKernel/

        rm -rf out/GraKernel/system/lib/modules/*.ko
        find -name '*.ko' -exec cp -v {} out/GraKernel/system/lib/modules \;
        rm -rf *.zip
        zip -r GraKernel_${gkversion}.zip cleaner META-INF system boot.img
   
        echo -e "${bldcya} Finished!! ${txtrst}"
        DATE_END=$(date +"%s")
        DIFF=$(($DATE_END - $DATE_START))
        echo "Build completed in $(($DIFF / 60)) minute(s) and $(($DIFF % 60)) seconds."
        date '+%a, %d %b %Y %H:%M:%S'
        echo -e "${bldcya} Flashable zip is in /out/GraKernel ${txtrst}"

else
	        echo "${bldred} KERNEL DID NOT BUILD! ${txtrst}"
fi

exit 0
############################################################################

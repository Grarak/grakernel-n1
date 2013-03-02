cmd_arch/arm/kernel/relocate_kernel.o := /home/willi/android/kernel/toolchains/arm-eabi-linaro-4.6.2/bin/arm-eabi-gcc -Wp,-MD,arch/arm/kernel/.relocate_kernel.o.d  -nostdinc -isystem /home/willi/android/kernel/toolchains/arm-eabi-linaro-4.6.2/bin/../lib/gcc/arm-eabi/4.6.2/include -I/home/willi/android/kernel/n1_jb/arch/arm/include -Iarch/arm/include/generated -Iinclude  -include /home/willi/android/kernel/n1_jb/include/linux/kconfig.h -D__KERNEL__ -mlittle-endian -Iarch/arm/mach-tegra/include -D__ASSEMBLY__ -O2 -mcpu=cortex-a9 -mtune=cortex-a9 -D__ARM_ARCH_7__ -D__ARM_ARCH_7A__ -D__VFP_FP__ -D__ARM_HAVE_VFP -mfloat-abi=hard -mfpu=vfpv3-d16 -mabi=aapcs-linux -mno-thumb-interwork -funwind-tables  -D__LINUX_ARM_ARCH__=7 -march=armv7-a -Wa,-march=armv7-a  -include asm/unified.h        -c -o arch/arm/kernel/relocate_kernel.o arch/arm/kernel/relocate_kernel.S

source_arch/arm/kernel/relocate_kernel.o := arch/arm/kernel/relocate_kernel.S

deps_arch/arm/kernel/relocate_kernel.o := \
  /home/willi/android/kernel/n1_jb/include/linux/kconfig.h \
    $(wildcard include/config/h.h) \
    $(wildcard include/config/.h) \
    $(wildcard include/config/foo.h) \
  /home/willi/android/kernel/n1_jb/arch/arm/include/asm/unified.h \
    $(wildcard include/config/arm/asm/unified.h) \
    $(wildcard include/config/thumb2/kernel.h) \
  /home/willi/android/kernel/n1_jb/arch/arm/include/asm/kexec.h \
    $(wildcard include/config/kexec.h) \

arch/arm/kernel/relocate_kernel.o: $(deps_arch/arm/kernel/relocate_kernel.o)

$(deps_arch/arm/kernel/relocate_kernel.o):

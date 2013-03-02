cmd_arch/arm/kernel/entry-common.o := /home/willi/android/kernel/toolchains/arm-eabi-linaro-4.6.2/bin/arm-eabi-gcc -Wp,-MD,arch/arm/kernel/.entry-common.o.d  -nostdinc -isystem /home/willi/android/kernel/toolchains/arm-eabi-linaro-4.6.2/bin/../lib/gcc/arm-eabi/4.6.2/include -I/home/willi/android/kernel/n1_jb/arch/arm/include -Iarch/arm/include/generated -Iinclude  -include /home/willi/android/kernel/n1_jb/include/linux/kconfig.h -D__KERNEL__ -mlittle-endian -Iarch/arm/mach-tegra/include -D__ASSEMBLY__ -O2 -mcpu=cortex-a9 -mtune=cortex-a9 -D__ARM_ARCH_7__ -D__ARM_ARCH_7A__ -D__VFP_FP__ -D__ARM_HAVE_VFP -mfloat-abi=hard -mfpu=vfpv3-d16 -mabi=aapcs-linux -mno-thumb-interwork -funwind-tables  -D__LINUX_ARM_ARCH__=7 -march=armv7-a -Wa,-march=armv7-a  -include asm/unified.h        -c -o arch/arm/kernel/entry-common.o arch/arm/kernel/entry-common.S

source_arch/arm/kernel/entry-common.o := arch/arm/kernel/entry-common.S

deps_arch/arm/kernel/entry-common.o := \
    $(wildcard include/config/irqsoff/tracer.h) \
    $(wildcard include/config/function/tracer.h) \
    $(wildcard include/config/old/mcount.h) \
    $(wildcard include/config/frame/pointer.h) \
    $(wildcard include/config/function/graph/tracer.h) \
    $(wildcard include/config/dynamic/ftrace.h) \
    $(wildcard include/config/cpu/arm710.h) \
    $(wildcard include/config/oabi/compat.h) \
    $(wildcard include/config/arm/thumb.h) \
    $(wildcard include/config/cpu/endian/be8.h) \
    $(wildcard include/config/aeabi.h) \
    $(wildcard include/config/alignment/trap.h) \
    $(wildcard include/config/seccomp.h) \
  /home/willi/android/kernel/n1_jb/include/linux/kconfig.h \
    $(wildcard include/config/h.h) \
    $(wildcard include/config/.h) \
    $(wildcard include/config/foo.h) \
  /home/willi/android/kernel/n1_jb/arch/arm/include/asm/unified.h \
    $(wildcard include/config/arm/asm/unified.h) \
    $(wildcard include/config/thumb2/kernel.h) \
  /home/willi/android/kernel/n1_jb/arch/arm/include/asm/unistd.h \
  /home/willi/android/kernel/n1_jb/arch/arm/include/asm/ftrace.h \
    $(wildcard include/config/arm/unwind.h) \
  arch/arm/mach-tegra/include/mach/entry-macro.S \
    $(wildcard include/config/arm/gic.h) \
  arch/arm/mach-tegra/include/mach/iomap.h \
    $(wildcard include/config/arch/tegra/2x/soc.h) \
    $(wildcard include/config/arch/tegra/3x/soc.h) \
    $(wildcard include/config/base.h) \
    $(wildcard include/config/size.h) \
    $(wildcard include/config/tegra/debug/uart/none.h) \
    $(wildcard include/config/tegra/debug/uarta.h) \
    $(wildcard include/config/tegra/debug/uartb.h) \
    $(wildcard include/config/tegra/debug/uartc.h) \
    $(wildcard include/config/tegra/debug/uartd.h) \
    $(wildcard include/config/tegra/debug/uarte.h) \
  /home/willi/android/kernel/n1_jb/arch/arm/include/asm/sizes.h \
  include/asm-generic/sizes.h \
  arch/arm/mach-tegra/include/mach/io.h \
    $(wildcard include/config/tegra/pci.h) \
  /home/willi/android/kernel/n1_jb/arch/arm/include/asm/hardware/entry-macro-gic.S \
  /home/willi/android/kernel/n1_jb/arch/arm/include/asm/hardware/gic.h \
  include/linux/compiler.h \
    $(wildcard include/config/sparse/rcu/pointer.h) \
    $(wildcard include/config/trace/branch/profiling.h) \
    $(wildcard include/config/profile/all/branches.h) \
    $(wildcard include/config/enable/must/check.h) \
    $(wildcard include/config/enable/warn/deprecated.h) \
  /home/willi/android/kernel/n1_jb/arch/arm/include/asm/unwind.h \
  arch/arm/kernel/entry-header.S \
    $(wildcard include/config/cpu/v6.h) \
    $(wildcard include/config/cpu/32v6k.h) \
  include/linux/init.h \
    $(wildcard include/config/modules.h) \
    $(wildcard include/config/hotplug.h) \
  include/linux/linkage.h \
  /home/willi/android/kernel/n1_jb/arch/arm/include/asm/linkage.h \
  /home/willi/android/kernel/n1_jb/arch/arm/include/asm/assembler.h \
    $(wildcard include/config/cpu/feroceon.h) \
    $(wildcard include/config/trace/irqflags.h) \
    $(wildcard include/config/smp.h) \
  /home/willi/android/kernel/n1_jb/arch/arm/include/asm/ptrace.h \
  /home/willi/android/kernel/n1_jb/arch/arm/include/asm/hwcap.h \
  /home/willi/android/kernel/n1_jb/arch/arm/include/asm/domain.h \
    $(wildcard include/config/io/36.h) \
    $(wildcard include/config/cpu/use/domains.h) \
  /home/willi/android/kernel/n1_jb/arch/arm/include/asm/asm-offsets.h \
  include/generated/asm-offsets.h \
  /home/willi/android/kernel/n1_jb/arch/arm/include/asm/errno.h \
  include/asm-generic/errno.h \
  include/asm-generic/errno-base.h \
  /home/willi/android/kernel/n1_jb/arch/arm/include/asm/thread_info.h \
    $(wildcard include/config/arm/thumbee.h) \
  /home/willi/android/kernel/n1_jb/arch/arm/include/asm/fpstate.h \
    $(wildcard include/config/vfpv3.h) \
    $(wildcard include/config/iwmmxt.h) \
  arch/arm/kernel/calls.S \

arch/arm/kernel/entry-common.o: $(deps_arch/arm/kernel/entry-common.o)

$(deps_arch/arm/kernel/entry-common.o):

# Rename this file to Android.mk to build in AOSP
ifeq ($(TARGET_BOOTLOADER_BOARD_NAME),i9103)

# Prevent conflict with CM9 kernel.mk build task
ifeq ($(TARGET_AUTO_KDIR),)

# Adaptation from Defy & Atrix repos config by Tanguy Pruvot for CM7
#
#####################################################################
#
# How to use:
#
# This makefile is invoked from kernel/Android.mk. You may build
# the kernel and modules by using the "kernel" target in repo root :
#  . build/envsetup.sh
#  choosecombo 1 1 i9103 eng
#  make kernel
#  make kernel_modules
#  make wlan_dhd
#  make kernel_install
#
######################################################################
#set -x

ROOTDIR := $(shell pwd -P)/

ifneq ($(strip $(TOPDIR)),)
    ROOTDIR := $(TOPDIR)
endif

ifeq ($(TARGET_PRODUCT),)
	TARGET_PRODUCT := generic
endif

ifeq ($(PRODUCT_OUT),)
	PRODUCT_OUT := out/target/product/$(TARGET_PRODUCT)
endif

ifeq ($(HOST_PREBUILT_TAG),)
	HOST_PREBUILT_TAG := linux-x86
endif

ifeq ($(TARGET_BUILD_VARIANT),)
	TARGET_BUILD_VARIANT := user
endif

ifeq ($(HOST_OUT_EXECUTABLES),)
	HOST_OUT_EXECUTABLES := out/host/$(HOST_PREBUILT_TAG)/bin
endif

ifeq ($(DEPMOD),)
	DEPMOD := $(shell which depmod 2> /dev/null || echo $(HOST_OUT_EXECUTABLES)/depmod$(HOST_EXECUTABLE_SUFFIX))
endif

###############################################################################
# Adjust Settings here if required, or in your BoardConfig.mk
###############################################################################

# Default board defconfig
ifeq ($(TARGET_KERNEL_CONFIG),)
    BLD_CONF=butter_n1_defconfig
else
    BLD_CONF=$(TARGET_KERNEL_CONFIG)
endif

ifeq ($(KERNEL_SRC_DIR),)
    KERNEL_SRC_DIR := $(ROOTDIR)kernel/samsung/n1
endif

###############################################################################

# gcc 4.6.x-google in jelly bean, doesnt work yet
# KERNEL_CROSS_COMPILE := $(ROOTDIR)prebuilts/gcc/linux-x86/arm/arm-linux-androideabi-4.6/bin/arm-linux-androideabi-
# MODULE_CROSS_COMPILE := $(ROOTDIR)prebuilt/$(HOST_PREBUILT_TAG)/toolchain/arm-eabi-4.4.3/bin/arm-eabi-

KERNEL_CROSS_COMPILE := $(ROOTDIR)prebuilt/$(HOST_PREBUILT_TAG)/toolchain/arm-eabi-4.4.3/bin/arm-eabi-
MODULE_CROSS_COMPILE := $(KERNEL_CROSS_COMPILE)

KERNEL_BUILD_DIR       := $(ROOTDIR)$(PRODUCT_OUT)/obj/kernel_intermediates/build
TARGET_PREBUILT_KERNEL ?= $(KERNEL_BUILD_DIR)/arch/arm/boot/zImage

KERNEL_WARN_FILTER := $(KERNEL_SRC_DIR)/scripts/gcc_warn_filter.cfg
KERNEL_ERR_LOG     := $(KERNEL_BUILD_DIR)/.kbld_err_log.txt
KMOD_ERR_LOG       := $(KERNEL_BUILD_DIR)/.kmod_err_log.txt
KERNEL_FFLAG       := #$(KERNEL_BUILD_DIR)/.filter_ok.txt

DEFCONFIGSRC                := ${KERNEL_SRC_DIR}/arch/arm/configs
LJAPDEFCONFIGSRC            := ${DEFCONFIGSRC}/ext_config
PRODUCT_SPECIFIC_DEFCONFIGS := $(DEFCONFIGSRC)/tegra_secure_os_defconfig

_TARGET_DEFCONFIG           := __ext_n1_defconfig
TARGET_DEFCONFIG            := $(DEFCONFIGSRC)/$(_TARGET_DEFCONFIG)

TARGET_MOD_INSTALL := $(PRODUCT_OUT)/modules

#WLAN_DHD_PATH := $(ROOTDIR)vendor/bcm/wlan/osrc/open-src/src/dhd/linux
#WLAN_DHD_PATH := $(ROOTDIR)hardware/broadcom/wlan/bcm4330/src/dhd/linux
#WLAN_DHD_PATH := $(KERNEL_SRC_DIR)/drivers/net/wireless/bcm4330
WLAN_DHD_PATH := $(KERNEL_SRC_DIR)/drivers/net/wireless/bcmdhd

# Disabled, this is made to force proper syntax commits (spaces etc)
# GIT_HOOKS_DIR := $(KERNEL_SRC_DIR)/.git/hooks
# inst_hook: $(GIT_HOOKS_DIR)/pre-commit $(GIT_HOOKS_DIR)/checkpatch.pl
inst_hook:

$(GIT_HOOKS_DIR)/pre-commit: $(KERNEL_SRC_DIR)/scripts/pre-commit
	@-cp -f $< $@
	@-chmod ugo+x $@

$(GIT_HOOKS_DIR)/checkpatch.pl: $(KERNEL_SRC_DIR)/scripts/checkpatch.pl
	@-cp -f $< $@
	@-chmod ugo+x $@

ifneq ($(BLD_CONF),)
    PRODUCT_SPECIFIC_DEFCONFIGS := $(DEFCONFIGSRC)/$(BLD_CONF)
endif

ifneq ($(PRODUCT),)
    PRODUCT_SPECIFIC_DEFCONFIGS += ${LJAPDEFCONFIGSRC}/product/${PRODUCT}.config
endif

# Turn on kernel engineering build as default when TARGET_BUILD_VARIANT is eng
# to disable it, add ENG_BLD=0 in build command

#Use 0 for stock rom, 1 for CM
ENG_BLD = 0

PRODUCT_SPECIFIC_DEFCONFIGS += ${LJAPDEFCONFIGSRC}/feature/networkfs.config
PRODUCT_SPECIFIC_DEFCONFIGS += ${LJAPDEFCONFIGSRC}/feature/ntfs.config
# PRODUCT_SPECIFIC_DEFCONFIGS += ${LJAPDEFCONFIGSRC}/feature/kexec.config
# PRODUCT_SPECIFIC_DEFCONFIGS += ${LJAPDEFCONFIGSRC}/feature/hid.config
# PRODUCT_SPECIFIC_DEFCONFIGS += ${LJAPDEFCONFIGSRC}/feature/zram.config
# PRODUCT_SPECIFIC_DEFCONFIGS += ${LJAPDEFCONFIGSRC}/feature/cdrom.config


ifeq ($(ENG_BLD),1)
    PRODUCT_SPECIFIC_DEFCONFIGS += ${LJAPDEFCONFIGSRC}/eng_bld.config
else
    PRODUCT_SPECIFIC_DEFCONFIGS += ${LJAPDEFCONFIGSRC}/user_bld.config
endif

#
# make kernel output directory structure
#---------------------------------------
$(KERNEL_BUILD_DIR):
	mkdir -p $(KERNEL_BUILD_DIR)

#
# make combined defconfig file
#---------------------------------------
$(TARGET_DEFCONFIG): FORCE $(PRODUCT_SPECIFIC_DEFCONFIGS)
	( perl -le 'print "# This file was automatically generated from:\n#\t" . join("\n#\t", @ARGV) . "\n"' $(PRODUCT_SPECIFIC_DEFCONFIGS) && cat $(PRODUCT_SPECIFIC_DEFCONFIGS) ) > $(TARGET_DEFCONFIG) || ( rm -f $@ && false )

.PHONY: FORCE
FORCE:

#
# make kernel configuration
#--------------------------
# We need to remove include/config if a make was run in kernel source tree
CONFIG_OUT := $(KERNEL_BUILD_DIR)/.config
kernel_config: $(CONFIG_OUT)
$(CONFIG_OUT): $(TARGET_DEFCONFIG) $(KERNEL_FFLAG) inst_hook | $(KERNEL_BUILD_DIR)
	@echo -e ${CL_PFX}"kernel_config"${CL_RST}
	@rm -rf $(KERNEL_SRC_DIR)/include/config
	@echo DEPMOD: $(DEPMOD)
	$(MAKE) -j1 -C $(KERNEL_SRC_DIR) ARCH=arm $(KERN_FLAGS) \
		CROSS_COMPILE=$(KERNEL_CROSS_COMPILE) \
		O=$(KERNEL_BUILD_DIR) \
		KBUILD_DEFCONFIG=$(_TARGET_DEFCONFIG) \
		defconfig modules_prepare

#
# clean if warn filter changed
#-----------------------------
$(KERNEL_FFLAG): $(KERNEL_WARN_FILTER) | $(KERNEL_BUILD_DIR)
ifeq ($(KERNEL_CHECK_GCC_WARNINGS),1)
	@echo "Gcc warning filter changed, clean build will be enforced\n"
	$(MAKE) -j1 -C $(KERNEL_SRC_DIR) ARCH=arm $(KERN_FLAGS) \
                 CROSS_COMPILE=$(KERNEL_CROSS_COMPILE) \
                 O=$(KERNEL_BUILD_DIR) clean
endif
	@touch $(KERNEL_FFLAG)

## fail building if there are unfiltered warnings
## bypass if TEST_MUDFLAP is not set
# $(1): input log file
ifneq ($(TEST_MUDFLAP),1)
define kernel-check-gcc-warnings
endef
else
define kernel-check-gcc-warnings
	@if [ -e $1 ]; then \
		(cat $1 | \
			$(KERNEL_SRC_DIR)/scripts/chk_gcc_warn.pl $(KERNEL_SRC_DIR) \
				$(KERNEL_WARN_FILTER)) \
			|| ((rm -f $1) && false); fi
endef
endif

#
# build kernel and internal kernel modules
# ========================================
# We need to check warning no matter if build passed, failed or interuptted
.PHONY: kernel
kernel: $(CONFIG_OUT)
	@echo -e ${CL_PFX}"kernel"${CL_RST}
	$(call kernel-check-gcc-warnings, $(KERNEL_ERR_LOG))
	$(MAKE) -C $(KERNEL_SRC_DIR) ARCH=arm $(KERN_FLAGS) \
		CROSS_COMPILE=$(KERNEL_CROSS_COMPILE) O=$(KERNEL_BUILD_DIR) \
		zImage 2>&1 | tee $(KERNEL_ERR_LOG)
	$(call kernel-check-gcc-warnings, $(KERNEL_ERR_LOG))
	cp $(KERNEL_BUILD_DIR)/arch/arm/boot/zImage $(PRODUCT_OUT)/kernel


LINUXVER=$(shell strings "$(KERNEL_BUILD_DIR)/.config"|grep 'Linux kernel version:'|head -n1|cut -f 5 -d ' ')

ifneq ($(TARGET_KERNEL_UTSRELEASE),)
    LINUXVER := $(TARGET_KERNEL_UTSRELEASE)
    MODULES_CFLAGS += -DUTS_RELEASE=\\\"$(TARGET_KERNEL_UTSRELEASE)\\\"
endif

#
# make kernel modules
#--------------------------
# We need to check warning no matter if build passed, failed or interuptted
.PHONY: kernel_modules
kernel_modules: $(CONFIG_OUT) | $(DEPMOD)
	@echo -e ${CL_PFX}"kernel_modules"${CL_RST}
	$(call kernel-check-gcc-warnings, $(KMOD_ERR_LOG))
	$(MAKE) -C $(KERNEL_SRC_DIR) ARCH=arm $(KERN_FLAGS) \
		CROSS_COMPILE=$(MODULE_CROSS_COMPILE) O=$(KERNEL_BUILD_DIR) \
		DEPMOD=$(DEPMOD) INSTALL_MOD_PATH=$(KERNEL_BUILD_DIR) \
		EXTRA_CFLAGS="$(MODULES_CFLAGS)" \
		modules 2>&1 | tee $(KMOD_ERR_LOG)
	$(call kernel-check-gcc-warnings, $(KMOD_ERR_LOG))

# To build modules (.ko) in specific folder
# It is useful for build specific module with extra options
# (e.g. TEST_DRV_CER)
kernel_dir:
	@echo -e ${CL_PFX}"kernel_dir"${CL_RST}
	$(MAKE) -C $(KERNEL_SRC_DIR) ARCH=arm $(KERN_FLAGS) \
		CROSS_COMPILE=$(KERNEL_CROSS_COMPILE) \
		O=$(KERNEL_BUILD_DIR) $(DIR_TO_BLD)

#NOTE: "strip" MUST be done for generated .ko files!!!
.PHONY: kernel_modules_install
kernel_modules_install: kernel_modules | $(DEPMOD)
	@echo -e ${CL_PFX}"kernel_modules_install"${CL_RST}
	$(MAKE) -C $(KERNEL_SRC_DIR) ARCH=arm $(KERN_FLAGS) \
		CROSS_COMPILE=$(KERNEL_CROSS_COMPILE) \
		O=$(KERNEL_BUILD_DIR) \
		EXTRA_CFLAGS="$(MODULES_CFLAGS)" \
		DEPMOD=$(DEPMOD) \
		INSTALL_MOD_PATH=$(KERNEL_BUILD_DIR) \
		modules_install

kernel_clean:
	@echo -e ${CL_PFX}"kernel_clean"${CL_RST}
	@rm -f $(PRODUCT_OUT)/kernel
	@rm -f $(PRODUCT_OUT)/boot.img
	@rm -f $(PRODUCT_OUT)/recovery.img
	$(MAKE) -C $(KERNEL_SRC_DIR) ARCH=arm $(KERN_FLAGS) \
		CROSS_COMPILE=$(KERNEL_CROSS_COMPILE) \
		O=$(KERNEL_BUILD_DIR) mrproper
	@rm -f $(KERNEL_BUILD_DIR)/.*.txt
	@rm -rf $(KERNEL_SRC_DIR)/include/config
	@rm -f $(TARGET_DEFCONFIG)
	@rm -f $(TARGET_MOD_INSTALL)/*.ko
	@rm -rf $(KERNEL_BUILD_DIR)

#
#----------------------------------------------------------------------------
# To use "make ext_modules" to buld external kernel modules
#----------------------------------------------------------------------------
# build external kernel modules
#
# NOTE: "strip" MUST be done for generated .ko files!!!
# =============================
.PHONY: ext_kernel_modules
ext_kernel_modules: wlan_dhd

ext_kernel_modules_clean: wlan_dhd_clean

# wlan driver module
#-------------------
#API_MAKE = env -u MAKECMDGOALS make PREFIX=$(KERNEL_BUILD_DIR) \

API_MAKE = make PREFIX=$(KERNEL_BUILD_DIR) \
		ARCH=arm \
		CROSS=$(KERNEL_CROSS_COMPILE) \
		CROSS_COMPILE=$(MODULE_CROSS_COMPILE) \
		KERNEL_DIR=$(KERNEL_BUILD_DIR) \
		KDIR=$(KERNEL_BUILD_DIR) \
		PROJROOT=$(PROJROOT) \
		LINUXDIR=$(KERNEL_SRC_DIR) \
		LINUXVER=$(LINUXVER) \
		CUSTOM_FLAGS="$(MODULES_CFLAGS)"

#.PHONY: wlan_dhd
wlan_dhd: $(CONFIG_OUT)
	@echo -e ${CL_PFX}"wlan_dhd"${CL_RST}
	$(API_MAKE) -C $(WLAN_DHD_PATH)
	@mkdir -p $(TARGET_MOD_INSTALL)
	cp $(WLAN_DHD_PATH)/dhd.ko $(TARGET_MOD_INSTALL)
	@$(API_MAKE) -C $(WLAN_DHD_PATH) clean

wlan_dhd_clean:
	$(API_MAKE) -C $(WLAN_DHD_PATH) clean

#----------------------------------------------------------------------------

device_modules: $(CONFIG_OUT)
	$(API_MAKE) -C $(TARGET_KERNEL_MODULES_EXT) modules
	mkdir -p $(TARGET_MOD_INSTALL)
	find $(TARGET_KERNEL_MODULES_EXT)/ -name "*.ko" -exec mv {} \
		$(TARGET_MOD_INSTALL) \; || true

device_modules_clean:
	$(API_MAKE) -C $(TARGET_KERNEL_MODULES_EXT) clean

#
# install kernel modules into system image
#-------------------------------------------------
kernel_install:
	@echo -e ${CL_PFX}"Install kernel and modules..."${CL_RST}
	mkdir -p $(TARGET_MOD_INSTALL)
	cp $(KERNEL_BUILD_DIR)/arch/arm/boot/zImage $(PRODUCT_OUT)/kernel
	find $(KERNEL_BUILD_DIR) -name "*.ko" -exec cp -f {} $(TARGET_MOD_INSTALL)/ \;
	find $(TARGET_MOD_INSTALL)/* -maxdepth 0 -type d -exec rm -r {} \;
	-find $(TARGET_MOD_INSTALL) -name "*.ko" -exec $(KERNEL_CROSS_COMPILE)strip --strip-debug {} \;
	# add important kernel modules in bootimage, to always have them
	mkdir -p $(PRODUCT_OUT)/root/lib/modules
	cp $(TARGET_MOD_INSTALL)/*.ko $(PRODUCT_OUT)/root/lib/modules/
	touch $(PRODUCT_OUT)/kernel_post_install

#-------------------------------------------------
ifeq ($(TARGET_BUILD_KERNEL),true)
.PHONY: $(TARGET_PREBUILT_KERNEL)

$(TARGET_PREBUILT_KERNEL): kernel_config kernel kernel_modules_install wlan_dhd kernel_install

# To update the device tree (kernel and modules)
#-------------------------------------------------
device/samsung/i9103/kernel: $(TARGET_PREBUILT_KERNEL)
	cp $(KERNEL_BUILD_DIR)/arch/arm/boot/zImage $(ANDROID_BUILD_TOP)/device/samsung/i9103/kernel
	rm -f $(ANDROID_BUILD_TOP)/device/samsung/i9103/modules/*.ko
	cp $(TARGET_MOD_INSTALL)/*.ko $(ANDROID_BUILD_TOP)/device/samsung/i9103/modules/

$(INSTALLED_KERNEL_TARGET): $(TARGET_PREBUILT_KERNEL) | $(ACP)
	$(transform-prebuilt-to-target)
endif

ROOTDIR :=

endif # cm9 kernel build system not used
endif # device filter

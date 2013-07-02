/*
 * Tegra booloader atag parameters
 *
 * This program is free software; you can redistribute it and/or modify
 * it under the terms of the GNU General Public License version 2 as
 * published by the Free Software Foundation.
 */

#ifndef __TEGRA_BOOTARGS_H_
#define __TEGRA_BOOTARGS_H_

/**
 * The maximum number of memory handles that may be preserved across the
 * bootloader-to-OS transition.  @see NvRmBootArg_PreservedMemHandle.
 */
#define NV_BOOTARGS_MAX_PRESERVED_MEMHANDLES 3

/* NVidia bootloader tags */
#define ATAG_NVIDIA 0x41000801

#define ATAG_NVIDIA_RM                  0x1
#define ATAG_NVIDIA_DISPLAY             0x2
#define ATAG_NVIDIA_FRAMEBUFFER         0x3
#define ATAG_NVIDIA_CHIPSHMOO           0x4
#define ATAG_NVIDIA_CHIPSHMOOPHYS       0x5

#define ATAG_NVIDIA_PRESERVED_MEM_0     0x10000
#define ATAG_NVIDIA_PRESERVED_MEM_N     2
#define ATAG_NVIDIA_FORCE_32            0x7fffffff

/* accessor for various boot arg classes, see NvOsBootArg* */
typedef enum
{
	NvBootArgKey_Rm = 0x1,
	NvBootArgKey_Display,
	NvBootArgKey_Framebuffer,
	NvBootArgKey_ChipShmoo,
	NvBootArgKey_ChipShmooPhys,
	NvBootArgKey_Carveout,
	NvBootArgKey_WarmBoot,
	NvBootArgKey_PreservedMemHandle_0 = 0x10000,
	NvBootArgKey_PreservedMemHandle_Num =
		(NvBootArgKey_PreservedMemHandle_0 +
		 NV_BOOTARGS_MAX_PRESERVED_MEMHANDLES),

	NvBootArgKey_Force32 = 0x7FFFFFFF,

} NvBootArgKey;

typedef struct NvBootArgsRmRec
{
	u32 reserved;

} NvBootArgsRm;

typedef struct NvBootArgsCarveoutRec
{
	void* base;
	u32 size;

} NvBootArgsCarveout;

typedef struct NvBootArgsWarmbootRec
{
	u32 MemHandleKey;

} NvBootArgsWarmboot;

typedef struct NvBootArgsPreservedMemHandleRec
{
	u32 Address;
	u32 Size;

} NvBootArgsPreservedMemHandle;

typedef struct NvBootArgsDisplayRec
{
	u32 Controller;
	u32 DisplayDeviceIndex;
	bool bEnabled;

} NvBootArgsDisplay;

typedef struct NvBootArgsFramebufferRec
{
	u32 MemHandleKey;

	u32 Size;
	u32 ColorFormat;
	u16 Width;
	u16 Height;
	u16 Pitch;
	u8  SurfaceLayout;
	u8  NumSurfaces;

	u32 Flags;

	/*
	 * use a tearing effect signal in combination with a trigger
	 * from the display software to generate a frame of pixels
	 * for the display device.
	 */
	#define NVBOOTARG_FB_FLAG_TEARING_EFFECT (0x1)

} NvBootArgsFramebuffer;

typedef struct NvBootArgsChipShmooRec
{
	u32 MemHandleKey;
	u32 CoreShmooVoltagesListOffset;
	u32 CoreShmooVoltagesListSize;
	u32 CoreScaledLimitsListOffset;
	u32 CoreScaledLimitsListSize;
	u32 OscDoublerListOffset;
	u32 OscDoublerListSize;
	u32 SKUedLimitsOffset;
	u32 SKUedLimitsSize;
	u32 CpuShmooVoltagesListOffset;
	u32 CpuShmooVoltagesListSize;
	u32 CpuScaledLimitsOffset;
	u32 CpuScaledLimitsSize;
	u16 CoreCorner;
	u16 CpuCorner;
	u32 Dqsib;
	u32 SvopLowVoltage;
	u32 SvopLowSetting;
	u32 SvopHighSetting;

} NvBootArgsChipShmoo;

typedef struct NvBootArgsChipShmooPhysRec
{
	u32 PhysShmooPtr;
	u32 Size;

} NvBootArgsChipShmooPhys;

#define NVBOOTARG_NUM_PRESERVED_HANDLES (NvBootArgKey_PreservedMemHandle_Num - \
					NvBootArgKey_PreservedMemHandle_0)
typedef struct NvBootArgsRec
{
	NvBootArgsRm RmArgs;
	NvBootArgsDisplay DisplayArgs;
	NvBootArgsFramebuffer FramebufferArgs;
	NvBootArgsChipShmoo ChipShmooArgs;
	NvBootArgsChipShmooPhys ChipShmooPhysArgs;
	NvBootArgsWarmboot WarmbootArgs;
	NvBootArgsPreservedMemHandle MemHandleArgs[NVBOOTARG_NUM_PRESERVED_HANDLES];

} NvBootArgs;

#endif /* __TEGRA_BOOTARGS_H_ */


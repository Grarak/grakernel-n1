/*
 * arch/arm/mach-tegra/board-n1-panel.c
 *
 * Copyright (c) 2010-2011, NVIDIA Corporation.
 *
 * This program is free software; you can redistribute it and/or modify
 * it under the terms of the GNU General Public License as published by
 * the Free Software Foundation; either version 2 of the License, or
 * (at your option) any later version.
 *
 * This program is distributed in the hope that it will be useful, but WITHOUT
 * ANY WARRANTY; without even the implied warranty of MERCHANTABILITY or
 * FITNESS FOR A PARTICULAR PURPOSE.  See the GNU General Public License for
 * more details.
 *
 * You should have received a copy of the GNU General Public License along
 * with this program; if not, write to the Free Software Foundation, Inc.,
 * 51 Franklin Street, Fifth Floor, Boston, MA  02110-1301, USA.
 */

#include <linux/delay.h>
#include <linux/gpio.h>
#include <linux/regulator/consumer.h>
#include <linux/resource.h>
#include <asm/mach-types.h>
#include <linux/platform_device.h>
#include <linux/earlysuspend.h>
#include <linux/kernel.h>
#include <linux/pwm_backlight.h>
#include <linux/spi/spi.h>
#include <linux/nvhost.h>
#include <mach/nvmap.h>
#include <mach/irqs.h>
#include <mach/iomap.h>
#include <mach/dc.h>
#include <mach/fb.h>

#include "devices.h"
#include "gpio-names.h"
#include "board.h"

static struct resource n1_disp1_resources[] = {
	{
		.name	= "irq",
		.start	= INT_DISPLAY_GENERAL,
		.end	= INT_DISPLAY_GENERAL,
		.flags	= IORESOURCE_IRQ,
	},
	{
		.name	= "regs",
		.start	= TEGRA_DISPLAY_BASE,
		.end	= TEGRA_DISPLAY_BASE + TEGRA_DISPLAY_SIZE-1,
		.flags	= IORESOURCE_MEM,
	},
	{
		.name	= "fbmem",
		.flags	= IORESOURCE_MEM,
	},
};

static struct tegra_dc_mode n1_panel_modes[] = {
	{
		.flags = TEGRA_DC_MODE_FLAG_NEG_V_SYNC | TEGRA_DC_MODE_FLAG_NEG_H_SYNC,
		.pclk = 24000000,
		//.pclk = 27000000,
		.h_ref_to_sync = 0,//.h_ref_to_sync = 11,
		.v_ref_to_sync = 1,//.v_ref_to_sync = 1,
		.h_sync_width = 10,
		.v_sync_width = 2,
		.h_back_porch = 20,
		.v_back_porch = 4,//.v_back_porch = 6,
		.h_active = 480,
		.v_active = 800,
		.h_front_porch = 10,
		.v_front_porch = 3,//.v_front_porch = 4,
	},
};

static struct tegra_dc_out_pin n1_dc_out_pins[] = {
	{
		.name	= TEGRA_DC_OUT_PIN_DATA_ENABLE,
		.pol	= TEGRA_DC_OUT_PIN_POL_HIGH,
	},
	{
		.name	= TEGRA_DC_OUT_PIN_H_SYNC,
		.pol	= TEGRA_DC_OUT_PIN_POL_LOW,
	},
	{
		.name	= TEGRA_DC_OUT_PIN_V_SYNC,
		.pol	= TEGRA_DC_OUT_PIN_POL_LOW,
	},
	{
		.name	= TEGRA_DC_OUT_PIN_PIXEL_CLOCK,
		.pol	= TEGRA_DC_OUT_PIN_POL_LOW,
	},
};


static u8 n1_dc_out_pin_sel_config[] = {
	TEGRA_PIN_OUT_CONFIG_SEL_LM1_PM1,
};

static struct tegra_dc_out n1_disp1_out = {
	.type		= TEGRA_DC_OUT_RGB,

	.align		= TEGRA_DC_ALIGN_MSB,
	.order		= TEGRA_DC_ORDER_RED_BLUE,

	.height		= 91, /* mm */
	.width		= 55, /* mm */

	.modes	 	= n1_panel_modes,
	.n_modes 	= ARRAY_SIZE(n1_panel_modes),

	.out_pins	= n1_dc_out_pins,
	.n_out_pins	= ARRAY_SIZE(n1_dc_out_pins),

	.out_sel_configs   = n1_dc_out_pin_sel_config,
	.n_out_sel_configs = ARRAY_SIZE(n1_dc_out_pin_sel_config),
};

static struct tegra_fb_data n1_fb_data = {
	.win		= 0,
	.xres		= 480,
	.yres		= 800,
	.bits_per_pixel	= 32,
	.flags		= TEGRA_FB_FLIP_ON_PROBE,
};

static struct tegra_dc_platform_data n1_disp1_pdata = {
	.flags		= TEGRA_DC_FLAG_ENABLED,
	.default_out	= &n1_disp1_out,
	.fb		= &n1_fb_data,
};

static struct nvhost_device n1_disp1_device = {
	.name		= "tegradc",
	.id		= 0,
	.resource	= n1_disp1_resources,
	.num_resources	= ARRAY_SIZE(n1_disp1_resources),
	.dev = {
		.platform_data = &n1_disp1_pdata,
	},
};

static struct nvmap_platform_carveout n1_carveouts[] = {
	[0] = NVMAP_HEAP_CARVEOUT_IRAM_INIT,
	[1] = {
		.name		= "generic-0",
		.usage_mask	= NVMAP_HEAP_CARVEOUT_GENERIC,
		.base		= 0x18C00000,
		.size		= SZ_128M - 0xC00000,
		.buddy_size	= SZ_32K,
	},
};

static struct nvmap_platform_data n1_nvmap_data = {
	.carveouts	= n1_carveouts,
	.nr_carveouts	= ARRAY_SIZE(n1_carveouts),
};

static struct platform_device n1_nvmap_device = {
	.name	= "tegra-nvmap",
	.id	= -1,
	.dev	= {
		.platform_data = &n1_nvmap_data,
	},
};
static struct platform_device n1_device_cmc623 = {
	.name	= "sec_cmc623",
	.id	= -1,
};
static struct platform_device n1_backlight_device = {
	.name	= "cmc623_pwm_bl",
	.id	= -1,
};
static struct spi_board_info n1_spi_device2[] = {
	{
		.modalias = "panel_n1_spi",
		.bus_num = 2,
		.chip_select = 2,
		.max_speed_hz = 1000000,
		.mode = SPI_MODE_3,
	},
};

static struct platform_device *n1_gfx_devices[] __initdata = {
	&n1_nvmap_device,
	&tegra_spi_device3,
	&n1_backlight_device,
	&n1_device_cmc623,
};

#ifdef CONFIG_HAS_EARLYSUSPEND
/* put early_suspend/late_resume handlers here for the display in order
 * to keep the code out of the display driver, keeping it closer to upstream
 */
struct early_suspend n1_panel_early_suspender;

static void n1_panel_early_suspend(struct early_suspend *h)
{
	printk(KERN_INFO "\n ************ %s : %d\n", __func__, __LINE__);

	n1_panel_disable();

	/* power down LCD, add use a blank screen for HDMI */
	if (num_registered_fb > 0)
		fb_blank(registered_fb[0], FB_BLANK_POWERDOWN);
	if (num_registered_fb > 1)
		fb_blank(registered_fb[1], FB_BLANK_NORMAL);

#ifdef CONFIG_TEGRA_CONSERVATIVE_GOV_ON_EARLYSUPSEND
	cpufreq_save_default_governor();
	cpufreq_set_conservative_governor();
        cpufreq_set_conservative_governor_param("up_threshold",
			SET_CONSERVATIVE_GOVERNOR_UP_THRESHOLD);

	cpufreq_set_conservative_governor_param("down_threshold",
			SET_CONSERVATIVE_GOVERNOR_DOWN_THRESHOLD);

	cpufreq_set_conservative_governor_param("freq_step",
		SET_CONSERVATIVE_GOVERNOR_FREQ_STEP);

#if 0 /* ardatdat */
	cpufreq_store_default_gov();
	if (cpufreq_change_gov(cpufreq_conservative_gov))
		 pr_err("Early_suspend: Error changing governor to %s\n",
			cpufreq_conservative_gov);
#endif

#endif

	cmc623_suspend(NULL);
}

static void n1_panel_late_resume(struct early_suspend *h)
{
	unsigned i;
	printk(KERN_INFO "-- start of  %s : %d\n", __func__, __LINE__);

#ifdef CONFIG_TEGRA_CONSERVATIVE_GOV_ON_EARLYSUPSEND
	cpufreq_restore_default_governor();

#if 0 /* ardatdat */
	if (cpufreq_restore_default_gov())
		pr_err("Early_suspend: Unable to restore governor\n");
#endif

#endif
	for (i = 0; i < num_registered_fb; i++)
		fb_blank(registered_fb[i], FB_BLANK_UNBLANK);

	cmc623_resume(NULL);
	n1_panel_pre_enable();
	printk(KERN_INFO "-- end of  %s : %d\n", __func__, __LINE__);
}
#endif

int __init n1_panel_init(void)
{
	int err;
	struct resource __maybe_unused *res;

#ifdef CONFIG_HAS_EARLYSUSPEND
	n1_panel_early_suspender.suspend = n1_panel_early_suspend;
	n1_panel_early_suspender.resume = n1_panel_late_resume;
	n1_panel_early_suspender.level = EARLY_SUSPEND_LEVEL_DISABLE_FB;
	register_early_suspend(&n1_panel_early_suspender);
#endif
	n1_carveouts[1].base = tegra_carveout_start;
	n1_carveouts[1].size = tegra_carveout_size;

#ifdef CONFIG_TEGRA_GRHOST
	err = nvhost_device_register(&tegra_grhost_device);
	if (err)
		return err;
#endif

	err = platform_add_devices(n1_gfx_devices,
				   ARRAY_SIZE(n1_gfx_devices));

#if defined(CONFIG_TEGRA_GRHOST) && defined(CONFIG_TEGRA_DC)
	res = nvhost_get_resource_byname(&n1_disp1_device,
					 IORESOURCE_MEM, "fbmem");
	res->start = tegra_fb_start;
	res->end = tegra_fb_start + tegra_fb_size - 1;
#endif

	/* Copy the bootloader fb to the fb. */
	tegra_move_framebuffer(tegra_fb_start, tegra_bootloader_fb_start,
		min(tegra_fb_size, tegra_bootloader_fb_size));

#if defined(CONFIG_TEGRA_GRHOST) && defined(CONFIG_TEGRA_DC)
	spi_register_board_info(n1_spi_device2, ARRAY_SIZE(n1_spi_device2));

	if (!err)
		err = nvhost_device_register(&n1_disp1_device);

#endif

	return err;
}

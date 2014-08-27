/*
 * Author: Willi Ye <williye97@gmail.com>
 *
 * Copyright 2014 Willi Ye
 *
 * This software is licensed under the terms of the GNU General Public
 * License version 2, as published by the Free Software Foundation, and
 * may be copied, distributed, and modified under those terms.
 *
 * This program is distributed in the hope that it will be useful,
 * but WITHOUT ANY WARRANTY; without even the implied warranty of
 * MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the
 * GNU General Public License for more details.
 *
 */

#include <linux/kobject.h>
#include <linux/sysfs.h>
#include <linux/battery_control.h>

/*
 * 0 - 0MA
 * 1 - 2MA
 * 2 - 100MA
 * 3 - 200MA
 * 4 - 300MA
 * 5 - 400MA
 * 6 - 500MA
 * 7 - 600MA
 */

static int getNumber(int voltage) {
	
	int ret;

	switch (voltage) {
		default:
		case 0:
			ret = 0;
			break;
		case 2:
			ret = 1;
			break;
		case 100:
			ret = 2;
			break;
		case 200:
			ret = 3;
			break;
		case 300:
			ret = 4;
			break;
		case 400:
			ret = 5;
			break;
		case 500:
			ret = 6;
			break;
		case 600:
			ret = 7;
			break;
	}
	return ret;
}

static int getVoltage(int number) {

	int ret;

	switch (number) {
		default:
		case 0:
			ret = 0;
			break;
		case 1:
			ret = 2;
			break;
		case 2:
			ret = 100;
			break;
		case 3:
			ret = 200;
			break;
		case 4:
			ret = 300;
			break;
		case 5:
			ret = 400;
			break;
		case 6:
			ret = 500;
			break;
		case 7:
			ret = 600;
			break;
	}
	return ret;
}

/*
 * AC
 */
static ssize_t ac_limit_show(struct kobject *kobj, struct kobj_attribute *attr,
				char *buf) {
	return sprintf(buf, "%d\n", getNumber(ac_limit));
}

static ssize_t ac_limit_store(struct kobject *kobj, struct kobj_attribute *attr,
				const char *buf, size_t count) {

	int value;

	sscanf(buf, "%d", &value);
	if (value > -1 && value < 11) {
		pr_info("set voltage of ac to %d\n", getVoltage(value));
		ac_limit = getVoltage(value);
	}

	return count;
}

/*
 * Dock
 */
static ssize_t dock_limit_show(struct kobject *kobj, struct kobj_attribute *attr,
				char *buf) {
	return sprintf(buf, "%d\n", getNumber(dock_limit));
}

static ssize_t dock_limit_store(struct kobject *kobj, struct kobj_attribute *attr,
				const char *buf, size_t count) {

	int value;

	sscanf(buf, "%d", &value);
	if (value > -1 && value < 11) {
		pr_info("set voltage of dock to %d\n", getVoltage(value));
		dock_limit = getVoltage(value);
	}

	return count;
}

/*
 * USB
 */
static ssize_t usb_limit_show(struct kobject *kobj, struct kobj_attribute *attr,
				char *buf) {
	return sprintf(buf, "%d\n", getNumber(usb_limit));
}

static ssize_t usb_limit_store(struct kobject *kobj, struct kobj_attribute *attr,
				const char *buf, size_t count) {

	int value;

	sscanf(buf, "%d", &value);
	if (value > -1 && value < 11) {
		pr_info("set voltage of usb to %d\n", getVoltage(value));
		usb_limit = getVoltage(value);
	}

	return count;
}

static struct kobj_attribute ac_attribute = __ATTR(ac, 0666, ac_limit_show, ac_limit_store);
static struct kobj_attribute dock_attribute = __ATTR(dock, 0666, dock_limit_show, dock_limit_store);
static struct kobj_attribute usb_attribute = __ATTR(usb, 0666, usb_limit_show, usb_limit_store);

static struct attribute *battery_control_attrs[] = {
	&ac_attribute.attr,
	&dock_attribute.attr,
	&usb_attribute.attr,
	NULL,
};

static struct attribute_group battery_control_attr_group = {
	.attrs = battery_control_attrs,
};

static struct kobject *battery_control_kobj;

int battery_control_init(void)
{
	int ret;

	battery_control_kobj =
		kobject_create_and_add("battery_control", kernel_kobj);

	if (!battery_control_kobj) {
		pr_err("%s battery_control_kobj create failed!\n", __FUNCTION__);
		return -ENOMEM;
        }

	ret = sysfs_create_group(battery_control_kobj, &battery_control_attr_group);

	if (ret) {
		pr_info("%s sysfs create failed!\n", __FUNCTION__);
		kobject_put(battery_control_kobj);
	}

	return ret;
}

void battery_control_exit(void) {
	if (battery_control_kobj != NULL)
		kobject_put(battery_control_kobj);
}

module_init(battery_control_init);
module_exit(battery_control_exit);

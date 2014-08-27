#!/sbin/busybox sh

mount -o remount,rw /system
mount -t rootfs -o remount,rw rootfs

mount -t tmpfs tmpfs /system/lib/modules
ln -s /lib/modules/* /system/lib/modules/

echo 2 > /sys/devices/system/cpu/sched_mc_power_savings

echo 6 > /sys/class/misc/voodoo_sound/headphone_eq_b1_gain
echo 9 > /sys/class/misc/voodoo_sound/headphone_eq_b2_gain
echo 5 > /sys/class/misc/voodoo_sound/headphone_eq_b3_gain
echo 9 > /sys/class/misc/voodoo_sound/headphone_eq_b4_gain
echo 8 > /sys/class/misc/voodoo_sound/headphone_eq_b5_gain
echo 0 > /sys/class/misc/voodoo_sound/digital_gain
echo 14 > /sys/class/misc/voodoo_sound/stereo_expansion_gain

echo 0 > /sys/class/misc/fsynccontrol/fsync_enabled
echo 1 > /sys/kernel/mm/ksm/run

for i in /sys/block/*/queue/add_random;do echo 0 > $i;done

[ -d /system/etc/init.d ] && /sbin/busybox run-parts /system/etc/init.d

ln -s /res/synapse/uci /sbin/uci
/sbin/uci

echo interactive > /sys/devices/system/cpu/cpu0/cpufreq/scaling_governor

mount -t rootfs -o remount,ro rootfs
mount -o remount,ro /system

#!/sbin/busybox sh

mount -o remount,rw /system
/sbin/busybox mount -t rootfs -o remount,rw rootfs
mount -t tmpfs tmpfs /system/lib/modules
ln -s /lib/modules/* /system/lib/modules/
/sbin/busybox mount -t rootfs -o remount,ro rootfs
mount -o remount,ro /system

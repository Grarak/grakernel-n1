#!/sbin/busybox sh

mount -o remount,rw /system
/sbin/busybox mount -t rootfs -o remount,rw rootfs

mount -t tmpfs tmpfs /system/lib/modules
ln -s /lib/modules/* /system/lib/modules/

for i in /sys/block/*/queue/add_random;do echo 0 > $i;done

[ -d /system/app/Synapse.apk ] || mv -f /res/synapse/Synapse.apk /system/app/ && chmod 644 /system/app/Synapse.apk

ln -s /res/synapse/uci /sbin/uci
/sbin/uci

mkdir -p /mnt/ntfs
chmod 777 /mnt/ntfs
mount -o mode=0777,gid=1000 -t tmpfs tmpfs /mnt/ntfs

if [ -d /system/etc/init.d ]; then
	/sbin/busybox run-parts /system/etc/init.d
fi;

/sbin/busybox mount -t rootfs -o remount,ro rootfs
mount -o remount,ro /system

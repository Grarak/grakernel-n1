#!/sbin/sh

# clean cache
rm -rf /data/dalvik-cache
rm -rf /cache/dalvik-cache

# clean modules
rm -rf /system/modules
rm -rf /system/lib/modules

# CM Default
rm -f $INITD_DIR/00banner
rm -f $INITD_DIR/90userinit

# clean kernel setting app shared_prefs
rm -rf /data/data/com.liquid.control/shared_prefs

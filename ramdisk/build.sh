#!/bin/bash

rm -rf kernel.zip
find -name "*~" -exec rm -rf {} \;
find -name ".DS_Store" -exec rm -rf {} \;

cd out
zip -r kernel.zip *
mv -v kernel.zip ../
cd ..
adb push kernel.zip /sdcard/.

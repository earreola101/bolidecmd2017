#!/bin/sh
# #######################################################
# Copyright (c) 2017 bdSound s.r.l. All Rights Reserved.
# Company: bdSound s.r.l.
# Version 1.0
# ######################################################## 


set -x
set -e

mkdir -p ./Build/tmp
bootgen -image ./boot_mic_pod.bif -arch zynq -o ./Build/tmp/jtag_mic_pod.bin -packagename 7x007s -w
../../Utility/FWgenerate/FWgenerate 217 216 0 0 ./Build/tmp/jtag_mic_pod.bin
cp ./Build/tmp/jtag_mic_pod.bin.217_216_0_0.md5 ./Build/tmp/boot_mic_pod.bin
cd ./Build/tmp
zip ./boot_mic_pod.bin.217_216_0_0.md5.zip boot_mic_pod.bin
mv boot_mic_pod.bin.217_216_0_0.md5.zip ../
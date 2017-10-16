#!/bin/sh

set -x
set -e

cd ZynqPL/
vivado -mode batch -source ./00_create_mic_pod.tcl
vivado -mode batch -source ./00_build_mic_pod.tcl
xsdk -batch -source 00_fsbl_app_mic_pod.tcl 
cd ..
./gen_boot_mic_pod.sh
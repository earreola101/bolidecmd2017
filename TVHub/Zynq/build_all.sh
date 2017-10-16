#!/bin/sh

set -x
set -e

cd ZynqPL
vivado -mode batch -source ./00_create_tv_hub.tcl
vivado -mode batch -source ./00_build_tv_hub.tcl
xsdk -batch -source 00_fsbl_tv_hub.tcl 

cd ../ZynqARM/Linux
./clean_tv_hub.sh
./build_and_package_tv_hub.sh

cd ../Application
make clean
make

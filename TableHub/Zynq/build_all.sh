#!/bin/sh

set -x
set -e

cd ZynqPL
vivado -mode batch -source ./00_create_table_hub.tcl
vivado -mode batch -source ./00_build_table_hub.tcl
xsdk -batch -source 00_fsbl_table_hub.tcl 

cd ../ZynqARM/Linux
./clean_table_hub.sh
./build_and_package_table_hub.sh

cd ../Application
make clean
make

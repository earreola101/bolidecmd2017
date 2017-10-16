#!/bin/sh

set -x
set -e

cd ZynqPL/
vivado -mode batch -source ./00_create_splitter.tcl
vivado -mode batch -source ./00_build_splitter.tcl
xsdk -batch -source 00_fsbl_app_splitter.tcl
cd ..
./gen_splitter_update.sh
#!/bin/sh
# #######################################################
# Copyright (c) 2017 bdSound s.r.l. All Rights Reserved.
# Company: bdSound s.r.l.
# Version 1.0
# ######################################################## 

./01_create_vivado_proj.sh
./03_build_vivado_proj.sh
./04_export_fsbl.sh
./06_gen_boot_micpod.sh
rm *.dmp
rm *.log
rm *.jou
cd ..
rm *.jou
rm *.log
rm *.str

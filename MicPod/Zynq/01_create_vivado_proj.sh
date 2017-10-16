#!/bin/sh
# #######################################################
# Copyright (c) 2017 bdSound s.r.l. All Rights Reserved.
# Company: bdSound s.r.l.
# Version 1.0
# ######################################################## 

cd ZynqPL
vivado -mode batch -source ./00_create_mic_pod.tcl
rm *.dmp
rm *.log
rm *.jou
cd ..
rm *.jou
rm *.log
rm *.str

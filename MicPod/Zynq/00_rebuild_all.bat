call C:\Xilinx\Vivado\2016.4\.settings64-Vivado.bat
call cd ZynqPL
call vivado -mode batch -source ./00_create_mic_pod.tcl
call vivado -mode batch -source ./00_build_mic_pod.tcl
call C:\Xilinx\SDK\2016.4\.settings64-Software_Development_Kit__SDK_.bat
xsdk -batch -source 00_fsbl_app_mic_pod.tcl 
pause
call del *.dmp
call del *.log
call del *.jou
call cd ..
call del *.jou
call del *.log
call del *.str

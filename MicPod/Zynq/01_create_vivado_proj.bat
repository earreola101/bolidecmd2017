call C:\Xilinx\Vivado\2016.4\.settings64-Vivado.bat
call cd ZynqPL
call vivado -mode batch -source ./00_create_mic_pod.tcl
pause
call del *.dmp
call del *.log
call del *.jou
call cd ..
call del *.jou
call del *.log
call del *.str

REM ################################################################################
REM # Vivado 2019.1 batch file to create the TCLink lpGBT10G Example design
REM # This batch file uses the default Xilinx installation path.
REM ################################################################################
call C:\Xilinx\Vivado\2019.1\\.\\bin\\vivado.bat -mode batch -source tclink_vcu118.tcl

del *.jou
del *.log

pause
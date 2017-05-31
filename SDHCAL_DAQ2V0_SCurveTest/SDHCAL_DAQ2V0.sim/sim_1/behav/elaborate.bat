@echo off
set xv_path=D:\\Xilinx\\Vivado\\2016.3\\bin
call %xv_path%/xelab  -wto adce4a2d0d5c4005b4f70bb8dab1a3ee -m64 --debug typical --relax --mt 2 -L xil_defaultlib -L fifo_generator_v13_1_2 -L unisims_ver -L unimacro_ver -L secureip -L xpm --snapshot FPGA_TOP_behav xil_defaultlib.FPGA_TOP xil_defaultlib.glbl -log elaborate.log
if "%errorlevel%"=="0" goto SUCCESS
if "%errorlevel%"=="1" goto END
:END
exit 1
:SUCCESS
exit 0

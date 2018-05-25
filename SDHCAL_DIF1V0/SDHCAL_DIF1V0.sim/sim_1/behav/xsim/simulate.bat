@echo off
REM ****************************************************************************
REM Vivado (TM) v2018.1 (64-bit)
REM
REM Filename    : simulate.bat
REM Simulator   : Xilinx Vivado Simulator
REM Description : Script for simulating the design by launching the simulator
REM
REM Generated by Vivado on Fri May 25 18:59:40 +0800 2018
REM SW Build 2188600 on Wed Apr  4 18:40:38 MDT 2018
REM
REM Copyright 1986-2018 Xilinx, Inc. All Rights Reserved.
REM
REM usage: simulate.bat
REM
REM ****************************************************************************
call xsim HoldGenerate_tb_behav -key {Behavioral:sim_1:Functional:HoldGenerate_tb} -tclbatch HoldGenerate_tb.tcl -view D:/MyProject/SDHCAL_DAQ/SDHCAL_DIF1V0/SDHCAL_DIF1V0.sim/Wave/SlowControlAndReadScope_tb_behav.wcfg -log simulate.log
if "%errorlevel%"=="0" goto SUCCESS
if "%errorlevel%"=="1" goto END
:END
exit 1
:SUCCESS
exit 0

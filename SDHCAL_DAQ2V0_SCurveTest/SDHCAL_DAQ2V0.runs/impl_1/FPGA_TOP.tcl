proc start_step { step } {
  set stopFile ".stop.rst"
  if {[file isfile .stop.rst]} {
    puts ""
    puts "*** Halting run - EA reset detected ***"
    puts ""
    puts ""
    return -code error
  }
  set beginFile ".$step.begin.rst"
  set platform "$::tcl_platform(platform)"
  set user "$::tcl_platform(user)"
  set pid [pid]
  set host ""
  if { [string equal $platform unix] } {
    if { [info exist ::env(HOSTNAME)] } {
      set host $::env(HOSTNAME)
    }
  } else {
    if { [info exist ::env(COMPUTERNAME)] } {
      set host $::env(COMPUTERNAME)
    }
  }
  set ch [open $beginFile w]
  puts $ch "<?xml version=\"1.0\"?>"
  puts $ch "<ProcessHandle Version=\"1\" Minor=\"0\">"
  puts $ch "    <Process Command=\".planAhead.\" Owner=\"$user\" Host=\"$host\" Pid=\"$pid\">"
  puts $ch "    </Process>"
  puts $ch "</ProcessHandle>"
  close $ch
}

proc end_step { step } {
  set endFile ".$step.end.rst"
  set ch [open $endFile w]
  close $ch
}

proc step_failed { step } {
  set endFile ".$step.error.rst"
  set ch [open $endFile w]
  close $ch
}

set_msg_config -id {HDL 9-1061} -limit 100000
set_msg_config -id {HDL 9-1654} -limit 100000
set_msg_config  -ruleid {1}  -id {Synth 8-3917}  -string {{WARNING: [Synth 8-3917] design FPGA_TOP has port usb_slcs driven by constant 0}}  -suppress 
set_msg_config  -ruleid {2}  -id {Synth 8-3917}  -string {{WARNING: [Synth 8-3917] design FPGA_TOP has port usb_fifoaddr[0] driven by constant 0}}  -suppress 
set_msg_config  -ruleid {3}  -id {Project 1-486}  -string {{WARNING: [Project 1-486] Could not resolve non-primitive black box cell 'usb_cmd_fifo' instantiated as 'usb_control/usbcmdfifo_16depth' [D:/Xilinx_Vivado_workspace/SDHCAL_DAQ2V0/RTL/usb_command_interpreter.v:55]}}  -suppress 
set_msg_config  -ruleid {4}  -id {Project 1-486}  -string {{WARNING: [Project 1-486] Could not resolve non-primitive black box cell 'usb_data_fifo' instantiated as 'usb_data_fifo_8192depth' [D:/Xilinx_Vivado_workspace/SDHCAL_DAQ2V0/RTL/FPGA_TOP.v:294]}}  -suppress 
set_msg_config  -ruleid {5}  -id {Project 1-486}  -string {{WARNING: [Project 1-486] Could not resolve non-primitive black box cell 'param_store_fifo' instantiated as 'Microroc_u1/SC_Readreg/param_store_fifo_16bitx256deep' [D:/Xilinx_Vivado_workspace/SDHCAL_DAQ2V0/RTL/SlowControl_ReadReg.v:339]}}  -suppress 
set_msg_config  -ruleid {6}  -id {Synth 8-3917}  -string {{WARNING: [Synth 8-3917] design FPGA_TOP has port LED[5] driven by constant 1}}  -suppress 
set_msg_config  -ruleid {7}  -id {Synth 8-350}  -string {{WARNING: [Synth 8-350] instance 'SC_Readreg' of module 'SlowControl_ReadReg' requires 53 connections, but only 52 given [D:/Xilinx_Vivado_workspace/SDHCAL_DAQ2V0/RTL/Microroc_top.v:135]}}  -suppress 
set_msg_config  -ruleid {8}  -id {Project 1-486}  -string {{WARNING: [Project 1-486] Could not resolve non-primitive black box cell 'param_store_fifo' instantiated as 'Microroc_u1/SC_Readreg/param_store_fifo_16bitx256deep' [D:/Xilinx_Vivado_workspace/SDHCAL_DAQ2V0/RTL/SlowControl_ReadReg.v:283]}}  -suppress 

start_step init_design
set ACTIVE_STEP init_design
set rc [catch {
  create_msg_db init_design.pb
  set_property design_mode GateLvl [current_fileset]
  set_param project.singleFileAddWarning.threshold 0
  set_property webtalk.parent_dir D:/MyProject/SDHCAL_DAQ/SDHCAL_DAQ2V0_SCurveTest/SDHCAL_DAQ2V0.cache/wt [current_project]
  set_property parent.project_path D:/MyProject/SDHCAL_DAQ/SDHCAL_DAQ2V0_SCurveTest/SDHCAL_DAQ2V0.xpr [current_project]
  set_property ip_output_repo D:/MyProject/SDHCAL_DAQ/SDHCAL_DAQ2V0_SCurveTest/SDHCAL_DAQ2V0.cache/ip [current_project]
  set_property ip_cache_permissions {read write} [current_project]
  set_property XPM_LIBRARIES {XPM_CDC XPM_MEMORY} [current_project]
  add_files -quiet D:/MyProject/SDHCAL_DAQ/SDHCAL_DAQ2V0_SCurveTest/SDHCAL_DAQ2V0.runs/synth_1/FPGA_TOP.dcp
  add_files -quiet d:/MyProject/SDHCAL_DAQ/SDHCAL_DAQ2V0_SCurveTest/SDHCAL_DAQ2V0.srcs/sources_1/ip/SCurve_Data_FIFO/SCurve_Data_FIFO.dcp
  set_property netlist_only true [get_files d:/MyProject/SDHCAL_DAQ/SDHCAL_DAQ2V0_SCurveTest/SDHCAL_DAQ2V0.srcs/sources_1/ip/SCurve_Data_FIFO/SCurve_Data_FIFO.dcp]
  add_files -quiet d:/MyProject/SDHCAL_DAQ/SDHCAL_DAQ2V0_SCurveTest/SDHCAL_DAQ2V0.srcs/sources_1/ip/param_store_fifo/param_store_fifo.dcp
  set_property netlist_only true [get_files d:/MyProject/SDHCAL_DAQ/SDHCAL_DAQ2V0_SCurveTest/SDHCAL_DAQ2V0.srcs/sources_1/ip/param_store_fifo/param_store_fifo.dcp]
  add_files -quiet d:/MyProject/SDHCAL_DAQ/SDHCAL_DAQ2V0_SCurveTest/SDHCAL_DAQ2V0.srcs/sources_1/ip/usb_cmd_fifo/usb_cmd_fifo.dcp
  set_property netlist_only true [get_files d:/MyProject/SDHCAL_DAQ/SDHCAL_DAQ2V0_SCurveTest/SDHCAL_DAQ2V0.srcs/sources_1/ip/usb_cmd_fifo/usb_cmd_fifo.dcp]
  read_xdc -ref SweepACQ_FIFO -cells U0 d:/MyProject/SDHCAL_DAQ/SDHCAL_DAQ2V0_SCurveTest/SDHCAL_DAQ2V0.srcs/sources_1/ip/SweepACQ_FIFO/SweepACQ_FIFO/SweepACQ_FIFO.xdc
  set_property processing_order EARLY [get_files d:/MyProject/SDHCAL_DAQ/SDHCAL_DAQ2V0_SCurveTest/SDHCAL_DAQ2V0.srcs/sources_1/ip/SweepACQ_FIFO/SweepACQ_FIFO/SweepACQ_FIFO.xdc]
  read_xdc -ref SCurve_Data_FIFO -cells U0 d:/MyProject/SDHCAL_DAQ/SDHCAL_DAQ2V0_SCurveTest/SDHCAL_DAQ2V0.srcs/sources_1/ip/SCurve_Data_FIFO/SCurve_Data_FIFO/SCurve_Data_FIFO.xdc
  set_property processing_order EARLY [get_files d:/MyProject/SDHCAL_DAQ/SDHCAL_DAQ2V0_SCurveTest/SDHCAL_DAQ2V0.srcs/sources_1/ip/SCurve_Data_FIFO/SCurve_Data_FIFO/SCurve_Data_FIFO.xdc]
  read_xdc -ref usb_data_fifo -cells U0 d:/MyProject/SDHCAL_DAQ/SDHCAL_DAQ2V0_SCurveTest/SDHCAL_DAQ2V0.srcs/sources_1/ip/usb_data_fifo/usb_data_fifo/usb_data_fifo.xdc
  set_property processing_order EARLY [get_files d:/MyProject/SDHCAL_DAQ/SDHCAL_DAQ2V0_SCurveTest/SDHCAL_DAQ2V0.srcs/sources_1/ip/usb_data_fifo/usb_data_fifo/usb_data_fifo.xdc]
  read_xdc -mode out_of_context -ref param_store_fifo -cells U0 d:/MyProject/SDHCAL_DAQ/SDHCAL_DAQ2V0_SCurveTest/SDHCAL_DAQ2V0.srcs/sources_1/ip/param_store_fifo/param_store_fifo_ooc.xdc
  set_property processing_order EARLY [get_files d:/MyProject/SDHCAL_DAQ/SDHCAL_DAQ2V0_SCurveTest/SDHCAL_DAQ2V0.srcs/sources_1/ip/param_store_fifo/param_store_fifo_ooc.xdc]
  read_xdc -ref param_store_fifo -cells U0 d:/MyProject/SDHCAL_DAQ/SDHCAL_DAQ2V0_SCurveTest/SDHCAL_DAQ2V0.srcs/sources_1/ip/param_store_fifo/param_store_fifo/param_store_fifo.xdc
  set_property processing_order EARLY [get_files d:/MyProject/SDHCAL_DAQ/SDHCAL_DAQ2V0_SCurveTest/SDHCAL_DAQ2V0.srcs/sources_1/ip/param_store_fifo/param_store_fifo/param_store_fifo.xdc]
  read_xdc -mode out_of_context -ref usb_cmd_fifo -cells U0 d:/MyProject/SDHCAL_DAQ/SDHCAL_DAQ2V0_SCurveTest/SDHCAL_DAQ2V0.srcs/sources_1/ip/usb_cmd_fifo/usb_cmd_fifo_ooc.xdc
  set_property processing_order EARLY [get_files d:/MyProject/SDHCAL_DAQ/SDHCAL_DAQ2V0_SCurveTest/SDHCAL_DAQ2V0.srcs/sources_1/ip/usb_cmd_fifo/usb_cmd_fifo_ooc.xdc]
  read_xdc -ref usb_cmd_fifo -cells U0 d:/MyProject/SDHCAL_DAQ/SDHCAL_DAQ2V0_SCurveTest/SDHCAL_DAQ2V0.srcs/sources_1/ip/usb_cmd_fifo/usb_cmd_fifo/usb_cmd_fifo.xdc
  set_property processing_order EARLY [get_files d:/MyProject/SDHCAL_DAQ/SDHCAL_DAQ2V0_SCurveTest/SDHCAL_DAQ2V0.srcs/sources_1/ip/usb_cmd_fifo/usb_cmd_fifo/usb_cmd_fifo.xdc]
  read_xdc D:/MyProject/SDHCAL_DAQ/SDHCAL_DAQ2V0_SCurveTest/Constraints/SDHCAL_DAQ2V0.xdc
  read_xdc -ref usb_data_fifo -cells U0 d:/MyProject/SDHCAL_DAQ/SDHCAL_DAQ2V0_SCurveTest/SDHCAL_DAQ2V0.srcs/sources_1/ip/usb_data_fifo/usb_data_fifo/usb_data_fifo_clocks.xdc
  set_property processing_order LATE [get_files d:/MyProject/SDHCAL_DAQ/SDHCAL_DAQ2V0_SCurveTest/SDHCAL_DAQ2V0.srcs/sources_1/ip/usb_data_fifo/usb_data_fifo/usb_data_fifo_clocks.xdc]
  read_xdc -ref param_store_fifo -cells U0 d:/MyProject/SDHCAL_DAQ/SDHCAL_DAQ2V0_SCurveTest/SDHCAL_DAQ2V0.srcs/sources_1/ip/param_store_fifo/param_store_fifo/param_store_fifo_clocks.xdc
  set_property processing_order LATE [get_files d:/MyProject/SDHCAL_DAQ/SDHCAL_DAQ2V0_SCurveTest/SDHCAL_DAQ2V0.srcs/sources_1/ip/param_store_fifo/param_store_fifo/param_store_fifo_clocks.xdc]
  read_xdc -ref usb_cmd_fifo -cells U0 d:/MyProject/SDHCAL_DAQ/SDHCAL_DAQ2V0_SCurveTest/SDHCAL_DAQ2V0.srcs/sources_1/ip/usb_cmd_fifo/usb_cmd_fifo/usb_cmd_fifo_clocks.xdc
  set_property processing_order LATE [get_files d:/MyProject/SDHCAL_DAQ/SDHCAL_DAQ2V0_SCurveTest/SDHCAL_DAQ2V0.srcs/sources_1/ip/usb_cmd_fifo/usb_cmd_fifo/usb_cmd_fifo_clocks.xdc]
  link_design -top FPGA_TOP -part xc7a100tfgg484-2
  write_hwdef -file FPGA_TOP.hwdef
  close_msg_db -file init_design.pb
} RESULT]
if {$rc} {
  step_failed init_design
  return -code error $RESULT
} else {
  end_step init_design
  unset ACTIVE_STEP 
}

start_step opt_design
set ACTIVE_STEP opt_design
set rc [catch {
  create_msg_db opt_design.pb
  opt_design 
  write_checkpoint -force FPGA_TOP_opt.dcp
  report_drc -file FPGA_TOP_drc_opted.rpt
  close_msg_db -file opt_design.pb
} RESULT]
if {$rc} {
  step_failed opt_design
  return -code error $RESULT
} else {
  end_step opt_design
  unset ACTIVE_STEP 
}

start_step place_design
set ACTIVE_STEP place_design
set rc [catch {
  create_msg_db place_design.pb
  implement_debug_core 
  place_design 
  write_checkpoint -force FPGA_TOP_placed.dcp
  report_io -file FPGA_TOP_io_placed.rpt
  report_utilization -file FPGA_TOP_utilization_placed.rpt -pb FPGA_TOP_utilization_placed.pb
  report_control_sets -verbose -file FPGA_TOP_control_sets_placed.rpt
  close_msg_db -file place_design.pb
} RESULT]
if {$rc} {
  step_failed place_design
  return -code error $RESULT
} else {
  end_step place_design
  unset ACTIVE_STEP 
}

start_step route_design
set ACTIVE_STEP route_design
set rc [catch {
  create_msg_db route_design.pb
  route_design 
  write_checkpoint -force FPGA_TOP_routed.dcp
  report_drc -file FPGA_TOP_drc_routed.rpt -pb FPGA_TOP_drc_routed.pb -rpx FPGA_TOP_drc_routed.rpx
  report_methodology -file FPGA_TOP_methodology_drc_routed.rpt -rpx FPGA_TOP_methodology_drc_routed.rpx
  report_timing_summary -warn_on_violation -max_paths 10 -file FPGA_TOP_timing_summary_routed.rpt -rpx FPGA_TOP_timing_summary_routed.rpx
  report_power -file FPGA_TOP_power_routed.rpt -pb FPGA_TOP_power_summary_routed.pb -rpx FPGA_TOP_power_routed.rpx
  report_route_status -file FPGA_TOP_route_status.rpt -pb FPGA_TOP_route_status.pb
  report_clock_utilization -file FPGA_TOP_clock_utilization_routed.rpt
  close_msg_db -file route_design.pb
} RESULT]
if {$rc} {
  write_checkpoint -force FPGA_TOP_routed_error.dcp
  step_failed route_design
  return -code error $RESULT
} else {
  end_step route_design
  unset ACTIVE_STEP 
}


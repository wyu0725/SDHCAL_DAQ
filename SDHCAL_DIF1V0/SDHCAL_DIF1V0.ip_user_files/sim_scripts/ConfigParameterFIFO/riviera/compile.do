vlib work
vlib riviera

vlib riviera/fifo_generator_v13_2_2
vlib riviera/xil_defaultlib

vmap fifo_generator_v13_2_2 riviera/fifo_generator_v13_2_2
vmap xil_defaultlib riviera/xil_defaultlib

vlog -work fifo_generator_v13_2_2  -v2k5 \
"../../../ipstatic/simulation/fifo_generator_vlog_beh.v" \

vcom -work fifo_generator_v13_2_2 -93 \
"../../../ipstatic/hdl/fifo_generator_v13_2_rfs.vhd" \

vlog -work fifo_generator_v13_2_2  -v2k5 \
"../../../ipstatic/hdl/fifo_generator_v13_2_rfs.v" \

vlog -work xil_defaultlib  -v2k5 \
"../../../../SDHCAL_DIF1V0.srcs/sources_1/ip/ConfigParameterFIFO/sim/ConfigParameterFIFO.v" \


vlog -work xil_defaultlib \
"glbl.v"


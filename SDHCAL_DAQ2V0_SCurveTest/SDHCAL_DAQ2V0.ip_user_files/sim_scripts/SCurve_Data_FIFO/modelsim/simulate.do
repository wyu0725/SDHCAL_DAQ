onbreak {quit -f}
onerror {quit -f}

vsim -voptargs="+acc" -t 1ps -L xil_defaultlib -L xpm -L fifo_generator_v13_1_2 -L unisims_ver -L unimacro_ver -L secureip -lib xil_defaultlib xil_defaultlib.SCurve_Data_FIFO xil_defaultlib.glbl

do {wave.do}

view wave
view structure
view signals

do {SCurve_Data_FIFO.udo}

run -all

quit -force

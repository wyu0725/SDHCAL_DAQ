onbreak {quit -force}
onerror {quit -force}

asim -t 1ps +access +r +m+SCurve_Data_FIFO -L xil_defaultlib -L xpm -L fifo_generator_v13_1_2 -L unisims_ver -L unimacro_ver -L secureip -O5 xil_defaultlib.SCurve_Data_FIFO xil_defaultlib.glbl

do {wave.do}

view wave
view structure

do {SCurve_Data_FIFO.udo}

run -all

endsim

quit -force

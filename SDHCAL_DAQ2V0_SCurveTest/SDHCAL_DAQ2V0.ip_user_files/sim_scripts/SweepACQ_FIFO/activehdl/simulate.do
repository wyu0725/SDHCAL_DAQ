onbreak {quit -force}
onerror {quit -force}

asim -t 1ps +access +r +m+SweepACQ_FIFO -L xil_defaultlib -L xpm -L fifo_generator_v13_1_2 -L unisims_ver -L unimacro_ver -L secureip -O5 xil_defaultlib.SweepACQ_FIFO xil_defaultlib.glbl

do {wave.do}

view wave
view structure

do {SweepACQ_FIFO.udo}

run -all

endsim

quit -force

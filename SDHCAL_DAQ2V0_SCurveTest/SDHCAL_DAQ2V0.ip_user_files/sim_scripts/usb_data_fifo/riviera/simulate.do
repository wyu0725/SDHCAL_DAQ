onbreak {quit -force}
onerror {quit -force}

asim -t 1ps +access +r +m+usb_data_fifo -L xil_defaultlib -L xpm -L fifo_generator_v13_1_2 -L unisims_ver -L unimacro_ver -L secureip -O5 xil_defaultlib.usb_data_fifo xil_defaultlib.glbl

do {wave.do}

view wave
view structure

do {usb_data_fifo.udo}

run -all

endsim

quit -force

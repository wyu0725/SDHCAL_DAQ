onbreak {quit -force}
onerror {quit -force}

asim -t 1ps +access +r +m+usb_cmd_fifo -L xil_defaultlib -L xpm -L fifo_generator_v13_1_2 -L unisims_ver -L unimacro_ver -L secureip -O5 xil_defaultlib.usb_cmd_fifo xil_defaultlib.glbl

do {wave.do}

view wave
view structure

do {usb_cmd_fifo.udo}

run -all

endsim

quit -force

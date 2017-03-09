onbreak {quit -f}
onerror {quit -f}

vsim -t 1ps -lib xil_defaultlib usb_cmd_fifo_opt

do {wave.do}

view wave
view structure
view signals

do {usb_cmd_fifo.udo}

run -all

quit -force

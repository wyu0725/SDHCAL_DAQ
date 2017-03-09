onbreak {quit -f}
onerror {quit -f}

vsim -t 1ps -lib xil_defaultlib param_store_fifo_opt

do {wave.do}

view wave
view structure
view signals

do {param_store_fifo.udo}

run -all

quit -force

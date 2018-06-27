onbreak {quit -f}
onerror {quit -f}

vsim -t 1ps -lib xil_defaultlib CommandFifo_opt

do {wave.do}

view wave
view structure
view signals

do {CommandFifo.udo}

run -all

quit -force

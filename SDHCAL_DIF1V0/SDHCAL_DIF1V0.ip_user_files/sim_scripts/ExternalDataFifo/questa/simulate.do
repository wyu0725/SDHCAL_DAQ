onbreak {quit -f}
onerror {quit -f}

vsim -t 1ps -lib xil_defaultlib ExternalDataFifo_opt

do {wave.do}

view wave
view structure
view signals

do {ExternalDataFifo.udo}

run -all

quit -force

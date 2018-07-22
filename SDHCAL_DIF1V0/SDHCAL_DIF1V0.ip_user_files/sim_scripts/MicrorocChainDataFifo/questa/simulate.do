onbreak {quit -f}
onerror {quit -f}

vsim -t 1ps -lib xil_defaultlib MicrorocChainDataFifo_opt

do {wave.do}

view wave
view structure
view signals

do {MicrorocChainDataFifo.udo}

run -all

quit -force

onbreak {quit -f}
onerror {quit -f}

vsim -t 1ps -lib xil_defaultlib SCurveDataFifo_opt

do {wave.do}

view wave
view structure
view signals

do {SCurveDataFifo.udo}

run -all

quit -force

transcript off
onbreak {quit -force}
onerror {quit -force}
transcript on

vlib work
vlib riviera/xpm
vlib riviera/xil_defaultlib

vmap xpm riviera/xpm
vmap xil_defaultlib riviera/xil_defaultlib

vlog -work xpm  -incr  +define+JTAG_EXTERNAL=1  +define+XSIM=1  +define+SIMULATION=1 "+incdir+../../../../nexysA7card.gen/sources_1/ip/ila_syscon/hdl/verilog" -l xpm -l xil_defaultlib \
"C:/Xilinx/Vivado/2023.2/data/ip/xpm/xpm_cdc/hdl/xpm_cdc.sv" \
"C:/Xilinx/Vivado/2023.2/data/ip/xpm/xpm_memory/hdl/xpm_memory.sv" \

vcom -work xpm -93  -incr \
"C:/Xilinx/Vivado/2023.2/data/ip/xpm/xpm_VCOMP.vhd" \

vlog -work xil_defaultlib  -incr -v2k5  +define+JTAG_EXTERNAL=1  +define+XSIM=1  +define+SIMULATION=1 "+incdir+../../../../nexysA7card.gen/sources_1/ip/ila_syscon/hdl/verilog" -l xpm -l xil_defaultlib \
"../../../../nexysA7card.gen/sources_1/ip/ila_syscon/sim/ila_syscon.v" \

vlog -work xil_defaultlib \
"glbl.v"


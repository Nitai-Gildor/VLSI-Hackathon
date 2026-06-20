vlib modelsim_lib/work
vlib modelsim_lib/msim

vlib modelsim_lib/msim/xpm
vlib modelsim_lib/msim/xil_defaultlib

vmap xpm modelsim_lib/msim/xpm
vmap xil_defaultlib modelsim_lib/msim/xil_defaultlib

vlog -work xpm  -incr -mfcu  -sv  +define+JTAG_EXTERNAL=1  +define+XSIM=1  +define+SIMULATION=1 "+incdir+../../../../nexysA7card.gen/sources_1/ip/ila_syscon/hdl/verilog" \
"C:/Xilinx/Vivado/2023.2/data/ip/xpm/xpm_cdc/hdl/xpm_cdc.sv" \
"C:/Xilinx/Vivado/2023.2/data/ip/xpm/xpm_memory/hdl/xpm_memory.sv" \

vcom -work xpm  -93  \
"C:/Xilinx/Vivado/2023.2/data/ip/xpm/xpm_VCOMP.vhd" \

vlog -work xil_defaultlib  -incr -mfcu   +define+JTAG_EXTERNAL=1  +define+XSIM=1  +define+SIMULATION=1 "+incdir+../../../../nexysA7card.gen/sources_1/ip/ila_syscon/hdl/verilog" \
"../../../../nexysA7card.gen/sources_1/ip/ila_syscon/sim/ila_syscon.v" \

vlog -work xil_defaultlib \
"glbl.v"


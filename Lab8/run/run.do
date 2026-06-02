# Configurable Variables
set TOP datapath_tb
# set TOP cpu_tb
set SRC_DIR ../

# Setup Library
vlib work

# Compile
vlog $SRC_DIR/*.sv

# Simulate
vsim -voptargs=+acc work.$TOP

# Waves (Generic)

# Add all signals automatically
add wave -r sim:/$TOP/dut/*

# OR if DUT exists inside TB
# add wave -r sim:/$TOP/cpu/*
# add wave -r sim:/$TOP/dut/mem_d
# add wave -r sim:/$TOP/dut/mem_i
# add wave -r sim:/$TOP/dut/reg_file

# Run
run -all
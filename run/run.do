# Configurable Variables
set TOP pc_tb
set SRC_DIR ../Lab4/src
set TB_DIR ../Lab4/testbench

# Setup Library
vlib work

# Compile
vlog $SRC_DIR/*.sv
vlog $TB_DIR/*.sv

# Simulate
vsim -voptargs=+acc work.$TOP

# Waves (Generic)

# Add all signals automatically
# add wave -r sim:/$TOP/*

# OR if DUT exists inside TB
add wave -r sim:/$TOP/dut/*
# add wave -r sim:/$TOP/dut/mem # uncomment it when running regiter_file_tb to view register_file contents.

# Run
run -all
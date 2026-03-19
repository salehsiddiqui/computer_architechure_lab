# Configurable Variables
set TOP immgen_tb
set SRC_DIR ../Lab3/src
set TB_DIR ../Lab3/sim

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

# Run
run -all
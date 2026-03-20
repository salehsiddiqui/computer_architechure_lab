# Configurable Variables
set TOP register_file_tb
set SRC_DIR ../Lab4/src
set TB_DIR ../Lab4/testbench
set QUESTA_DIR ../Lab4/questa

# Create the directory if it doesn't exist
file mkdir $QUESTA_DIR

# Setup Library inside the questa folder
vlib $QUESTA_DIR/work
vmap work $QUESTA_DIR/work

# Compile (pointing to the work library in the questa folder)
vlog -work work $SRC_DIR/*.sv
vlog -work work $TB_DIR/*.sv

# Simulate
vsim -voptargs=+acc -lib $QUESTA_DIR/work $TOP

# Waves
add wave -r sim:/$TOP/dut/*

# Run
run -all
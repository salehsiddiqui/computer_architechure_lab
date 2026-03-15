vlib work
vlog ../Lab2/src/*.sv
vlog ../Lab2/sim/*.sv
vsim alu_tb
add wave *
run -all
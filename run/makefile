# directories
SRC_DIR = ../Lab2/src
TB_DIR = ../Lab2/sim

# testbench module name
TOP = alu_tb

all: compile simulate run

compile:
	vlib work
	vlog $(SRC_DIR)/*.sv
	vlog $(TB_DIR)/*.sv

simulate:
	vsim -voptargs=+acc work.$(TOP)

wave:
	# Add all signals automatically
	# add wave -r sim:/$(TOP)/*

	# OR if DUT exists inside TB
	add wave -r sim:/$(TOP)/dut/*

run:
	run -all

clean:
	rm -rf work transcript vsim.wlf
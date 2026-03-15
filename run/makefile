# ModelSim commands
VLIB = vlib
VLOG = vlog
VSIM = vsim

# directories
SRC_DIR = ../Lab2/src
TB_DIR = ../Lab2/sim

# files
SRC_FILES = $(SRC_DIR)/*.sv
TB_FILES = $(TB_DIR)/*.sv

# testbench module name
TOP = alu_tb

all: compile run

compile:
	$(VLIB) work
	$(VLOG) $(SRC_FILES)
	$(VLOG) $(TB_FILES)

run:
	$(VSIM) $(TOP) -do "add wave *; run -all"

clean:
	rm -rf work transcript vsim.wlf
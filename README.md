# Computer Architecture Lab

This repository contains **Lab Experiments** and **Course End Project (CEP)** for the Computer Architecture Lab.

---

## Project Structure

```
project/
│
├── src/            # Design source files 
├── simulation/     # Testbench files
└── run/            # Simulation build directory
    └── Makefile
```

* `src/` → Contains the design modules.
* `simulation/` → Contains testbench files used for verification.
* `run/` → Used to compile and run simulations.

### NOTE: Replace project with your local repository name.

## Running Simulations (Linux)

A `Makefile` is provided in the `run/` directory to simplify compiling and running simulations using ModelSim.
To run a specific simulation, set the testbench module name in the `TOP` variable inside the Makefile.

Example:
TOP = alu_tb

### Step 1: Navigate to the run directory

```bash
cd project/run
```

### Step 2: Compile and run the simulation

```bash
make
```

---

## Useful Make Commands

### Compile only

```bash
make compile
```

### Run simulation only

```bash
make run
```

### Clean generated simulation files

```bash
make clean
```

This removes temporary simulation files such as:

* `work/`
* `transcript`
* `vsim.wlf`

---

## Requirements

* Linux environment
* ModelSim installed and accessible from the terminal

---

## Notes

* The `run/` directory is used only for simulation builds.
* Temporary files generated during simulation are ignored using `.gitignore`.
* Only the `Makefile` is tracked inside the `run/` directory.

---


## Running Simulations (Windows)
In the `run` directory jsut double click the `run.bat` file.
Make sure to replace your testbench module with alu_tb.
Make sure to have Questa Sim installed and added to your path on windows.


# NOTE:
Make sure to select the appropriate Lab Folder in the path as well both for Linux and Windows
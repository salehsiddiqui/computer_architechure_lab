module datapath (
    input logic clk,
    input logic reset
);

    parameter DWIDTH = 32;
    parameter AWIDTH = 32;
    parameter DEPTH  = 256;

    logic              pc_write;
    logic              pc_src;
    logic [AWIDTH-1:0] address;

    logic [DWIDTH-1:0] instruction;

    logic [1:0]        aluop;
    logic reg_write;
    logic imm_sel;
    logic mem_to_reg;

    program_counter pc_reg (
        .clk(clk),
        .reset(reset),
        .pc_write(pc_write),
        .pc_src(pc_src),
        .load_value(address + 4),
        .address(address)
    );

    imem #(
        .DWIDTH(DWIDTH),
        .AWIDTH(AWIDTH),
        .DEPTH(DEPTH),
        .MIF_HEX("imem.hex")   // file to load
    ) instr_mem (
        .clk(clk),
        .addr1(address[9:2]),
        .q1(instruction)
    );

    control_unit ctrl (
        .instruction(instruction),
        .aluop(aluop),
        .pc_write(pc_write),
        .pc_src(pc_src),
        .reg_write(reg_write),
        .imm_sel(imm_sel),
        .mem_to_reg(mem_to_reg)
    );

endmodule
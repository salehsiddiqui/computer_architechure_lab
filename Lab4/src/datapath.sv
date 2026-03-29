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
    logic mem_write;

    logic [DWIDTH-1:0] imm_ext;

    logic [4:0]  rs1, rs2, rd;

    logic [DWIDTH-1:0] write_back_data;
    logic [DWIDTH-1:0] reg_data1, reg_data2;

    logic [2:0]  funct3;
    logic [6:0]  funct7;

    logic [3:0] alu_operation;
    logic [DWIDTH-1:0] alu_result;
    logic zero;

    logic [DWIDTH-1:0] mem_data;

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
        .mem_to_reg(mem_to_reg),
        .mem_write(mem_write)
    );

    // ----- Instruction fields -----
    assign rd     = instruction[11:7];
    assign rs1    = instruction[19:15];
    assign rs2    = instruction[24:20];


    // ----- Immediate Generator -----
    immgen imm_extender (
        .instruction(instruction),
        .imm_ext(imm_ext)
    );

    register_file rf (
        .clk(clk),
        .d0(write_back_data),
        .addr0(rd),
        .we0(reg_write),
        .addr1(rs1),
        .q1(reg_data1),
        .addr2(rs2),
        .q2(reg_data2)
    );

    alu_control_unit alc (
        .aluop(aluop),
        .funct3(funct3),
        .funct7(funct7),
        .alu_operation(alu_operation)
    );

    logic [31:0] operand2;
    always_comb begin
        if (!imm_sel) begin
            operand2 = reg_data2;
        end else if (imm_sel) begin
            operand2 = imm_ext;
        end
    end

    alu alu (
        .operand1     (reg_data1),
        .operand2     (operand2),
        .alu_operation(alu_operation),
        .result       (alu_result),
        .zero         (zero)
    );

    dmem #(
        .DWIDTH(DWIDTH),
        .AWIDTH(AWIDTH),
        .DEPTH(DEPTH)
    ) data_mem (
        .clk(clk),
        .d0(reg_data2),
        .addr0(alu_result[9:2]),
        .we0(mem_write),
        .addr1(alu_result[9:2]),
        .q1(mem_data)
    );

    // ----- Write Back -----
    assign write_back_data = mem_to_reg ? mem_data : alu_result;

endmodule
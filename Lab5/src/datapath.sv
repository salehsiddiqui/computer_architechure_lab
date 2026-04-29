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
    logic              reg_write;
    logic              imm_sel;
    logic              u_sel;
    logic              mem_to_reg;
    logic              mem_write;

    logic [DWIDTH-1:0] imm_ext;

    logic [4:0]        rs1, rs2, rd;

    logic [DWIDTH-1:0] write_back_data;
    logic [DWIDTH-1:0] reg_data1, reg_data2;

    logic [2:0]        funct3;
    logic [6:0]        funct7;

    logic [3:0]        alu_operation;
    logic [DWIDTH-1:0] alu_result;
    logic              zero;

    logic [DWIDTH-1:0] mem_data;
    logic [DWIDTH-1:0] operand1;
    logic [DWIDTH-1:0] operand2;

    logic              is_jal;
    logic              is_jalr;

    logic [DWIDTH-1:0] load_data;
    logic [DWIDTH-1:0] write_data;

    // ----- Branch Logic -----
    logic              branch_taken;
    logic [DWIDTH-1:0] next_pc;

    always_comb begin
        branch_taken = 1'b0;

        if (pc_src) begin // branch instruction

            unique case (funct3)
                3'b000: branch_taken =  zero;             // BEQ
                3'b001: branch_taken = ~zero;             // BNE
                3'b100: branch_taken =  alu_result[0];    // BLT  (signed <)
                3'b101: branch_taken = ~alu_result[0];    // BGE  (signed >=)
                default: branch_taken = 1'b0;
            endcase

        end
    end

    always_comb begin
        if (branch_taken || is_jal)
            next_pc = address + imm_ext;
        else if (is_jalr)
            next_pc = (alu_result & 32'hFFFFFFFE); // clear LSB
        else
            next_pc = address + 4;
    end

    program_counter pc_reg (
        .clk(clk),
        .reset(reset),
        .pc_write(pc_write),
        .pc_src(pc_src),
        .load_value(next_pc),
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
        .mem_write(mem_write),
        .u_sel(u_sel)
    );

    // ----- Instruction fields -----
    assign rd     = instruction[11:7];
    assign rs1    = instruction[19:15];
    assign rs2    = instruction[24:20];
    assign funct3 = instruction[14:12];
    assign funct7 = instruction[31:25];


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

    always_comb begin
        if (!imm_sel) begin
            operand2 = reg_data2;
        end else if (imm_sel) begin
            operand2 = imm_ext;
        end
        if (!u_sel) begin
            operand1 = reg_data1;
        end else if (u_sel) begin
            operand1 = 32'b0;
        end
    end

    alu alu (
        .operand1     (operand1),
        .operand2     (operand2),
        .alu_operation(alu_operation),
        .result       (alu_result),
        .zero         (zero)
    );


    // Write Logic to accomdate SB, SH, SW
    always_comb begin
        case (funct3)
            3'b000: begin // SB
                case (alu_result[1:0])
                    2'b00: write_data = {mem_data[31:8],  reg_data2[7:0]};
                    2'b01: write_data = {mem_data[31:16], reg_data2[7:0], mem_data[7:0]};
                    2'b10: write_data = {mem_data[31:24], reg_data2[7:0], mem_data[15:0]};
                    2'b11: write_data = {reg_data2[7:0],  mem_data[23:0]};
                endcase
            end

            3'b001: begin // SH
                if (alu_result[1] == 0)
                    write_data = {mem_data[31:16], reg_data2[15:0]};
                else
                    write_data = {reg_data2[15:0], mem_data[15:0]};
            end

            default: write_data = reg_data2; // SW
        endcase
    end

    dmem #(
        .DWIDTH(DWIDTH),
        .AWIDTH(AWIDTH),
        .DEPTH(DEPTH)
    ) data_mem (
        .clk(clk),
        .d0(write_data),
        .addr0(alu_result[9:2]),
        .we0(mem_write),
        .addr1(alu_result[9:2]),
        .q1(mem_data)
    );

    
    // Read Logic to accomdate LB, LBU, LH, LHU, LW
    always_comb begin
        case (funct3)

            3'b000: begin // LB
                case (alu_result[1:0])
                    2'b00: load_data = {{24{mem_data[7]}},  mem_data[7:0]};
                    2'b01: load_data = {{24{mem_data[15]}}, mem_data[15:8]};
                    2'b10: load_data = {{24{mem_data[23]}}, mem_data[23:16]};
                    2'b11: load_data = {{24{mem_data[31]}}, mem_data[31:24]};
                endcase
            end

            3'b100: begin // LBU
                case (alu_result[1:0])
                    2'b00: load_data = {24'b0, mem_data[7:0]};
                    2'b01: load_data = {24'b0, mem_data[15:8]};
                    2'b10: load_data = {24'b0, mem_data[23:16]};
                    2'b11: load_data = {24'b0, mem_data[31:24]};
                endcase
            end

            3'b001: begin // LH
                if (alu_result[1] == 0)
                    load_data = {{16{mem_data[15]}}, mem_data[15:0]};
                else
                    load_data = {{16{mem_data[31]}}, mem_data[31:16]};
            end

            3'b101: begin // LHU
                if (alu_result[1] == 0)
                    load_data = {16'b0, mem_data[15:0]};
                else
                    load_data = {16'b0, mem_data[31:16]};
            end

            default: load_data = mem_data; // LW
        endcase
    end


    // ----- Write Back -----
    assign is_jal =  (instruction[6:0] == 7'b1101111);
    assign is_jalr = (instruction[6:0] == 7'b1100111);
    // assign write_back_data = mem_to_reg ? mem_data : alu_result;
    always_comb begin
        if (is_jal)
            write_back_data = address + 4;   // return address
        else if (mem_to_reg)
            write_back_data = load_data;
        else
            write_back_data = alu_result;
    end

endmodule
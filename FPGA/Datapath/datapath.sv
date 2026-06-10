module datapath (
    input logic clk,
    input logic reset,
    output logic [31:0] val0,
	output logic [31:0] val1,
	output logic [31:0] val2,
	output logic [31:0] val3
);

    parameter DWIDTH = 32;
    parameter AWIDTH = 32;

    // ========================================================================
    // PIPELINE STAGE 1: INSTRUCTION FETCH (IF)
    // ========================================================================
    logic [AWIDTH-1:0] address;       // Current PC
    logic [DWIDTH-1:0] next_pc;       // Next PC value
    logic [DWIDTH-1:0] instruction;   // Raw fetched instruction

    logic [4:0]        rd_memwb;
    logic reg_write_memwb, mem_write_memwb, mem_to_reg_memwb;
    logic is_jal_memwb, is_jalr_memwb;
    
    // IF control
    logic              flush_if;      // Triggered by branches/jumps in ID/EX
    logic [DWIDTH-1:0] pc_plus_4;

    assign pc_plus_4 = address + 4;

    program_counter pc_reg (
        .clk(clk),
        .reset(reset),
        .pc_write(1'b1), // In a simple pipeline, PC always writes unless stalling
        .load_value(next_pc),
        .address(address)
    );

    imem #(
        .DWIDTH(DWIDTH),
        .AWIDTH(16),  
        .DEPTH(65536), 
        .MIF_HEX("imem.hex")   
    ) instr_mem (
        .clk(clk),
        .reset(reset),
        .addr1(address[17:2]), 
        .q1(instruction)
    );

    // ========================================================================
    // IF/IDEX PIPELINE REGISTERS
    // ========================================================================
    logic [DWIDTH-1:0] pc_idex;
    logic [DWIDTH-1:0] instr_idex;

    always_ff @(posedge clk or posedge reset) begin
        if (reset) begin
            pc_idex    <= 0;
            instr_idex <= 32'h00000013; // NOP (addi x0, x0, 0)
        end else if (flush_if) begin
            pc_idex    <= 0;
            instr_idex <= 32'h00000013; // Flush with NOP
        end else begin
            pc_idex    <= address;
            instr_idex <= instruction;
        end
    end

    // ========================================================================
    // PIPELINE STAGE 2: DECODE & EXECUTE (ID/EX)
    // ========================================================================
    // Instruction Decoding
    logic [4:0]        rs1_idex, rs2_idex, rd_idex;
    logic [2:0]        funct3_idex;
    logic [6:0]        funct7_idex;
    logic              is_jal_idex, is_jalr_idex;

    assign rd_idex     = instr_idex[11:7];
    assign rs1_idex    = instr_idex[19:15];
    assign rs2_idex    = instr_idex[24:20];
    assign funct3_idex = instr_idex[14:12];
    assign funct7_idex = instr_idex[31:25];
    assign is_jal_idex = (instr_idex[6:0] == 7'b1101111);
    assign is_jalr_idex= (instr_idex[6:0] == 7'b1100111);

    // Control Signals
    logic [1:0] aluop;
    logic       pc_write_idex, pc_src_idex, reg_write_idex, imm_sel_idex;
    logic       mem_to_reg_idex, mem_write_idex, u_sel_idex;

    control_unit ctrl (
        .instruction(instr_idex),
        .aluop      (aluop),
        .pc_write   (pc_write_idex),
        .pc_src     (pc_src_idex),
        .reg_write  (reg_write_idex),
        .imm_sel    (imm_sel_idex),
        .mem_to_reg (mem_to_reg_idex),
        .mem_write  (mem_write_idex),
        .u_sel      (u_sel_idex)
    );

    logic [DWIDTH-1:0] imm_ext_idex;
    immgen imm_extender (
        .instruction(instr_idex),
        .imm_ext    (imm_ext_idex)
    );

    logic [DWIDTH-1:0] reg_data1, reg_data2;
    logic [DWIDTH-1:0] write_back_data; // Comes from MEM/WB stage

    register_file rf (
        .clk  (clk),
        .d0   (write_back_data),
        .addr0(rd_idex),           // From MEM/WB stage
        .we0  (reg_write_memwb),    // From MEM/WB stage
        .addr1(rs1_idex),
        .q1   (reg_data1),
        .addr2(rs2_idex),
        .q2   (reg_data2)
    );

    // Forwarding Logic (MEM/WB -> ID/EX)
    logic forwardA, forwardB;
    logic [DWIDTH-1:0] fw_reg_data1, fw_reg_data2;

    assign forwardA = (reg_write_memwb && (rd_memwb != 0) && (rd_memwb == rs1_idex));
    assign forwardB = (reg_write_memwb && (rd_memwb != 0) && (rd_memwb == rs2_idex));

    assign fw_reg_data1 = forwardA ? write_back_data : reg_data1;
    assign fw_reg_data2 = forwardB ? write_back_data : reg_data2;

    // ALU Logic
    logic [3:0]        alu_operation;
    logic [DWIDTH-1:0] alu_result_idex;
    logic              zero_idex;
    logic [DWIDTH-1:0] operand1, operand2;

    alu_control_unit alc (
        .aluop        (aluop),
        .funct3       (funct3_idex),
        .funct7       (funct7_idex),
        .alu_operation(alu_operation)
    );

    always_comb begin
        operand2 = imm_sel_idex ? imm_ext_idex : fw_reg_data2;
        operand1 = u_sel_idex   ? 32'b0        : fw_reg_data1;
    end

    alu alu (
        .operand1     (operand1),
        .operand2     (operand2),
        .alu_operation(alu_operation),
        .result       (alu_result_idex),
        .zero         (zero_idex)
    );

    // Branch & Jump Resolution
    logic branch_taken;
    always_comb begin
        branch_taken = 1'b0;
        if (pc_src_idex) begin 
            unique case (funct3_idex)
                3'b000: branch_taken =  zero_idex;           // BEQ
                3'b001: branch_taken = ~zero_idex;           // BNE
                3'b100: branch_taken =  alu_result_idex[0];  // BLT  
                3'b101: branch_taken = ~alu_result_idex[0];  // BGE  
                default: branch_taken = 1'b0;
            endcase
        end
    end

    // Next PC Calculation & Flush Generation
    always_comb begin
        if (pc_src_idex && branch_taken)
            next_pc = pc_idex + imm_ext_idex; 
        else if (is_jal_idex)
            next_pc = pc_idex + imm_ext_idex; 
        else if (is_jalr_idex)
            next_pc = (alu_result_idex & 32'hFFFFFFFE); // clear LSB
        else 
            next_pc = pc_plus_4;
    end

    // Flush the IF stage if a jump or branch was successfully taken
    assign flush_if = (pc_src_idex && branch_taken) || is_jal_idex || is_jalr_idex;

    // ========================================================================
    // IDEX/MEMWB PIPELINE REGISTERS
    // ========================================================================
    logic [DWIDTH-1:0] pc_memwb;
    logic [DWIDTH-1:0] alu_result_memwb;
    logic [DWIDTH-1:0] reg_data2_memwb;
    // logic [4:0]        rd_memwb;
    logic [2:0]        funct3_memwb;
    
    // Registered Control Signals
    // logic reg_write_memwb, mem_write_memwb, mem_to_reg_memwb;
    // logic is_jal_memwb, is_jalr_memwb;

    always_ff @(posedge clk or posedge reset) begin
        if (reset) begin
            pc_memwb         <= 0;
            alu_result_memwb <= 0;
            reg_data2_memwb  <= 0;
            rd_memwb         <= 0;
            funct3_memwb     <= 0;
            reg_write_memwb  <= 0;
            mem_write_memwb  <= 0;
            mem_to_reg_memwb <= 0;
            is_jal_memwb     <= 0;
            is_jalr_memwb    <= 0;
        end else begin
            pc_memwb         <= pc_idex;
            alu_result_memwb <= alu_result_idex;
            reg_data2_memwb  <= fw_reg_data2; // Must pass the forwarded data!
            rd_memwb         <= rd_idex;
            funct3_memwb     <= funct3_idex;
            
            // Pass control signals
            reg_write_memwb  <= reg_write_idex;
            mem_write_memwb  <= mem_write_idex;
            mem_to_reg_memwb <= mem_to_reg_idex;
            is_jal_memwb     <= is_jal_idex;
            is_jalr_memwb    <= is_jalr_idex;
        end
    end

    // ========================================================================
    // PIPELINE STAGE 3: MEMORY & WRITEBACK (MEM/WB)
    // ========================================================================
    logic [DWIDTH-1:0] mem_data;
    logic [DWIDTH-1:0] write_data;
    logic [DWIDTH-1:0] load_data;

    // Write Logic to accommodate SB, SH, SW
    always_comb begin
        case (funct3_memwb)
            3'b000: begin // SB
                case (alu_result_memwb[1:0])
                    2'b00: write_data = {mem_data[31:8],  reg_data2_memwb[7:0]};
                    2'b01: write_data = {mem_data[31:16], reg_data2_memwb[7:0], mem_data[7:0]};
                    2'b10: write_data = {mem_data[31:24], reg_data2_memwb[7:0], mem_data[15:0]};
                    2'b11: write_data = {reg_data2_memwb[7:0],  mem_data[23:0]};
                endcase
            end
            3'b001: begin // SH
                if (alu_result_memwb[1] == 0)
                    write_data = {mem_data[31:16], reg_data2_memwb[15:0]};
                else
                    write_data = {reg_data2_memwb[15:0], mem_data[15:0]};
            end
            default: write_data = reg_data2_memwb; // SW
        endcase
    end


    dmem #(
        .DWIDTH(DWIDTH),
        .AWIDTH(16),
        .DEPTH(65536),
        .MIF_HEX("dmem.hex")
    ) data_mem (
        .clk  (clk),
        .reset  (reset),
        .d0   (write_data),
        .addr0(alu_result_memwb[15:0]), 
        .we0  (mem_write_memwb),
        .addr1(alu_result_memwb[15:0]), 
        .q1   (mem_data)
    );

    // Read Logic to accommodate LB, LBU, LH, LHU, LW
    always_comb begin
        case (funct3_memwb)
            3'b000: begin // LB
                case (alu_result_memwb[1:0])
                    2'b00: load_data = {{24{mem_data[7]}},  mem_data[7:0]};
                    2'b01: load_data = {{24{mem_data[15]}}, mem_data[15:8]};
                    2'b10: load_data = {{24{mem_data[23]}}, mem_data[23:16]};
                    2'b11: load_data = {{24{mem_data[31]}}, mem_data[31:24]};
                endcase
            end
            3'b100: begin // LBU
                case (alu_result_memwb[1:0])
                    2'b00: load_data = {24'b0, mem_data[7:0]};
                    2'b01: load_data = {24'b0, mem_data[15:8]};
                    2'b10: load_data = {24'b0, mem_data[23:16]};
                    2'b11: load_data = {24'b0, mem_data[31:24]};
                endcase
            end
            3'b001: begin // LH
                if (alu_result_memwb[1] == 0)
                    load_data = {{16{mem_data[15]}}, mem_data[15:0]};
                else
                    load_data = {{16{mem_data[31]}}, mem_data[31:16]};
            end
            3'b101: begin // LHU
                if (alu_result_memwb[1] == 0)
                    load_data = {16'b0, mem_data[15:0]};
                else
                    load_data = {16'b0, mem_data[31:16]};
            end
            default: load_data = mem_data; // LW
        endcase
    end

    // Write Back Selection
    always_comb begin
        if (is_jal_memwb || is_jalr_memwb)       
            write_back_data = pc_memwb + 4; // Return address for jumps
        else if (mem_to_reg_memwb)
            write_back_data = load_data;
        else
            write_back_data = alu_result_memwb;
    end

    always_comb begin
        val0 = data_mem.memory[256];
        val1 = data_mem.memory[260];
        val2 = data_mem.memory[264];
        val3 = data_mem.memory[268];
    end

endmodule
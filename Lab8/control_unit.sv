module control_unit(
    input logic [31:0] instruction,

    output logic [1:0] aluop,
    output logic       pc_write,
    output logic       pc_src,
    output logic       reg_write,
    output logic       imm_sel,
    output logic       mem_to_reg,
    output logic       mem_write,
    output logic       u_sel

);

    logic [6:0] opcode;
    

    always_comb begin

        opcode = instruction[6:0];

        // Default values
        reg_write   = 0;
        aluop     = 2'b00;
        pc_write    = 1; // default: increment PC
        pc_src = 0; // Defualt no jump
        imm_sel = 0; // Defualt reg2 is selected.
        mem_to_reg = 0; // defulat no write from mem to reg
        mem_write = 0;
        u_sel = 0;

        case (opcode)
            
            7'b0110011: begin // R-Type
                reg_write  = 1;
                aluop    = 2'b10;
                imm_sel = 0;
                mem_to_reg = 0;
                mem_write = 0;
            end

            7'b0010011: begin // I-Type arithmetic
                reg_write  = 1;
                aluop    = 2'b11;
                imm_sel = 1;
            end

            7'b0000011: begin // Load instruction I-Type
                reg_write  = 1;
                aluop    = 2'b00;
                imm_sel = 1;
                mem_to_reg = 1; // memory to reg
                mem_write = 0;
            end

            7'b0100011: begin // Store instruction I-Type
                reg_write  = 0;
                aluop    = 2'b00;
                imm_sel = 1;
                mem_to_reg = 0; // memory to reg
                mem_write = 1;
            end

            7'b1100011: begin // Branch (BEQ, BNE, etc.)
                reg_write = 0;
                aluop     = 2'b01; // tells ALU control → comparison
                imm_sel   = 0;     // use reg_data2 (compare registers)
                mem_write = 0;
                mem_to_reg = 0;
                pc_src    = 1;     // indicates branch instruction
            end

            7'b1101111, 7'b1100111: begin // JAL
                reg_write  = 1;   // write return address
                aluop      = 2'b00; // irrelevant here
                imm_sel    = 1;   // not really used
                mem_to_reg = 0;
                mem_write  = 0;

                pc_src     = 1;   // jump instruction
            end

            7'b0110111: begin // LUI instruction
                reg_write = 1;
                aluop     = 2'b00;
                imm_sel   = 1;
                u_sel     = 1;
            end

            default: begin
                reg_write = 0;
                aluop     = 2'b00;
                pc_write  = 1;
                pc_src    = 0;
                imm_sel   = 0;
                mem_to_reg = 0;
                mem_write = 0;
                u_sel     = 0;
            end

        endcase

    end

endmodule
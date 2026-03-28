module control_unit(
    input logic [31:0] instruction,

    output logic [1:0] aluop,
    output logic       pc_write,
    output logic       pc_src,
    output logic       reg_write,
    output logic       imm_sel,
    output logic       mem_to_reg

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

        case (opcode)
            
            7'b0110011: begin // R-Type
                reg_write  = 1;
                aluop    = 2'b10;
                imm_sel = 0;
                mem_to_reg = 0;
            end

            7'b0010011: begin // I-Type arithmetic
                reg_write  = 1;
                aluop    = 2'b11;
                imm_sel = 1;
            end

            7'b0000011: begin // Load instruction I-Type
                reg_write  = 1;
                aluop    = 2'b00;
                mem_to_reg = 1; // memory to reg
            end

            default: begin
                reg_write = 0;
                aluop     = 2'b00;
                pc_write  = 1;
                pc_src    = 0;
                imm_sel   = 0;
                mem_to_reg = 0;
            end

        endcase

    end

endmodule
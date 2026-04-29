
module alu_control_unit (

    input  logic [1:0] aluop,
    input  logic [2:0] funct3,
    input  logic [6:0] funct7,
    output logic [3:0] alu_operation

);

    // Same encodings as ALU
    localparam ALU_AND  = 4'b0000;
    localparam ALU_OR   = 4'b0001;
    localparam ALU_ADD  = 4'b0010;
    localparam ALU_SUB  = 4'b0011;
    localparam ALU_XOR  = 4'b0100;
    localparam ALU_SLT  = 4'b0101;
    localparam ALU_SLTU = 4'b0110;
    localparam ALU_SLL  = 4'b0111;
    localparam ALU_SRL  = 4'b1000;
    localparam ALU_SRA  = 4'b1001;

    always_comb begin

        // Default
        alu_operation = ALU_ADD;

        unique case (aluop)

            
            // Load / Store -> always ADD
          
            2'b00: begin
                alu_operation = ALU_ADD;
            end

      
            // Branch Instructions
      
            2'b01: begin
                case (funct3)
                    3'b000: alu_operation = ALU_SUB;  
                    3'b001: alu_operation = ALU_SUB;  
                    3'b100: alu_operation = ALU_SLT;  
                    3'b101: alu_operation = ALU_SLT;  
                    3'b110: alu_operation = ALU_SLTU; 
                    3'b111: alu_operation = ALU_SLTU; 
                    default: alu_operation = ALU_ADD;
                endcase
            end


            // R-Type Instructions
           
            2'b10: begin
                unique case (funct3)

                    3'b000: begin
                        if (funct7 == 7'b0100000)
                            alu_operation = ALU_SUB;  
                        else
                            alu_operation = ALU_ADD;  
                    end

                    3'b111: alu_operation = ALU_AND;
                    3'b110: alu_operation = ALU_OR;
                    3'b100: alu_operation = ALU_XOR;
                    3'b010: alu_operation = ALU_SLT;
                    3'b011: alu_operation = ALU_SLTU;
                    3'b001: alu_operation = ALU_SLL;

                    3'b101: begin
                        if (funct7 == 7'b0100000)
                            alu_operation = ALU_SRA;  
                        else
                            alu_operation = ALU_SRL;  
                    end

                    default: alu_operation = ALU_ADD;

                endcase
            end

      
            // I-Type Arithmetic Instructions
    
            2'b11: begin
                unique case (funct3)

                    3'b000: alu_operation = ALU_ADD;   
                    3'b111: alu_operation = ALU_AND;   
                    3'b110: alu_operation = ALU_OR;    
                    3'b100: alu_operation = ALU_XOR;   
                    3'b010: alu_operation = ALU_SLT;  
                    3'b011: alu_operation = ALU_SLTU;  
                    3'b001: alu_operation = ALU_SLL;  

                    3'b101: begin
                        if (funct7 == 7'b0100000)
                            alu_operation = ALU_SRA;  
                        else
                            alu_operation = ALU_SRL;  
                    end

                    default: alu_operation = ALU_ADD;

                endcase
            end

            default: alu_operation = ALU_ADD;

        endcase
    end

endmodule
module alu (
    input  logic [31:0] operand1,
    input  logic [31:0] operand2,
    input  logic [3:0]  alu_operation,   
    output logic [31:0] result,
    output logic        zero
);


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
        unique case (alu_operation)

            ALU_AND  : result = operand1 & operand2;
            ALU_OR   : result = operand1 | operand2;
            ALU_ADD  : result = operand1 + operand2;
            ALU_SUB  : result = operand1 - operand2;
            ALU_XOR  : result = operand1 ^ operand2;

            ALU_SLT  : result = {{31{1'b0}}, ($signed(operand1) < $signed(operand2))};

            ALU_SLTU : result = {{31{1'b0}}, (operand1 < operand2)};

            ALU_SLL  : result = operand1 << operand2[4:0];
            ALU_SRL  : result = operand1 >> operand2[4:0];
            ALU_SRA  : result = $signed(operand1) >>> operand2[4:0];

            default  : result = 32'b0;

        endcase
    end

    assign zero = ~|result;  

endmodule
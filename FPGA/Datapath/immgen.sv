module immgen (
    input  logic [31:0] instruction,
    output logic [31:0] imm_ext
);

    logic [6:0] imm_src;

    always_comb begin
        
        imm_src = instruction[6:0];

        case (imm_src)
            7'b0010011, 7'b0000011, 7'b1100111: // I-type (Example completed)
                imm_ext = {{20{instruction[31]}}, instruction[31:20]};

            7'b0100011: // S-type
                imm_ext = {{20{instruction[31]}}, instruction[31:25], instruction[11:7]};
                 // {instruction[31:25], instruction[11:7], {18{instruction[31]}}};

            7'b1100011: // B-type
                imm_ext = {{19{instruction[31]}}, instruction[31], instruction[7], instruction[30:25], instruction[11:8], 1'b0};

            7'b0110111, 7'b0010111: // U-type
                imm_ext = {instruction[31:12], 12'b0};
            7'b1101111: // J-type
                imm_ext = {{12{instruction[31]}}, instruction[19:12], instruction[20], instruction[30:21], 1'b0};

            default:
                imm_ext = 32'h0000_0000;
        endcase
    end

endmodule
module immgen_tb;

    logic [31:0] instruction;
    logic [31:0] imm_ext;

    // DUT
    immgen dut (
        .instruction(instruction),
        .imm_ext(imm_ext)
    );

    // Expected value
    logic [31:0] expected;

    // Task to compute expected immediate
    task compute_expected(input logic [31:0] instr);
        logic [6:0] opcode;
        begin
            opcode = instr[6:0];

            case (opcode)

                // I-Type
                7'b0010011, 7'b0000011, 7'b1100111:
                    expected = {{20{instr[31]}}, instr[31:20]};

                // S-Type
                7'b0100011:
                    expected = {{20{instr[31]}}, instr[31:25], instr[11:7]};

                // B-Type
                7'b1100011:
                    expected = {{19{instr[31]}}, instr[31], instr[7],
                                instr[30:25], instr[11:8], 1'b0};

                // U-Type
                7'b0110111, 7'b0010111:
                    expected = {instr[31:12], 12'b0};

                // J-Type
                7'b1101111:
                    expected = {{12{instr[31]}}, instr[19:12], instr[20],
                                instr[30:21], 1'b0};

                default:
                    expected = 32'h0;

            endcase
        end
    endtask

    // Task to generate random instruction of a given type
    task gen_random_instr(input logic [6:0] opcode);
        begin
            instruction = $random;
            instruction[6:0] = opcode;
        end
    endtask

    // Main test
    initial begin
        int i;

        $display("Starting IMMGEN Test...");

        // Run multiple random tests
        for (i = 0; i < 100; i++) begin

            // Randomly pick a type
            case ($urandom_range(0,4))
                0: gen_random_instr(7'b0010011); // I
                1: gen_random_instr(7'b0100011); // S
                2: gen_random_instr(7'b1100011); // B
                3: gen_random_instr(7'b0110111); // U
                4: gen_random_instr(7'b1101111); // J
            endcase

            #1; // wait for combinational logic

            compute_expected(instruction);

            if (imm_ext !== expected) begin
                $display("FAIL");
                $display("Instruction = %h", instruction);
                $display("Expected    = %h", expected);
                $display("Got         = %h", imm_ext);
                $stop;
            end
        end

        $display("All tests PASSED!");
        // $finish;
        $stop;
    end

endmodule
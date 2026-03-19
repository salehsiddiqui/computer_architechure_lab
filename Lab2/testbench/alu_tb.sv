`timescale 1ns/1ps


module alu_tb;

    logic [31:0] operand1;
    logic [31:0] operand2;
    logic [3:0]  alu_operation;
    logic [31:0] result;
    logic        zero;


    alu dut (
        .operand1     (operand1),
        .operand2     (operand2),
        .alu_operation(alu_operation),
        .result       (result),
        .zero         (zero)
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

    int pass_count = 0;
    int fail_count = 0;

    logic [31:0] expected;
    logic        expected_zero;

    task automatic check(
        input logic [31:0] op1,
        input logic [31:0] op2,
        input logic [3:0]  op,
        input logic [31:0] exp_result,
        input string       op_name
    );
        operand1      = op1;
        operand2      = op2;
        alu_operation = op;
        #10;

        if (result !== exp_result) begin
            $display("FAIL | %-5s | op1=0x%08h op2=0x%08h | expected=0x%08h got=0x%08h",
                     op_name, op1, op2, exp_result, result);
            fail_count++;
        end else begin
            pass_count++;
        end

    
        if (zero !== (exp_result == 32'b0)) begin
            $display("FAIL | %-5s | zero flag wrong | result=0x%08h zero=%b",
                     op_name, exp_result, zero);
            fail_count++;
        end else begin
            pass_count++;
        end
    endtask

    task run_directed_tests();
        $display("\n=== Directed Tests ===");

        // AND
        check(32'hFFFFFFFF, 32'h0F0F0F0F, ALU_AND, 32'h0F0F0F0F, "AND");
        check(32'hAAAAAAAA, 32'h55555555, ALU_AND, 32'h00000000, "AND");

        // OR
        check(32'hAAAAAAAA, 32'h55555555, ALU_OR,  32'hFFFFFFFF, "OR");
        check(32'h00000000, 32'h00000000, ALU_OR,  32'h00000000, "OR");

        // ADD
        check(32'h00000001, 32'h00000001, ALU_ADD, 32'h00000002, "ADD");
        check(32'hFFFFFFFF, 32'h00000001, ALU_ADD, 32'h00000000, "ADD"); // overflow wrap

        // SUB (zero flag)
        check(32'h00000005, 32'h00000005, ALU_SUB, 32'h00000000, "SUB");
        check(32'h00000010, 32'h00000001, ALU_SUB, 32'h0000000F, "SUB");

        // XOR
        check(32'hFFFFFFFF, 32'hFFFFFFFF, ALU_XOR, 32'h00000000, "XOR");
        check(32'hA5A5A5A5, 32'h5A5A5A5A, ALU_XOR, 32'hFFFFFFFF, "XOR");

        // SLT signed
        check(32'hFFFFFFFF, 32'h00000001, ALU_SLT, 32'h00000001, "SLT");  // -1 < 1
        check(32'h00000001, 32'hFFFFFFFF, ALU_SLT, 32'h00000000, "SLT");  // 1 > -1

        // SLTU unsigned
        check(32'hFFFFFFFF, 32'h00000001, ALU_SLTU, 32'h00000000, "SLTU"); // big > 1
        check(32'h00000001, 32'hFFFFFFFF, ALU_SLTU, 32'h00000001, "SLTU"); // 1 < big

        // SLL
        check(32'h00000001, 32'h00000004, ALU_SLL, 32'h00000010, "SLL");
        check(32'h00000001, 32'h0000001F, ALU_SLL, 32'h80000000, "SLL");

        // SRL
        check(32'h80000000, 32'h00000001, ALU_SRL, 32'h40000000, "SRL");
        check(32'hFFFFFFFF, 32'h00000004, ALU_SRL, 32'h0FFFFFFF, "SRL");

        // SRA (arithmetic — sign bit preserved)
        check(32'h80000000, 32'h00000001, ALU_SRA, 32'hC0000000, "SRA");
        check(32'hFFFFFFFF, 32'h00000004, ALU_SRA, 32'hFFFFFFFF, "SRA");
    endtask

    // ─── Randomized tests ─────────────────────────────────────
    task run_random_tests(input int num_tests);
        logic [31:0] op1, op2, exp;
        logic [3:0]  op;
        logic [4:0]  shamt;
        string op_name;

        $display("\n=== Randomized Tests (%0d iterations) ===", num_tests);

        repeat (num_tests) begin
            op1 = $urandom();
            op2 = $urandom();
            op  = $urandom_range(0, 9);

            case (op)
                ALU_AND : begin exp = op1 & op2;                                   op_name = "AND";  end
                ALU_OR  : begin exp = op1 | op2;                                   op_name = "OR";   end
                ALU_ADD : begin exp = op1 + op2;                                   op_name = "ADD";  end
                ALU_SUB : begin exp = op1 - op2;                                   op_name = "SUB";  end
                ALU_XOR : begin exp = op1 ^ op2;                                   op_name = "XOR";  end
                ALU_SLT : begin exp = ($signed(op1) < $signed(op2)) ? 32'd1:32'd0; op_name = "SLT";  end
                ALU_SLTU: begin exp = (op1 < op2) ? 32'd1 : 32'd0;                op_name = "SLTU"; end
                ALU_SLL : begin exp = op1 << op2[4:0];                            op_name = "SLL";  end
                ALU_SRL : begin exp = op1 >> op2[4:0];                            op_name = "SRL";  end
                ALU_SRA : begin exp = $signed(op1) >>> op2[4:0];                  op_name = "SRA";  end
                default : exp = 32'b0;
            endcase

            check(op1, op2, op, exp, op_name);
        end
    endtask
    initial begin
        $display("========================================");
        $display("  ALU Testbench");
        $display("========================================");

        operand1      = 0;
        operand2      = 0;
        alu_operation = 0;
        #10;

        run_directed_tests();
        run_random_tests(500);

        $display("\n========================================");
        $display("  Results: %0d PASSED | %0d FAILED", pass_count, fail_count);
        $display("========================================\n");

        if (fail_count == 0)
            $display("ALL TESTS PASSED");
        else
            $display("SOME TESTS FAILED — review output above");

        $finish;
    end

endmodule

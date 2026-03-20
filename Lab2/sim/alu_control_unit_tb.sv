`timescale 1ns/1ps

module alu_control_unit_tb;

    logic [1:0] aluop;
    logic [2:0] funct3;
    logic [6:0] funct7;
    logic [3:0] alu_operation;

    // DUT
    alu_control_unit dut (
        .aluop(aluop),
        .funct3(funct3),
        .funct7(funct7),
        .alu_operation(alu_operation)
    );

    // ALU encodings (must match alu.sv)
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


    // ===============================
    // Reference Model
    // ===============================
    task automatic [3:0] reference_model;

        input [1:0] aluop_i;
        input [2:0] funct3_i;
        input [6:0] funct7_i;

        case (aluop_i)

            2'b00: return ALU_ADD;

            2'b01: begin
                case (funct3_i)
                    3'b000,3'b001: return ALU_SUB;
                    3'b100,3'b101: return ALU_SLT;
                    3'b110,3'b111: return ALU_SLTU;
                    default: return ALU_ADD;
                endcase
            end

            2'b10,2'b11: begin
                case (funct3_i)
                    3'b000: return (funct7_i==7'b0100000)?ALU_SUB:ALU_ADD;
                    3'b111: return ALU_AND;
                    3'b110: return ALU_OR;
                    3'b100: return ALU_XOR;
                    3'b010: return ALU_SLT;
                    3'b011: return ALU_SLTU;
                    3'b001: return ALU_SLL;
                    3'b101: return (funct7_i==7'b0100000)?ALU_SRA:ALU_SRL;
                    default:return ALU_ADD;
                endcase
            end

            default: return ALU_ADD;

        endcase

    endtask


    // ===============================
    // Checker Task
    // ===============================
    task check_output;
        input [3:0] expected;
        begin
            #1;
            if (alu_operation !== expected)
                $display("FAIL: aluop=%b funct3=%b funct7=%b -> got=%b expected=%b",
                         aluop,funct3,funct7,alu_operation,expected);
            else
                $display("PASS");
        end
    endtask


    // ===============================
    // Directed Tests
    // ===============================
    task directed_tests;
        begin
            $display("\n===== DIRECTED TESTING =====");

            aluop=2'b00; funct3=3'b000; funct7=7'b0000000;
            check_output(ALU_ADD);

            aluop=2'b01; funct3=3'b000;
            check_output(ALU_SUB);

            aluop=2'b10; funct3=3'b000; funct7=7'b0000000;
            check_output(ALU_ADD);

            aluop=2'b10; funct3=3'b000; funct7=7'b0100000;
            check_output(ALU_SUB);

            aluop=2'b10; funct3=3'b111;
            check_output(ALU_AND);

            aluop=2'b10; funct3=3'b110;
            check_output(ALU_OR);

            aluop=2'b10; funct3=3'b100;
            check_output(ALU_XOR);

            aluop=2'b10; funct3=3'b010;
            check_output(ALU_SLT);

            aluop=2'b10; funct3=3'b011;
            check_output(ALU_SLTU);

            aluop=2'b10; funct3=3'b001;
            check_output(ALU_SLL);

            aluop=2'b10; funct3=3'b101; funct7=7'b0000000;
            check_output(ALU_SRL);

            aluop=2'b10; funct3=3'b101; funct7=7'b0100000;
            check_output(ALU_SRA);

        end
    endtask


    // ===============================
    // Randomized Tests
    // ===============================
    task random_tests;
        integer i;
        begin
            $display("\n===== RANDOMIZED TESTING =====");

            for (i=0;i<200;i++) begin

                aluop  = $urandom_range(0,3);
                funct3 = $urandom_range(0,7);
                funct7 = $urandom;

                #1;

                if (alu_operation !== reference_model(aluop,funct3,funct7)) begin
                    $display(" RANDOM FAIL: aluop=%b funct3=%b funct7=%b",
                             aluop,funct3,funct7);
                end

            end

            $display("Random Testing Completed");

        end
    endtask


    // ===============================
    // Run Tests
    // ===============================
    initial begin

        directed_tests();

        random_tests();

        $display("\n===== TESTING FINISHED =====");

        $finish;

    end

endmodule
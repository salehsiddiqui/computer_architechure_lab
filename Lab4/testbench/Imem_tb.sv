`timescale 1ns/1ps

module imem_tb;

    parameter DWIDTH = 32;
    parameter AWIDTH = 8;
    parameter DEPTH  = 256;

    logic clk;
    logic [AWIDTH-1:0] addr1;
    logic [DWIDTH-1:0] q1;

    // DUT
    imem #(
        .DWIDTH(DWIDTH),
        .AWIDTH(AWIDTH),
        .DEPTH(DEPTH),
        .MIF_HEX("imem.hex")   // file to load
    ) dut (
        .clk(clk),
        .addr1(addr1),
        .q1(q1)
    );

    // Clock (not really needed, but kept for consistency)
    always #5 clk = ~clk;

    // Reference memory
    logic [DWIDTH-1:0] ref_mem [0:DEPTH-1];

    integer i;

    // Task: check
    task check(input [31:0] expected, input [31:0] actual);
        begin
            if (expected !== actual) begin
                $display("FAIL at addr %0d", addr1);
                $display("Expected: %h, Got: %h", expected, actual);
                $stop;
            end else begin
                $display("PASS addr %0d → %h", addr1, actual);
            end
        end
    endtask

    initial begin
        clk = 0;

        for (i = 0; i < DEPTH; i = i + 1) begin
            ref_mem[i] = 0;
        end

        // Load same file into reference model
        $readmemh("imem.hex", ref_mem);

        $display("Starting IMEM Test...");

        // ---------------------------
        // Sequential check
        // ---------------------------
        for (i = 0; i < DEPTH; i++) begin
            addr1 = i;
            #1;
            check(ref_mem[i], q1);
        end

        // ---------------------------
        // Random testing
        // ---------------------------
        for (i = 0; i < 100; i++) begin
            addr1 = $urandom_range(0, DEPTH-1);
            #1;
            check(ref_mem[addr1], q1);
        end

        $display("ALL TESTS PASSED!");
        $stop;
    end

endmodule
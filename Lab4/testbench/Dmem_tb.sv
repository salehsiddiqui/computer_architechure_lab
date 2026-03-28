`timescale 1ns/1ps

module dmem_tb;

    parameter DWIDTH = 32;
    parameter AWIDTH = 8;
    parameter DEPTH  = 256;

    logic clk;
    logic we0;

    logic [DWIDTH-1:0] d0;
    logic [AWIDTH-1:0] addr0;

    logic [AWIDTH-1:0] addr1;
    logic [DWIDTH-1:0] q1;

    // DUT
    dmem #(
        .DWIDTH(DWIDTH),
        .AWIDTH(AWIDTH),
        .DEPTH(DEPTH)
    ) dut (
        .clk(clk),
        .d0(d0),
        .addr0(addr0),
        .we0(we0),
        .q1(q1),
        .addr1(addr1)
    );

    // Clock
    always #5 clk = ~clk;

    // Reference model
    logic [31:0] ref_mem [0:DEPTH-1];

    integer i;

    // Check task
    task check(input [31:0] expected, input [31:0] actual, input string msg);
        begin
            if (expected !== actual) begin
                $display("FAIL: %s", msg);
                $display("Expected: %h, Got: %h", expected, actual);
                $stop;
            end else begin
                $display("PASS: %s | %h", msg, actual);
            end
        end
    endtask

    initial begin
        clk = 0;
        we0 = 0;
        d0 = 0;
        addr0 = 0;
        addr1 = 0;

        // Initialize reference memory
        for (i = 0; i < DEPTH; i++) begin
            ref_mem[i] = 0;
        end

        $display("Starting DMEM Test...");

        // ---------------------------
        // Test 1: Initial state
        // ---------------------------
        addr1 = 10;
        #1;
        check(ref_mem[10], q1, "Initial read");

        // ---------------------------
        // Test 2: Single write
        // ---------------------------
        we0 = 1;
        addr0 = 5;
        d0 = 32'hDEADBEEF;
        ref_mem[5] = d0;

        #10; // clock edge

        we0 = 0;
        addr1 = 5;
        #1;
        check(ref_mem[5], q1, "Write/Read");

        #10;
        we0 = 1;
        #10;
        we0 = 0;
        addr1 = 11;
        #10;
        check(ref_mem[11], q1, "Write/Read with wwe0 = 0");

        #10;

        // ---------------------------
        // Test 3: Multiple writes
        // ---------------------------
        for (i = 0; i < 10; i++) begin
            we0 = 1;
            addr0 = i;
            d0 = i * 10;
            ref_mem[i] = d0;
            #10;
        end

        we0 = 0;

        for (i = 0; i < 10; i++) begin
            addr1 = i;
            #1;
            check(ref_mem[i], q1, "Sequential read");
        end

        // ---------------------------
        // Test 4: Random testing
        // ---------------------------
        for (i = 0; i < 100; i++) begin
            // Random write
            we0 = 1;
            addr0 = $urandom_range(0, DEPTH-1);
            d0 = $random;
            ref_mem[addr0] = d0;

            #10;

            // Random read
            we0 = 0;
            addr1 = $urandom_range(0, DEPTH-1);

            #1;

            check(ref_mem[addr1], q1, "Random test");
        end

        $display("ALL TESTS PASSED!");
        $stop;
    end

endmodule
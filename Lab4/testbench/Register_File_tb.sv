`timescale 1ns/1ps

module register_file_tb;

    parameter DWIDTH = 32;
    parameter AWIDTH = 5;

    logic clk;
    logic we0;

    logic [DWIDTH-1:0] d0;
    logic [AWIDTH-1:0] addr0;

    logic [AWIDTH-1:0] addr1, addr2;
    logic [DWIDTH-1:0] q1, q2;

    // DUT
    register_file dut (
        .clk(clk),
        .d0(d0),
        .addr0(addr0),
        .we0(we0),
        .q1(q1),
        .addr1(addr1),
        .q2(q2),
        .addr2(addr2)
    );

    // Clock
    always #5 clk = ~clk;

    // Reference model (golden model)
    logic [31:0] ref_mem [0:31];

    // Check task
    task check(input [31:0] expected, input [31:0] actual, input string msg);
        begin
            if (expected !== actual) begin
                $display("FAIL: %s", msg);
                $display("Expected: %h, Got: %h", expected, actual);
                $stop;
            end else begin
                $display("PASS: %s | Value = %h", msg, actual);
            end
        end
    endtask

    integer i;

    initial begin
        clk = 0;
        we0 = 0;
        d0 = 0;
        addr0 = 0;
        addr1 = 0;
        addr2 = 0;

        // Initialize reference model
        for (i = 0; i < 32; i++) begin
            ref_mem[i] = 0;
        end

        $display("Starting Register File Test...");

        // ---------------------------
        // Test 1: x0 always zero
        // ---------------------------
        addr1 = 0;
        #1;
        check(0, q1, "x0 read");

        // Try writing to x0
        we0 = 1;
        addr0 = 0;
        d0 = 32'hDEADBEEF;
        #10;

        addr1 = 0;
        #1;
        check(0, q1, "x0 write ignored");

        we0 = 0;

        // ---------------------------
        // Test 2: Write + Read
        // ---------------------------
        we0 = 1;
        addr0 = 5'd5;
        d0 = 32'h12345678;
        ref_mem[5] = d0;

        #10;

        we0 = 0;
        addr1 = 5'd5;
        #1;
        check(ref_mem[5], q1, "Write/Read reg[5]");

        // ---------------------------
        // Test 3: Dual read
        // ---------------------------
        we0 = 1;
        addr0 = 5'd10;
        d0 = 32'hAAAA5555;
        ref_mem[10] = d0;
        #10;

        we0 = 0;
        addr1 = 5'd5;
        addr2 = 5'd10;
        #1;
        check(ref_mem[5], q1, "Read port 1");
        check(ref_mem[10], q2, "Read port 2");

        // ---------------------------
        // Test 4: Random testing
        // ---------------------------
        for (i = 0; i < 50; i++) begin
            we0 = 1;
            addr0 = $urandom_range(1,31); // avoid x0
            d0 = $random;
            ref_mem[addr0] = d0;

            #10;

            we0 = 0;

            addr1 = $urandom_range(0,31);
            addr2 = $urandom_range(0,31);

            #1;

            check((addr1==0)?0:ref_mem[addr1], q1, "Random Read q1");
            check((addr2==0)?0:ref_mem[addr2], q2, "Random Read q2");
        end

        $display("ALL TESTS PASSED!");
        $stop;
    end

endmodule
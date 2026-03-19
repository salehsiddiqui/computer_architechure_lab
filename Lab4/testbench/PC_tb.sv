`timescale 1ns/1ps

module pc_tb;

    logic clk;
    logic reset;
    logic pc_write;
    logic [31:0] load_value;
    logic [31:0] address;

    // DUT
    program_counter dut (
        .clk(clk),
        .reset(reset),
        .pc_write(pc_write),
        .load_value(load_value),
        .address(address)
    );

    // Clock generation (10ns period)
    always #5 clk = ~clk;

    // Task: check expected value
    task check(input [31:0] expected);
        begin
            #1;
            if (address !== expected) begin
                $display("FAIL at time %0t", $time);
                $display("Expected: %h, Got: %h", expected, address);
                $stop;
            end else begin
                $display("✅ PASS at time %0t | Address = %h", $time, address);
            end
        end
    endtask

    initial begin
        // Initialize
        clk = 0;
        reset = 1;
        pc_write = 0;
        load_value = 0;

        $display("Starting Program Counter Test...");

        // ---------------------------
        // Test 1: Reset
        // ---------------------------
        #10;
        check(32'h00000000);

        // ---------------------------
        // Test 2: Increment
        // ---------------------------
        reset = 0;

        @(posedge clk); check(32'h00000004);
        @(posedge clk); check(32'h00000008);
        @(posedge clk); check(32'h0000000C);

        // ---------------------------
        // Test 3: Load (Jump)
        // ---------------------------
        pc_write = 1;
        load_value = 32'h00000064; // 100

        @(posedge clk);
        check(32'h00000064);

        // ---------------------------
        // Test 4: Continue increment
        // ---------------------------
        pc_write = 0;

        @(posedge clk); check(32'h00000068);
        @(posedge clk); check(32'h0000006C);

        // ---------------------------
        // Test 5: Another jump
        // ---------------------------
        pc_write = 1;
        load_value = 32'h00000020;

        @(posedge clk);
        check(32'h00000020);
        pc_write = 0;

        repeat(3) @(posedge clk);

        $display("All tests PASSED!");
        $stop;
    end

endmodule
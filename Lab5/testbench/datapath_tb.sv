// This testbench will:

// Reset PC
// Run clock
// Show PC + instruction
// Verify instruction fetch works

`timescale 1ns/1ps

module datapath_tb;

    logic clk;
    logic reset;

    // Instantiate DUT
    datapath dut (
        .clk(clk),
        .reset(reset)
    );

    // Clock generation
    always #5 clk = ~clk;

    initial begin
        clk = 0;
        reset = 1;

        $display("Starting Datapath Test...");

        // Release reset
        #10;
        // @(posedge clk);
        reset = 0;

        // Run for some cycles
        repeat (10) begin
            // #10;
            @(posedge clk);

            $display("Time=%0t | PC=%h | Instruction=%h",
                $time,
                dut.address,
                dut.instruction
            );
        end

        $display("Test finished.");
        $stop;
    end

endmodule
module program_counter(
    
    input logic clk,
    input logic reset,

    input logic pc_write,
    input logic [31:0] load_value,

    output logic [31:0] address
);
    
    logic [31:0] counter;

    always_ff @(posedge clk or posedge reset) begin
        if (reset) begin
            counter = 32'b0;
        end else if (pc_write) begin
            counter <= load_value;
        end else begin
            counter <= counter + 4;
        end

    end

    always_comb begin
        address = counter;
    end

endmodule
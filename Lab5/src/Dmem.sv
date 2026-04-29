// Multi-port RAM with two asynchronous-read ports, one synchronous-write port
module dmem(d0, addr0, we0, q1, addr1, clk);
  parameter DWIDTH = 32;  // Data width
  parameter AWIDTH = 8;   // Address width
  parameter DEPTH =  256; //(1 << AWIDTH); // Memory depth
  parameter MIF_HEX = "";
  parameter MIF_BIN = "";
  input clk;

  input [DWIDTH-1:0] d0;    // Data input
  input [AWIDTH-1:0] addr0; // Address input
  input              we0;   // Write enable

  input [AWIDTH-1:0] addr1; // Address input
  output [DWIDTH-1:0] q1;

  (* ram_style = "distributed" *) reg [DWIDTH-1:0] mem_d [0:DEPTH-1];

  integer i;
  initial begin

    for (i = 0; i < DEPTH; i = i + 1) begin
        mem_d[i] = 0;
    end

    if (MIF_HEX != "") begin
      $readmemh(MIF_HEX, mem_d);
    end
    else if (MIF_BIN != "") begin
      $readmemb(MIF_BIN, mem_d);
    end
  end

  always @(posedge clk) begin
    if (we0)
      mem_d[addr0] <= d0;
  end

  assign q1 = mem_d[addr1];

endmodule
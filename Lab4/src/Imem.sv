// Multi-port RAM with two asynchronous-read ports, one synchronous-write port
module imem(q1, addr1, clk);
  parameter DWIDTH = 32;  // Data width
  parameter AWIDTH = 8;  // Address width
  parameter DEPTH =  256; //(1 << AWIDTH); // Memory depth
  parameter MIF_HEX = "imem.hex";
  parameter MIF_BIN = "";
  input clk;

  input [AWIDTH-1:0] addr1; // Address input
  output [DWIDTH-1:0] q1;

  (* ram_style = "distributed" *) reg [DWIDTH-1:0] mem [0:DEPTH-1];

  integer i;
  initial begin

    for (i = 0; i < DEPTH; i = i + 1) begin
        mem[i] = 0;
    end

    if (MIF_HEX != "") begin
      $readmemh(MIF_HEX, mem);
    end
    else if (MIF_BIN != "") begin
      $readmemb(MIF_BIN, mem);
    end
  end

  assign q1 = mem[addr1];

endmodule
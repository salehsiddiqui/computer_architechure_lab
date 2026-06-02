// Multi-port RAM with two asynchronous-read ports, one synchronous-write port
module imem(q1, addr1, clk);
  parameter DWIDTH = 32;  // Data width
  parameter AWIDTH = 16;  // Address width
  parameter DEPTH =  65536; //(1 << AWIDTH); // Memory depth
  parameter MIF_HEX = "imem.hex";
  parameter MIF_BIN = "";
  input clk;

  input [AWIDTH-1:0] addr1; // Address input
  output [DWIDTH-1:0] q1;

  // (* ram_style = "distributed" *) reg [DWIDTH-1:0] mem_i [0:DEPTH-1];
  (* ram_style = "distributed" *) reg [DWIDTH-1:0] memory [0:DEPTH-1];

  integer i;
  initial begin

    for (i = 0; i < DEPTH; i = i + 1) begin
        // mem_i[i] = 0;
        memory[i] = 0;
    end

    if (MIF_HEX != "") begin
      // $readmemh(MIF_HEX, mem_i);
      $readmemh(MIF_HEX, memory);
    end
    else if (MIF_BIN != "") begin
      // $readmemb(MIF_BIN, mem_i);
      $readmemb(MIF_BIN, memory);
    end
  end

  // assign q1 = mem_i[addr1];
  assign q1 = memory[addr1];

endmodule
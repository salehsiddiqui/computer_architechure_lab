// Multi-port RAM with two asynchronous-read ports, one synchronous-write port
module dmem(d0, addr0, we0, q1, addr1, clk, reset);
  parameter DWIDTH = 32;  // Data width
  parameter AWIDTH = 9;   // Address width
  parameter DEPTH =  (1 << AWIDTH); // Memory depth
  parameter MIF_HEX = "dmem.hex";
  parameter MIF_BIN = "";
  input clk;
  input reset;

  input [DWIDTH-1:0] d0;    // Data input
  input [AWIDTH-1:0] addr0; // Address input
  input              we0;   // Write enable

  input [AWIDTH-1:0] addr1; // Address input
  output [DWIDTH-1:0] q1;

  // (* ram_style = "distributed" *) reg [DWIDTH-1:0] mem_d [0:DEPTH-1];
  (* ram_style = "distributed" *) reg [DWIDTH-1:0] memory [0:DEPTH-1];

  // integer i;
  // initial begin

  //   for (i = 0; i < DEPTH; i = i + 1) begin
  //       // mem_d[i] = 0;
  //       memory[i] = 0;
  //   end

  //   if (MIF_HEX != "") begin
  //     // $readmemh(MIF_HEX, mem_d);
  //     $readmemh(MIF_HEX, memory);
  //   end
  //   else if (MIF_BIN != "") begin
  //     // $readmemb(MIF_BIN, mem_d);
  //     $readmemb(MIF_BIN, memory);
  //   end
  // end

  always @(posedge clk or posedge reset) begin
  // always @(posedge clk) begin
    if (reset)begin
      memory[256] = 32'h2; 
      memory[260] = 32'h4;
      memory[264] = 32'h1;
      memory[268] = 32'h3;
    end
    else if (we0)
      // mem_d[addr0] <= d0;
      memory[addr0] <= d0;
  end

  // assign q1 = mem_d[addr1];
  assign q1 = memory[addr1];

endmodule
// Multi-port RAM with two asynchronous-read ports, one synchronous-write port
module register_file(d0, addr0, we0, q1, addr1, q2, addr2, clk);
  parameter DWIDTH = 32;  // Data width
  parameter AWIDTH =  5;  // Address width
  parameter DEPTH =  32;  // (1 << AWIDTH) Memory depth

  input clk;

  input [DWIDTH-1:0] d0;    // Data input
  input [AWIDTH-1:0] addr0; // Address input
  input              we0;   // Write enable

  input [AWIDTH-1:0] addr1; // Address input
  output [DWIDTH-1:0] q1;

  input [AWIDTH-1:0] addr2; // Address input
  output [DWIDTH-1:0] q2;

  reg [DWIDTH-1:0] reg_file [0:DEPTH-1];

  integer i;
  initial begin
      for (i = 0; i < DEPTH; i = i + 1) begin
        reg_file[i] = 0;
      end
  end


  // Write (synchronous)
  always @(posedge clk) begin
    if (we0 && addr0 != 5'd0)
      reg_file[addr0] <= d0;
  end

  // Read (asynchronous)
  assign q1 = (addr1 == 0) ? {DWIDTH{1'b0}} : reg_file[addr1];
  assign q2 = (addr2 == 0) ? {DWIDTH{1'b0}} : reg_file[addr2];

endmodule
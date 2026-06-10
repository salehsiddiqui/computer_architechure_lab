// Multi-port RAM with two asynchronous-read ports, one synchronous-write port
module imem(q1, addr1, clk, reset);
  parameter DWIDTH = 32;  // Data width
  parameter AWIDTH = 16;  // Address width
  parameter DEPTH =  65536; //(1 << AWIDTH); // Memory depth
  parameter MIF_HEX = "imem.hex";
  parameter MIF_BIN = "";
  input clk;
  input reset;

  input [AWIDTH-1:0] addr1; // Address input
  output [DWIDTH-1:0] q1;

  // (* ram_style = "distributed" *) reg [DWIDTH-1:0] mem_i [0:DEPTH-1];
  (* ram_style = "distributed" *) reg [DWIDTH-1:0] memory [0:DEPTH-1];

  // integer i;
  // initial begin

  //   for (i = 0; i < DEPTH; i = i + 1) begin
  //       // mem_i[i] = 0;
  //       memory[i] = 0;
  //   end

  //   if (MIF_HEX != "") begin
  //     // $readmemh(MIF_HEX, mem_i);
  //     $readmemh(MIF_HEX, memory);
  //   end
  //   else if (MIF_BIN != "") begin
  //     // $readmemb(MIF_BIN, mem_i);
  //     $readmemb(MIF_BIN, memory);
  //   end
  // end

  always_ff @(posedge clk or posedge reset) begin
    if (reset) begin
      memory[0] = 32'h00000537;
      memory[1] = 32'h10050513;
      memory[2] = 32'h00200293;
      memory[3] = 32'h00552023;
      memory[4] = 32'h00400293;
      memory[5] = 32'h00552223;
      memory[6] = 32'h00100293;
      memory[7] = 32'h00552423;
      memory[8] = 32'h00300293;
      memory[9] = 32'h00552623;
      memory[10] = 32'h00400593;
      memory[11] = 32'h008000ef;
      memory[12] = 32'h0000006f;
      memory[13] = 32'h00100293;
      memory[14] = 32'h04b2d463;
      memory[15] = 32'h00229e13;
      memory[16] = 32'h01c50e33;
      memory[17] = 32'h000e2383;
      memory[18] = 32'hfff28313;
      memory[19] = 32'h02034063;
      memory[20] = 32'h00231e13;
      memory[21] = 32'h01c50e33;
      memory[22] = 32'h000e2e83;
      memory[23] = 32'h01d3d863;
      memory[24] = 32'h01de2223;
      memory[25] = 32'hfff30313;
      memory[26] = 32'hfe5ff06f;
      memory[27] = 32'h00231e13;
      memory[28] = 32'h01c50e33;
      memory[29] = 32'h007e2223;
      memory[30] = 32'h00128293;
      memory[31] = 32'hfbdff06f;
      memory[32] = 32'h00008067;
    end
  end

  // assign q1 = mem_i[addr1];
  assign q1 = memory[addr1];

endmodule
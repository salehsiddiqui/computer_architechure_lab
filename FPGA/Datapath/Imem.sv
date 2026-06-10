// Multi-port RAM with two asynchronous-read ports, one synchronous-write port
module imem(q1, addr1, clk, reset);
  parameter DWIDTH = 32;  // Data width
  parameter AWIDTH = 8;  // Address width
  parameter DEPTH =  (1 << AWIDTH); // Memory depth
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
      memory[0]  = 32'h00000093;
      memory[1]  = 32'h00400113;
      memory[2]  = 32'h00100193;
      memory[3]  = 32'h0021A433;
      memory[4]  = 32'h06040063;
      memory[5]  = 32'h00219313;
      memory[6]  = 32'h00608333;
      memory[7]  = 32'h00032283;
      memory[8]  = 32'hFFF18213;
      memory[9]  = 32'h00022433;
      memory[10] = 32'h02041863;
      memory[11] = 32'h00221313;
      memory[12] = 32'h00608333;
      memory[13] = 32'h00032383;
      memory[14] = 32'h0072A433;
      memory[15] = 32'h00040E63;
      memory[16] = 32'h00120513;
      memory[17] = 32'h00251593;
      memory[18] = 32'h00B085B3;
      memory[19] = 32'h0075A023;
      memory[20] = 32'hFFF20213;
      memory[21] = 32'hFD1FF06F;
      memory[22] = 32'h00120513;
      memory[23] = 32'h00251593;
      memory[24] = 32'h00B085B3;
      memory[25] = 32'h0055A023;
      memory[26] = 32'h00118193;
      memory[27] = 32'hFA1FF06F;
      memory[28] = 32'h0000006F;
    end
  end

  // assign q1 = mem_i[addr1];
  assign q1 = memory[addr1];

endmodule
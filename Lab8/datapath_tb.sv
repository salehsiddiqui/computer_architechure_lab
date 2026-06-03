`timescale 1ns/1ps

module datapath_tb();

    // Clock and Reset Signals
    logic clk;
    logic reset;

    // Instantiate the Top-Level Datapath
    datapath dut (
        .clk(clk),
        .reset(reset)
    );

    // Clock Generation (10ns period / 100MHz)
    always #5 clk = ~clk;

    initial begin
        // --------------------------------------------------------------------
        // 1. GENERATE THE ADVANCED TEST PROGRAM (imem.hex)
        // --------------------------------------------------------------------
        int fd;
        fd = $fopen("imem.hex", "w");
        
        if (fd == 0) begin
            $display("ERROR: Could not create imem.hex");
            $stop;
        end

        // --- SECTION 1: LUI & Basic Data Hazards ---
        // 0x00: lui x1, 4         (000040b7) - x1 gets 0x00004000
        $fdisplay(fd, "000040b7");
        // 0x04: addi x1, x1, 4    (00408093) - x1 gets 0x00004004 (Forwarding test)
        $fdisplay(fd, "00408093");
        
        // --- SECTION 2: Load-Use Data Hazard ---
        // 0x08: sw x1, 0(x0)      (00102023) - Store 0x4004 at Mem[0]
        $fdisplay(fd, "00102023");
        // 0x0C: lw x2, 0(x0)      (00002103) - Load 0x4004 into x2
        $fdisplay(fd, "00002103");
        // 0x10: addi x3, x2, 1    (00110193) - EXTREME HAZARD: x3 = x2 + 1. x2 must forward immediately from MEM/WB.
        $fdisplay(fd, "00110193"); 

        // --- SECTION 3: ALU-to-ALU Data Forwarding ---
        // 0x14: addi x4, x0, 10   (00a00213) - x4 = 10
        $fdisplay(fd, "00a00213");
        // 0x18: addi x5, x4, 5    (00520293) - x5 = x4 + 5 = 15 (Forwarding x4)
        $fdisplay(fd, "00520293");
        // 0x1C: add x6, x5, x4    (00428333) - x6 = 15 + 10 = 25 (Forwarding both x4 and x5)
        $fdisplay(fd, "00428333");

        // --- SECTION 4: Control Hazards (Branches) ---
        // 0x20: beq x0, x4, 8     (00400463) - 0 == 10? FALSE. Branch NOT taken. Should NOT flush.
        $fdisplay(fd, "00400463");
        // 0x24: addi x7, x0, 1    (00100393) - This MUST execute. x7 = 1.
        $fdisplay(fd, "00100393");
        // 0x28: bne x4, x0, 8     (00021463) - 10 != 0? TRUE. Branch TAKEN.
        $fdisplay(fd, "00021463");
        // 0x2C: addi x7, x0, 99   (06300393) - HAZARD: This MUST be flushed. x7 stays 1.
        $fdisplay(fd, "06300393");
        
        // --- SECTION 5: Control Hazards (Jumps & Link) ---
        // 0x30: addi x8, x0, 2    (00200413) - Target of BNE. x8 = 2.
        $fdisplay(fd, "00200413");
        // 0x34: jal x10, 12       (00c0056f) - Jumps to 0x40. x10 gets Return Addr (0x38).
        $fdisplay(fd, "00c0056f");
        // 0x38: addi x11, x0, 99  (06300593) - HAZARD: MUST be flushed!
        $fdisplay(fd, "06300593");
        // 0x3C: addi x11, x0, 99  (06300593) - HAZARD: MUST be flushed!
        $fdisplay(fd, "06300593");
        
        // --- SECTION 6: JALR Control Hazard ---
        // 0x40: addi x12, x0, 3   (00300613) - Target of JAL. x12 = 3.
        $fdisplay(fd, "00300613");
        // 0x44: addi x9, x0, 80   (05000493) - x9 = 80 (0x50). Prepare jump target.
        $fdisplay(fd, "05000493");
        // 0x48: jalr x13, x9, 0   (000486e7) - Jump to address in x9 (0x50). x13 gets 0x4C.
        $fdisplay(fd, "000486e7");
        // 0x4C: addi x14, x0, 99  (06300713) - HAZARD: MUST be flushed!
        $fdisplay(fd, "06300713");
        
        // 0x50: jal x0, 0         (0000006f) - Infinite loop / Halt
        $fdisplay(fd, "0000006f");
        
        $fclose(fd);

        // --------------------------------------------------------------------
        // 2. INITIALIZE AND RUN SIMULATION
        // --------------------------------------------------------------------
        clk = 0;
        reset = 1;
        
        #25;
        reset = 0;

        // Increased runtime to allow the longer program to finish
        #300; 

        // --------------------------------------------------------------------
        // 3. SELF-CHECKING VERIFICATION
        // --------------------------------------------------------------------
        $display("\n==================================================");
        $display("   COMPREHENSIVE PIPELINE & HAZARD TEST RESULTS   ");
        $display("==================================================");

        // Test 1: LUI & Immediate logic
        if (dut.rf.Registers[1] === 32'h00004004) $display(" [PASS] x1  = 0x4004 (LUI & ADDI)");
        else $display(" [FAIL] x1  = %0h (Expected 4004)", dut.rf.Registers[1]);

        // Test 2: Load-Use Hazard Forwarding
        if (dut.rf.Registers[2] === 32'h00004004) $display(" [PASS] x2  = 0x4004 (SW/LW Memory Access)");
        else $display(" [FAIL] x2  = %0h (Expected 4004)", dut.rf.Registers[2]);
        if (dut.rf.Registers[3] === 32'h00004005) $display(" [PASS] x3  = 0x4005 (Load-Use Forwarding)");
        else $display(" [FAIL] x3  = %0h (Expected 4005)", dut.rf.Registers[3]);

        // Test 3: ALU-to-ALU Hazard Forwarding
        if (dut.rf.Registers[4] === 32'd10) $display(" [PASS] x4  = 10     (Base ALU)");
        else $display(" [FAIL] x4  = %0d (Expected 10)", dut.rf.Registers[4]);
        if (dut.rf.Registers[5] === 32'd15) $display(" [PASS] x5  = 15     (ALU->ALU Forwarding 1)");
        else $display(" [FAIL] x5  = %0d (Expected 15)", dut.rf.Registers[5]);
        if (dut.rf.Registers[6] === 32'd25) $display(" [PASS] x6  = 25     (ALU->ALU Forwarding 2)");
        else $display(" [FAIL] x6  = %0d (Expected 25)", dut.rf.Registers[6]);

        // Test 4: Branch Not Taken (Fall-through)
        if (dut.rf.Registers[7] === 32'd1) $display(" [PASS] x7  = 1      (Branch NOT Taken correct)");
        else if (dut.rf.Registers[7] === 32'd99) $display(" [FAIL] x7  = 99 (Branch Not Taken incorrectly flushed!)");
        else $display(" [FAIL] x7  = %0d (Expected 1)", dut.rf.Registers[7]);

        // Test 5: Branch Taken (Flush)
        if (dut.rf.Registers[8] === 32'd2) $display(" [PASS] x8  = 2      (Branch Taken correct & target reached)");
        else $display(" [FAIL] x8  = %0d (Expected 2)", dut.rf.Registers[8]);

        // Test 6: JAL and Return Address
        if (dut.rf.Registers[11] !== 32'd99) $display(" [PASS] x11 = Unused (JAL IF Stage Flushed correctly)");
        else $display(" [FAIL] x11 = 99 (JAL Failed to flush pipeline!)");
        
        if (dut.rf.Registers[10] === 32'h00000038) $display(" [PASS] x10 = 0x0038 (JAL Writeback Return Address)");
        else $display(" [FAIL] x10 = %0h (Expected 0x38)", dut.rf.Registers[10]);

        if (dut.rf.Registers[12] === 32'd3) $display(" [PASS] x12 = 3      (JAL Target Reached)");
        else $display(" [FAIL] x12 = %0d (Expected 3)", dut.rf.Registers[12]);

        // Test 7: JALR and Return Address
        if (dut.rf.Registers[14] !== 32'd99) $display(" [PASS] x14 = Unused (JALR IF Stage Flushed correctly)");
        else $display(" [FAIL] x14 = 99 (JALR Failed to flush pipeline!)");
        
        if (dut.rf.Registers[13] === 32'h0000004C) $display(" [PASS] x13 = 0x004C (JALR Writeback Return Address)");
        else $display(" [FAIL] x13 = %0h (Expected 0x4C)", dut.rf.Registers[13]);

        $display("==================================================\n");
        
        $stop;
    end

endmodule
module hazard(
    // Fetch stage
    output StallF,

    // Decode stage
    input [3:0] RA1D,
    input [3:0] RA2D,
    output StallD,
    output FlushD,
    
    // Execute stage
    input [3:0] RA1E,
    input [3:0] RA2E,
    input [3:0] WA3E,
    input MemtoRegE,
    input PCSrcE,
    input RegWriteE, 
    output [1:0] ForwardAE,
    output [1:0] ForwardBE,
    output FlushE,

    // MEM stage
    input [3:0] WA3M, 
    input [3:0] RA2M,
    input RegWriteM,
    input MemWriteM,
    output ForwardM,

    // Write-back stage
    input [3:0] WA3W,
    input RegWriteW,
    input MemtoRegW,
    //mul
    input Start_MCycle_E,
    output FlushM,
    input [3:0] WA3_E_MCycle,
    input [3:0] WA3_D,
    input RegWrite_E_MCycle, 
    input Busy_MCycle_E,
    input MCycleResultstall   //mul结果算出阻塞
);

    wire Match_1D_E, Match_2D_E;
    wire Match_1D_M, Match_2D_M;
    wire Match_1E_M, Match_2E_M;
    wire Match_1E_W, Match_2E_W;
    wire FlushE1, FlushE2;
    wire LDRstall;

    assign Match_1D_E = (RA1D == WA3E);
    assign Match_2D_E = (RA2D == WA3E);
    assign Match_1D_M = (RA1D == WA3M);
    assign Match_2D_M = (RA2D == WA3M);
    assign Match_1E_M = (RA1E == WA3M);
    assign Match_2E_M = (RA2E == WA3M);
    assign Match_1E_W = (RA1E == WA3W);
    assign Match_2E_W = (RA2E == WA3W);

    // I. Data forward
    // I.1. DP-DP
    assign ForwardAE = (Match_1E_M && RegWriteM) ? 2'b10 : 
                       ((Match_1E_W && RegWriteW) ? 2'b01 : 2'b00);
    assign ForwardBE = (Match_2E_M && RegWriteM) ? 2'b10 : 
                       ((Match_2E_W && RegWriteW) ? 2'b01 : 2'b00);
    // I.2. MEM-MEM (LDR->STR, The stored content is just loaded from Mem)
    assign ForwardM =  (RA2M == WA3W) & MemWriteM & MemtoRegW & RegWriteW;

    // Stall
    // Current only support one-cycle stall, for MUL/DIV or cache, there are chances to stall for multiple cycles
    wire Match_1D_E_MCycle, Match_2D_E_MCycle,Match_WA3D_E_MCycle,MCyclestall;//与mul备份信息冲突，WA3_E_MCycle
    
    assign LDRstall = (Match_1D_E || Match_2D_E) & MemtoRegE & RegWriteE; // write back value is the operand of the next instruction
    assign StallF = LDRstall || MCyclestall || MCycleResultstall;
    assign StallD = LDRstall || MCyclestall || MCycleResultstall;
    assign FlushE1 = LDRstall || MCyclestall;
    
    // Flush
    assign FlushD = PCSrcE;
    assign FlushE2 = PCSrcE;

    assign FlushE = FlushE1 || FlushE2 || MCycleResultstall;
//mul第一周期刷新M

assign FlushM = Start_MCycle_E;
//与mul备份信息冲突，WA3_E_MCycle

assign Match_1D_E_MCycle = (RA1D == WA3_E_MCycle);
assign Match_2D_E_MCycle = (RA2D == WA3_E_MCycle);
assign Match_WA3D_E_MCycle = (WA3_D == WA3_E_MCycle);
assign MCyclestall = (Match_1D_E_MCycle || Match_2D_E_MCycle || Match_WA3D_E_MCycle) & RegWrite_E_MCycle & Busy_MCycle_E;
endmodule
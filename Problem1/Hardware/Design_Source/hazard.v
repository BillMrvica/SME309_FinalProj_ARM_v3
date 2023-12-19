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
    input RegWriteW
);

    wire Match_1D_E, Match_2D_E;
    wire Match_1E_M, Match_2E_M;
    wire Match_1E_W, Match_1E_W;
    wire FlushE1, FlushE2;
    wire LDRstall;

    assign Match_1D_E = (RA1D == WA3E);
    assign Match_2D_E = (RA2D == WA3E);
    assign Match_1E_M = (RA1E == WA3M);
    assign Match_2E_M = (RA2E == WA3M);
    assign Match_1E_W = (RA1E == WA3W);
    assign Match_2E_W = (RA2E == WA3W);

    // I. Data forward
    // I.1. DP-DP
    assign ForwardAE = (Match_1E_M && RegWrite_M) ? 2'b10 : 
                       ((Match_1E_W && RegWrite_W) ? 2'b01 : 2'b00);
    assign ForwardBE = (Match_2E_M && RegWrite_M) ? 2'b10 : 
                       ((Match_2E_W && RegWrite_W) ? 2'b01 : 2'b00);
    // I.2. MEM-MEM (LDR->STR, The stored content is just loaded from Mem)
    assign ForwardM =  (RA2M == WA3W) & MemWriteM & MemtoRegW & RegWriteW;

    // Stall
    assign LDRstall = (Match_1D_E || Match_2D_E) & MemtoRegE & RegWrite_E; // write back value is the operand of the next instruction
    assign StallF = LDRstall;
    assign StallD = LDRstall;
    assign FlushE1 = LDRstall;
    
    // Flush
    assign FlushD = PCSrcE;
    assign FlushE2 = PCSrcE;

    assign FlushE = FlushE1 || FlushE2;

endmodule
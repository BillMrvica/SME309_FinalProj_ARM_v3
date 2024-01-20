module hazard(
    // Fetch stage
    output StallF,

    // Decode stage
    input [3:0] RA1D,
    input [3:0] RA2D,
    input [3:0] WA3D,
    output StallD,
    output FlushD,
    
    // Execute stage
    input [3:0] RA1E,
    input [3:0] RA2E,
    input [3:0] WA3E,
    input MemtoRegE,
    input MemWriteE,
    input PCSrcE,
    input RegWriteE, 
    output [1:0] ForwardAE,
    output [1:0] ForwardBE,
    output FlushE,
    // for cache stall
    output StallE,

    // MEM stage
    input [3:0] WA3M, 
    input [3:0] RA2M,
    input RegWriteM,
    input MemWriteM,
    output ForwardM,
    // for cache stall
    output StallM,
    // For cache miss, add MemtoRegM and cache_ready signal
    input MemtoRegM,
    input cache_ready,
    // input cache_busy,

    // Write-back stage
    input [3:0] WA3W,
    input RegWriteW,
    input MemtoRegW,

    // MUL
    input Busy_MCycle_E, 
    input Ready_MCycle_E,
    input [3:0] WA3_MCycle_E,
    output MUL_halt
);

    wire Match_1D_E, Match_2D_E;
    wire Match_1D_M, Match_2D_M;
    wire Match_1E_M, Match_2E_M;
    wire Match_1E_W, Match_2E_W;
    wire FlushE1, FlushE2;
    wire LDRstall;
    wire LDRstall_cache_read_miss;
    wire STRstall_cache_write_miss;
    wire Match_1D_E_MCycle, Match_2D_E_MCycle, Match_WA3D_E_MCycle, MCyclestall;

    assign Match_1D_E = (RA1D == WA3E);
    assign Match_2D_E = (RA2D == WA3E);
    assign Match_1D_M = (RA1D == WA3M);
    assign Match_2D_M = (RA2D == WA3M);
    assign Match_1E_M = (RA1E == WA3M);
    assign Match_2E_M = (RA2E == WA3M);
    assign Match_1E_W = (RA1E == WA3W);
    assign Match_2E_W = (RA2E == WA3W);

    assign Match_1D_E_MCycle = (RA1D == WA3_MCycle_E);
    assign Match_2D_E_MCycle = (RA2D == WA3_MCycle_E);
    assign Match_WA3D_E_MCycle = (WA3D == WA3_MCycle_E);

    // I. Data forward
    // I.1. DP-DP
    assign ForwardAE = (Match_1E_M && RegWriteM) ? 2'b10 : 
                       ((Match_1E_W && RegWriteW) ? 2'b01 : 2'b00);
    assign ForwardBE = (Match_2E_M && RegWriteM) ? 2'b10 : 
                       ((Match_2E_W && RegWriteW) ? 2'b01 : 2'b00);
    // I.2. MEM-MEM (LDR->STR, The stored content is just loaded from Mem)
    // NEED IMPROVE
    // With cache, LDR-STR, STR might be write miss so the forward data will lose
    // So we need to stall STR at D when LDR at E, and forward the data from WB to E, combined above
    // assign ForwardM =  (RA2M == WA3W) & MemWriteM & MemtoRegW & RegWriteW;
    

    // Stall
    // Current only support one-cycle stall, for MUL/DIV or cache, there are chances to stall for multiple cycles
    assign LDRstall = (Match_1D_E || Match_2D_E) & MemtoRegE & RegWriteE; // write back value is the operand of the next instruction
    // add for cache read miss
    assign LDRstall_cache_read_miss = MemtoRegM & ~cache_ready;
    // add for cache write miss, if STR is followed by another MEM instruction (LDR/STR)
    assign STRstall_cache_write_miss = MemWriteM & ~cache_ready ; // & (MemtoRegE | MemWriteE)

    // for MUL
    assign MCyclestall = (Match_1D_E_MCycle || Match_2D_E_MCycle || Match_WA3D_E_MCycle) & Busy_MCycle_E;

    assign StallF = LDRstall | LDRstall_cache_read_miss | STRstall_cache_write_miss | MCyclestall;
    assign StallD = LDRstall | LDRstall_cache_read_miss | STRstall_cache_write_miss | MCyclestall;
    assign StallE = LDRstall_cache_read_miss | STRstall_cache_write_miss;
    assign StallM = LDRstall_cache_read_miss | STRstall_cache_write_miss;
    assign FlushE1 = (LDRstall | MCyclestall) && ~StallE;
    
    // Flush
    // Aujusted for branch prediction
    assign FlushD = PCSrcE;
    // assign FlushE2 = PCSrcE;

    // assign FlushE = FlushE1 || FlushE2;
    assign FlushE = FlushE1;

    assign MUL_halt = Match_WA3D_E_MCycle & Busy_MCycle_E & ~MCyclestall;

endmodule
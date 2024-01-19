module Decoder(
    input [31:0] Instr,
    
    output Start_MCycle,
    output MCycleOp_MCycle, 
	
    output PCS,
    
    output RegW, 
    output MemW, 
    output MemtoReg,
    output ALUSrc,
    output [1:0] ImmSrc,
    output [1:0] RegSrc,
    

    output reg [3:0] ALUControl,
    output reg [1:0] FlagW,
    output reg NoWrite
); 
//以下乘法
assign Start_MCycle = ((Instr[27:21]==7'b0000000 && Instr[7:4]==4'b1001) || (Instr[27:20]==8'b0111_1111&&Instr[7:4]==4'b1111)) ? 1'b1:1'b0;  
assign MCycleOp_MCycle = (Instr[7:4]==4'b1001) ? 1'b0:1'b1;

//以上乘法    
    wire [1:0] op;
    wire Branch, DP, MEM;

    wire [3:0] Rd;
    wire [5:0] funct;
    wire S, U, I; // U: Add in memory isntgr

    assign op = Instr[27:26];
    assign Branch = (op==2'b10) ? 1 : 0;
    assign DP = (op==2'b00) ? 1 : 0;
    assign MEM = (op==2'b01) ? 1 : 0;

    assign Rd = Instr[15:12];
    assign funct = Instr[25:20];
    assign U = funct[3];
    

    // main decoder
    assign RegW = DP | (MEM && (funct[0]==1)); // DP or LTR
    assign MemW = MEM && (funct[0]==0); // STR
    assign MemtoReg = MEM && (funct[0]==1); // LTR
    assign ALUSrc = (DP && (funct[5]==1)) | MEM | Branch; // control src2 MUX
    
    assign ImmSrc = (DP && (funct[5]==1)) ? 2'b00 : 
                    ((MEM) ? 2'b01 : 
                    ((Branch) ? 2'b10 : 2'b00));
    assign RegSrc = {((MEM && (funct[0]==0)) ? 1'b1 : 1'b0), ((Branch) ? 1'b1 : 1'b0)};
    

    // PC select
    assign PCS = ((Rd==4'd15) && RegW) | Branch;

    // ALU decoder
    /* 
        in original version, ADD: 2'd0, SUB: 2'd1, AND: 2'd2, SUB: 2'd3 
        Now directly assign ALUControl[3:0] = Instr[24:21]
    */
    always @* begin
        if(DP==0) begin // not DP
            ALUControl = (MEM) ? ((U==0) ? 4'b0010 : 4'b0100) : // MEM: if U=0, negative imm, SUB
                                 (4'b0100); // Branch
            FlagW = 2'b00;
            NoWrite = 0;
        end
        else begin
            ALUControl = funct[4:1];
            
            // TST, TEQ, CMP, CMN: do not write back the result
            NoWrite = (funct[4:1]>=4'b1000 && funct[4:1]<=4'b1011) ? 1'b1 : 1'b0; 
            
            // Functions relevant to add/sub: 2'b11, AND/OR/XOR: 2'b10
            FlagW = (funct[0]) ? (((funct[4:1]>=4'b0010 && funct[4:1]<=4'b0111) || (funct[4:1]>=4'b1010 && funct[4:1]<=4'b1011)) ? 2'b11 : 2'b10) : 2'b00;
        end
    end


// CMP I_1010_1

// CMN I_1011_1, another value should be negeted,

// for memeory, immediate_bar, Pre-index, Add, Byte, WriteBack, Load
   
endmodule
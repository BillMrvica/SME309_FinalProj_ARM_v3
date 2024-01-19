module Decoder(
    input [31:0] Instr,
	
    output PCS,
    
    output RegW, 
    output MemW, 
    output MemtoReg,
    output ALUSrc,
    output [1:0] ImmSrc,
    output [1:0] RegSrc,
    
    output FPUW,
    output FPUSrc,
    output FPUcontrol,

    output reg [3:0] ALUControl,
    output reg [1:0] FlagW,
    output reg NoWrite
); 
    
    wire [1:0] op;
    wire Branch, DP, MEM;

    wire [3:0] Rd;
    wire [5:0] funct;
    wire S, U, I; // U: Add in memory isntgr
     
    assign FPUW = (Instr[27:23] == 5'b11100) && (Instr[11:8] == 4'b1010) && (Instr[6] == 1'b0) && (Instr[4] == 1'b0);
    assign FPUcontrol = (Instr[20] == 1'b1); // 任何时刻均赋值但是若不是浮点运算时输出不给result即可？
    assign FPUSrc = (op==2'b11) ? 1 : 0; // 浮点运算
    
    assign op = Instr[27:26];
    assign Branch = (op==2'b10) ? 1 : 0;
    assign DP = (op==2'b00) ? 1 : 0;
    assign MEM = (op==2'b01) ? 1 : 0;

    assign Rd = Instr[15:12];
    assign funct = Instr[25:20];
    assign U = funct[3];
    

    // main decoder
    assign RegW = DP | (MEM && (funct[0]==1)) | FPUSrc; // DP or LTR
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
module Decoder(
    input [31:0] Instr,
	
    output PCS,
    
    output RegW, 
    output MemW, 
    output MemtoReg,
    output ALUSrc,
    output [1:0] ImmSrc,
    output [1:0] RegSrc,

    output reg [1:0] ALUControl,
    output reg [1:0] FlagW,
    output reg NoWrite
); 
    
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
    always @* begin
        if(DP==0) begin // not DP
            ALUControl = (U==0) ? 2'b01 : 2'b00; // if U=0, negative imm, SUB
            FlagW = 2'b00;
            NoWrite = 0;
        end
        else begin
            case(funct[4:1])
                4'b0100: begin  // ADD
                    ALUControl = 2'b00;
                    FlagW = (funct[0]) ? 2'b11 : 2'b00;
                    NoWrite = 0;
                end
                4'b0010: begin  // SUB
                    ALUControl = 2'b01;
                    FlagW = (funct[0]) ? 2'b11 : 2'b00;
                    NoWrite = 0;
                end
                4'b0000: begin  // AND
                    ALUControl = 2'b10;
                    FlagW = (funct[0]) ? 2'b10 : 2'b00;
                    NoWrite = 0;
                end
                4'b1100: begin  // ORR
                    ALUControl = 2'b11;
                    FlagW = (funct[0]) ? 2'b10 : 2'b00;
                    NoWrite = 0;
                end
                4'b1010: begin  // CMP
                    ALUControl = 2'b01;
                    FlagW = (funct[0]) ? 2'b11 : 2'b00;
                    NoWrite = 1;
                end
                4'b1011: begin  // CMN
                    ALUControl = 2'b00;
                    FlagW = (funct[0]) ? 2'b11 : 2'b00;
                    NoWrite = 1;
                end
                default: begin 
                    ALUControl = 2'b00;
                    FlagW = 2'b00;
                    NoWrite = 0;
                end
            endcase
        end
    end


// CMP I_1010_1

// CMN I_1011_1, another value should be negeted,

// for memeory, immediate_bar, Pre-index, Add, Byte, WriteBack, Load
   
endmodule
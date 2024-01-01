`timescale 1ns / 1ps
//>>>>>>>>>>>> ******* FOR SIMULATION. DO NOT SYNTHESIZE THIS DIRECTLY (This is used as a component in TOP.v for Synthesis) ******* <<<<<<<<<<<<

module Wrapper
#(
	parameter N_LEDs = 16,       // Number of LEDs displaying Result. LED(15 downto 15-N_LEDs+1). 16 by default
	parameter N_DIPs = 7         // Number of DIPs. 16 by default	                             
)
(
	input  [N_DIPs-1:0] DIP, 		 		// DIP switch inputs, used as a user definied memory address for checking memory content.
	output reg [N_LEDs-1:0] LED, 	// LED light display. Display the value of program counter.
	output reg [31:0] SEVENSEGHEX, 			// 7 Seg LED Display. The 32-bit value will appear as 8 Hex digits on the display. Used to display memory content.
	input  RESET,							// Active high.
	input  CLK								// Divided Clock from TOP.
);                                             

//----------------------------------------------------------------
// ARM signals
//----------------------------------------------------------------
wire[31:0] PC ;
wire[31:0] Instr ;
reg[31:0] ReadData ;
wire MemWrite ;
wire[31:0] ALUResult ;
wire[31:0] WriteData ;

//----------------------------------------------------------------
// Address Decode signals
//---------------------------------------------------------------
wire dec_DATA_CONST, dec_DATA_VAR;  // 'enable' signals from data memory address decoding

//----------------------------------------------------------------
// Memory read for IO signals
//----------------------------------------------------------------
wire [31:0] ReadData_IO;

//----------------------------------------------------------------
// Memory declaration
//-----------------------------------------------------------------
reg [31:0] INSTR_MEM		[0:127]; // instruction memory
reg [31:0] DATA_CONST_MEM	[0:127]; // data (constant) memory
reg [31:0] DATA_VAR_MEM     [0:127]; // data (variable) memory
integer i;

// wyh instructions 
//----------------------------------------------------------------
// Instruction Memory
//----------------------------------------------------------------
initial begin
	INSTR_MEM[0] = 32'hE59F1204; 
	INSTR_MEM[1] = 32'hE59F2208; 
	INSTR_MEM[2] = 32'hE1510002; 
	INSTR_MEM[3] = 32'h0A000002; 
	INSTR_MEM[4] = 32'hE0411002; 
	INSTR_MEM[5] = 32'hE2833001; 
	INSTR_MEM[6] = 32'hEAFFFFFA; 
	INSTR_MEM[7] = 32'hE59F11E8; 
	INSTR_MEM[8] = 32'hE1822002; 
	INSTR_MEM[9] = 32'hE1C33003; 
	INSTR_MEM[10] = 32'hE1510002; 
	INSTR_MEM[11] = 32'h0A000002; 
	INSTR_MEM[12] = 32'hE2933001; 
	INSTR_MEM[13] = 32'hE2C11000; 
	INSTR_MEM[14] = 32'hEAFFFFFA; 
	INSTR_MEM[15] = 32'hE59F51CC; 
	INSTR_MEM[16] = 32'hE59F61CC; 
	INSTR_MEM[17] = 32'hE2033000; 
	INSTR_MEM[18] = 32'hE1550006; 
	INSTR_MEM[19] = 32'hE2A66000; 
	INSTR_MEM[20] = 32'hE0833006; 
	INSTR_MEM[21] = 32'h1AFFFFFB; 
	INSTR_MEM[22] = 32'hE2433014; 
	INSTR_MEM[23] = 32'hE0631001; 
	INSTR_MEM[24] = 32'hE2266000; 
	INSTR_MEM[25] = 32'hE1A07006; 
	INSTR_MEM[26] = 32'hE59F71A4; 
	INSTR_MEM[27] = 32'hE0975005; 
	INSTR_MEM[28] = 32'hE1560005; 
	INSTR_MEM[29] = 32'h1AFFFFFC; 
	INSTR_MEM[30] = 32'hE0E75005; 
	INSTR_MEM[31] = 32'hE1550007; 
	INSTR_MEM[32] = 32'h0AFFFFFC; 
	INSTR_MEM[33] = 32'h1A000001; 
	INSTR_MEM[34] = 32'hE2855005; 
	INSTR_MEM[35] = 32'hE2465003; 
	INSTR_MEM[36] = 32'hE2455005; 
	INSTR_MEM[37] = 32'hEAFFFFFE; 
	for(i = 38; i < 128; i = i+1) begin 
		INSTR_MEM[i] = 32'h0; 
	end
end

//----------------------------------------------------------------
// Data (Constant) Memory
//----------------------------------------------------------------
initial begin
	DATA_CONST_MEM[0] = 32'h00000810; 
	DATA_CONST_MEM[1] = 32'h00000820; 
	DATA_CONST_MEM[2] = 32'h00000830; 
	DATA_CONST_MEM[3] = 32'h00000005; 
	DATA_CONST_MEM[4] = 32'h00000006; 
	DATA_CONST_MEM[5] = 32'h00000001; 
	for(i = 6; i < 128; i = i+1) begin 
		DATA_CONST_MEM[i] = 32'h0; 
	end
end
//----------------------------------------------------------------
// Data (Variable) Memory
//----------------------------------------------------------------
initial begin
            for(i = 0; i < 128; i = i+1) begin 
				DATA_VAR_MEM[i] = 32'h0; 
			end
end


//----------------------------------------------------------------
// ARM port map
//----------------------------------------------------------------
ARM ARM1(
	CLK,
	RESET,
	Instr,
	ReadData,
	MemWrite,
	PC,
	ALUResult,
	WriteData
);

//----------------------------------------------------------------
// Data memory address decoding
//----------------------------------------------------------------
assign dec_DATA_CONST		= (ALUResult >= 32'h00000200 && ALUResult <= 32'h000003FC) ? 1'b1 : 1'b0;
assign dec_DATA_VAR			= (ALUResult >= 32'h00000800 && ALUResult <= 32'h000009FC) ? 1'b1 : 1'b0;

//----------------------------------------------------------------
// Data memory read 1
//----------------------------------------------------------------
always@( * ) begin
if (dec_DATA_VAR)
	ReadData <= DATA_VAR_MEM[ALUResult[8:2]] ; 
else if (dec_DATA_CONST)
	ReadData <= DATA_CONST_MEM[ALUResult[8:2]] ; 	
else
	ReadData <= 32'h0 ; 
end

//----------------------------------------------------------------
// Data memory read 2
//----------------------------------------------------------------
assign ReadData_IO = DATA_VAR_MEM[DIP[6:0]];

//----------------------------------------------------------------
// Data Memory write
//----------------------------------------------------------------
always@(posedge CLK) begin
    if( MemWrite && dec_DATA_VAR ) 
        DATA_VAR_MEM[ALUResult[8:2]] <= WriteData ;
end

//----------------------------------------------------------------
// Instruction memory read
//----------------------------------------------------------------
assign Instr = ( (PC >= 32'h00000000) && (PC <= 32'h000001FC) ) ? // To check if address is in the valid range, assuming 128 word memory. Also helps minimize warnings
                 INSTR_MEM[PC[8:2]] : 32'h00000000 ; 

//----------------------------------------------------------------
// LED light - display PC value
//----------------------------------------------------------------
always@(posedge CLK or posedge RESET) begin
    if(RESET)
        LED <= 'b0 ;
    else 
        LED <= PC ;
end

//----------------------------------------------------------------
// SevenSeg LED - display memory content
//----------------------------------------------------------------
always @(posedge CLK or posedge RESET) begin
	if (RESET)
		SEVENSEGHEX <= 32'b0;
	else
		SEVENSEGHEX <= ReadData_IO;
end

endmodule

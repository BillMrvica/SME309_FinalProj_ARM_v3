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
wire [31:0] ReadData ;
wire MemWrite ;
wire[31:0] ALUResult ;
wire[31:0] WriteData ;

// CPU-cache
// Assume, From cpu_valid until cache_ready high-active, the input values of cache_addr and cpu_write_data and the same
wire cpu_op; // read or write operation, R/W'
wire cpu_valid; // to enable read or write
wire cache_ready; // used to control the CPU, if low, stall the CPU

// cache-MEM
wire cache_op; // read or write operation
wire cache_valid; // enable MEM write, read is not necessary in this case
wire [31:0] mem_addr;
wire [31:0] cache_write_data;
wire mem_ready;
wire [31:0] mem_data;  

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
	INSTR_MEM[1] = 32'hE59F2204; 
	INSTR_MEM[2] = 32'hE59F31F0; 
	INSTR_MEM[3] = 32'hE59F41F0; 
	INSTR_MEM[4] = 32'hE59FC1F0; 
	INSTR_MEM[5] = 32'hE0815002; 

	INSTR_MEM[6] = 32'hE5835004; 
	INSTR_MEM[7] = 32'hE2833008; 
	INSTR_MEM[8] = 32'hE5135004; 

	INSTR_MEM[9] = 32'hE0426001; 
	INSTR_MEM[10] = 32'hE5046004; 
	INSTR_MEM[11] = 32'hE2444008; 
	INSTR_MEM[12] = 32'hE5946004; 

	INSTR_MEM[13] = 32'hE0070295; 
	INSTR_MEM[14] = 32'hE59F81D4; 
	INSTR_MEM[15] = 32'hE59F31F4; 
	INSTR_MEM[16] = 32'h00070891; 
	INSTR_MEM[17] = 32'hE2933000; 
	INSTR_MEM[18] = 32'h000A0891; 
	INSTR_MEM[19] = 32'hE09AA007; 

	INSTR_MEM[20] = 32'hE7F707F8; 
	INSTR_MEM[21] = 32'hE7F707F1; 
	INSTR_MEM[22] = 32'h07F702F8; 
	INSTR_MEM[23] = 32'hE2933000; 
	INSTR_MEM[24] = 32'h07FB02F8; 
	INSTR_MEM[25] = 32'hE08BB007; 
	INSTR_MEM[26] = 32'hE08BB00A; 

	INSTR_MEM[27] = 32'hE59F1198; 

	INSTR_MEM[28] = 32'hE59FD1A0;
	INSTR_MEM[29] = 32'hE151000D; 
	INSTR_MEM[30] = 32'h0A000001; 
	INSTR_MEM[31] = 32'hE041100D; 
	INSTR_MEM[32] = 32'hEAFFFFFB; 
	INSTR_MEM[33] = 32'hE59F1180; 
	INSTR_MEM[34] = 32'hE18DD00D; 
	INSTR_MEM[35] = 32'hE1C33003; 
	INSTR_MEM[36] = 32'hE151000D; 
	INSTR_MEM[37] = 32'h0A000002; 
	INSTR_MEM[38] = 32'hE2933001; 
	INSTR_MEM[39] = 32'hE2C11000; 
	INSTR_MEM[40] = 32'hEAFFFFFA; 
	INSTR_MEM[41] = 32'hE59F5164; 
	INSTR_MEM[42] = 32'hE59F6168; 
	INSTR_MEM[43] = 32'hE2033000; 
	INSTR_MEM[44] = 32'hE1550006; 
	INSTR_MEM[45] = 32'hE2A66000; 
	INSTR_MEM[46] = 32'hE0833006; 
	INSTR_MEM[47] = 32'h1AFFFFFB; 
	INSTR_MEM[48] = 32'hE2433014; 
	INSTR_MEM[49] = 32'hE0631001; 
	INSTR_MEM[50] = 32'hE2266000; 
	INSTR_MEM[51] = 32'hE1A07006; 
	INSTR_MEM[52] = 32'hE59F7140; 
	INSTR_MEM[53] = 32'hE59F1130; 
	INSTR_MEM[54] = 32'hE59F2130; 
	INSTR_MEM[55] = 32'hE0815002; 
	INSTR_MEM[56] = 32'hE59F3118; 
	INSTR_MEM[57] = 32'hE59F4118; 
	INSTR_MEM[58] = 32'hE59FC118; 
	INSTR_MEM[59] = 32'hE5835004; 
	INSTR_MEM[60] = 32'hE2833008; 
	INSTR_MEM[61] = 32'hE5135004; 
	INSTR_MEM[62] = 32'hE0426001; 
	INSTR_MEM[63] = 32'hE5046004; 
	INSTR_MEM[64] = 32'hE2444008; 
	INSTR_MEM[65] = 32'hE5946004; 
	INSTR_MEM[66] = 32'hE2857037; 
	INSTR_MEM[67] = 32'hE59F8100; 
	INSTR_MEM[68] = 32'hE59F3120; 
	INSTR_MEM[69] = 32'hE5948004; 
	INSTR_MEM[70] = 32'hE5048004; 
	INSTR_MEM[71] = 32'hE2844000; 
	INSTR_MEM[72] = 32'hE2455000; 
	INSTR_MEM[73] = 32'hE3855000; 
	INSTR_MEM[74] = 32'hE5141004; 
	INSTR_MEM[75] = 32'hE0841005; 
	INSTR_MEM[76] = 32'hE0018003; 
	INSTR_MEM[77] = 32'hE59F10E0; 
	INSTR_MEM[78] = 32'hE59F20E0; 
	INSTR_MEM[79] = 32'hE59F30BC; 
	INSTR_MEM[80] = 32'hE59F40BC; 
	INSTR_MEM[81] = 32'hE59FC0BC; 
	INSTR_MEM[82] = 32'hEE315A02; 
	INSTR_MEM[83] = 32'hEE215A02; 
	INSTR_MEM[84] = 32'hE59F30CC; 
	INSTR_MEM[85] = 32'hEE333A01; 
	INSTR_MEM[86] = 32'hE59F60C8; 
	INSTR_MEM[87] = 32'hEE326A01; 
	INSTR_MEM[88] = 32'hE2444008; 
	INSTR_MEM[89] = 32'hE59F70C0; 
	INSTR_MEM[90] = 32'hEE277A01; 
	INSTR_MEM[91] = 32'hE59F80A0; 
	INSTR_MEM[92] = 32'hEE217A06; 
	INSTR_MEM[93] = 32'hE2844000; 
	INSTR_MEM[94] = 32'hE59FA0B0; 
	INSTR_MEM[95] = 32'hEE21AA03; 
	INSTR_MEM[96] = 32'hEE3AAA07; 
	INSTR_MEM[97] = 32'hEE37AA0A; 
	INSTR_MEM[98] = 32'hE59FE074; 
	INSTR_MEM[99] = 32'hE58E4000; 
	INSTR_MEM[100] = 32'hE58CB000; 
	INSTR_MEM[101] = 32'hEAFFFFFE; 
	for(i = 102; i < 128; i = i+1) begin 
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
	DATA_CONST_MEM[5] = 32'h00000003; 
	DATA_CONST_MEM[6] = 32'h00000001; 
	DATA_CONST_MEM[7] = 32'h40B00000; 
	DATA_CONST_MEM[8] = 32'h40D80000; 
	DATA_CONST_MEM[9] = 32'h426A0000; 
	DATA_CONST_MEM[10] = 32'h3FA00000; 
	DATA_CONST_MEM[11] = 32'h41340000; 
	DATA_CONST_MEM[12] = 32'h3F000000; 
	DATA_CONST_MEM[13] = 32'h418D0000; 
	for(i = 14; i < 128; i = i+1) begin 
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
ARM u_ARM(
    .CLK       ( CLK       ),
    .Reset     ( RESET     ),
    .Instr     ( Instr     ),

    .ReadData  ( ReadData  ),
    .PC        ( PC        ),
    .ALUResult ( ALUResult ),
    .WriteData ( WriteData ),
    .cpu_op    ( cpu_op    ),
    .cpu_valid ( cpu_valid ),
    .cache_ready  ( cache_ready  )//,
	//.cache_busy   ( cache_valid )
);

//----------------------------------------------------------------
// cache port map
//----------------------------------------------------------------
Set_Asso_Cache_4W_256S u_Set_Asso_Cache_4W_256S(
    .clk              ( CLK              ),
    .nrst             ( ~RESET             ),

    .cpu_op           ( cpu_op           ),
    .cpu_valid        ( cpu_valid        ),
    .cache_addr       ( ALUResult       ),
    .cpu_write_data   ( WriteData   ),
    .cache_ready      ( cache_ready      ),
    .cache_data       ( ReadData       ),
    
	.cache_op         ( cache_op         ),
    .cache_valid      ( cache_valid      ),
    .mem_addr         ( mem_addr         ),
    .cache_write_data ( cache_write_data ),
    .mem_ready        ( 1'b1        ), // main memory is always ready 
    .mem_data         ( mem_data         )
);

//----------------------------------------------------------------
// Data memory address decoding
//----------------------------------------------------------------
assign dec_DATA_CONST		= (mem_addr >= 32'h00000200 && mem_addr <= 32'h000003FC) ? 1'b1 : 1'b0;
assign dec_DATA_VAR			= (mem_addr >= 32'h00000800 && mem_addr <= 32'h000009FC) ? 1'b1 : 1'b0;

//----------------------------------------------------------------
// Data memory read 1
//----------------------------------------------------------------
assign mem_data = (dec_DATA_VAR) ? DATA_VAR_MEM[mem_addr[8:2]] : (
	(dec_DATA_CONST) ? DATA_CONST_MEM[mem_addr[8:2]] : 32'h0
); 

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



// `timescale 1ns / 1ps
// //>>>>>>>>>>>> ******* FOR SIMULATION. DO NOT SYNTHESIZE THIS DIRECTLY (This is used as a component in TOP.v for Synthesis) ******* <<<<<<<<<<<<

// module Wrapper
// #(
// 	parameter N_LEDs = 16,       // Number of LEDs displaying Result. LED(15 downto 15-N_LEDs+1). 16 by default
// 	parameter N_DIPs = 11         // Number of DIPs. 16 by default	                             
// )
// (
// 	input  [N_DIPs-1:0] DIP, 		 		// DIP switch inputs, used as a user definied memory address for checking memory content.
// 	output reg [N_LEDs-1:0] LED, 	// LED light display. Display the value of program counter.
// 	output reg [31:0] SEVENSEGHEX, 			// 7 Seg LED Display. The 32-bit value will appear as 8 Hex digits on the display. Used to display memory content.
// 	input  RESET,							// Active high.
// 	input  CLK								// Divided Clock from TOP.
// );                                             

// //----------------------------------------------------------------
// // ARM and cache signals
// //----------------------------------------------------------------
// wire[31:0] PC ;
// wire[31:0] Instr ;
// wire [31:0] ReadData ;
// wire MemWrite ;
// wire[31:0] ALUResult ;
// wire[31:0] WriteData ;

// // CPU-cache
// // Assume, From cpu_valid until cache_ready high-active, the input values of cache_addr and cpu_write_data and the same
// wire cpu_op; // read or write operation, R/W'
// wire cpu_valid; // to enable read or write
// wire cache_ready; // used to control the CPU, if low, stall the CPU

// // cache-MEM
// wire cache_op; // read or write operation
// wire cache_valid; // enable MEM write, read is not necessary in this case
// wire [31:0] mem_addr;
// wire [31:0] cache_write_data;
// wire mem_ready;
// wire [31:0] mem_data;  

// //----------------------------------------------------------------
// // Address Decode signals
// //---------------------------------------------------------------
// // wire dec_DATA_CONST, dec_DATA_VAR;  // 'enable' signals from data memory address decoding

// //----------------------------------------------------------------
// // Memory read for IO signals
// //----------------------------------------------------------------
// wire [31:0] ReadData_IO;

// //----------------------------------------------------------------
// // Memory declaration
// //-----------------------------------------------------------------
// reg [31:0] INSTR_MEM		[0:127]; // instruction memory
// // reg [31:0] DATA_CONST_MEM	[0:127]; // data (constant) memory
// // reg [31:0] DATA_VAR_MEM     [0:127]; // data (variable) memory
// reg [31:0] DATA_MEM     [0:2048]; // data memory, 11-bit address in this case
// integer i;

// // wyh instructions 
// //----------------------------------------------------------------
// // Instruction Memory
// //----------------------------------------------------------------
// //----------------------------------------------------------------
// // Instruction Memory
// //----------------------------------------------------------------
// initial begin
// 		INSTR_MEM[0] = 32'hE59F11F8; 
// 		INSTR_MEM[1] = 32'hE59F21F8; 
// 		INSTR_MEM[2] = 32'hE59F31F8; 
// 		INSTR_MEM[3] = 32'hE59F41F8; 
// 		INSTR_MEM[4] = 32'hE59F51F8; 
// 		INSTR_MEM[5] = 32'hE59F620C; 
// 		INSTR_MEM[6] = 32'hE5834004; 
// 		INSTR_MEM[7] = 32'hE5835000; 
// 		INSTR_MEM[8] = 32'hE5816004; 
// 		INSTR_MEM[9] = 32'hE5014004; 
// 		INSTR_MEM[10] = 32'hE5825004; 
// 		INSTR_MEM[11] = 32'hE5026004; 
// 		INSTR_MEM[12] = 32'hE59F71D4; 
// 		INSTR_MEM[13] = 32'hE0874007; 
// 		INSTR_MEM[14] = 32'hE0875007; 
// 		INSTR_MEM[15] = 32'hE0876007; 
// 		INSTR_MEM[16] = 32'hE59F81CC; 
// 		INSTR_MEM[17] = 32'hE0884008; 
// 		INSTR_MEM[18] = 32'hE0885008; 
// 		INSTR_MEM[19] = 32'hE0886008; 
// 		INSTR_MEM[20] = 32'hE59F91C0; 
// 		INSTR_MEM[21] = 32'hE5839004; 
// 		INSTR_MEM[22] = 32'hE59FA1BC; 
// 		INSTR_MEM[23] = 32'hE583A008; 
// 		INSTR_MEM[24] = 32'hEAFFFFFE; 
// 		for(i = 25; i < 128; i = i+1) begin 
// 			INSTR_MEM[i] = 32'h0; 
// 		end
// end


// //----------------------------------------------------------------
// // Data (Constant) Memory
// //----------------------------------------------------------------
// initial begin
// 	DATA_MEM[0] = 32'h00000005; 
// 	DATA_MEM[1] = 32'h00000900; 
// 	DATA_MEM[2] = 32'h00000D00; 
// 	DATA_MEM[3] = 32'h00001900; 
// 	for(i = 4; i < 256; i = i+1) begin 
// 		DATA_MEM[i] = 32'h0; 
// 	end

// 	DATA_MEM[256] = 32'h00000010; 
// 	for(i = 257; i < 512; i = i+1) begin 
// 		DATA_MEM[i] = 32'h0; 
// 	end 
// 	DATA_MEM[512] = 32'h00000011; 
// 	for(i = 513; i < 1024; i = i+1) begin 
// 		DATA_MEM[i] = 32'h0; 
// 	end 
// 	DATA_MEM[1024] = 32'h00000012;    
// 	for(i = 1025; i < 1280; i = i+1) begin 
// 		DATA_MEM[i] = 32'h0; 
// 	end
// 	DATA_MEM[1280] = 32'h00000013;
// 	for(i = 1281; i < 2048; i = i+1) begin 
// 		DATA_MEM[i] = 32'h0; 
// 	end
// 	DATA_MEM[2048] = 32'h00000014;
   
// end

// //----------------------------------------------------------------
// // ARM port map
// //----------------------------------------------------------------
// ARM u_ARM(
//     .CLK       ( CLK       ),
//     .Reset     ( RESET     ),
//     .Instr     ( Instr     ),

//     .ReadData  ( ReadData  ),
//     .PC        ( PC        ),
//     .ALUResult ( ALUResult ),
//     .WriteData ( WriteData ),
//     .cpu_op    ( cpu_op    ),
//     .cpu_valid ( cpu_valid ),
//     .cache_ready  ( cache_ready  )
// );

// //----------------------------------------------------------------
// // cache port map
// //----------------------------------------------------------------
// Set_Asso_Cache_4W_256S u_Set_Asso_Cache_4W_256S(
//     .clk              ( CLK              ),
//     .nrst             ( ~RESET             ),

//     .cpu_op           ( cpu_op           ),
//     .cpu_valid        ( cpu_valid        ),
//     .cache_addr       ( ALUResult       ),
//     .cpu_write_data   ( WriteData   ),
//     .cache_ready      ( cache_ready      ),
//     .cache_data       ( ReadData       ),
    
// 	.cache_op         ( cache_op         ),
//     .cache_valid      ( cache_valid      ),
//     .mem_addr         ( mem_addr         ),
//     .cache_write_data ( cache_write_data ),
//     .mem_ready        ( 1'b1        ), // main memory is always ready 
//     .mem_data         ( mem_data         )
// );

	

// //----------------------------------------------------------------
// // Data memory address decoding
// //----------------------------------------------------------------
// // assign dec_DATA_CONST		= (ALUResult >= 32'h00000200 && ALUResult <= 32'h000003FC) ? 1'b1 : 1'b0;
// // assign dec_DATA_VAR			= (ALUResult >= 32'h00000800 && ALUResult <= 32'h000009FC) ? 1'b1 : 1'b0;

// //----------------------------------------------------------------
// // Data memory read 1
// //----------------------------------------------------------------
// // always@( * ) begin
// // if (dec_DATA_VAR)
// // 	ReadData <= DATA_MEM[ALUResult[12:2]] ; 
// // else if (dec_DATA_CONST)
// // 	ReadData <= DATA_MEM[ALUResult[12:2]] ; 	
// // else
// // 	ReadData <= 32'h0 ; 
// // end

// assign mem_data = DATA_MEM[mem_addr[13:2]];

// //----------------------------------------------------------------
// // Data memory read 2
// //----------------------------------------------------------------
// assign ReadData_IO = DATA_MEM[DIP];

// //----------------------------------------------------------------
// // Data Memory write
// //----------------------------------------------------------------
// always@(posedge CLK) begin
//     if((cache_op==1'b0) && cache_valid ) 
//         DATA_MEM[mem_addr[13:2]] <= cache_write_data ;
// end

// //----------------------------------------------------------------
// // Instruction memory read
// //----------------------------------------------------------------
// assign Instr = ( (PC >= 32'h00000000) && (PC <= 32'h000001FC) ) ? // To check if address is in the valid range, assuming 128 word memory. Also helps minimize warnings
//                  INSTR_MEM[PC[8:2]] : 32'h00000000; 

// //----------------------------------------------------------------
// // LED light - display PC value
// //----------------------------------------------------------------
// always@(posedge CLK or posedge RESET) begin
//     if(RESET)
//         LED <= 'b0 ;
//     else 
//         LED <= PC ;
// end

// //----------------------------------------------------------------
// // SevenSeg LED - display memory content
// //----------------------------------------------------------------
// always @(posedge CLK or posedge RESET) begin
// 	if (RESET)
// 		SEVENSEGHEX <= 32'b0;
// 	else
// 		SEVENSEGHEX <= ReadData_IO;
// end

// endmodule

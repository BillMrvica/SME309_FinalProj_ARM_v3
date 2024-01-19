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
	INSTR_MEM[0] = 32'hE59F11F8; 
	INSTR_MEM[1] = 32'hE59F21F8; 
	INSTR_MEM[2] = 32'hE59F31F8; 
	INSTR_MEM[3] = 32'hE59F41F8; 
	INSTR_MEM[4] = 32'hE59F51F8; 
	INSTR_MEM[5] = 32'hE59F620C; 
	INSTR_MEM[6] = 32'hE5834004; 
	INSTR_MEM[7] = 32'hE5835004; 
	INSTR_MEM[8] = 32'hE5816004; 
	INSTR_MEM[9] = 32'hE5814000; 
	INSTR_MEM[10] = 32'hE5825004; 
	INSTR_MEM[11] = 32'hE5826000; 
	INSTR_MEM[12] = 32'hE59F71D4; 
	INSTR_MEM[13] = 32'hE0874007; 
	INSTR_MEM[14] = 32'hE0875007; 
	INSTR_MEM[15] = 32'hE0876007; 
	INSTR_MEM[16] = 32'hE59F81CC; 
	INSTR_MEM[17] = 32'hE0884008; 
	INSTR_MEM[18] = 32'hE0885008; 
	INSTR_MEM[19] = 32'hE0886008; 
	INSTR_MEM[20] = 32'hE59F91C0; 
	INSTR_MEM[21] = 32'hE5839004; 
	INSTR_MEM[22] = 32'hE59FA1BC; 
	INSTR_MEM[23] = 32'hE583A008; 
	INSTR_MEM[24] = 32'hEAFFFFFE; 
	for(i = 25; i < 128; i = i+1) begin 
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
	DATA_CONST_MEM[6] = 32'h00000004; 
	DATA_CONST_MEM[7] = 32'h00000002; 
	DATA_CONST_MEM[8] = 32'h00000001; 
	DATA_CONST_MEM[9] = 32'h00000003; 
	DATA_CONST_MEM[10] = 32'h00000006; 
	for(i = 11; i < 128; i = i+1) begin 
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

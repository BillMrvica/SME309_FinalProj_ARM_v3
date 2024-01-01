// wyh instructions 
//----------------------------------------------------------------
// Instruction Memory
//----------------------------------------------------------------
initial begin
	INSTR_MEM[0] = 32'hE59F1204; 
	INSTR_MEM[1] = 32'hE59F2204; 
	INSTR_MEM[2] = 32'hE0815002; 
	INSTR_MEM[3] = 32'hE59F31EC; 
	INSTR_MEM[4] = 32'hE59F41EC; 
	INSTR_MEM[5] = 32'hE59FC1EC; 
	INSTR_MEM[6] = 32'hE5835004; 
	INSTR_MEM[7] = 32'hE2833008; 
	INSTR_MEM[8] = 32'hE5135004; 
	INSTR_MEM[9] = 32'hE0426001; 
	INSTR_MEM[10] = 32'hE5046004; 
	INSTR_MEM[11] = 32'hE2444008; 
	INSTR_MEM[12] = 32'hE5946004; 
	INSTR_MEM[13] = 32'hE2857037; 
	INSTR_MEM[14] = 32'hE59F81D4; 
	INSTR_MEM[15] = 32'hE59F31D4; 
	INSTR_MEM[16] = 32'hE2933000; 
	INSTR_MEM[17] = 32'hE281A00A; 
	INSTR_MEM[18] = 32'hE09AA007; 
	INSTR_MEM[19] = 32'hE5948004; 
	INSTR_MEM[20] = 32'hE5048004; 
	INSTR_MEM[21] = 32'hE2844000; 
	INSTR_MEM[22] = 32'hE2455000; 
	INSTR_MEM[23] = 32'hE3855000; 
	INSTR_MEM[24] = 32'hE5141004; 
	INSTR_MEM[25] = 32'hE0841005; 
	INSTR_MEM[26] = 32'hE0018003; 
	INSTR_MEM[27] = 32'hE1869001; 
	INSTR_MEM[28] = 32'hE041A007; 
	INSTR_MEM[29] = 32'hE18CB00D; 
	INSTR_MEM[30] = 32'hEA000003; 
	INSTR_MEM[31] = 32'hE0018003; 
	INSTR_MEM[32] = 32'hE1869001; 
	INSTR_MEM[33] = 32'hE041A007; 
	INSTR_MEM[34] = 32'hE041B008; 
	INSTR_MEM[35] = 32'hE5141004; 
	INSTR_MEM[36] = 32'hE0018003; 
	INSTR_MEM[37] = 32'hE1869001; 
	INSTR_MEM[38] = 32'hE047A001; 
	INSTR_MEM[39] = 32'hEAFFFFFE; 
	for(i = 40; i < 128; i = i+1) begin 
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
	for(i = 6; i < 128; i = i+1) begin 
		DATA_CONST_MEM[i] = 32'h0; 
	end
end
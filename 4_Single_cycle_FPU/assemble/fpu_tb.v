
//----------------------------------------------------------------
// Instruction Memory
//----------------------------------------------------------------
initial begin
			INSTR_MEM[0] = 32'hE59F1210; 
			INSTR_MEM[1] = 32'hE59F2210; 
			INSTR_MEM[2] = 32'hE59F31F0; 
			INSTR_MEM[3] = 32'hE59F41F0; 
			INSTR_MEM[4] = 32'hE59FC1F0; 
			INSTR_MEM[5] = 32'hEE315A02; 
			INSTR_MEM[6] = 32'hEE215A02; 
			INSTR_MEM[7] = 32'hE5835004; 
			INSTR_MEM[8] = 32'hE59F31F8; 
			INSTR_MEM[9] = 32'hEE333A01; 
			INSTR_MEM[10] = 32'hE59F61F4; 
			INSTR_MEM[11] = 32'hEE326A01; 
			INSTR_MEM[12] = 32'hE5046004; 
			INSTR_MEM[13] = 32'hE2444008; 
			INSTR_MEM[14] = 32'hE59F71E8; 
			INSTR_MEM[15] = 32'hEE277A01; 
			INSTR_MEM[16] = 32'hE59F81CC; 
			INSTR_MEM[17] = 32'hEE217A06; 
			INSTR_MEM[18] = 32'hE2844000; 
			INSTR_MEM[19] = 32'hE59FA1D8; 
			INSTR_MEM[20] = 32'hEE21AA03; 
			INSTR_MEM[21] = 32'hEE3AAA07; 
			INSTR_MEM[22] = 32'hEE37AA0A; 
			INSTR_MEM[23] = 32'hE59FB1AC; 
			INSTR_MEM[24] = 32'hE28BB004; 
			INSTR_MEM[25] = 32'hE58CB000; 
			INSTR_MEM[26] = 32'hE59FD1C0; 
			INSTR_MEM[27] = 32'hEE3DDA01; 
			INSTR_MEM[28] = 32'hEE2DDA01; 
			INSTR_MEM[29] = 32'hEAFFFFFE; 
			for(i = 30; i < 128; i = i+1) begin 
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
			DATA_CONST_MEM[6] = 32'h40B00000; 
			DATA_CONST_MEM[7] = 32'h40D80000; 
			DATA_CONST_MEM[8] = 32'h426A0000; 
			DATA_CONST_MEM[9] = 32'h3FA00000; 
			DATA_CONST_MEM[10] = 32'h41340000; 
			DATA_CONST_MEM[11] = 32'h3F000000; 
			DATA_CONST_MEM[12] = 32'h418D0000; 
			for(i = 13; i < 128; i = i+1) begin 
				DATA_CONST_MEM[i] = 32'h0; 
			end
end

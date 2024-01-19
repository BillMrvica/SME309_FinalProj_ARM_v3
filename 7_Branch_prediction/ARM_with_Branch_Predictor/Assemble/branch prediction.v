//----------------------------------------------------------------
// Instruction Memory
//----------------------------------------------------------------
initial begin
    INSTR_MEM[0] = 32'hE59F1204; // R1 = 5
    INSTR_MEM[1] = 32'hE59F2208; // R2 = 1
    
    INSTR_MEM[2] = 32'hE1510002; // Loop1: CMP R1, R2;
    INSTR_MEM[3] = 32'h0A000002; // BEQ Out1;
    INSTR_MEM[4] = 32'hE0411002; // SUB R1, R1, R2;
    INSTR_MEM[5] = 32'hE2833001; // ADD R3, R3, #1; R3 act as a timer, R3 = 4;
    INSTR_MEM[6] = 32'hEAFFFFFA; // B Loop1;
    
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
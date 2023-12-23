AREA    MYCODE, CODE, READONLY, ALIGN=9 
   	  ENTRY
	  
; ------- <code memory (ROM mapped to Instruction Memory) begins>

	LDR R1, constant1; R1=5
	LDR R2, constant2; R2=6
	ADD R5, R1, R2;  R5 = a1 + a2 = 11; first load and use hazard
	LDR R3, addr1; 810
	LDR R4, addr2; 820
	LDR R12,addr3; 830
	
	STR R5, [R3,#4];
	ADD R3, R3, #8;
	LDR R5,[R3,#-4]; R5 = 11;
	
	SUB R6, R2, R1;  R6 = 1;
	STR R6, [R4,#-4];
	SUB R4, R4, #8; R4 = 0x00000818; 
	LDR R6,[R4,#4];	 R6 = 1;
	
	MUL R7,R5,R2;R7=66
	LDR R8,constant3; R8=3
	LDR R3,number0;R3=0
	ADDS R3,R3,#0; SET Z FLAG = 1
	ADD R10,R1,#10; R10=15;
	ADDS R10,R10,R7; R10 =66+15=81,flags are 0
	
	LDR R8, [R4,#4]; R8 = 1;
	STR R8, [R4,#-4]; 
	ADD R4, R4, #0;
	SUB R5, R5, #0;
	ORR R5, R5, #0;
	LDR R1, [R4,#-4]; R1 = 1; correct if memory-memory copy is handled with data forwarding, PPT6 P32
	
	ADD R1, R4, R5; R1 = 0x00000823;
	AND R8, R1, R3; R8 = 0x00000000;
	ORR R9, R6, R1; R9 = 0x00000823; two correct if data forwarding correct, PPT6 P28
	SUB R10, R1, R7; R10 = 0x000007E1; this correct if wirte at different clock edges, to test using different clock edges PPT6 P25
	ORR R11, R12, R13; R11 = 0x00000830; R11 is 0x00000823 if R13 is initialized to 0, or R11 is indefinite
	
	B BTA;
	AND R8, R1, R3; 
	ORR R9, R6, R1;
	SUB R10, R1, R7;
    SUB R11, R1, R8; control hazard here; if wrong, later R8 = 0
		
BTA	
	LDR R1, [R4,#-4]; R1 = 1;
	AND R8, R1, R3; R8 = 0; this correct if load and use correct, PPT6 P34
	ORR R9, R6, R1; R9 = 1;
	SUB R10, R7, R1; R10 = 0x00000041; all the data hazard WARNING: BELOW INSTRUCTIONS RESULTS ARE ALL WRONG.
		
halt	
	B    halt
	
; ------- <code memory (ROM mapped to Instruction Memory) begins>
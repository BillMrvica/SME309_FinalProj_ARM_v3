	AREA    MYCODE, CODE, READONLY, ALIGN=9 
   	  ENTRY
	  
; ------- <code memory (ROM mapped to Instruction Memory) begins>


	LDR R1, addr1; R1=H810 this memory address is 0x00000200, which is the beginning of the constant data mem. 1st read, read miss and load from mem
	LDR R2, addr2; R2=H820 this memory address is 0x00000204, 2nd read, read miss and load from mem
	LDR R3, addr3; R3=H830 this memory address is 0x00000208, 3rd read, read miss and load from mem
	LDR R4, constant1; R4=5 this memory address is 0x0000020C, 4th read, read miss and load from mem
	LDR R5, constant2; R5=6 this memory address is 0x00000210, 5th read, read miss and load from mem
	LDR R6, constant8; R6=6 this memory address is 0x00000228, 6th read, read miss and load from mem
	
	STR R4, [R3,#4]; R4=5 this memory address is 0x00000834, 1st write, write miss and load from mem
	STR R5, [R3,#0]; R5=6 this memory address is 0x00000834, 2nd write, write hit and write it to cache
	STR R6, [R1,#4]; R6=6 this memory address is 0x00000814, 3rd write, write miss and load from mem
	STR R4, [R1,#-4]; R4=5 this memory address is 0x00000810, 4th write, write miss and load from mem
	STR R5, [R2,#4]; R5=6 this memory address is 0x00000824, 5th write, write miss and load from mem
	STR R6,  [R2,#-4]; R6=6 this memory address is 0x00000820, 6th write, write miss and load from mem
	
    LDR R7, constant1; R7=5 this memory address is 0x0000020C, read hit
	ADD R4, R7, R7; R4=10
	ADD R5, R7, R7; R5=10
	ADD R6, R7, R7; R6=10
	
	LDR R8, constant3; R8=3 this memory address is 0x00000214, read miss
	ADD R4, R8, R8; R4=6
	ADD R5, R8, R8; R5=6
	ADD R6, R8, R8; R6=6
	
	LDR R9, constant4; R9=4 this memory address is 0x00000218, read miss
	STR R9, [R3,#4]; R9=4 this memory address is 0x00000834, write hit
	LDR R10, constant5; R10=2 this memory address is 0x0000021C, read miss
	STR R10, [R3,#8]; R10=2 this memory address is 0x00000838, write miss
	
halt	
	B    halt
	
; ------- <code memory (ROM mapped to Instruction Memory) begins>
	
	
	
	

; ------- <code memory (ROM mapped to DATA Memory) begins>
	AREA    CONSTANTS, DATA, READONLY, ALIGN=9 


addr1
		DCD 0x00000810;
addr2 	
		DCD 0x00000820;
addr3
		DCD 0x00000830;
constant1
		DCD 0x00000005; 
constant2
		DCD 0x00000006;
constant3 
		DCD 0x00000003;
constant4
        DCD 0x00000004;
constant5
		DCD 0x00000002; 
constant6
		DCD 0x00000001;
constant7 
		DCD 0x00000003;
constant8
        DCD 0x00000006;

number0
		DCD 0x00000000;




		END	
	AREA    MYCODE, CODE, READONLY, ALIGN=9 
   	  ENTRY
	  
; ------- <code memory (ROM mapped to Instruction Memory) begins>

	LDR R1, constant1; R1=5
	LDR R2, constant3; R2=1
	
Loop1
	CMP R1, R2;
	BEQ Out1;
	SUB R1, R1, R2;
	ADD R3, R3, #1; R3 act as a timer, R3 = 4;
	B Loop1;
	
Out1  
	LDR R1, constant1; R1=5
	ORR R2, R2, R2;
	BIC R3, R3, R3; Set R3 to 0
	
Loop2
    CMP R1, R2;
	BEQ Out2;
	ADDS R3, R3, #1; R3 act as a timer, and it set C flag to zero.
	SBC R1, R1, #0;
	B Loop2; Two loops are forward case2
	
Out2
    
	LDR R5, constant2; R5=6
	LDR R6, constant3; R6=1
	AND R3, R3, #0; Set R3 to 0
	
Loop3
    CMP R5, R6; Set C flag to one.
	ADC R6, R6, #0;
	ADD R3, R3, R6; R3 act as a special timer, and R3 = 20.
	BNE Loop3; 
	
	
	SUB R3, R3, #20; R3 = 0
	RSB R1, R3, R1; R1 = 1
	EOR R6, R6, #0; R6 = 6
	MOV R7, R6; R7 = R6 = 6
	LDR R7, constant3; R7 = 1
	
Loop4
    ADDS R5, R7, R5; 	
    CMP R6, R5;
	BNE Loop4; Two loops are backward case1
	
Loop5 
    RSC R5, R7, R5; R5 = 5
    CMP R5, R7;

    BEQ Loop5;
    BNE Loop6;

    ADD R5, R5, #5;
	SUB R5, R6, #3;

Loop6
	SUB R5, R5, #5;
	
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
		DCD 0x00000001;

number0
		DCD 0x00000000;



		END	
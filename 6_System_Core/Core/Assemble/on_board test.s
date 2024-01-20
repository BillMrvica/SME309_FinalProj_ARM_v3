	AREA    MYCODE, CODE, READONLY, ALIGN=9 
   	  ENTRY
	  
; ------- <code memory (ROM mapped to Instruction Memory) begins>

	LDR R1, constant1; R1=5
	LDR R2, constant2; R2=6
	LDR R3, addr1; 810
	LDR R4, addr2; 820
	LDR R12,addr3; 830
	ADD R5, R1, R2; R5 = a1 + a2;
	
	STR R5, [R3,#4];
	ADD R3, R3, #8;
	LDR R5,[R3,#-4]; R5 = 11;
	
	SUB R6, R2, R1;  R6 = 1;
	STR R6, [R4,#-4];
	SUB R4, R4, #8;
	LDR R6,[R4,#4];	 R6 = 1;
	
	MUL R7,R5,R2;R7=66
	LDR R8,constant3; R8=3
	LDR R3,number0;R3=0
	MULEQ R7,R1,R8; not execute,R7=66
	ADDS R3,R3,#0; SET Z FLAG = 1
	MULEQ R10,R1,R8; R10=15;
	ADDS R10,R10,R7; R10 =66+15=81,flags are 0
	
	DIV R7,R7,R8; R7=66/3=22
	DIV R7,R7,R1; R7=22/5=4
	DIVEQ R7,R2,R8; not execute, R7 = 4
	ADDS R3,R3,#0; SET Z FLAG = 1
	DIVEQ R11,R2,R8;R11=6/3=2;
	ADD R11,R11,R7; R11=2+4=6
	ADD R11,R11,R10;R11=81+6=87=0X0000 0057
	
	LDR R1, constant1; R1=5
	LDR R13, constant4; R13=1

	
Loop1
	CMP R1, R13;
	BEQ Out1;
	SUB R1, R1, R13;
	B Loop1;
	
Out1  
	LDR R1, constant1; R1=5
	ORR R13, R13, R13;
	BIC R3, R3, R3; R3=0
	
Loop2
    CMP R1, R13;
	BEQ Out2;
	ADDS R3, R3, #1; R3 act as a timer, and it set C flag to zero. R3 = 4
	SBC R1, R1, #0;
	B Loop2; Two loops are forward case2
	
Out2
    
	LDR R5, constant2; R5=6
	LDR R6, constant4; R6=1
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
	LDR R7, constant4; R7 = 1
	
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
	
	ADD R7,R5,#55;R7=66
	LDR R8,constant3; R8=3
	LDR R3,number0;R3=0
	
	LDR R8, [R4,#4]; R8 = 1;
	STR R8, [R4,#-4]; 
	ADD R4, R4, #0; R4 = 0x00000818; 
	SUB R5, R5, #0; R5 = 11;
	ORR R5, R5, #0; R5 = 11;
	LDR R1, [R4,#-4]; R1 = 1; correct if memory-memory copy is handled with data forwarding, PPT6 P32
	ADD R1, R4, R5; R1 = 0x00000823;
	AND R8, R1, R3; R8 = 0x00000000;
	
	LDR R1, float1; R1=5.5
	LDR R2, float2; R2=6.75
	LDR R3, addr1; 810
	LDR R4, addr2; 820
	LDR R12,addr3; 830
	FADDS R5, R1, R2; R5=12.25	
	FMULS R5, R1, R2; R5=37.125
	
	LDR R3, float3;  R3=58.5
	FADDS R3, R3, R1; R3=64
	
	LDR R6, float4; R6=1.25
	FADDS R6, R2, R1; R6 = 12.25;
	SUB R4, R4, #8; R4 = 0x00000818; 
	
	LDR R7, float5; R7=11.25
	FMULS R7,R7,R1;R7=61.875
	LDR R8,constant3; R8 = 3
	FMULS R7,R1,R6; R7=67.375
	ADD R4,R4,#0; R4 = 0x00000818; 
	LDR R10, float6; R10 = 0.5 
	FMULS R10,R1,R3; R10=352; 
	FADDS R10,R10,R7; R10 =419.375 
	FADDS R10, R7, R10; R10=486.75
	
	LDR R14,addr2; R14=0x00000820;
    STR R4, [R14]; R4=0x00000818; 
	STR R11,[R12]; R11=0X0000 0057
	
	
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
		DCD 0x00000001;
float1
		DCD 0x40B00000; This floating-point number is 5.5
float2
		DCD 0x40D80000; This floating-point number is 6.75
float3 
		DCD 0x426A0000; This floating-point number is 58.5
float4
		DCD 0x3FA00000; This floating-point number is 1.25
float5
		DCD 0x41340000; This floating-point number is 11.25
float6
		DCD 0x3F000000; This floating-point number is 0.5
float7
		DCD 0x418D0000; This floating-point number is 17.625

number0
		DCD 0x00000000;




		END	
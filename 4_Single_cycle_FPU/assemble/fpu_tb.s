	AREA    MYCODE, CODE, READONLY, ALIGN=9 
   	  ENTRY
	  
; ------- <code memory (ROM mapped to Instruction Memory) begins>

	LDR R1, float1; R1=5.5
	LDR R2, float2; R2=6.75
	LDR R3, addr1; 810
	LDR R4, addr2; 820
	LDR R12,addr3; 830
	FADDS R5, R1, R2; R5=12.25	
	FMULS R5, R1, R2; R5=37.125
	
	STR R5, [R3,#4]; R5=37.125
	LDR R3, float3;  R3=58.5
	FADDS R3, R3, R1; R3=64
	
	LDR R6, float4; R6=1.25
	FADDS R6, R2, R1; R6 = 12.25;
	STR R6, [R4,#-4]; R6 = 12.25;
	SUB R4, R4, #8; R4 = 812
	
	LDR R7, float5; R7=11.25
	FMULS R7,R7,R1;R7=61.875
	LDR R8,constant3; R8 = 3
	FMULS R7,R1,R6; R7=67.375
	ADD R4,R4,#0; R4 = 812
	LDR R10, float6; R10 = 0.5 
	FMULS R10,R1,R3; R10=352; 
	FADDS R10,R10,R7; R10 =419.375 
	
	FADDS R10, R7, R10; R10=486.75
    LDR R11,constant2; R11=6
	ADD R11,R11,#4; R11=10
	STR R11,[R12];
	LDR R13, float7; R13=17.625
	FADDS R13, R13, R1; R13=23.125
	FMULS R13, R13, R1; R13=127.1875
	
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
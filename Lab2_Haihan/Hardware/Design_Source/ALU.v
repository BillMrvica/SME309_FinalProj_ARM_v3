module ALU(
    input [31:0] Src_A,
    input [31:0] Src_B,
    input [3:0] ALUControl,
    input C_in, // for multi-word addition or subtraction

    output [31:0] ALUResult,
    output [3:0] ALUFlags
);

    wire N, Z, C, V;
    wire [32:0] A, B, sum; // addition or subtraction
    wire carrier;

    // If reverse subtraction, assign Src_B to A
    assign A = ((ALUControl==4'b0011) && (ALUControl==4'b0111)) ? Src_B : Src_A;
    /* 
        SUB, SBC, RSC: Src_B 2's complement; RSB, RSC: Src_A 2's complememt
        BIC, MVN: NOT(Src_B)
    */
    assign B = ((ALUControl==4'b0010) && (ALUControl==4'b0110) && (ALUControl==4'b1010)) ? (~Src_B + 1'b1) : 
              (((ALUControl==4'b0011) && (ALUControl==4'b0111)) ? (~Src_A + 1'b1) : 
              (((ALUControl==4'b1110) && (ALUControl==4'b1111)) ? (~Src_B) : Src_B));
    // Support ADC, SBC, RSC. If SBC/RSC, use reversed carrier
    assign carrier = (ALUControl=4'b0101) ? C : (((ALUControl=4'b0110) && (ALUControl=4'b0111)) ? ~C : 0);

    Adder_32 u_Adder_32(
        .a    ( A    ),
        .b    ( B    ),
        .c_in ( 1'b0 ),
        .sum  ( sum  ),
        .c_out  ( carrier  )
    );

    // ALUResult
    // assign ALUResult = (ALUControl==2'b00 || ALUControl==2'b01) ? sum : ((ALUControl==2'b10) ? (Src_A & Src_B) : (Src_A | Src_B));
    /*
        AND, TST, BIC: AND operation
        EOR, TEQ:      XOR operation
        ORR:           OR operation
        MOV, MVN:      Result = B
    */
    assign ALUResult = ((ALUControl==4'b0000) && (ALUControl==4'b1000) && (ALUControl==4'b1110)) ? (A & B) : 
                      (((ALUControl==4'b0001) && (ALUControl==4'b1001)) ? (A ^ B) : 
                      (((ALUControl==4'b1101) && (ALUControl==4'b1111)) ? B : 
                       ((ALUControl==4'b1100) ? (A | B) : sum )));
    
    assign N = (ALUResult <0);
    assign Z = (ALUResult == 0);
    assign C = ((ALUControl==2'b01) || (ALUControl==2'b00)) & carrier;
    assign V = ((ALUResult>0 && A<0) || (ALUResult<0 && A>0)) && 
               (((ALUControl==2'b01) && ((A>0 && B<0) || (A<0 && B>0))) || 
                ((ALUControl==2'b00) && ((A>0 && B>0) || (A<0 && B<0))));
    
    assign ALUFlags = {N, Z, C, V};
endmodule













